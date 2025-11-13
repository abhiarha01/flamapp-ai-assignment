#!/usr/bin/env bash
set -euo pipefail

PKG="com.flamapp.ai"
RELATIVE="/sdcard/Android/data/${PKG}/files/processed_sample.png"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${ROOT_DIR}/web/assets/processed_sample.png"

mkdir -p "${ROOT_DIR}/web/assets"

adb shell ls "$RELATIVE" >/dev/null 2>&1 || { echo "File not found on device: $RELATIVE" >&2; exit 1; }

echo "Pulling $RELATIVE -> $DEST"
adb pull "$RELATIVE" "$DEST"
echo "Done."
