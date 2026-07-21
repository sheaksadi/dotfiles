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

### Umlauts need the compose table

keyd's unicode output works by emitting `<Cancel>`-prefixed compose sequences,
which are only meaningful if `/usr/share/keyd/keyd.compose` is reachable. That
is what the `xcompose` stow package provides — without it, holding Caps and
pressing `a` types the literal text `02s` instead of `ä`.

Applications read `~/.XCompose` at startup, so restart them (or relaunch the
session) after stowing it.
