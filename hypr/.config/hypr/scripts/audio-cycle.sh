#!/usr/bin/env bash
# Cycle between real Audio/Sink outputs (skip HDMI).
# Left-click on waybar pulseaudio icon to cycle.
set -euo pipefail

sink_raw=$(wpctl status 2>/dev/null \
  | sed -n '/^Audio$/,/^Video$/p' \
  | grep '\[vol:' \
  | sed -E 's/^[^0-9]*\*?[[:space:]]*//')

current_name=$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep 'node.name' | sed 's/.*"\(.*\)"/\1/')

sinks=()
current_idx=-1

while IFS= read -r line; do
  id=$(echo "$line" | grep -oP '^[0-9]+')
  [[ -z "$id" ]] && continue

  klass=$(wpctl inspect "$id" 2>/dev/null | grep 'media.class' | sed 's/.*"\(.*\)"/\1/')
  [[ "$klass" != "Audio/Sink" ]] && continue

  name=$(wpctl inspect "$id" 2>/dev/null | grep 'node.name' | sed 's/.*"\(.*\)"/\1/')
  [[ "$name" =~ [Hh][Dd][Mm][Ii]|DisplayPort ]] && continue

  sinks+=("$id")
  [[ "$name" == "$current_name" ]] && current_idx=$((${#sinks[@]} - 1))
done <<< "$sink_raw"

if [[ ${#sinks[@]} -eq 0 ]]; then
  notify-send -u critical "Audio" "No speakers found" -t 2000
  exit 1
fi

if [[ $current_idx -eq -1 ]]; then
  next_idx=0
else
  next_idx=$(( (current_idx + 1) % ${#sinks[@]} ))
fi

next_id="${sinks[$next_idx]}"
desc=$(wpctl inspect "$next_id" 2>/dev/null | grep 'node.description' | sed 's/.*"\(.*\)"/\1/')
[[ -z "$desc" ]] && desc="Speaker $next_id"

if wpctl set-default "$next_id" 2>/dev/null; then
  notify-send -u low "󰓃 Output" "$desc" -t 2000
  pkill -RTMIN+1 waybar 2>/dev/null || true
fi
