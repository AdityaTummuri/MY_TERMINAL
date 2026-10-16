# ~/.zshrc - Managed by OMEN Terminal
# Standalone, fast, robust configuration without large frameworks

# 1. Environment & History
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

# Ensure user binaries are on PATH
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# 2. Enhanced Completions (Native Zsh)
autoload -Uz compinit
# Cache completions for speed (only re-dump once a day)
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24)" ]]; then
    compinit
else
    compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# 3. Keybindings (Emacs style standard)
bindkey -e
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# 4. Optional Tool Integrations (graceful fallbacks)

# eza -> ls replacement
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -lh --icons=auto --group-directories-first'
    alias la='eza -lah --icons=auto --group-directories-first'
    alias tree='eza --tree --icons=auto'
else
    alias ll='ls -lh'
    alias la='ls -lah'
fi

# bat / batcat -> cat replacement
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
    export PAGER='bat'
elif command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
    alias cat='batcat --paging=never'
    export PAGER='batcat'
fi

# zoxide -> cd replacement
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# fzf integration
if command -v fzf >/dev/null 2>&1; then
    # Enable native fzf keybindings if file exists
    for fzf_script in /usr/share/fzf/key-bindings.zsh /usr/share/doc/fzf/examples/key-bindings.zsh; do
        if [[ -f "$fzf_script" ]]; then
            source "$fzf_script"
            break
        fi
    done
    for fzf_comp in /usr/share/fzf/completion.zsh /usr/share/doc/fzf/examples/completion.zsh; do
        if [[ -f "$fzf_comp" ]]; then
            source "$fzf_comp"
            break
        fi
    done
fi

# Zsh autosuggestions (use distro package if present, or manual clone)
for suggest in /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
               /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
               "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
               "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
    if [[ -f "$suggest" ]]; then
        source "$suggest"
        break
    fi
done

# 5. Starship Prompt Integration
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
else
    # Simple fallback prompt if starship is missing
    PROMPT='%F{magenta}%n@%m%f:%F{cyan}%~%f%# '
fi

# 6. Fastfetch on Interactive Startup
# Config switch: set ENABLE_FASTFETCH=false in ~/.zshrc.local to disable
ENABLE_FASTFETCH=${ENABLE_FASTFETCH:-true}

if [[ -o interactive ]] && [[ "$ENABLE_FASTFETCH" == "true" ]]; then
    if command -v fastfetch >/dev/null 2>&1; then
        fastfetch
    fi
fi

# 7. Local Customization Override (untouched by OMEN updates)
if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

