#!/usr/bin/env bash
# Wallpaper picker with per-monitor support.
#
#   wallpaper-picker.sh                    # choose monitor (if >1), then image
#   wallpaper-picker.sh --all              # skip chooser, set every monitor
#   wallpaper-picker.sh --monitor DP-1     # skip chooser, target one monitor
#   wallpaper-picker.sh --random           # random image per monitor (each different)
#   wallpaper-picker.sh --monitor DP-1 /path/to.png    # set directly, no UI
#
# Applies instantly over IPC and records the choice in hyprpaper.conf so it
# survives a relogin.

set -uo pipefail
source "$HOME/.config/hypr/scripts/wallpaper-lib.sh"

WOFI=(wofi --dmenu --insensitive --cache-file /dev/null)

target=""       # "" = not yet chosen; "*" = all monitors; else a monitor name
want_random=0
direct_image=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)     target="*"; shift ;;
    --monitor) target="${2:-}"; shift 2 ;;
    --random)  want_random=1; shift ;;
    *)         direct_image="$1"; shift ;;
  esac
done

mapfile -t images < <(collect_images)
if [[ ${#images[@]} -eq 0 ]]; then
  notify-send -u critical "Wallpaper" "No images found in ~/Pictures"
  exit 1
fi

load_walls
ensure_hyprpaper || { notify-send -u critical "Wallpaper" "hyprpaper not responding"; exit 1; }

# --- random: give every monitor its own image -------------------------------
if (( want_random )); then
  if [[ -n "$target" && "$target" != "*" ]]; then
    WALLS["$target"]="${images[RANDOM % ${#images[@]}]}"
  else
    while read -r mon; do
      [[ -n "$mon" ]] || continue
      WALLS["$mon"]="${images[RANDOM % ${#images[@]}]}"
    done < <(connected_monitors)
  fi
  save_walls; apply_all
  notify-send -u low "Wallpaper" "Randomised"
  exit 0
fi

# --- choose the target monitor ----------------------------------------------
mapfile -t mons < <(connected_monitors)

if [[ -z "$target" ]]; then
  if [[ ${#mons[@]} -le 1 ]]; then
    target="*"
  else
    # Build "DP-1  —  AOC 24G42E" style rows, plus an all-monitors option.
    menu=""
    for m in "${mons[@]}"; do
      menu+="$(printf '%-8s  —  %s' "$m" "$(monitor_label "$m")")"$'\n'
    done
    menu+="All monitors"$'\n'

    sel=$(printf '%s' "$menu" | "${WOFI[@]}" --prompt "Which monitor" \
      --width 640 --height 260 --define image_size=0)
    [[ -n "$sel" ]] || exit 0

    if [[ "$sel" == "All monitors" ]]; then
      target="*"
    else
      target="$(trim "${sel%%—*}")"
    fi
  fi
fi

# --- direct set (no image UI) -----------------------------------------------
set_target() {
  local img="$1"
  if [[ "$target" == "*" ]]; then
    # A new default replaces any per-monitor overrides.
    WALLS=([__default__]="$img")
  else
    WALLS["$target"]="$img"
  fi
  save_walls; apply_all
}

if [[ -n "$direct_image" ]]; then
  direct_image="$(expand_home "$direct_image")"
  [[ -f "$direct_image" ]] || { notify-send -u critical "Wallpaper" "Not found: $direct_image"; exit 1; }
  set_target "$direct_image"
  notify-send -u low "Wallpaper" "$(basename "$direct_image")"
  exit 0
fi

# --- image picker ------------------------------------------------------------
declare -A by_label
for img in "${images[@]}"; do
  label="$(basename "$img")"
  [[ -n "${by_label[$label]:-}" ]] && label="$(basename "$(dirname "$img")")/$label"
  by_label["$label"]="$img"
done

menu=""
for label in $(printf '%s\n' "${!by_label[@]}" | sort); do
  menu+="img:${by_label[$label]}:text:${label}"$'\n'
done

if [[ "$target" == "*" ]]; then prompt="Wallpaper → all"; else prompt="Wallpaper → $target"; fi

choice=$(printf '%s' "$menu" | "${WOFI[@]}" --allow-images \
  --prompt "$prompt" --width 900 --height 700 --define image_size=96)
[[ -n "$choice" ]] || exit 0

# wofi may return the raw entry or just the label depending on version.
[[ "$choice" == img:*:text:* ]] && choice="${choice##*:text:}"

chosen="${by_label[$choice]:-}"
if [[ -z "$chosen" ]]; then
  for label in "${!by_label[@]}"; do
    if [[ "$(basename "${by_label[$label]}")" == "$choice" ]]; then chosen="${by_label[$label]}"; break; fi
  done
fi
[[ -n "$chosen" ]] || { notify-send -u critical "Wallpaper" "Could not resolve: $choice"; exit 1; }

set_target "$chosen"
notify-send -u low "Wallpaper" "$(basename "$chosen")${target:+ → $target}"
