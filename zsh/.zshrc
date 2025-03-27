
#!/usr/bin/env zsh
# ~/.zshrc - Optimized for productivity and speed

# ===== Core Configuration =====
# History settings (better than Bash)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt append_history       # Append instead of overwrite
setopt extended_history     # Save timestamp and duration
setopt hist_expire_dups_first # Expire duplicates first
setopt hist_ignore_dups     # Ignore repeated commands
setopt hist_ignore_space    # Ignore commands starting with space
setopt share_history        # Share history across sessions

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
# Load plugins (install with: git clone <url> ~/.zsh/plugin-name)
ZSH_PLUGINS=(
    "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
)

for plugin in $ZSH_PLUGINS; do
    if [[ -f $plugin ]]; then
        source $plugin
    else
        echo "Plugin not found: $(basename $plugin)"
    fi
done

# Configure autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1
bindkey '^ ' autosuggest-accept  # Ctrl+Space to accept suggestion

# ===== Node Version Manager =====
export NVM_DIR="$HOME/.nvm"
# Lazy-load NVM for faster startup
nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm "$@"
}

# ===== Prompt Configuration =====
# Oh My Posh prompt (install first)
eval "$(oh-my-posh init zsh --config ~/.poshthemes/M365Princess.omp.json)"

# ===== Aliases =====
# Navigation
alias ll='ls -lAh --color=auto'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Editors
alias nv='nvim'
alias vim='nvim'

# Utilities
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

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
if [[ -z "$TMUX" ]]; then
    cd /mnt/c/users/sheak.DESKTOP-97UOPK1/  # Your Windows home
fi

# ===== Startup Optimizations =====
# Skip compinit if compdump is recent
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi
# ===== Oh My Posh Prompt =====
# Initialize with your preferred theme
eval "$(oh-my-posh init zsh --config ~/.poshthemes/M365Princess.omp.json)"

# Optional: Auto-refresh prompt (for WSL)
if [[ "$(uname -r)" == *microsoft* ]]; then
    export PROMPT_COMMAND='oh-my-posh --config=$HOME/.poshthemes/M365Princess.omp.json --shell=zsh'
fi
# ===== Final Setup =====
# Load local overrides if they exist
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
