#!/usr/bin/env bash
#
# Kodra Shell Integration
# Sourced into interactive bash/zsh sessions on every shell start.
# Provides the MOTD banner, aliases for cloud-native tools, FZF
# configuration, helper functions, and shell completions.
#
# NOTE: set -e is intentionally omitted — this file is sourced into
# interactive shells where set -e would cause the session to exit on
# any command failure (e.g., a typo or failed alias).
#

# Load enhanced readline config (tab-cycle completion)
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.inputrc" ]; then
    bind -f "$HOME/.inputrc" 2>/dev/null || true
fi

# Ensure XDG_DATA_DIRS includes Flatpak paths for app launcher discovery
# This must be set on every shell start for GNOME to find Flatpak apps
if [[ ! "$XDG_DATA_DIRS" =~ "flatpak" ]]; then
    export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
fi

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

# Create a .desktop launcher to open a URL as a standalone web app
# Arguments: $1 - URL, $2 - app name, $3 - icon name (default: utilities-terminal)
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

# Universal archive extractor — detects format from extension
# Supports: tar.gz, tar.bz2, tar.xz, zip, gz, bz2, 7z, rar
# Arguments: $1 - archive file path
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

# Create a tar.gz archive of a folder
# Arguments: $1 - folder, $2 - output filename (default: <folder>.tar.gz)
compress() {
    if [ -z "$1" ]; then
        echo "Usage: compress <folder> [output.tar.gz]"
        return 1
    fi
    
    local output="${2:-$(basename "$1").tar.gz}"
    tar -czf "$output" "$1"
    echo "Created: $output"
}

# Clone a git repo and cd into the resulting directory
# Arguments: $1 - repo URL
gclone() {
    if [ -z "$1" ]; then
        echo "Usage: gclone <repo-url>"
        return 1
    fi
    
    git clone "$1" && cd "$(basename "$1" .git)"
}

# Scaffold a new project from an Azure Developer CLI template
# Arguments: $1 - template name, $2 - optional project directory name
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

# kubectl port-forward with friendly output
# Arguments: $1 - pod name, $2 - port mapping (default: 8080:8080)
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

# List or search running Docker containers in a compact table
# Arguments: $1 - optional search filter
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

# Fuzzy directory jump using zoxide history and fzf
zz() {
    local result
    result=$(zoxide query -l | fzf --no-sort --tac) && cd "$result"
}

# Fuzzy checkout a git branch (local or remote) via fzf
fco() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Fuzzy process kill — select processes via fzf, then send signal
# Arguments: $1 - signal number (default: 9/SIGKILL)
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
        echo "$pid" | xargs kill -${1:-9}
    fi
}

# Fuzzy select a running Docker container and exec into it
# Arguments: $1 - optional container filter, $2 - shell (default: bash)
dsh() {
    local cid
    cid=$(docker ps | sed 1d | fzf -1 -q "$1" | awk '{print $1}')
    [ -n "$cid" ] && docker exec -it "$cid" ${2:-bash}
}

# Fuzzy find and open a file in the editor
fe() {
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always --line-range :300 {}')
    [ -n "$file" ] && ${EDITOR:-nvim} "$file"
}

# Interactive git log browser with fzf (Ctrl+M to view a commit)
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
# Extended Shell Helpers (v0.4.0)
# ─────────────────────────────────────────────────────────────

# Tmux: attach or new session
alias t='tmux attach 2>/dev/null || tmux new-session'

# Open a file or URL with the default system handler (silent, backgrounded)
open() {
    if [ -z "$1" ]; then
        echo "Usage: open <file|url>"
        return 1
    fi
    nohup xdg-open "$@" &>/dev/null &
}

# Smart nvim opener — directories open the file explorer, files open directly
n() {
    local target="${1:-.}"
    if [ -d "$target" ]; then
        (cd "$target" && nvim .)
    else
        nvim "$target"
    fi
}

# Enhanced directory jump — fzf over zoxide history with tree preview
zd() {
    local dir
    dir=$(zoxide query -l 2>/dev/null | fzf --height 40% --reverse --preview 'eza --tree --level=1 --icons {}' --preview-window=right:50%)
    if [ -n "$dir" ]; then
        cd "$dir" && eza --icons
    fi
}

# ─────────────────────────────────────────────────────────────
# SSH Port Forwarding Helpers
# ─────────────────────────────────────────────────────────────

# Forward a local port to a remote host through an SSH tunnel
# Arguments: $1 - local port, $2 - remote host, $3 - remote port, $4 - SSH host
fip() {
    local local_port="${1:-8080}"
    local remote_host="${2:-localhost}"
    local remote_port="${3:-$local_port}"
    local ssh_host="${4:-}"
    
    if [ -z "$ssh_host" ]; then
        echo "Usage: fip <local_port> <remote_host> <remote_port> <ssh_host>"
        echo "Example: fip 8080 localhost 80 user@server"
        return 1
    fi
    
    echo "Forwarding localhost:$local_port -> $remote_host:$remote_port via $ssh_host"
    echo "Press Ctrl+C to stop"
    ssh -N -L "$local_port:$remote_host:$remote_port" "$ssh_host"
}

# Start a SOCKS5 proxy via SSH (useful for tunneling browser traffic)
# Arguments: $1 - local port (default: 1080), $2 - SSH host
dip() {
    local port="${1:-1080}"
    local ssh_host="${2:-}"
    
    # If only one arg, treat it as ssh_host
    if [ -z "$ssh_host" ]; then
        ssh_host="$port"
        port="1080"
    fi
    
    if [ -z "$ssh_host" ]; then
        echo "Usage: dip [port] <ssh_host>"
        echo "Example: dip 1080 user@server"
        echo "Then: configure browser SOCKS5 proxy to localhost:1080"
        return 1
    fi
    
    echo "Starting SOCKS5 proxy on localhost:$port via $ssh_host"
    echo "Configure your browser SOCKS5 proxy to localhost:$port"
    echo "Press Ctrl+C to stop"
    ssh -N -D "$port" "$ssh_host"
}

# List active SSH tunnels and commonly-forwarded dev ports
lip() {
    echo "Active SSH tunnels:"
    ps aux | grep 'ssh -[NL]' | grep -v grep | awk '{print $2, $11, $12, $13}'
    echo ""
    echo "Listening ports:"
    ss -tlnp 2>/dev/null | grep -E ':(8080|1080|3000|5000|9090)' || echo "  No common dev ports forwarded"
}

# ─────────────────────────────────────────────────────────────
# Media Transcoding Helpers
# ─────────────────────────────────────────────────────────────

# Convert images to JPEG using ImageMagick
# Arguments: $@ - image files to convert
img2jpg() {
    if ! command -v convert &>/dev/null; then
        echo "ImageMagick required. Install with: sudo apt install imagemagick"
        return 1
    fi
    for img in "$@"; do
        local out="${img%.*}.jpg"
        convert "$img" -quality 90 "$out" && echo "Converted: $out"
    done
}

# Convert images to PNG using ImageMagick
# Arguments: $@ - image files to convert
img2png() {
    if ! command -v convert &>/dev/null; then
        echo "ImageMagick required. Install with: sudo apt install imagemagick"
        return 1
    fi
    for img in "$@"; do
        local out="${img%.*}.png"
        convert "$img" "$out" && echo "Converted: $out"
    done
}

# Convert images to WebP format using cwebp
# Arguments: $@ - image files to convert
img2webp() {
    if ! command -v cwebp &>/dev/null; then
        echo "WebP tools required. Install with: sudo apt install webp"
        return 1
    fi
    for img in "$@"; do
        local out="${img%.*}.webp"
        cwebp -q 85 "$img" -o "$out" && echo "Converted: $out"
    done
}

# Transcode a video to 1080p H.264 using ffmpeg
# Arguments: $1 - input file, $2 - output file (default: <input>_1080p.mp4)
transcode-video-1080p() {
    if ! command -v ffmpeg &>/dev/null; then
        echo "FFmpeg required. Install with: sudo apt install ffmpeg"
        return 1
    fi
    local input="$1"
    local output="${2:-${input%.*}_1080p.mp4}"
    echo "Transcoding $input to 1080p..."
    ffmpeg -i "$input" -vf "scale=-1:1080" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "$output"
}

# Transcode a video to 720p H.264 using ffmpeg
# Arguments: $1 - input file, $2 - output file (default: <input>_720p.mp4)
transcode-video-720p() {
    if ! command -v ffmpeg &>/dev/null; then
        echo "FFmpeg required. Install with: sudo apt install ffmpeg"
        return 1
    fi
    local input="$1"
    local output="${2:-${input%.*}_720p.mp4}"
    echo "Transcoding $input to 720p..."
    ffmpeg -i "$input" -vf "scale=-1:720" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k "$output"
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

# ─────────────────────────────────────────────────────────────
# Tmux Dev Layouts (#42)
# ─────────────────────────────────────────────────────────────

# Pre-built tmux layouts for common development workflows
# Arguments: $1 - layout name (web|api|k8s), $2 - session name (default: dev)
tml() {
    local layout="${1:-web}"
    local session="${2:-dev}"
    
    if ! command -v tmux &>/dev/null; then
        echo "tmux required. Install with: brew install tmux"
        return 1
    fi
    
    case "$layout" in
        web)
            # 3-pane layout: large editor, small server & shell
            tmux new-session -d -s "$session" -n main
            tmux send-keys -t "$session:main" "nvim ." Enter
            tmux split-window -t "$session:main" -h -l 40%
            tmux split-window -t "$session:main.2" -v -l 30%
            tmux select-pane -t "$session:main.1"
            tmux attach -t "$session"
            ;;
        api)
            # 4-pane layout for API dev: editor, logs, tests, shell
            tmux new-session -d -s "$session" -n main
            tmux send-keys -t "$session:main" "nvim ." Enter
            tmux split-window -t "$session:main" -h -l 45%
            tmux split-window -t "$session:main.2" -v -l 50%
            tmux split-window -t "$session:main.2" -v -l 50%
            tmux select-pane -t "$session:main.1"
            tmux attach -t "$session"
            ;;
        k8s)
            # Kubernetes: editor, k9s, logs
            tmux new-session -d -s "$session" -n main
            tmux send-keys -t "$session:main" "nvim ." Enter
            tmux split-window -t "$session:main" -h -l 50%
            tmux send-keys -t "$session:main.2" "k9s" Enter
            tmux select-pane -t "$session:main.1"
            tmux attach -t "$session"
            ;;
        *)
            echo "Usage: tml <layout> [session-name]"
            echo ""
            echo "Layouts:"
            echo "  web    Editor + server + shell (default)"
            echo "  api    Editor + logs + tests + shell"
            echo "  k8s    Editor + k9s"
            echo ""
            echo "Example: tml web myproject"
            ;;
    esac
}

# Create or attach to a tmux session named after the current directory
nic() {
    local session_name=$(basename "$PWD" | tr '.' '-' | tr ' ' '-')
    
    if ! command -v tmux &>/dev/null; then
        echo "tmux required. Install with: brew install tmux"
        return 1
    fi
    
    # Check if session exists
    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux attach -t "$session_name"
    else
        tmux new-session -s "$session_name"
    fi
}

# Like nic but creates a web dev layout if the session is new
nicx() {
    local session_name=$(basename "$PWD" | tr '.' '-' | tr ' ' '-')
    
    if ! command -v tmux &>/dev/null; then
        echo "tmux required. Install with: brew install tmux"
        return 1
    fi
    
    # Check if session exists
    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux attach -t "$session_name"
    else
        tml web "$session_name"
    fi
}
