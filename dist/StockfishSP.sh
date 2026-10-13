#!/bin/bash
# Knulli "Ports" launcher: lives in /userdata/roms/ports/, app in ./StockfishSP/
APPDIR="$(cd "$(dirname "$0")" && pwd)/StockfishSP"
cd "$APPDIR" || exit 1
exec ./hello > "$APPDIR/log.txt" 2>&1
