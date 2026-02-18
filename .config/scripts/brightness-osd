#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  up)   brightnessctl set +5% >/dev/null ;;
  down) brightnessctl set 5%- >/dev/null ;;
  *)    exit 0 ;;
esac


CUR="$(brightnessctl get)"
MAX="$(brightnessctl max)"
PCT=$(( CUR * 100 / MAX ))

ICONS=( "" "" "" "" "󰖙" )

(( PCT < 0 )) && PCT=0
(( PCT > 100 )) && PCT=100

INDEX=$(( PCT * 4 / 100 ))

ICON="${ICONS[$INDEX]}"


BODY="<span font='JetBrains Mono Nerd Font 20'>${ICON}</span>"

notify-send \
  -a "osd" \
  -u low \
  -h "int:value:${PCT}" \
  -h "string:x-canonical-private-synchronous:osd" \
  -h "string:category:osd.brightness" \
  -h "int:transient:1" \
  " " \
  "${BODY}"

