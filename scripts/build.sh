#!/usr/bin/env bash
# Usage: scripts/build.sh [device|host]
#   device (default): cross-compile for aarch64 and stage out/StockfishSP/
#   host:             native build in build-host/ for development
set -euo pipefail
TARGET="${1:-device}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

case "$TARGET" in
  host)
    cmake -S . -B build-host -G Ninja -DCMAKE_BUILD_TYPE=Release
    cmake --build build-host
    echo "built: build-host/hello"
    ;;
  device)
    [ -f sysroot/aarch64/lib/libSDL2-2.0.so ] || scripts/setup_sysroot.sh
    cmake -S . -B build-aarch64 -G Ninja -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_TOOLCHAIN_FILE="$ROOT/cmake/aarch64-linux-gnu.cmake"
    cmake --build build-aarch64
    STAGE="$ROOT/out/StockfishSP"
    rm -rf "$ROOT/out" && mkdir -p "$STAGE"
    install -m755 build-aarch64/hello "$STAGE/hello"
    aarch64-linux-gnu-strip "$STAGE/hello"
    install -m755 dist/StockfishSP.sh "$ROOT/out/StockfishSP.sh"
    echo "staged: out/StockfishSP.sh + out/StockfishSP/"
    echo "needed shared libs:"
    aarch64-linux-gnu-readelf -d "$STAGE/hello" | awk '/NEEDED/{print "  " $5}'
    echo "highest GLIBC symbol version required (device glibc must be >= this):"
    aarch64-linux-gnu-objdump -T "$STAGE/hello" | grep -o 'GLIBC_[0-9.]*' | sort -uV | tail -1 | sed 's/^/  /'
    ;;
  *) echo "usage: $0 [device|host]" >&2; exit 2 ;;
esac
