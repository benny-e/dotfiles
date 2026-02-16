#!/usr/bin/env bash
set -euo pipefail

ICON_OFF="󰂲"
ICON_ON="󰂯"
ICON_CONNECTED="󰂱"

text="$ICON_OFF"
class="off"
tooltip="Bluetooth: Off"

powered="$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print tolower($2)}' | head -n1 || true)"

if [[ "$powered" == "yes" ]]; then
  class="on"
  text="$ICON_ON"
  tooltip="Bluetooth: On"

  connected_mac="$(
    bluetoothctl devices Connected 2>/dev/null | awk '/^Device /{print $2; exit}'
  )"

  if [[ -n "${connected_mac:-}" ]]; then
    class="connected"
    text="$ICON_CONNECTED"
    name="$(bluetoothctl info "$connected_mac" 2>/dev/null | awk -F': ' '/^Name:/ {print $2; exit}')"
    tooltip="Bluetooth: ${name:-Connected}"
  fi
fi

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' \
  "$text" "$class" "$tooltip"

