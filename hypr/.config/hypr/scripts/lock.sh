#!/usr/bin/env bash
# Crash-resistant screen lock.
#
# The failure this prevents: hyprlock dies (crash, OOM, GPU hiccup) while the
# compositor still holds the session lock. Hyprland will not release the lock —
# that would expose the desktop — so it draws the "Oopsie daisy, it looks like
# you locked your screen but the lockscreen app died" fallback and you are stuck
# on that VT.
#
# Two things make recovery possible:
#   1. misc:allow_session_lock_restore = true  (set in looknfeel.conf) lets a
#      replacement lock client attach to the existing lock. Without it, nothing
#      inside the session can recover — you must switch to another TTY.
#   2. This wrapper respawns hyprlock whenever it exits abnormally, so a crash
#      is corrected in about a second instead of stranding you.
#
# Exit 0 from hyprlock means the user authenticated and the lock was released
# normally — that is the only case where we stop.
#
# Manual recovery, should it ever be needed: Super + Ctrl + Shift + L relaunches
# this while locked. Failing that, Ctrl+Alt+F3, log in, and run:
#   hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'
#   hyprctl --instance 0 'dispatch exec hyprlock'

set -uo pipefail

# Already have a healthy lock client — don't stack a second one.
if pgrep -x hyprlock >/dev/null 2>&1; then
  exit 0
fi

max_attempts=60
attempt=0

while (( attempt < max_attempts )); do
  hyprlock "$@"
  rc=$?

  # Clean unlock.
  (( rc == 0 )) && exit 0

  # Killed by SIGTERM/SIGINT (143/130) — treat as deliberate, e.g. a script
  # tearing the lock down on purpose. Anything else is a crash: respawn.
  if (( rc == 143 || rc == 130 )); then
    exit 0
  fi

  attempt=$(( attempt + 1 ))
  sleep 1
done

# Gave up. Say so loudly rather than dying silently behind a dead lock screen.
notify-send -u critical "Lock screen" \
  "hyprlock crashed $max_attempts times. Press Ctrl+Alt+F3 and see scripts/lock.sh." 2>/dev/null || true
exit 1
