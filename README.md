# 🚀 My Dotfiles

Configuration files for Linux/WSL and Windows development environment.

## 📋 Quick Setup

### 🔧 Prerequisites
- [Git](https://git-scm.com/)
- [GNU Stow](https://www.gnu.org/software/stow/) 
  - Install on Ubuntu/WSL: `sudo apt install stow`

### 📥 1. Clone Repository
```bash
git clone https://github.com/sheaksadi/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 🐧 Linux/WSL Setup

#### Install Dependencies
```bash
# Update package list and install GNU Stow
sudo apt update && sudo apt install stow
```

#### Stow Configurations
```bash
# Run these commands from ~/dotfiles
stow zsh       # Install Zsh configuration
stow nvim      # Install Neovim configuration
stow tmux      # Install Tmux configuration
```

### 🪟 Windows Setup

#### Enable Developer Mode
```powershell
# Enable Developer mode registry key
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
```

#### Create Symlinks
```powershell
# Define WSL home path variable
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
#### Alternate Way (with Fullpath)
```bash
# WezTerm configuration
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.wezterm.lua" -Target "\\wsl$\Debian\home\sadi\dotfiles\wezterm\.wezterm.lua"

# Create .glzr folder
New-Item -ItemType Directory -Path "$env:USERPROFILE\.glzr" -Force

# GlazeWM configuration
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.glzr\glazewm" -Target "\\wsl$\Debian\home\sadi\dotfiles\glazewm"

# Zebar configuration
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.glzr\zebar" -Target "\\wsl$\Debian\home\sadi\dotfiles\zebar"
```
## 🛠 Maintenance Commands

| Command | Description |
|---------|-------------|
| `git pull` | Update dotfiles repository |
| `stow -R zsh` | Restow configuration (replace symlinks) |
| `stow -D zsh` | Unstow configuration (remove symlinks) |

### 💡 Helpful Utilities
```powershell
# Remove existing configuration
Remove-Item "$env:USERPROFILE\.glzr\glazewm\" -Force

# Verify symlink details
Get-Item "$env:USERPROFILE\.wezterm.lua" | Select-Object LinkType, Target
```
### Maybe necessary
#### `/etc/wsl.conf` (Need to be in as root `sudo -i`) 
```bash
[automount]
options = "metadata,uid=1000,gid=1000,umask=22,fmask=111"
```
## 📝 Notes
- Ensure you have the necessary permissions before running symlink and stow commands
- Backup your existing configurations before applying these dotfiles
- Update `$WslHomePath` variable if your WSL distribution or username differs
