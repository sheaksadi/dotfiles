#!/usr/bin/env bash
# Shared helpers for the wallpaper picker and the login restore script.
#
# Model: hyprpaper.conf holds at most one default plus any number of
# per-monitor overrides:
#
#   wallpaper = ,/path/default.png     <- key "" in WALLS, used by any monitor
#   wallpaper = DP-1,/path/left.png       without an explicit entry
#   wallpaper = eDP-1,/path/right.png
#
# Keeping the default entry means a monitor that is currently unplugged still
# gets a sensible wallpaper when it comes back.

PAPER_CONF="${PAPER_CONF:-$HOME/.config/hypr/hyprpaper.conf}"

# Directories scanned for images, non-recursive.
WALL_DIRS=(
  "$HOME/Pictures"
  "$HOME/Pictures/wallpapers"
)

declare -A WALLS

# Bash forbids "" as an associative-array subscript, so the wildcard
# (`wallpaper = ,/path`) entry is stored under this sentinel instead.
DEFAULT_KEY="__default__"

trim() { local s="$1"; s="${s#"${s%%[![:space:]]*}"}"; s="${s%"${s##*[![:space:]]}"}"; printf '%s' "$s"; }

expand_home() {
  local p="$1"
  [[ "$p" == "~/"* ]] && p="$HOME/${p#\~/}"
  printf '%s' "$p"
}

connected_monitors() { hyprctl monitors -j | jq -r '.[].name'; }
focused_monitor()    { hyprctl monitors -j | jq -r 'first(.[] | select(.focused)) | .name'; }
monitor_label()      { hyprctl monitors -j | jq -r --arg m "$1" '.[] | select(.name==$m) | .description'; }

# Animated GIFs are skipped: hyprpaper renders only the first frame.
# Screenshots are skipped so they don't accumulate as wallpaper choices.
collect_images() {
  local dir
  for dir in "${WALL_DIRS[@]}"; do
    [[ -d "$dir" ]] || continue
    find "$dir" -maxdepth 1 -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
      -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.jxl' \) 2>/dev/null
  done | grep -viE '_hyprshot\.|/Screenshot_' | sort -u
}

load_walls() {
  WALLS=()
  [[ -f "$PAPER_CONF" ]] || return 0
  local line rest mon path
  while IFS= read -r line; do
    rest="${line#*=}"
    mon="$(trim "${rest%%,*}")"
    path="$(expand_home "$(trim "${rest#*,}")")"
    [[ -n "$path" ]] && WALLS["${mon:-$DEFAULT_KEY}"]="$path"
  done < <(grep -E '^[[:space:]]*wallpaper[[:space:]]*=' "$PAPER_CONF")
}

# Resolve which image a given monitor should show: explicit entry, else default.
wall_for() {
  local mon="$1"
  if [[ -n "${WALLS[$mon]:-}" ]]; then printf '%s' "${WALLS[$mon]}"
  else printf "%s" "${WALLS[$DEFAULT_KEY]:-}"; fi
}

save_walls() {
  local -a preloads=()
  local k
  for k in "${!WALLS[@]}"; do preloads+=("${WALLS[$k]}"); done

  {
    echo "# Managed by wallpaper-picker.sh — edit via the picker (Super + Ctrl + Space)"
    echo
    printf '%s\n' "${preloads[@]}" | sort -u | sed 's/^/preload = /'
    echo
    # Default first, then per-monitor overrides.
    [[ -n "${WALLS[$DEFAULT_KEY]:-}" ]] && echo "wallpaper = ,${WALLS[$DEFAULT_KEY]}"
    for k in $(printf '%s\n' "${!WALLS[@]}" | grep -v "^$DEFAULT_KEY$" | sort); do
      echo "wallpaper = $k,${WALLS[$k]}"
    done
    echo
    echo "splash = false"
    echo "ipc = on"
  } >"$PAPER_CONF"
}

ensure_hyprpaper() {
  pgrep -x hyprpaper >/dev/null 2>&1 || { hyprpaper >/dev/null 2>&1 & }
  local _
  for _ in $(seq 1 40); do
    hyprctl hyprpaper listactive >/dev/null 2>&1 && return 0
    sleep 0.25
  done
  return 1
}

# Push the current WALLS map to every connected monitor over IPC.
# hyprpaper 0.8.4 ignores `wallpaper =` in its own config, so we always set it
# explicitly rather than relying on the file being re-read.
apply_all() {
  local mon img
  while read -r mon; do
    [[ -n "$mon" ]] || continue
    img="$(wall_for "$mon")"
    [[ -n "$img" && -f "$img" ]] || continue
    hyprctl hyprpaper wallpaper "$mon,$img" >/dev/null 2>&1
  done < <(connected_monitors)
}
