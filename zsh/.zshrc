#!/usr/bin/env zsh
# ~/.zshrc - Optimized for productivity and speed

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"




# ===== Core Configuration =====
# History key bindings
bindkey '^p' history-search-backward  # Ctrl+P to search backward
bindkey '^n' history-search-forward   # Ctrl+N to search forward

# History settings
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# ===== Completion System =====
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select                          # Interactive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'     # Case-insensitive matching
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"    # Colorized completions
zstyle ':completion:*' rehash true                         # Auto-update PATH completions




# ===== PATH Configuration =====
# User binaries
export PATH="$HOME/.local/bin:$PATH"
# Neovim
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
# Go
export PATH="/usr/local/go/bin:$PATH"
# Homebrew (macOS/Linux)
export PATH="/usr/local/bin:$PATH"

# ===== Plugin Management =====
# Load zsh-syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting

# Load zsh-autosuggestions
zinit light zsh-users/zsh-autosuggestions

# zinit ice depth=1
# zinit light jeffreytse/zsh-vi-mode
# # Basic completions (zsh-completions)
# zinit ice blockf
# zinit light zsh-users/zsh-completions
#
# # Turbo-loaded completions (faster)
# zinit ice wait lucid blockf atload"zicompinit; zicdreplay"
# zinit light marlonrichert/zsh-autocomplete
#
# # Fuzzy completions (fzf-tab)
# zinit ice wait lucid
# zinit light Aloxaf/fzf-tab
#
# # System completions (docker, pip, etc.)
# zinit ice as"completion"
# zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker
#

# fzf configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'batcat --color=always {}'"
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --no-ignore --exclude node_modules --exclude dist --exclude .next --exclude .nuxt --exclude .cache'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Fuzzy find and open in nvim (now includes hidden files)
nzf() {
  local selected
  selected=$(fzf) || return
  nvim "$selected"
}
# vi mode
bindkey -v

zle-keymap-select() {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[2 q'  # Steady block cursor
  else
    echo -ne '\e[6 q'  # Steady line cursor
  fi
}
zle -N zle-keymap-select


# Set initial cursor shape (insert mode)
echo -ne '\e[6 q'

# Reset cursor shape on exit (optional)
precmd() { echo -ne '\e[6 q'; }

# Set a low timeout for ESC key
export KEYTIMEOUT=1




# Configure autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1


bindkey -r '^y'      # Remove existing binding
bindkey '^y' autosuggest-accept




# # add this to your .zshrc
# function zle-keymap-select {
#   case $keymap in
#     vicmd) export vi_mode="normal" ;;
#     main|viins) export vi_mode="insert" ;;
#   esac
#   zle reset-prompt
# }
# zle -n zle-keymap-select
#
# # set default mode
# export vi_mode="insert"

# ===== node version manager =====
export nvm_dir="$home/.nvm"
# lazy-load nvm for faster startup
nvm() {
    unset -f nvm
    [ -s "$nvm_dir/nvm.sh" ] && \. "$nvm_dir/nvm.sh"
    nvm "$@"
}

# ===== prompt configuration =====
# oh my posh prompt (install first)
# eval "$(oh-my-posh init zsh --config ~/.poshthemes/m365princess.omp.json)"

# ===== aliases =====
# navigation
alias ll='ls -lah --color=auto'
alias la='ls -a --color=auto'
alias l='ls -cf'
alias ls='ls --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias cdw='cd /mnt/c/Users/sheaksadi/'

# editors
alias nv='nvim'
alias vim='nvim'

# utilities
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'

# git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'


alias fd=fdfind

alias bat='batcat'

# ===== Quality of Life =====
# Auto-change directory without 'cd'
setopt autocd
# Correct minor typos
setopt correct
# Allow comments in interactive shell
setopt interactive_comments
# Extended globbing patterns
setopt extended_glob

# ===== TMUX Integration =====
# if [[ -z "$TMUX" ]]; then
#     cd /mnt/c/users/sheaksadi/  # Your Windows home
# fi

# ===== Startup Optimizations =====
# Skip compinit if compdump is recent
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
# ===== Oh My Posh Prompt =====
# Initialize with your preferred theme 
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/M365Princess.omp.json)"


# ===== Final Setup =====
# Load local overrides if they exist
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export PATH=$PATH:~/go/bin
export PATH=$PATH:$(go env GOPATH)/bin
