#!/usr/bin/env bash
# Start hyprpaper and re-apply the saved wallpapers, per monitor.
#
# Why this exists: hyprpaper 0.8.4 on this machine never applies the
# `wallpaper =` lines from its own config — it logs "Monitor <X> has no target:
# no wp will be created" and leaves the screen bare. Its IPC works fine, so we
# parse hyprpaper.conf ourselves and set each monitor over IPC.
#
# hyprpaper.conf stays the single source of truth; the picker rewrites it.

set -uo pipefail
source "$HOME/.config/hypr/scripts/wallpaper-lib.sh"

ensure_hyprpaper || exit 0
load_walls
apply_all
