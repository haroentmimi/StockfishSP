#!/usr/bin/env bash
# Usage: scripts/deploy.sh <device-ip> [--run]
# Copies out/ to /userdata/roms/ports on the device (default creds root/linux).
# --run also launches it over SSH and prints the log afterwards.
set -euo pipefail
HOST="${1:?usage: $0 <device-ip> [--run]}"
DEST="${DEST:-/userdata/roms/ports}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
[ -d "$ROOT/out/StockfishSP" ] || { echo "run scripts/build.sh first" >&2; exit 1; }

if command -v rsync >/dev/null && ssh "root@$HOST" command -v rsync >/dev/null 2>&1; then
  rsync -av "$ROOT/out/" "root@$HOST:$DEST/"
else
  scp -r "$ROOT/out/StockfishSP" "$ROOT/out/StockfishSP.sh" "root@$HOST:$DEST/"
fi
ssh "root@$HOST" "chmod +x '$DEST/StockfishSP.sh' '$DEST/StockfishSP/hello'"
echo "deployed to $HOST:$DEST"

if [ "${2:-}" = "--run" ]; then
  ssh "root@$HOST" "'$DEST/StockfishSP.sh'; cat '$DEST/StockfishSP/log.txt'"
fi
