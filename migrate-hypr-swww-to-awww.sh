#!/usr/bin/env bash
set -euo pipefail

HYPR_DIR="$HOME/.config/hypr"
BACKUP_ROOT="$HOME/.config-backups"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/hypr-before-awww-$TS"

MODE="${1:---dry-run}"

if [[ "$MODE" != "--dry-run" && "$MODE" != "--apply" ]]; then
  echo "Uso:"
  echo "  migrate-hypr-swww-to-awww.sh --dry-run"
  echo "  migrate-hypr-swww-to-awww.sh --apply"
  exit 1
fi

if [[ ! -d "$HYPR_DIR" ]]; then
  echo "No existe $HYPR_DIR"
  exit 1
fi

FILES=(
  "$HYPR_DIR/scripts/WallustSwww.sh"
  "$HYPR_DIR/scripts/UpdateLockWallpaper.sh"
  "$HYPR_DIR/scripts/RefreshNoWaybar.sh"
  "$HYPR_DIR/scripts/KeyHints.sh"
  "$HYPR_DIR/scripts/GameMode.sh"
  "$HYPR_DIR/scripts/DarkLight.sh"
  "$HYPR_DIR/initial-boot.sh"
  "$HYPR_DIR/configs/Startup_Apps.conf"
  "$HYPR_DIR/UserScripts/WallpaperSelect.sh"
  "$HYPR_DIR/UserScripts/WallpaperRandom.sh"
  "$HYPR_DIR/UserScripts/WallpaperEffects.sh"
  "$HYPR_DIR/UserScripts/WallpaperAutoChange.sh"
)

existing_files=()

for file in "${FILES[@]}"; do
  [[ -f "$file" ]] && existing_files+=("$file")
done

echo "Modo: $MODE"
echo "Archivos encontrados para migrar:"
printf '  %s\n' "${existing_files[@]}"
echo

if [[ "$MODE" == "--dry-run" ]]; then
  echo "Referencias actuales:"
  echo

  for file in "${existing_files[@]}"; do
    if grep -nE 'swww|Swww|SWWW' "$file" >/dev/null 2>&1; then
      echo "---- $file"
      grep -nE 'swww|Swww|SWWW' "$file" || true
      echo
    fi
  done

  echo "Dry-run terminado."
  echo "Para aplicar:"
  echo "  migrate-hypr-swww-to-awww.sh --apply"
  exit 0
fi

echo "Creando backup en:"
echo "  $BACKUP_DIR"
mkdir -p "$BACKUP_ROOT"
cp -a "$HYPR_DIR" "$BACKUP_DIR"

echo
echo "Aplicando reemplazos..."

for file in "${existing_files[@]}"; do
  if grep -qE 'swww|Swww|SWWW' "$file"; then
    perl -0pi -e '
      # Daemon: awww no usa xrgb como formato válido según man page actual.
      s/swww-daemon\s+--format\s+xrgb/awww-daemon/g;
      s/swww-daemon/awww-daemon/g;

      # Cliente principal.
      s/\bswww\s+query\b/awww query/g;
      s/\bswww\s+kill\b/awww kill/g;
      s/\bswww\s+img\b/awww img/g;

      # Variables / nombres de script / comentarios.
      s/WallustSwww\.sh/WallustAwww.sh/g;
      s/SWWW_PARAMS/AWWW_PARAMS/g;
      s/SwwwRandom/AwwwRandom/g;

      # Cache.
      s/\.cache\/swww/\.cache\/awww/g;
      s/cache_dir="\$HOME\/\.cache\/swww\/"/cache_dir="\$HOME\/.cache\/awww\/"/g;

      # Texto suelto en comentarios o hints.
      s/\bswww\b/awww/g;
      s/Swww/Awww/g;
      s/SWWW_TRANSITION_TYPE/AWWW_TRANSITION/g;
      s/SWWW/AWWW/g;
    ' "$file"

    echo "Editado: $file"
  fi
done

OLD="$HYPR_DIR/scripts/WallustSwww.sh"
NEW="$HYPR_DIR/scripts/WallustAwww.sh"

if [[ -f "$OLD" ]]; then
  if [[ -e "$NEW" ]]; then
    echo "No renombro $OLD porque ya existe $NEW"
  else
    mv "$OLD" "$NEW"
    chmod +x "$NEW"
    echo "Renombrado: $OLD -> $NEW"
  fi
fi

echo
echo "Migración terminada."
echo "Backup guardado en:"
echo "  $BACKUP_DIR"
echo
echo "Chequeá referencias restantes con:"
echo "  grep -RInE 'swww|Swww|SWWW' ~/.config/hypr 2>/dev/null"
