#!/usr/bin/env bash
#
# Kodra Shell Aliases
# A Code To Cloud Project ☁️
#
# Organized into categories:
#   - Modern CLI replacements (bat, eza, fd — opt-in via KODRA_POSIX_ALIASES)
#   - Git shortcuts (g, gs, gp, etc.)
#   - Docker shortcuts (d, dc, dps, etc.)
#   - Azure & azd shortcuts
#   - GitHub Copilot CLI shortcuts
#   - Terraform / OpenTofu shortcuts
#   - Utility shortcuts (navigation, editors, quick info)
#   - Kodra command aliases
#
# Source this file in your .bashrc or .zshrc:
#   source ~/.kodra/configs/shell/aliases.sh
#
# To disable POSIX-overriding aliases (cat, ls):
#   export KODRA_POSIX_ALIASES=false
#
# To re-enable find→fd alias (disabled by default as it breaks scripts):
#   export KODRA_ALIAS_FIND=true

# Default: enable modern replacements in interactive shells
KODRA_POSIX_ALIASES="${KODRA_POSIX_ALIASES:-true}"
KODRA_ALIAS_FIND="${KODRA_ALIAS_FIND:-false}"

# ---------------------------------------------------------
# Modern CLI replacements (opt-in/out via KODRA_POSIX_ALIASES)
# ---------------------------------------------------------

if [ "$KODRA_POSIX_ALIASES" = "true" ]; then
    # Use bat instead of cat (with syntax highlighting)
    if command -v bat &>/dev/null; then
        alias cat='bat --paging=never'
        alias catp='bat'  # with pager
    fi

    # Use eza instead of ls (with icons)
    if command -v eza &>/dev/null; then
        alias ls='eza --icons --group-directories-first'
        alias ll='eza -l --icons --group-directories-first'
        alias la='eza -la --icons --group-directories-first'
        alias lt='eza --tree --icons --level=3'
        alias l='eza -l --icons --group-directories-first'
    fi
fi

# find→fd is OFF by default (breaks too many scripts)
if [ "$KODRA_ALIAS_FIND" = "true" ] && command -v fd &>/dev/null; then
    alias find='fd'
fi

# ---------------------------------------------------------
# Git shortcuts
# ---------------------------------------------------------

alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# Use lazygit if available
if command -v lazygit &>/dev/null; then
    alias lg='lazygit'
fi

# ---------------------------------------------------------
# Docker shortcuts
# ---------------------------------------------------------

alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'

# Use lazydocker if available
if command -v lazydocker &>/dev/null; then
    alias lzd='lazydocker'
fi

# ---------------------------------------------------------
# Azure shortcuts
# ---------------------------------------------------------

alias az-login='az login'
alias az-sub='az account show --query name -o tsv'
alias az-subs='az account list --query "[].{Name:name, ID:id, Default:isDefault}" -o table'
alias az-switch='az account set --subscription'

# Azure Developer CLI
alias azd-init='azd init'
alias azd-up='azd up'
alias azd-down='azd down'
alias azd-deploy='azd deploy'

# ---------------------------------------------------------
# GitHub Copilot CLI shortcuts
# ---------------------------------------------------------

if command -v copilot &>/dev/null; then
    alias '??'='copilot -p'
    alias 'explain'='copilot -p "Explain this command:"'
fi

# ---------------------------------------------------------
# Terraform / OpenTofu
# ---------------------------------------------------------

alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'

if command -v tofu &>/dev/null; then
    alias tofu-init='tofu init'
    alias tofu-plan='tofu plan'
    alias tofu-apply='tofu apply'
fi

# ---------------------------------------------------------
# Utility shortcuts
# ---------------------------------------------------------

alias c='clear'
alias h='history'
alias ports='ss -tulanp'
alias path='echo "${PATH//:/\\n}"'
alias now='date +"%Y-%m-%d %H:%M:%S"'

# Neovim
if command -v nvim &>/dev/null; then
    alias vim='nvim'
    alias vi='nvim'
    alias v='nvim'
fi

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Make a directory and cd into it in one step
# Usage: mkcd <directory>
mkcd() {
    [ -z "$1" ] && { echo "Usage: mkcd <directory>"; return 1; }
    mkdir -p "$1" && cd "$1"
}

# ---------------------------------------------------------
# Kodra
# ---------------------------------------------------------

alias kodra-theme='kodra theme'
alias kodra-update='kodra update'
alias kodra-doctor='kodra doctor'
