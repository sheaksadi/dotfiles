#!/usr/bin/env bash
# Power-aware idle actions for hypridle.
#
# hypridle has no notion of AC vs battery — its listeners are static — so every
# timeout routes through here and the action decides whether it applies to the
# current power state.
#
#   idle.sh <action> [ac|battery]
#
# The optional second argument gates the action: `ac` runs only when plugged in,
# `battery` only when running on battery, omitted means always.
#
# Timeline (see hypridle.conf):
#            on battery        plugged in
#   dim        2.5 min           10 min
#   lock         5 min           30 min
#   screen off   6 min           31 min
#   suspend     30 min           never

set -uo pipefail

DIM_FLAG="${XDG_RUNTIME_DIR:-/tmp}/hypridle-dimmed"
DIM_LEVEL=10

# Plugged in if any Mains supply is online, or — covering USB-C PD, where the
# charger shows up as a USB source rather than as AC0 — if the battery is not
# currently discharging.
on_ac() {
  local d
  for d in /sys/class/power_supply/*/; do
    [[ "$(cat "$d/type" 2>/dev/null)" == "Mains" ]] || continue
    [[ "$(cat "$d/online" 2>/dev/null)" == "1" ]] && return 0
  done
  for d in /sys/class/power_supply/*/; do
    [[ "$(cat "$d/type" 2>/dev/null)" == "Battery" ]] || continue
    case "$(cat "$d/status" 2>/dev/null)" in
      Discharging) return 1 ;;
      Charging|Full|"Not charging") return 0 ;;
    esac
  done
  # No battery at all (desktop): treat as plugged in.
  return 0
}

action="${1:-}"
gate="${2:-}"

case "$gate" in
  ac)      on_ac || exit 0 ;;
  battery) on_ac && exit 0 ;;
  "")      ;;
  *)       echo "unknown gate: $gate" >&2; exit 2 ;;
esac

case "$action" in
  dim)
    # Guard against a second dim overwriting the saved brightness with the
    # already-dimmed value, which would make the restore a no-op.
    [[ -e "$DIM_FLAG" ]] && exit 0
    brightnessctl -s set "$DIM_LEVEL" >/dev/null 2>&1 && : >"$DIM_FLAG"
    ;;
  undim)
    [[ -e "$DIM_FLAG" ]] || exit 0
    brightnessctl -r >/dev/null 2>&1
    rm -f "$DIM_FLAG"
    ;;
  lock)
    loginctl lock-session
    ;;
  dpms-off)
    hyprctl dispatch dpms off >/dev/null 2>&1
    ;;
  dpms-on)
    hyprctl dispatch dpms on >/dev/null 2>&1
    ;;
  suspend)
    systemctl suspend
    ;;
  status)
    on_ac && echo "on AC (plugged in)" || echo "on battery"
    ;;
  *)
    echo "usage: idle.sh {dim|undim|lock|dpms-off|dpms-on|suspend|status} [ac|battery]" >&2
    exit 2
    ;;
esac
