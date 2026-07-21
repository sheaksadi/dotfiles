# 🚀 My Dotfiles

Configuration files for a Linux desktop (Arch/Manjaro + Hyprland), Linux/WSL
shells, and a Windows development environment.

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Every top-level
directory is a *package* whose contents mirror `$HOME`, so
`hypr/.config/hypr/` is symlinked to `~/.config/hypr`.

## 📦 Packages

| Package | Target | Platform | What it is |
|---|---|---|---|
| `hypr` | `~/.config/hypr` | Linux (Wayland) | Hyprland compositor, lock, idle, wallpaper + helper scripts |
| `waybar` | `~/.config/waybar` | Linux (Wayland) | Status bar, Catppuccin Mocha |
| `wofi` | `~/.config/wofi` | Linux (Wayland) | App launcher / dmenu |
| `mako` | `~/.config/mako` | Linux (Wayland) | Notification daemon |
| `alacritty` | `~/.config/alacritty` | Linux | Terminal |
| `btop` | `~/.config/btop` | Linux | Resource monitor |
| `fastfetch` | `~/.config/fastfetch` | Linux | System info |
| `lazygit` | `~/.config/lazygit` | Linux | Git TUI |
| `starship` | `~/.config/starship.toml` | Linux | Shell prompt |
| `spotify-launcher` | `~/.config/spotify-launcher.conf` | Linux | Forces Spotify onto native Wayland (it crashes under XWayland) |
| `xcompose` | `~/.XCompose` | Linux | Compose table; required for keyd's unicode output (umlauts) |
| `zsh` | `~/.zshrc` | Linux/WSL | Shell |
| `bash` | `~/.bashrc` | Linux/WSL | Shell |
| `nvim` | `~/.config/nvim` | Linux/WSL | Neovim |
| `tmux` | `~/.config/tmux` | Linux/WSL | Terminal multiplexer |
| `oh-my-posh` | `~/.config/oh-my-posh` | Linux/WSL | Prompt themes |
| `wezterm` | `~/.wezterm.lua` | Windows | Terminal |
| `glazewm` | `~/.glzr/glazewm` | Windows | Tiling WM |
| `zebar` | `~/.glzr/zebar` | Windows | Status bar |
| `scripts` | — | Windows | AutoHotkey helpers |

## 📋 Quick Setup

### 🔧 Prerequisites

- [Git](https://git-scm.com/)
- [GNU Stow](https://www.gnu.org/software/stow/)

### 📥 1. Clone Repository

```bash
git clone https://github.com/sheaksadi/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

> Stow resolves symlinks relative to the repo's parent directory, so the clone
> must live directly in `$HOME` (i.e. `~/dotfiles`).

## 🖥️ Arch / Manjaro — Hyprland desktop

### Install dependencies

```bash
sudo pacman -S --needed \
  hyprland xdg-desktop-portal-hyprland waybar wofi mako \
  hyprlock hypridle hyprpaper hyprshot \
  wl-clipboard cliphist grim slurp \
  brightnessctl pamixer playerctl polkit-kde-agent \
  alacritty btop fastfetch lazygit starship \
  ttf-jetbrains-mono-nerd noto-fonts-emoji jq
```

### Stow

```bash
cd ~/dotfiles
stow hypr waybar wofi mako alacritty btop fastfetch lazygit starship
stow zsh bash nvim tmux oh-my-posh
```

Log out and pick **Hyprland** in your display manager's session menu.

### Notes on the Hyprland setup

- **Keybinds** are described inline (`bindd`), so `Super + Shift + /` opens a
  searchable list generated live from `hyprctl binds` — it can never drift from
  the config.
- **Wallpapers** are per-monitor. `Super + Ctrl + Space` picks one;
  `hyprpaper.conf` is rewritten by `scripts/wallpaper-picker.sh` and is the
  single source of truth.
  hyprpaper 0.8.4 does not apply `wallpaper =` from its own config on some
  systems, so `scripts/wallpaper-restore.sh` re-applies it over IPC at login.
- **Locking** goes through `scripts/lock.sh`, which respawns hyprlock if it
  crashes. This needs `misc:allow_session_lock_restore = true` (set in
  `looknfeel.conf`) — without it, a dead lock client strands the session and the
  only way out is another TTY.
- **Idle** timings are power-aware via `scripts/idle.sh`: on battery the screen
  locks after 5 min and suspends at 30; plugged in it locks after 30 min and
  never suspends.

## 🐧 Linux / WSL — shells only

```bash
cd ~/dotfiles
stow zsh nvim tmux
```

```bash
# zsh plugins
mkdir -p ~/.zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions
```

## 🪟 Windows Setup

### Enable Developer Mode

```powershell
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
```

### Create Symlinks

```powershell
$WslHomePath = "\\wsl.localhost\Debian\home\$env:USERNAME\dotfiles"

# WezTerm configuration
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.wezterm.lua" -Target "$WslHomePath\wezterm\.wezterm.lua"

# Create .glzr folder
$GlzrPath = "$env:USERPROFILE\.glzr"
New-Item -ItemType Directory -Path $GlzrPath -Force

# GlazeWM configuration
New-Item -ItemType SymbolicLink -Path "$GlzrPath\glazewm" -Target "$WslHomePath\glazewm"

# Zebar configuration
New-Item -ItemType SymbolicLink -Path "$GlzrPath\zebar" -Target "$WslHomePath\zebar"
```

## 🛠 Maintenance Commands

| Command | Description |
|---|---|
| `git pull` | Update dotfiles repository |
| `stow <pkg>` | Create symlinks for a package |
| `stow -R <pkg>` | Restow (refresh symlinks after adding files) |
| `stow -D <pkg>` | Unstow (remove symlinks; files stay in the repo) |
| `stow --adopt <pkg>` | Pull existing real files *into* the repo, then symlink — **overwrites the repo's copy**, so `git diff` right after |

### 💡 Helpful Utilities

```bash
# Confirm something is actually a symlink and where it points
readlink -f ~/.config/hypr
```

```powershell
# Verify symlink details (Windows)
Get-Item "$env:USERPROFILE\.wezterm.lua" | Select-Object LinkType, Target
```

### Maybe necessary

#### `/etc/wsl.conf` (needs root, `sudo -i`)

```bash
[automount]
options = "metadata,uid=1000,gid=1000,umask=22,fmask=111"
```

## 📝 Notes

- Back up existing configuration before stowing — `stow` refuses to overwrite
  real files, and `--adopt` silently replaces the repo's version with yours.
- Update `$WslHomePath` if your WSL distribution or username differs.
- The Windows packages (`glazewm`, `zebar`, `scripts`, `wezterm`) are not
  stowed on Linux.
