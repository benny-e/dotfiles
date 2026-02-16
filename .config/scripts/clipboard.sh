#!/usr/bin/env bash
set -euo pipefail

THEME="$HOME/.config/rofi/clipboard.rasi"

mapfile -t LINES < <(cliphist list)

((${#LINES[@]})) || exit 0

DISPLAY="$(printf '%s\n' "${LINES[@]}" | sed 's/^[0-9]\+\s\+//')"

IDX="$(
  printf '%s\n' "$DISPLAY" |
    rofi -dmenu -i -p "   " -theme "$THEME" -format 'i' -hover-select
)"

[[ -n "${IDX:-}" ]] || exit 0

cliphist decode <<<"${LINES[$IDX]}" | wl-copy

