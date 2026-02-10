#!/usr/bin/env bash
#
# Kodra Shell Integration
# Beautiful MOTD and shell enhancements
#

# Only show once per session
if [ -z "$KODRA_MOTD_SHOWN" ]; then
    export KODRA_MOTD_SHOWN=1
    
    KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
    KODRA_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
    
    # Colors
    C='\033[0;36m'
    M='\033[0;35m'
    G='\033[0;32m'
    Y='\033[0;33m'
    W='\033[0;37m'
    BR='\033[1;31m'
    BY='\033[1;33m'
    BG='\033[1;32m'
    BC='\033[1;36m'
    BM='\033[1;35m'
    BW='\033[1;37m'
    NC='\033[0m'
    
    # Get theme
    THEME="tokyo-night"
    [ -f "$KODRA_CONFIG/theme" ] && THEME=$(cat "$KODRA_CONFIG/theme")
    
    # Check MOTD style preference (banner, minimal, or none)
    MOTD_STYLE="banner"
    [ -f "$KODRA_CONFIG/motd" ] && MOTD_STYLE=$(cat "$KODRA_CONFIG/motd")
    
    # Tips for the day
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
    TIP="${TIPS[$RANDOM % ${#TIPS[@]}]}"
    
    case "$MOTD_STYLE" in
        banner)
            # Full ASCII art banner
            echo ""
            echo -e "${BR}    ██╗  ██╗${BY} ██████╗ ${BG}██████╗ ${BC}██████╗ ${BM} █████╗ ${NC}"
            echo -e "${BR}    ██║ ██╔╝${BY}██╔═══██╗${BG}██╔══██╗${BC}██╔══██╗${BM}██╔══██╗${NC}"
            echo -e "${BR}    █████╔╝ ${BY}██║   ██║${BG}██║  ██║${BC}██████╔╝${BM}███████║${NC}"
            echo -e "${BR}    ██╔═██╗ ${BY}██║   ██║${BG}██║  ██║${BC}██╔══██╗${BM}██╔══██║${NC}"
            echo -e "${BR}    ██║  ██╗${BY}╚██████╔╝${BG}██████╔╝${BC}██║  ██║${BM}██║  ██║${NC}"
            echo -e "${BR}    ╚═╝  ╚═╝${BY} ╚═════╝ ${BG}╚═════╝ ${BC}╚═╝  ╚═╝${BM}╚═╝  ╚═╝${NC}"
            echo ""
            echo -e "    ${C}━━━ F R O M   C O D E   T O   C L O U D ━━━${NC}"
            echo ""
            echo -e "    ${W}Theme:${NC} ${M}$THEME${NC}  ${W}|${NC}  ${G}Tip:${NC} $TIP"
            echo ""
            ;;
        minimal)
            # One-liner (original behavior)
            echo ""
            echo -e "  ${C}☁️  Kodra${NC} ${W}|${NC} Theme: ${M}$THEME${NC} ${W}|${NC} ${G}Tip:${NC} $TIP"
            echo ""
            ;;
        none)
            # No MOTD
            ;;
    esac
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
# Zoxide - Smart directory jumping
# ─────────────────────────────────────────────────────────────

if command -v zoxide &>/dev/null; then
    if [ -n "$ZSH_VERSION" ]; then
        eval "$(zoxide init zsh)"
    elif [ -n "$BASH_VERSION" ]; then
        eval "$(zoxide init bash)"
    fi
fi

# ─────────────────────────────────────────────────────────────
# FZF - Fuzzy finder enhancements
# ─────────────────────────────────────────────────────────────

if command -v fzf &>/dev/null; then
    # Tokyo Night colors for fzf
    export FZF_DEFAULT_OPTS="
        --color=fg:#c0caf5,bg:#1a1b26,hl:#ff9e64
        --color=fg+:#c0caf5,bg+:#292e42,hl+:#ff9e64
        --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7aa2f7
        --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
        --height=60%
        --layout=reverse
        --border=rounded
        --prompt='❯ '
        --pointer='▶'
        --marker='✓'
        --info=inline
    "

    # Use fd for faster file finding (if available)
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi

    # Preview with bat (if available)
    if command -v bat &>/dev/null; then
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :300 {}'"
    fi

    # Zsh keybindings
    if [ -n "$ZSH_VERSION" ]; then
        [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
        [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
        [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    fi

    # Bash keybindings
    if [ -n "$BASH_VERSION" ]; then
        [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
        [ -f ~/.fzf.bash ] && source ~/.fzf.bash
    fi
fi

# ─────────────────────────────────────────────────────────────
# Handy fzf functions
# ─────────────────────────────────────────────────────────────

# Fuzzy cd with zoxide
zz() {
    local result
    result=$(zoxide query -l | fzf --no-sort --tac) && cd "$result"
}

# Fuzzy git branch checkout
fco() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Fuzzy process kill
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
        echo "$pid" | xargs kill -${1:-9}
    fi
}

# Fuzzy docker container shell
dsh() {
    local cid
    cid=$(docker ps | sed 1d | fzf -1 -q "$1" | awk '{print $1}')
    [ -n "$cid" ] && docker exec -it "$cid" ${2:-bash}
}

# Fuzzy edit file in current directory
fe() {
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always --line-range :300 {}')
    [ -n "$file" ] && ${EDITOR:-nvim} "$file"
}

# Fuzzy git log browser
fgl() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
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
