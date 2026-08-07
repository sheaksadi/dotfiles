#!/usr/bin/env bash
# Directional workspace push (not swap).
#   left  → right monitor's workspace moves to left monitor
#   right → left monitor's workspace moves to right monitor
set -euo pipefail

direction="${1:-right}"

mons=$(hyprctl monitors -j 2>/dev/null \
  | jq -r 'sort_by(.x) | .[] | "\(.name) \(.activeWorkspace.id)"' 2>/dev/null)

if [[ -z "$mons" ]]; then
  exit 0
fi

left_mon=$(echo "$mons" | sed -n '1p' | awk '{print $1}')
left_ws=$(echo "$mons" | sed -n '1p' | awk '{print $2}')
right_mon=$(echo "$mons" | sed -n '2p' | awk '{print $1}')
right_ws=$(echo "$mons" | sed -n '2p' | awk '{print $2}')

if [[ -z "$left_mon" || -z "$right_mon" ]]; then
  exit 0
fi

if [[ "$direction" == "left" ]]; then
  hyprctl dispatch --quiet moveworkspacetomonitor "$right_ws $left_mon"
  sleep 0.1
  hyprctl dispatch --quiet focusmonitor "$left_mon"
  hyprctl dispatch --quiet workspace "$right_ws"
elif [[ "$direction" == "right" ]]; then
  hyprctl dispatch --quiet moveworkspacetomonitor "$left_ws $right_mon"
  sleep 0.1
  hyprctl dispatch --quiet focusmonitor "$right_mon"
  hyprctl dispatch --quiet workspace "$left_ws"
else
  hyprctl dispatch --quiet swapactiveworkspaces "$left_mon $right_mon"
fi
