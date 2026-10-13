#!/usr/bin/env bash
# Builds a link-time SDL2 for aarch64 into sysroot/aarch64.
# Only its headers and soname (libSDL2-2.0.so.0) matter: on the device the
# binary loads Knulli's own libSDL2. Keep SDL_VERSION <= the device's version
# so we never call a function the device lacks (see NOTES.md).
set -euo pipefail
SDL_VERSION="${SDL_VERSION:-2.26.5}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PREFIX="$ROOT/sysroot/aarch64"
WORK="$ROOT/build-sysroot"

mkdir -p "$WORK" "$PREFIX"
cd "$WORK"
TARBALL="SDL2-$SDL_VERSION.tar.gz"
if [ ! -f "$TARBALL" ]; then
  curl -fsSLo "$TARBALL" \
    "https://github.com/libsdl-org/SDL/releases/download/release-$SDL_VERSION/$TARBALL"
fi
rm -rf "SDL2-$SDL_VERSION" && tar xzf "$TARBALL"

cmake -S "SDL2-$SDL_VERSION" -B sdl-build -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="$ROOT/cmake/aarch64-linux-gnu.cmake" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST=OFF \
  -DSDL_X11=OFF -DSDL_WAYLAND=OFF -DSDL_KMSDRM=OFF -DSDL_VULKAN=OFF \
  -DSDL_OPENGL=OFF -DSDL_OPENGLES=OFF \
  -DSDL_ALSA=OFF -DSDL_PULSEAUDIO=OFF -DSDL_PIPEWIRE=OFF -DSDL_JACK=OFF \
  -DSDL_SNDIO=OFF -DSDL_LIBUDEV=OFF -DSDL_DBUS=OFF -DSDL_IBUS=OFF -DSDL_LIBSAMPLERATE=OFF
cmake --build sdl-build
cmake --install sdl-build
echo "SDL2 $SDL_VERSION installed to $PREFIX"
