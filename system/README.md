# System-level config

These files live outside `$HOME`, so they are **not** stow packages — stow only
symlinks into your home directory. Copy them into place manually.

## keyd — `etc/keyd/default.conf`

Caps Lock becomes a dual-role key: tap for Escape, hold for umlauts.
keyd remaps at the evdev layer, so this applies everywhere — Hyprland, Plasma
and the TTY — and to every attached keyboard, not just the built-in one.

```bash
sudo install -Dm644 system/etc/keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
sudo keyd reload      # after editing
```

**Panic sequence:** if a bad config ever leaves the keyboard unusable, press
`Backspace + Escape + Enter` together to force keyd to terminate.
