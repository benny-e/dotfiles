#!/usr/bin/env bash
set -euo pipefail

LOCKFILE="${XDG_RUNTIME_DIR:-/tmp}/rofi-bt.lock"

exec 9>"$LOCKFILE"
if ! flock -n 9; then
  pkill -x rofi >/dev/null 2>&1 || true
  exit 0
fi


ROFI_THEME="${ROFI_THEME:-$HOME/.config/rofi/bluetooth.rasi}"
SCAN_SECONDS="${SCAN_SECONDS:-3}"

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

require_deps() {
  have rofi || die "rofi not found"
  have bluetoothctl || die "bluetoothctl not found"
  have timeout || die "timeout not found"
}

SCAN_PID=""

cleanup() {
  if [[ -n "${SCAN_PID}" ]] && kill -0 "$SCAN_PID" 2>/dev/null; then
    kill "$SCAN_PID" 2>/dev/null || true
    wait "$SCAN_PID" 2>/dev/null || true
  fi
  timeout 2 bluetoothctl scan off >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

bt_powered() {
  timeout 2 bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print tolower($2)}' | head -n1
}

toggle_power() {
  local p
  p="$(bt_powered || true)"
  if [[ "$p" == "yes" ]]; then
    timeout 3 bluetoothctl power off >/dev/null 2>&1 || true
  else
    timeout 3 bluetoothctl power on >/dev/null 2>&1 || true
  fi
}

main_menu() {
  printf "Bluetooth On/Off (toggle)\nDevices\n" | \
    rofi -dmenu -i -p " Bluetooth" -theme "$ROFI_THEME" -hover-select 
}

scan_fixed() {
  [[ "$(bt_powered || true)" == "yes" ]] || return 0

  timeout "$((SCAN_SECONDS + 6))" bluetoothctl scan on >/dev/null 2>&1 &
  SCAN_PID="$!"

  sleep "$SCAN_SECONDS"

  timeout 2 bluetoothctl scan off >/dev/null 2>&1 || true

  if kill -0 "$SCAN_PID" 2>/dev/null; then
    kill "$SCAN_PID" 2>/dev/null || true
    wait "$SCAN_PID" 2>/dev/null || true
  fi
  SCAN_PID=""
}

named_devices() {
  timeout 3 bluetoothctl devices 2>/dev/null | awk '
    /^Device[[:space:]]+[0-9A-Fa-f:]+[[:space:]]+/ {
      mac=$2
      name=""
      for (i=3; i<=NF; i++) name = name (i==3?"":" ") $i
      # Only named devices
      if (name != "") printf "%s\t%s\n", mac, name
    }'
}

devices_menu() {
  local lines menu choice mac

  lines="$(named_devices || true)"
  if [[ -z "$lines" ]]; then
    printf "No named devices found\n" | \
      rofi -dmenu -i -p "Devices" -theme "$ROFI_THEME" -hover-select >/dev/null
    return 1
  fi

  menu="$(printf "%s\n" "$lines" | awk -F'\t' '
    {
      mac=$1; name=$2;
      suffix=substr(mac, length(mac)-4);  # e.g., "D2:B3"
      printf "%s  (%s)\t%s\n", name, suffix, mac
    }')"

  choice="$(printf "%s\n" "$menu" | cut -f1 | \
    rofi -dmenu -i -p "Devices" -theme "$ROFI_THEME" -hover-select)"
  [[ -n "$choice" ]] || return 1

  mac="$(printf "%s\n" "$menu" | awk -F'\t' -v c="$choice" '$1==c {print $2; exit}')"
  [[ -n "$mac" ]] || die "Failed to resolve selected device to MAC"
  echo "$mac"
}

pair_trust_connect() {
  local mac="$1"

  [[ "$(bt_powered || true)" == "yes" ]] || timeout 3 bluetoothctl power on >/dev/null 2>&1 || true

  timeout 12 bluetoothctl pair "$mac"   >/dev/null 2>&1 || true
  timeout 12 bluetoothctl trust "$mac"  >/dev/null 2>&1 || true
  timeout 12 bluetoothctl connect "$mac" >/dev/null 2>&1 || true
}

run_devices_flow() {
  scan_fixed

  local mac
  if mac="$(devices_menu)"; then
    pair_trust_connect "$mac"
  fi
}

main() {
  require_deps

  local sel
  sel="$(main_menu || true)"
  case "$sel" in
    "Bluetooth On/Off (toggle)") toggle_power ;;
    "Devices") run_devices_flow ;;
    *) exit 0 ;;
  esac
}

main "$@"

