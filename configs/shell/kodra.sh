#!/usr/bin/env bash
#
# Kodra Shell Integration
# Beautiful MOTD and shell enhancements
#

# Only show once per session
if [ -z "$KODRA_MOTD_SHOWN" ]; then
    export KODRA_MOTD_SHOWN=1
    
    # Quick system info (non-intrusive)
    KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
    
    # Colors
    C='\033[0;36m'
    M='\033[0;35m'
    G='\033[0;32m'
    Y='\033[0;33m'
    W='\033[0;37m'
    NC='\033[0m'
    
    # Get theme
    THEME="tokyo-night"
    [ -f "$HOME/.config/kodra/theme" ] && THEME=$(cat "$HOME/.config/kodra/theme")
    
    # One-liner with tips
    TIPS=(
        "Try ${M}kodra fetch${NC} for system info"
        "Use ${M}Ctrl+R${NC} to search command history with fzf"
        "Run ${M}kodra theme${NC} to switch themes"
        "${M}lazygit${NC} for beautiful git interface"
        "${M}bat${NC} is like cat, but better"
        "${M}eza -la${NC} for beautiful file listings"
        "Use ${M}z${NC} to jump to recent directories"
        "${M}gh copilot suggest${NC} for AI help"
        "${M}k9s${NC} for Kubernetes cluster UI"
        "${M}kgp${NC} = kubectl get pods"
        "${M}h${NC} = helm (use ${M}hs${NC} to search)"
        "${M}kl pod-name${NC} = kubectl logs"
        "${M}pwsh${NC} for PowerShell 7 with completions"
    )
    
    # Pick random tip
    TIP="${TIPS[$RANDOM % ${#TIPS[@]}]}"
    
    echo ""
    echo -e "  ${C}☁️  Kodra${NC} ${W}|${NC} Theme: ${M}$THEME${NC} ${W}|${NC} ${G}Tip:${NC} $TIP"
    echo ""
fi

# Aliases (modern replacements)
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons -L 2'
alias cat='bat --style=auto'
alias grep='rg'
alias find='fd'
alias du='dust'
alias df='duf'
alias top='btop'
alias vim='nvim'
alias vi='nvim'
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline -10'
alias gco='git checkout'
alias lg='lazygit'
alias ld='lazydocker'
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kdp='kubectl describe pod'
alias kds='kubectl describe svc'
alias kdd='kubectl describe deployment'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias ke='kubectl exec -it'
alias kpf='kubectl port-forward'
alias kctx='kubectl config get-contexts'
alias kuse='kubectl config use-context'
alias h='helm'
alias hl='helm list'
alias hi='helm install'
alias hu='helm upgrade'
alias hr='helm repo'
alias hs='helm search repo'
alias tf='terraform'
alias azl='az login'
alias dc='docker compose'

# Azure shortcuts
alias azup='az upgrade'
alias azdeploy='azd up'
alias azinit='azd init'
alias posh='pwsh'

# Development shortcuts
alias serve='python3 -m http.server'
alias ports='lsof -i -P -n | grep LISTEN'
alias myip='curl -s ifconfig.me'
alias weather='curl -s wttr.in/?format=3'
alias cheat='curl -s cheat.sh/'

# Kodra commands
alias ktheme='kodra theme'
alias kfetch='kodra fetch'
alias kdesktop='kodra desktop'
alias kdoc='kodra doctor'

# Quick edit configs
alias zshrc='${EDITOR:-nvim} ~/.zshrc'
alias gitconfig='${EDITOR:-nvim} ~/.gitconfig'
alias ghosttyconf='${EDITOR:-nvim} ~/.config/ghostty/config'

# Safe delete - moves to trash instead
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

# ─────────────────────────────────────────────────────────────
# Helper Functions
# ─────────────────────────────────────────────────────────────

# Create a web app desktop launcher
web2app() {
    local url="$1"
    local name="$2"
    local icon="${3:-utilities-terminal}"
    
    if [ -z "$url" ] || [ -z "$name" ]; then
        echo "Usage: web2app <url> <name> [icon]"
        echo "Example: web2app https://grafana.mycompany.io Grafana web-browser"
        return 1
    fi
    
    local safe_name=$(echo "$name" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    local desktop_file="$HOME/.local/share/applications/${safe_name}-webapp.desktop"
    
    mkdir -p "$HOME/.local/share/applications"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Name=$name
Exec=xdg-open $url
Icon=$icon
Type=Application
Categories=Network;WebApps;
StartupNotify=true
EOF
    
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    echo "Created: $desktop_file"
    echo "  $name is now available in your app launcher!"
}

# Quick extract - handles most archive types
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <archive>"
        return 1
    fi
    
    if [ ! -f "$1" ]; then
        echo "'$1' is not a valid file"
        return 1
    fi
    
    case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.tar.xz)    tar xJf "$1"     ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *.rar)       unrar x "$1"     ;;
        *)           echo "'$1' cannot be extracted" ; return 1 ;;
    esac
}

# Quick compress a folder
compress() {
    if [ -z "$1" ]; then
        echo "Usage: compress <folder> [output.tar.gz]"
        return 1
    fi
    
    local output="${2:-$(basename "$1").tar.gz}"
    tar -czf "$output" "$1"
    echo "Created: $output"
}

# Clone and cd into a repo
gclone() {
    if [ -z "$1" ]; then
        echo "Usage: gclone <repo-url>"
        return 1
    fi
    
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Create a new project from Azure template
aztemplate() {
    if [ -z "$1" ]; then
        echo "Usage: aztemplate <template-name> [project-name]"
        echo ""
        echo "Popular templates:"
        echo "  todo-nodejs-mongo    Full-stack Node.js with Cosmos DB"
        echo "  todo-python-mongo    Full-stack Python with Cosmos DB"
        echo "  todo-csharp-cosmos   ASP.NET Core with Cosmos DB"
        echo "  react-web            React SPA with Static Web Apps"
        echo "  aks-helm             Kubernetes app with AKS"
        echo ""
        echo "Browse: azd template list"
        return 0
    fi
    
    local template="$1"
    local name="${2:-$(basename "$template")}"
    
    mkdir -p "$name"
    cd "$name"
    azd init --template "$template"
}

# Quick kubectl port-forward with nice output
kpod() {
    local pod="$1"
    local ports="${2:-8080:8080}"
    
    if [ -z "$pod" ]; then
        echo "Usage: kpod <pod-name> [local:remote]"
        echo "       kpod my-app 8080:80"
        return 1
    fi
    
    echo "Forwarding $ports to $pod..."
    echo "Access at: http://localhost:${ports%%:*}"
    kubectl port-forward "$pod" "$ports"
}

# Search running containers
dps() {
    if [ -z "$1" ]; then
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | head -20
    else
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -i "$1"
    fi
}

# ─────────────────────────────────────────────────────────────
# Completions (auto-loaded)
# ─────────────────────────────────────────────────────────────

# Add Kodra completions to fpath (zsh)
if [ -n "$ZSH_VERSION" ]; then
    [ -d ~/.config/zsh/completions ] && fpath=(~/.config/zsh/completions $fpath)
    autoload -Uz compinit && compinit -C
fi

# Source bash completions
if [ -n "$BASH_VERSION" ]; then
    for f in ~/.local/share/bash-completion/completions/*; do
        [ -f "$f" ] && source "$f"
    done
fi

# kubectl alias completion
if command -v kubectl &>/dev/null; then
    complete -o default -F __start_kubectl k 2>/dev/null || true
fi

# helm alias completion  
if command -v helm &>/dev/null; then
    complete -o default -F __start_helm h 2>/dev/null || true
fi
