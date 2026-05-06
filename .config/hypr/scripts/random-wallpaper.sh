#!/usr/bin/env bash
set -euo pipefail

wall_dir="/home/pop/Pictures/Wallpapers"

mapfile -d '' wallpapers < <(
    find "$wall_dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \) \
        -print0 | sort -z
)

if ((${#wallpapers[@]} == 0)); then
    echo "No wallpapers found in $wall_dir" >&2
    exit 1
fi

choice="${wallpapers[RANDOM % ${#wallpapers[@]}]}"

if ! pgrep -x hyprpaper >/dev/null 2>&1; then
    hyprpaper >/dev/null 2>&1 &
    sleep 1
fi

hyprctl hyprpaper wallpaper ",$choice"
