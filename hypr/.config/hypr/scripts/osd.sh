#!/usr/bin/env bash
# Small floating OSD for volume / mic / brightness changes.
#
#   osd.sh volume     up|down|mute
#   osd.sh mic        up|down|mute
#   osd.sh brightness up|down
#
# Rendered by mako: the `value` hint draws a progress bar (styled by
# progress-color in mako/config), and x-canonical-private-synchronous makes
# repeated changes replace the same popup instead of stacking a queue of them.

set -uo pipefail

STEP=5

osd() { # title, value 0-100
  notify-send -u low \
    -h string:x-canonical-private-synchronous:osd \
    -h int:value:"$2" \
    "$1" "$2%"
}

osd_plain() { # title, subtitle — no progress bar
  notify-send -u low \
    -h string:x-canonical-private-synchronous:osd \
    "$1" "$2"
}

case "${1:-}" in
  volume)
    case "${2:-}" in
      up)   pamixer -i "$STEP" >/dev/null ;;
      down) pamixer -d "$STEP" >/dev/null ;;
      mute) pamixer -t >/dev/null ;;
      *) echo "usage: osd.sh volume up|down|mute" >&2; exit 2 ;;
    esac
    if [[ "$(pamixer --get-mute)" == "true" ]]; then
      osd_plain "󰝟  Volume" "Muted"
    else
      osd "󰕾  Volume" "$(pamixer --get-volume)"
    fi
    ;;

  mic)
    case "${2:-}" in
      up)   pamixer --default-source -i "$STEP" >/dev/null ;;
      down) pamixer --default-source -d "$STEP" >/dev/null ;;
      mute) pamixer --default-source -t >/dev/null ;;
      *) echo "usage: osd.sh mic up|down|mute" >&2; exit 2 ;;
    esac
    if [[ "$(pamixer --default-source --get-mute)" == "true" ]]; then
      osd_plain "󰍭  Microphone" "Muted"
    else
      osd "󰍬  Microphone" "$(pamixer --default-source --get-volume)"
    fi
    ;;

  brightness)
    case "${2:-}" in
      up)   brightnessctl set "+${STEP}%" >/dev/null ;;
      down) brightnessctl set "${STEP}%-" >/dev/null ;;
      *) echo "usage: osd.sh brightness up|down" >&2; exit 2 ;;
    esac
    # brightnessctl reports raw values; convert to a percentage.
    cur=$(brightnessctl get); max=$(brightnessctl max)
    osd "󰃠  Brightness" "$(( cur * 100 / max ))"
    ;;

  *)
    echo "usage: osd.sh {volume|mic|brightness} <action>" >&2
    exit 2
    ;;
esac
