#!/usr/bin/env bash
# Floating power-profile picker (power-profiles-daemon).
#
# Lists the profiles the daemon actually offers on this machine, marks the
# active one, and switches on selection. Bound to a click on waybar's battery.

set -uo pipefail

command -v powerprofilesctl >/dev/null 2>&1 || {
  notify-send -u critical "Power" "power-profiles-daemon is not installed"; exit 1; }

active="$(powerprofilesctl get 2>/dev/null)"

# `powerprofilesctl list` prints e.g.
#   * performance:
#         CpuDriver:  intel_pstate
# so take only the lines that name a profile.
mapfile -t profiles < <(
  powerprofilesctl list 2>/dev/null \
    | grep -oE '^[[:space:]*]*[a-z-]+:' \
    | tr -d ' *:' \
    | awk 'NF'
)

[[ ${#profiles[@]} -gt 0 ]] || { notify-send -u critical "Power" "No profiles reported"; exit 1; }

icon_for() {
  case "$1" in
    performance) printf '󰓅' ;;
    balanced)    printf '󰾅' ;;
    power-saver) printf '󰌪' ;;
    *)           printf '󰁹' ;;
  esac
}

label_for() {
  case "$1" in
    performance) printf 'Performance' ;;
    balanced)    printf 'Balanced' ;;
    power-saver) printf 'Power Saver' ;;
    *)           printf '%s' "$1" ;;
  esac
}

menu=""
for p in "${profiles[@]}"; do
  mark="  "; [[ "$p" == "$active" ]] && mark="● "
  menu+="$(printf '%s%s  %s' "$mark" "$(icon_for "$p")" "$(label_for "$p")")"$'\n'
done

choice="$(printf '%s' "$menu" | wofi --dmenu --insensitive --cache-file /dev/null \
  --prompt "Power profile" --width 420 --height 260 --define image_size=0)"
[[ -n "$choice" ]] || exit 0

# Map the display line back to the raw profile name.
target=""
for p in "${profiles[@]}"; do
  [[ "$choice" == *"$(label_for "$p")" ]] && { target="$p"; break; }
done
[[ -n "$target" ]] || { notify-send -u critical "Power" "Could not resolve selection"; exit 1; }

if powerprofilesctl set "$target" 2>/dev/null; then
  notify-send -u low "Power" "$(label_for "$target")"
else
  notify-send -u critical "Power" "Failed to set $target"
  exit 1
fi
