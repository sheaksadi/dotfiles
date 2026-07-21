#!/usr/bin/env bash
# Searchable list of every Hyprland keybind, read live from the compositor.
#
# Works because every bind in bindings.conf uses `bindd` (the "d" = described),
# so each one carries a human label. Binds without a description fall back to
# showing their dispatcher.
#
# Bound to Super + Shift + / (i.e. Super + ?).

set -uo pipefail

# Keycodes used in bindings.conf via `code:NN`, mapped back to their labels.
# XKB keycode = X11 keycode; 10..19 are the number row.
keycode_label() {
  case "$1" in
    10) echo "1" ;; 11) echo "2" ;; 12) echo "3" ;; 13) echo "4" ;; 14) echo "5" ;;
    15) echo "6" ;; 16) echo "7" ;; 17) echo "8" ;; 18) echo "9" ;; 19) echo "0" ;;
    20) echo "-" ;; 21) echo "=" ;; 61) echo "/" ;;
    *)  echo "code:$1" ;;
  esac
}

# modmask bits -> readable modifier string
mods_label() {
  local m=$1 out=""
  (( m & 64 )) && out+="Super + "
  (( m & 4  )) && out+="Ctrl + "
  (( m & 8  )) && out+="Alt + "
  (( m & 1  )) && out+="Shift + "
  printf '%s' "$out"
}

# NOTE: fields are joined with \x1f (unit separator), not tab. Tab is an IFS
# *whitespace* character, so bash collapses runs of tabs into one delimiter and
# empty fields (binds using `code:NN` have an empty .key) silently shift every
# later field left. \x1f is non-whitespace, so empty fields are preserved.
rows=""
while IFS=$'\x1f' read -r modmask key keycode desc dispatcher arg; do
  # Prefer the named key; fall back to the keycode mapping.
  if [[ -n "$key" && "$key" != "null" ]]; then
    keylabel="$key"
  elif [[ -n "$keycode" && "$keycode" != "0" && "$keycode" != "null" ]]; then
    keylabel="$(keycode_label "$keycode")"
  else
    continue
  fi

  # Tidy up mouse/scroll names
  case "$keylabel" in
    mouse_down) keylabel="Scroll down" ;;
    mouse_up)   keylabel="Scroll up" ;;
    mouse:272)  keylabel="Left click" ;;
    mouse:273)  keylabel="Right click" ;;
  esac

  # Uppercase single letters so "h" reads as "H"
  [[ ${#keylabel} -eq 1 ]] && keylabel="${keylabel^^}"

  label="$desc"
  if [[ -z "$label" || "$label" == "null" ]]; then
    label="$dispatcher${arg:+ $arg}"
  fi

  # Sort key: Super binds first, then by modifier combo, then by key name.
  if (( modmask & 64 )); then grp=0; else grp=1; fi
  rows+="$(printf '%d%03d%-20s\x1f%-34s  %s' \
    "$grp" "$modmask" "$keylabel" \
    "$(mods_label "$modmask")$keylabel" "$label")"$'\n'
done < <(
  hyprctl binds -j | jq -r '
    .[]
    | [ (.modmask // 0), (.key // ""), (.keycode // 0),
        (.description // ""), (.dispatcher // ""), (.arg // "") ]
    | join("")'
)

if [[ -z "$rows" ]]; then
  notify-send -u critical "Keybinds" "Could not read binds from hyprctl"
  exit 1
fi

# Sort on the hidden prefix, then drop it and show only the display column.
printf '%s' "$rows" \
  | sort -u \
  | cut -d$'\x1f' -f2- \
  | wofi --dmenu --insensitive \
      --prompt "Keybinds" --width 900 --height 700 --cache-file /dev/null \
      --define hide_scroll=false >/dev/null
