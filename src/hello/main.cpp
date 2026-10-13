// M0 hello world: opens a 640x480 window, draws a rectangle, exits on Start.
//
// Since the device's button mapping is not known yet (that is M1), it also:
//  - logs every raw joystick / controller event to stdout,
//  - recolors the rectangle on any button press (visual "input works" check),
//  - quits by itself after a timeout so it can never trap the device.
#include <SDL.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>

namespace {

constexpr int kWidth = 640;
constexpr int kHeight = 480;

void logSystemInfo(SDL_Renderer* renderer) {
  SDL_version compiled, linked;
  SDL_VERSION(&compiled);
  SDL_GetVersion(&linked);
  std::printf("SDL compiled %d.%d.%d, linked %d.%d.%d\n", compiled.major,
              compiled.minor, compiled.patch, linked.major, linked.minor,
              linked.patch);
  std::printf("video driver: %s\n", SDL_GetCurrentVideoDriver());

  SDL_DisplayMode mode;
  if (SDL_GetCurrentDisplayMode(0, &mode) == 0)
    std::printf("display 0: %dx%d @%dHz\n", mode.w, mode.h, mode.refresh_rate);

  SDL_RendererInfo info;
  if (SDL_GetRendererInfo(renderer, &info) == 0)
    std::printf("renderer: %s flags=0x%x\n", info.name, info.flags);
  int ow = 0, oh = 0;
  SDL_GetRendererOutputSize(renderer, &ow, &oh);
  std::printf("renderer output: %dx%d\n", ow, oh);
}

void openJoysticks(std::vector<SDL_GameController*>& pads,
                   std::vector<SDL_Joystick*>& sticks) {
  int n = SDL_NumJoysticks();
  std::printf("joysticks: %d\n", n);
  for (int i = 0; i < n; ++i) {
    char guid[64];
    SDL_JoystickGetGUIDString(SDL_JoystickGetDeviceGUID(i), guid, sizeof guid);
    std::printf("  [%d] name=\"%s\" guid=%s gamecontroller=%s\n", i,
                SDL_JoystickNameForIndex(i), guid,
                SDL_IsGameController(i) ? "yes" : "no");
    if (SDL_IsGameController(i)) {
      if (SDL_GameController* gc = SDL_GameControllerOpen(i)) {
        char* mapping = SDL_GameControllerMapping(gc);
        std::printf("      mapping: %s\n", mapping ? mapping : "(none)");
        SDL_free(mapping);
        pads.push_back(gc);
      }
    } else if (SDL_Joystick* js = SDL_JoystickOpen(i)) {
      std::printf("      buttons=%d axes=%d hats=%d\n", SDL_JoystickNumButtons(js),
                  SDL_JoystickNumAxes(js), SDL_JoystickNumHats(js));
      sticks.push_back(js);
    }
  }
}

void draw(SDL_Renderer* r, Uint8 hue) {
  SDL_SetRenderDrawColor(r, 20, 20, 28, 255);
  SDL_RenderClear(r);
  // 4px frame on the screen edge: shows whether the full 640x480 is visible.
  SDL_SetRenderDrawColor(r, 255, 255, 255, 255);
  for (int i = 0; i < 4; ++i) {
    SDL_Rect frame{i, i, kWidth - 2 * i, kHeight - 2 * i};
    SDL_RenderDrawRect(r, &frame);
  }
  static const SDL_Color palette[] = {
      {200, 60, 60, 255}, {60, 180, 80, 255}, {70, 110, 220, 255},
      {220, 180, 50, 255}, {170, 80, 200, 255}, {60, 190, 190, 255}};
  const SDL_Color& c = palette[hue % (sizeof palette / sizeof palette[0])];
  SDL_SetRenderDrawColor(r, c.r, c.g, c.b, 255);
  SDL_Rect box{kWidth / 2 - 120, kHeight / 2 - 80, 240, 160};
  SDL_RenderFillRect(r, &box);
  // Small marker in the top-left corner: shows orientation / rotation.
  SDL_SetRenderDrawColor(r, 255, 255, 0, 255);
  SDL_Rect corner{12, 12, 40, 40};
  SDL_RenderFillRect(r, &corner);
  SDL_RenderPresent(r);
}

}  // namespace

int main(int argc, char** argv) {
  bool windowed = false;
  Uint32 timeoutMs = 30000;
  for (int i = 1; i < argc; ++i) {
    if (!std::strcmp(argv[i], "--windowed")) windowed = true;
    else if (!std::strcmp(argv[i], "--timeout") && i + 1 < argc)
      timeoutMs = static_cast<Uint32>(std::atoi(argv[++i])) * 1000u;
  }
  setvbuf(stdout, nullptr, _IOLBF, 0);

  if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK | SDL_INIT_GAMECONTROLLER) != 0) {
    std::fprintf(stderr, "SDL_Init failed: %s\n", SDL_GetError());
    return 1;
  }
  Uint32 flags = SDL_WINDOW_SHOWN | (windowed ? 0 : SDL_WINDOW_FULLSCREEN);
  SDL_Window* win = SDL_CreateWindow("StockfishSP hello", SDL_WINDOWPOS_CENTERED,
                                     SDL_WINDOWPOS_CENTERED, kWidth, kHeight, flags);
  if (!win) {
    std::fprintf(stderr, "SDL_CreateWindow failed: %s\n", SDL_GetError());
    SDL_Quit();
    return 1;
  }
  SDL_Renderer* ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
  if (!ren) ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_SOFTWARE);
  if (!ren) {
    std::fprintf(stderr, "SDL_CreateRenderer failed: %s\n", SDL_GetError());
    SDL_DestroyWindow(win);
    SDL_Quit();
    return 1;
  }
  // Draw in a fixed 640x480 space even if the output size differs.
  SDL_RenderSetLogicalSize(ren, kWidth, kHeight);
  logSystemInfo(ren);

  std::vector<SDL_GameController*> pads;
  std::vector<SDL_Joystick*> sticks;
  openJoysticks(pads, sticks);

  Uint8 hue = 0;
  bool dirty = true, running = true;
  const Uint32 start = SDL_GetTicks();
  std::printf("running; press Start (or wait %us) to quit\n", timeoutMs / 1000);

  while (running) {
    if (dirty) {
      draw(ren, hue);
      dirty = false;
    }
    SDL_Event e;
    // Block for events instead of spinning; wake once a second for the timeout.
    if (SDL_WaitEventTimeout(&e, 1000)) {
      do {
        switch (e.type) {
          case SDL_QUIT:
            running = false;
            break;
          case SDL_KEYDOWN:
            std::printf("key down: %s\n", SDL_GetKeyName(e.key.keysym.sym));
            if (e.key.keysym.sym == SDLK_ESCAPE || e.key.keysym.sym == SDLK_RETURN)
              running = false;
            break;
          case SDL_CONTROLLERBUTTONDOWN:
            std::printf("controller %d button down: %s (%d)\n", e.cbutton.which,
                        SDL_GameControllerGetStringForButton(
                            static_cast<SDL_GameControllerButton>(e.cbutton.button)),
                        e.cbutton.button);
            if (e.cbutton.button == SDL_CONTROLLER_BUTTON_START) running = false;
            ++hue;
            dirty = true;
            break;
          case SDL_JOYBUTTONDOWN:
            std::printf("joystick %d raw button down: %d\n", e.jbutton.which, e.jbutton.button);
            ++hue;
            dirty = true;
            break;
          case SDL_JOYHATMOTION:
            std::printf("joystick %d hat %d: %d\n", e.jhat.which, e.jhat.hat, e.jhat.value);
            break;
          case SDL_JOYAXISMOTION:
            if (e.jaxis.value > 16000 || e.jaxis.value < -16000)
              std::printf("joystick %d axis %d: %d\n", e.jaxis.which, e.jaxis.axis, e.jaxis.value);
            break;
          case SDL_WINDOWEVENT:
            if (e.window.event == SDL_WINDOWEVENT_EXPOSED) dirty = true;
            break;
        }
      } while (SDL_PollEvent(&e));
    }
    if (timeoutMs && SDL_GetTicks() - start > timeoutMs) {
      std::printf("timeout reached\n");
      running = false;
    }
  }

  std::printf("exiting\n");
  for (auto* gc : pads) SDL_GameControllerClose(gc);
  for (auto* js : sticks) SDL_JoystickClose(js);
  SDL_DestroyRenderer(ren);
  SDL_DestroyWindow(win);
  SDL_Quit();
  return 0;
}
