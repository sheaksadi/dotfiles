#!/usr/bin/env bash
# Floating audio device picker.
#
# Lists every output (sink) and input (source) in one wofi menu, marks the
# current defaults, and switches to whatever you pick.
#
#   audio-menu.sh            # both outputs and inputs
#   audio-menu.sh output     # outputs only
#   audio-menu.sh input      # inputs only
#
# Uses wpctl (wireplumber). Right-clicking the waybar icons opens pavucontrol
# instead, for per-stream routing and profile changes this menu does not cover.

set -uo pipefail

WOFI=(wofi --dmenu --insensitive --cache-file /dev/null
      --prompt "Audio" --width 720 --height 420 --define image_size=0)

want="${1:-both}"

# wpctl status lines look like:
#     │  *   96. Meteor Lake-P HD Audio Controller Speaker [vol: 0.70]
# The leading * marks the current default. Strip tree glyphs and the vol suffix.
list_section() {
  local section="$1" kind="$2"
  # Slice out the Audio block FIRST. `wpctl status` repeats the Sinks:/Sources:
  # headers under Video, so without this the webcams show up as audio inputs.
  wpctl status 2>/dev/null \
    | sed -n '/^Audio$/,/^Video$/p' \
    | sed -n "/^ ├─ ${section}:/,/^ │  \$/p" \
    | grep -E '[0-9]+\.' \
    | sed -E 's/^[^A-Za-z0-9*]*//; s/\[vol:[^]]*\]//; s/[[:space:]]+$//' \
    | while IFS= read -r line; do
        local mark="  " id name
        if [[ "$line" == \** ]]; then
          mark="● "
          line="${line#\*}"
          line="${line#"${line%%[![:space:]]*}"}"
        fi
        id="${line%%.*}"
        name="${line#*. }"
        [[ "$id" =~ ^[0-9]+$ ]] || continue
        printf '%s%s\t%s\t%s\n' "$mark" "$kind" "$name" "$id"
      done
}

rows=""
[[ "$want" == both || "$want" == output ]] && rows+="$(list_section Sinks   '󰓃 Output')"$'\n'
[[ "$want" == both || "$want" == input  ]] && rows+="$(list_section Sources '󰍬 Input ')"$'\n'

rows="$(printf '%s' "$rows" | sed '/^[[:space:]]*$/d')"

if [[ -z "$rows" ]]; then
  notify-send -u critical "Audio" "No devices found (is wireplumber running?)"
  exit 1
fi

# Display columns without the trailing id, which we keep for the lookup.
menu="$(printf '%s\n' "$rows" | awk -F'\t' '{printf "%s  %s\n", $1, $2}')"

choice="$(printf '%s' "$menu" | "${WOFI[@]}")"
[[ -n "$choice" ]] || exit 0

# Match the chosen display line back to its node id.
id="$(printf '%s\n' "$rows" | awk -F'\t' -v c="$choice" '
  { disp = $1 "  " $2 }
  disp == c { print $3; exit }
')"

if [[ -z "$id" ]]; then
  notify-send -u critical "Audio" "Could not resolve selection"
  exit 1
fi

if wpctl set-default "$id" 2>/dev/null; then
  notify-send -u low "Audio" "Switched to ${choice#* }"
else
  notify-send -u critical "Audio" "Failed to switch device"
  exit 1
fi
