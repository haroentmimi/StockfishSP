# StockfishSP
A Stockfish chess adaptation for Allwinner H700 devices (Anbernic RG35XXSP)
running Knulli (a Batocera fork). C++17 + SDL2, controller-first.

Status: **M0 (toolchain hello world)**. See NOTES.md for device findings.

## Build
```sh
sudo apt-get install g++-aarch64-linux-gnu cmake ninja-build qemu-user-static libsdl2-dev
scripts/build.sh device   # cross-compile, stage out/StockfishSP.sh + out/StockfishSP/
scripts/build.sh host     # native dev build in build-host/
```

## Deploy
```sh
scripts/deploy.sh <device-ip>          # copy to /userdata/roms/ports
scripts/deploy.sh <device-ip> --run    # copy, launch over SSH, print log
```
Then refresh the game list on the device and start "StockfishSP" from Ports.

## License
GPLv3 (see LICENSE). Stockfish, bundled in later milestones, is GPLv3 as well.
