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
sudo systemctl restart keyd   # after editing
```

**Do not use `keyd reload`.** On keyd 2.6.0 it can segfault the daemon; the
command still exits 0, so the service silently ends up `failed` and no
remapping happens at all. Check with `systemctl is-active keyd` after any
change. `systemctl restart keyd` is reliable.

**Panic sequence:** if a bad config ever leaves the keyboard unusable, press
`Backspace + Escape + Enter` together to force keyd to terminate.

### Caps Lock

Caps Lock is remapped to Escape. keyd works at the evdev layer, so this applies
everywhere — Hyprland, Plasma and the TTY — and to every attached keyboard.

Umlauts are **not** handled by keyd. They come from the layout: `AltGr` plus
`a`/`e`/`o`/`u`/`s` gives `ä ë ö ü ß` (add Shift for `Ä Ë Ö Ü ẞ`). See the
`xkb` stow package.
