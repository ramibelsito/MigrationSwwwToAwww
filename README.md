# Guía de Migración: de `swww` a `awww` en Hyprland

Este documento detalla los pasos necesarios para migrar de forma segura tu configuración de wallpapers desde `swww` hacia `awww`.

---

## Paso 0: Asegurarse de que los scripts sean ejecutables

Asigná permisos de ejecución a los scripts de escaneo y migración:

```bash
chmod +x ~/.local/bin/scan-swww.sh
chmod +x ~/.local/bin/migrate-hypr-swww-to-awww.sh

Verificá los permisos:
Bash

ls -l ~/.local/bin/scan-swww.sh ~/.local/bin/migrate-hypr-swww-to-awww.sh

Deberías ver una salida similar a:
Plaintext

-rwxr-xr-x ...

Paso 1: Confirmar que awww está instalado

Ejecutá los siguientes comandos para comprobar si ya tenés las herramientas instaladas:
Bash

command -v awww
command -v awww-daemon
pacman -Q awww

Si no aparece o no está instalado, ejecutá:
Bash

sudo pacman -S awww

Paso 2: Escanear antes de migrar

Corré el script de escaneo específicamente sobre el directorio de Hyprland (evitá hacerlo sobre todo ~/.config para ahorrar tiempo):
Bash

~/.local/bin/scan-swww.sh ~/.config/hypr

Esto te mostrará en pantalla qué archivos todavía contienen menciones a swww.
Paso 3: Correr el Dry-Run del migrador

Antes de aplicar cambios reales, ejecutá una simulación:
Bash

~/.local/bin/migrate-hypr-swww-to-awww.sh --dry-run

    ⚠️ Nota: Esto no modifica nada. Solo listará los archivos que se van a tocar y las referencias actuales que serán reemplazadas.

Paso 4: Aplicar la migración

Cuando verifiques que el dry-run es correcto y se ve bien, aplicá los cambios de forma definitiva:
Bash

~/.local/bin/migrate-hypr-swww-to-awww.sh --apply

El script creará automáticamente un respaldo en una ruta similar a:
~/.config-backups/hypr-before-awww-YYYYMMDD-HHMMSS

Guardá bien ese path, ya que será tu punto de restauración en caso de fallas (rollback).
Paso 5: Verificar que no queden referencias a swww

Asegurate de que la migración haya sido total usando grep:
Bash

grep -RInE 'swww|Swww|SWWW' ~/.config/hypr 2>/dev/null

O volviendo a usar el script de escaneo:
Bash

~/.local/bin/scan-swww.sh ~/.config/hypr

Lo ideal es que estos comandos no devuelvan ninguna salida, lo que significa que ya no quedan rastros de swww.
Paso 6: Reiniciar el daemon de wallpaper

Matá cualquier proceso previo e iniciá el nuevo demonio de awww:
Bash

pkill -f 'swww-daemon|awww-daemon' 2>/dev/null

awww-daemon &
sleep 1

awww query

Si awww query devuelve información sobre tus monitores y wallpapers, significa que el daemon está corriendo correctamente.
Paso 7: Probar wallpaper manualmente

Probá la herramienta utilizando tu fondo de pantalla actual:
Bash

awww img "$HOME/.config/rofi/.current_wallpaper"

Si ese archivo no existe, podés buscar una imagen disponible en tu sistema con el siguiente comando:
Bash

find ~/Pictures ~/.config/hypr -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) | head

E introducí la ruta que encontraste:
Bash

awww img "/ruta/al/wallpaper.png"

Paso 8: Probar scripts de JaKooLit

Si utilizás los scripts integrados de JaKooLit, probalos en el siguiente orden para verificar la integración:

    Wallpaper Aleatorio:
    Bash

    ~/.config/hypr/UserScripts/WallpaperRandom.sh

    Selector de Wallpapers:
    Bash

    ~/.config/hypr/UserScripts/WallpaperSelect.sh

    Script de Wallust:
    Bash

    ~/.config/hypr/scripts/WallustAwww.sh

Paso 9: Recargar Hyprland

Para aplicar todos los cambios en el entorno gráfico, ejecutá:
Bash

hyprctl reload

También podés cerrar sesión y volver a entrar, pero se recomienda probar primero únicamente con el reload.
Rollback (Si algo se rompe)

Si algo sale mal, podés revertir el proceso al estado anterior de la migración de la siguiente manera:

    Buscá el último backup generado:
    Bash

    ls -dt ~/.config-backups/hypr-before-awww-* | head

    Restaurá el directorio:
    Bash

    backup="$(ls -dt ~/.config-backups/hypr-before-awww-* | head -n1)"

    rm -rf ~/.config/hypr
    cp -a "$backup" ~/.config/hypr

    Recargá Hyprland:
    Bash

    hyprctl reload

Secuencia Compacta Recomendada

Si ya tenés claro el proceso y querés ejecutarlo de manera fluida y rápida en la terminal:
Bash

# Otorgar permisos
chmod +x ~/.local/bin/scan-swww.sh ~/.local/bin/migrate-hypr-swww-to-awww.sh

# Asegurar dependencias
command -v awww || sudo pacman -S awww

# Escaneo previo
~/.local/bin/scan-swww.sh ~/.config/hypr

# Simulación y aplicación
~/.local/bin/migrate-hypr-swww-to-awww.sh --dry-run
~/.local/bin/migrate-hypr-swww-to-awww.sh --apply

# Verificación limpia
grep -RInE 'swww|Swww|SWWW' ~/.config/hypr 2>/dev/null

# Reinicio del entorno de wallpapers
pkill -f 'swww-daemon|awww-daemon' 2>/dev/null
awww-daemon &
sleep 1
awww query

# Recarga final
hyprctl reload
