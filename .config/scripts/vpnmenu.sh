#!/usr/bin/env bash
set -euo pipefail

THEME="$HOME/.config/rofi/vpn.rasi"

#notification function
notify() {
   command -v notify-send >/dev/null 2>&1 || return 0
   notify-send -a "VPN" -u normal "$1" "${2:-}"
}

#get vpn network manager connections
mapfile -t VPN_LIST < <(nmcli -t -f NAME,TYPE con show | awk -F: '$2=="vpn"{print $1}')

#get active vpn
ACTIVE_VPN="$(nmcli -t -f NAME,TYPE con show --active | awk -F: '$2=="vpn"{print $1}' | head -n1 || true)"

#create rofi menu entries
#header text for rofi window
HEADER="󰌷 Active VPN: ${ACTIVE_VPN:-"None"}"

#Build menu entries (ONLY actions / VPNs)
MENU=""

#show disconnect if there is a active vpn
if [[ -n "${ACTIVE_VPN:-}" ]]; then
  MENU+="✖ Disconnect active VPN\n"
fi

if ((${#VPN_LIST[@]})); then
  for vpn in "${VPN_LIST[@]}"; do
    if [[ "$vpn" == "$ACTIVE_VPN" ]]; then
      MENU+=" $vpn (Connected)\n"
    else
      MENU+=" $vpn\n"
    fi
  done
else
  MENU+="(No VPN connections found in NetworkManager)\n"
fi


HEADER="󰌷 Active VPN: ${ACTIVE_VPN:-"None"}"

CHOICE="$(printf "%b" "$MENU" | rofi -dmenu -theme "$THEME" -p "$HEADER" -hover-select)"


[[ -z "${CHOICE:-}" ]] && exit 0

case "$CHOICE" in
  "✖ Disconnect active VPN")
   if [[ -n "${ACTIVE_VPN:-}" ]]; then
      if nmcli con down "$ACTIVE_VPN"; then
        notify "VPN disconnected" "$ACTIVE_VPN"
      else
        notify "VPN disconnect failed" "$ACTIVE_VPN"
      fi
    fi
    ;;   
  ✅\ *|\ *)
    VPN_NAME="${CHOICE#* }"
    if nmcli con up "$VPN_NAME"; then
      notify "VPN connected" "$VPN_NAME"
    else
      notify "VPN connect failed" "$VPN_NAME"
    fi
    ;;
  *)
    ;;
    esac

