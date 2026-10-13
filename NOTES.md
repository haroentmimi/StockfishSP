# StockfishSP device and toolchain notes

Every finding about the device and toolchain goes here, dated.
`UNVERIFIED` = still needs confirming on the real device.

## Build host (2026-10-13)
- Cloud container: Ubuntu 24.04.5, x86_64, glibc 2.39, 4 cores. Docker CLI is
  present but no daemon is running, so no arm64 container (option a) here.
- Chosen approach: **option (c), generic cross compiler**:
  `g++-aarch64-linux-gnu` 13.3.0 (Ubuntu), `-mcpu=cortex-a53`.
  - SDL2 at link time: SDL2 2.26.5 built from source by `scripts/setup_sysroot.sh`
    into `sysroot/aarch64` (all backends off, link stub only). At runtime the
    binary loads the device's own `libSDL2-2.0.so.0`. SDL2's ABI is stable
    across 2.x, so the only rule is: **link-time SDL version <= device SDL version**
    (no calls to functions the device lacks). Bump `SDL_VERSION` once the device version is known.
  - libstdc++/libgcc are linked statically (`-static-libstdc++ -static-libgcc`),
    so only libc, ld-linux and libSDL2 come from the device.
  - Smoke-tested on the host with `qemu-aarch64-static` + `SDL_VIDEODRIVER=dummy`.
- **glibc floor: the binary needs GLIBC_2.38 on the device.** Sources:
  `__libc_start_main@2.34` (any 2.34+ toolchain), `_dl_find_object@2.35`,
  `arc4random@2.36` (static libstdc++), `__isoc23_strtol/strtoul@2.38`
  (glibc 2.38+ headers redirect strtol when compiling C++ with `_GNU_SOURCE`).
  `scripts/build.sh` prints the highest required version after each build.
  - If the device's glibc is older: (1) build with `zig c++ -target aarch64-linux-gnu.<ver>`,
    which pins the glibc symbol versions, or (2) a Bootlin aarch64 glibc toolchain
    matching the device's glibc, or (3) option (b), the Knulli buildroot toolchain.

## Device: Anbernic RG35XXSP / Knulli
- SSH: user `root`, password `linux` by default (can be changed under
  System settings > Security), hostname `knulli`. Source: knulli.org/configure/ssh/
- Ports: launcher `.sh` files go in `/userdata/roms/ports/` (UNVERIFIED, check the probe output).
- glibc version: UNVERIFIED
- SDL2 version / SDL2_ttf / SDL2_image present: UNVERIFIED
- Video driver SDL picks (expect KMSDRM): UNVERIFIED
- CPU features (dotprod `asimddp`? expected NO on the A53): UNVERIFIED
- Button mapping: UNVERIFIED (M1)

Run the probe and paste the output here:
`ssh root@<ip> 'sh -s' < scripts/probe_device.sh | tee probe.txt`
