#!/usr/bin/env bash
# Switch to the SDDM greeter so another session (Plasma, a second Hyprland,
# another user) can be started, without killing this one.
#
# hyprlock has no "switch session" button — no clickable widgets at all — so
# this is bound with Hyprland's `bindl` flag, which keeps firing while locked.
#
# IMPORTANT: this used to be able to strand you. SDDM can leave an orphaned
# greeter registered on a VT whose X server has already died; SwitchToGreeter
# then silently does nothing and simply drops you onto that dead VT — black
# screen, no greeter, no way back except Ctrl+Alt+F1. So this script now:
#   1. reaps any orphaned greeter session before switching,
#   2. verifies a live greeter actually appeared after switching,
#   3. switches you back automatically if it did not.
#
# Return manually any time with Ctrl + Alt + F1.

set -uo pipefail

DM_DEST=org.freedesktop.DisplayManager
DM_PATH=/org/freedesktop/DisplayManager/Seat0
DM_IFACE=org.freedesktop.DisplayManager.Seat

note() { notify-send -u "${2:-low}" "Switch session" "$1" 2>/dev/null || true; }

# --- current session, so we can come back -----------------------------------
here="${XDG_SESSION_ID:-}"
[[ -n "$here" ]] || here=$(loginctl --no-legend list-sessions 2>/dev/null \
  | awk -v u="$USER" '$3==u && $6 ~ /tty/ {print $1; exit}')

if [[ -z "$here" ]]; then
  note "Cannot identify current session; refusing to switch" critical
  exit 1
fi

session_class() { loginctl show-session "$1" -p Class --value 2>/dev/null; }
session_state() { loginctl show-session "$1" -p State --value 2>/dev/null; }

# A greeter session that has no live process behind it is the trap described
# above. Report its id if one exists.
find_greeter() {
  local s
  while read -r s; do
    [[ -n "$s" ]] || continue
    [[ "$(session_class "$s")" == greeter ]] && { printf '%s' "$s"; return 0; }
  done < <(loginctl --no-legend list-sessions 2>/dev/null | awk '{print $1}')
  return 1
}

greeter_is_live() {
  local s="$1" leader
  leader=$(loginctl show-session "$s" -p Leader --value 2>/dev/null)
  [[ -n "$leader" && "$leader" != 0 ]] || return 1
  kill -0 "$leader" 2>/dev/null || return 1
  # A greeter with no greeter binary running is an orphan.
  pgrep -f 'sddm-greeter' >/dev/null 2>&1
}

[[ "$(systemctl is-active sddm 2>/dev/null)" == active ]] || {
  note "SDDM is not running" critical; exit 1; }

can=$(busctl --system get-property "$DM_DEST" "$DM_PATH" "$DM_IFACE" CanSwitch 2>/dev/null | awk '{print $2}')
[[ "$can" == true ]] || { note "Display manager cannot switch sessions" critical; exit 1; }

# --- reap an orphaned greeter before switching ------------------------------
if stale=$(find_greeter) && ! greeter_is_live "$stale"; then
  loginctl terminate-session "$stale" 2>/dev/null
  sleep 1
fi

# --- lock, then switch -------------------------------------------------------
"$HOME/.config/hypr/scripts/lock.sh" >/dev/null 2>&1 & sleep 0.6

busctl --system call "$DM_DEST" "$DM_PATH" "$DM_IFACE" SwitchToGreeter >/dev/null 2>&1 \
  || { note "SwitchToGreeter call failed" critical; exit 1; }

# --- verify a real greeter came up, else go back ----------------------------
for _ in $(seq 1 20); do          # up to ~10s
  sleep 0.5
  if g=$(find_greeter) && greeter_is_live "$g"; then
    exit 0                        # greeter is up; you are on it
  fi
done

# Nothing usable appeared — do not leave the user on a dead VT.
loginctl activate "$here" 2>/dev/null
note "No greeter appeared — returned you to your session. Log out (Super+Shift+Esc) to switch WM." critical
exit 1
