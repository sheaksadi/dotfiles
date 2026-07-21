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

### How the umlauts work

keyd's built-in unicode support is deliberately **not** used. It emits
`<Cancel>`-prefixed compose sequences, which only resolve if every application
loads keyd's compose table — when one does not, you get the raw sequence text
(`02s`) typed instead of `ä`.

Instead the umlaut layer sends AltGr plus the key that already carries the
character in the `us(altgr-intl)` layout (set via `kb_variant` in
`hypr/input.conf`):

| Hold Caps + | sends   | gives |
|-------------|---------|-------|
| `a`         | AltGr+q | ä / Ä |
| `e`         | AltGr+r | ë / Ë |
| `o`         | AltGr+p | ö / Ö |
| `u`         | AltGr+y | ü / Ü |
| `s`         | AltGr+s | ß     |

Shift gives the capitals for free (level 4 of the same keys). The one exception
is `ß`: level 4 of the `s` key is `§`, not `ẞ`, so Shift+Caps+s types `§`.

This needs no compose table and takes effect immediately, with no app restart.
