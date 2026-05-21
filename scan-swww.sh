#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-$HOME/.config}"

echo "Buscando referencias reales a swww dentro de: $TARGET_DIR"
echo

EXCLUDES=(
  "--glob=!**/.git/**"
  "--glob=!**/google-chrome/**"
  "--glob=!**/chromium/**"
  "--glob=!**/BraveSoftware/**"
  "--glob=!**/vivaldi/**"
  "--glob=!**/Cache/**"
  "--glob=!**/cache/**"
  "--glob=!**/Code Cache/**"
  "--glob=!**/GPUCache/**"
  "--glob=!**/node_modules/**"
  "--glob=!**/.zcompdump*"
  "--glob=!**/zen/**"
  "--glob=!**/discord/**"
  "--glob=!**/mozilla/**"
)

if command -v rg >/dev/null 2>&1; then
  rg -n --hidden --follow "${EXCLUDES[@]}" '\bswww\b|swww-daemon|SWWW|Swww' "$TARGET_DIR"
else
  grep -RIn \
    --exclude-dir=.git \
    --exclude-dir=google-chrome \
    --exclude-dir=chromium \
    --exclude-dir=BraveSoftware \
    --exclude-dir=Cache \
    --exclude-dir=cache \
    --exclude='.zcompdump*' \
    -E '\bswww\b|swww-daemon|SWWW|Swww' "$TARGET_DIR"
fi

echo
echo "Archivos únicos:"
echo

if command -v rg >/dev/null 2>&1; then
  rg -l --hidden --follow "${EXCLUDES[@]}" '\bswww\b|swww-daemon|SWWW|Swww' "$TARGET_DIR" | sort
else
  grep -RIl \
    --exclude-dir=.git \
    --exclude-dir=google-chrome \
    --exclude-dir=chromium \
    --exclude-dir=BraveSoftware \
    --exclude-dir=Cache \
    --exclude-dir=cache \
    --exclude='.zcompdump*' \
    -E '\bswww\b|swww-daemon|SWWW|Swww' "$TARGET_DIR" | sort
fi
