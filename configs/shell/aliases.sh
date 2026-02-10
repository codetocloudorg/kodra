# Kodra Shell Aliases
# A Code To Cloud Project ☁️
#
# Source this file in your .bashrc or .zshrc:
#   source ~/.kodra/configs/shell/aliases.sh

# ---------------------------------------------------------
# Modern CLI replacements
# ---------------------------------------------------------

# Use bat instead of cat (with syntax highlighting)
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias catp='bat'  # with pager
fi

# Use eza instead of ls (with icons)
if command -v eza &> /dev/null; then
    alias ls='eza --icons'
    alias ll='eza -l --icons'
    alias la='eza -la --icons'
    alias lt='eza --tree --icons'
    alias l='eza -l --icons'
fi

# Use fd instead of find
if command -v fd &> /dev/null; then
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
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# Use lazygit if available
if command -v lazygit &> /dev/null; then
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
if command -v lazydocker &> /dev/null; then
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

if command -v gh &> /dev/null && gh extension list 2>/dev/null | grep -q copilot; then
    alias '??'='gh copilot suggest -t shell'
    alias 'git?'='gh copilot suggest -t git'
    alias 'gh?'='gh copilot suggest -t gh'
    alias 'explain'='gh copilot explain'
fi

# ---------------------------------------------------------
# Terraform / OpenTofu
# ---------------------------------------------------------

alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'

# OpenTofu (drop-in replacement)
if command -v tofu &> /dev/null; then
    alias tofu-init='tofu init'
    alias tofu-plan='tofu plan'
    alias tofu-apply='tofu apply'
fi

# ---------------------------------------------------------
# Utility shortcuts
# ---------------------------------------------------------

alias c='clear'
alias h='history'
alias ports='netstat -tulanp'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'

# Neovim
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Make directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# ---------------------------------------------------------
# Kodra
# ---------------------------------------------------------

alias kodra-theme='kodra theme'
alias kodra-update='kodra update'
alias kodra-doctor='kodra doctor'
