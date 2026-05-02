#!/usr/bin/env bash
#
# Kodra Fetch - Beautiful system info for developers
# Uses fastfetch with custom config, or falls back to built-in display
#

# ─────────────────────────────────────────────────────────────
# Use fastfetch if available with kodra config
# ─────────────────────────────────────────────────────────────

if command -v fastfetch &>/dev/null; then
    # Check if we have our custom config
    if [ -f "$HOME/.config/fastfetch/config.jsonc" ]; then
        exec fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
    else
        exec fastfetch
    fi
fi

# ─────────────────────────────────────────────────────────────
# Fallback: Built-in display (when fastfetch not installed)
# ─────────────────────────────────────────────────────────────

# Colors (regular and bold variants for the ASCII art logo)
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
B='\033[0;34m'
M='\033[0;35m'
C='\033[0;36m'
W='\033[0;37m'
BR='\033[1;31m'  # Bold Red
BG='\033[1;32m'  # Bold Green
BY='\033[1;33m'  # Bold Yellow
BB='\033[1;34m'  # Bold Blue
BM='\033[1;35m'  # Bold Magenta
BC='\033[1;36m'  # Bold Cyan
BW='\033[1;37m'  # Bold White
NC='\033[0m'     # Reset

# ── System info gathering functions ──

# Read OS pretty name from os-release, falling back to uname
get_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    else
        uname -s
    fi
}

# Get kernel release string
get_kernel() {
    uname -r
}

# Get human-readable uptime (e.g., "2 hours, 15 minutes")
get_uptime() {
    uptime -p 2>/dev/null | sed 's/up //' || uptime | awk -F'( |,|:)+' '{print $6"h "$7"m"}'
}

# Get the user's default shell name
get_shell() {
    basename "$SHELL"
}

# Detect terminal emulator from environment variables
get_terminal() {
    if [ -n "$TERM_PROGRAM" ]; then
        echo "$TERM_PROGRAM"
    elif [ -n "$TERMINAL" ]; then
        echo "$TERMINAL"
    else
        echo "${TERM:-unknown}"
    fi
}

# Detect the primary code editor available on the system
get_editor() {
    if command -v code &>/dev/null; then
        echo "VS Code"
    elif command -v nvim &>/dev/null; then
        echo "Neovim"
    elif command -v vim &>/dev/null; then
        echo "Vim"
    else
        echo "${EDITOR:-nano}"
    fi
}

# Read the active Kodra theme name, defaulting to tokyo-night
get_theme() {
    KODRA_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
    if [ -f "$KODRA_CONFIG/theme" ]; then
        cat "$KODRA_CONFIG/theme"
    else
        echo "tokyo-night"
    fi
}

# Build a space-separated list of detected cloud/DevOps CLIs
get_cloud_tools() {
    tools=""
    command -v az &>/dev/null && tools="${tools}Azure "
    command -v terraform &>/dev/null && tools="${tools}Terraform "
    command -v docker &>/dev/null && tools="${tools}Docker "
    command -v kubectl &>/dev/null && tools="${tools}K8s "
    command -v k9s &>/dev/null && tools="${tools}k9s "
    command -v helm &>/dev/null && tools="${tools}Helm "
    command -v pwsh &>/dev/null && tools="${tools}pwsh "
    echo "${tools:-None}"
}

# Get the global Git user name
get_git_user() {
    git config --global user.name 2>/dev/null || echo "Not configured"
}

# Get Node.js version (strips leading 'v')
get_node_version() {
    node --version 2>/dev/null | tr -d 'v' || echo "-"
}

# Get Python 3 version number
get_python_version() {
    python3 --version 2>/dev/null | cut -d' ' -f2 || echo "-"
}

# Get Go version (strips "go" prefix)
get_go_version() {
    go version 2>/dev/null | awk '{print $3}' | tr -d 'go' || echo "-"
}

# ── Collect info and render the Kodra ASCII logo with system details ──
USER_NAME=$(whoami)
HOST_NAME=$(hostname -s 2>/dev/null || hostname)
OS=$(get_os)
KERNEL=$(get_kernel)
UPTIME=$(get_uptime)
SHELL_NAME=$(get_shell)
TERMINAL=$(get_terminal)
EDITOR=$(get_editor)
THEME=$(get_theme)
CLOUD=$(get_cloud_tools)
GIT_USER=$(get_git_user)
NODE_V=$(get_node_version)
PYTHON_V=$(get_python_version)
GO_V=$(get_go_version)

# Print the KODRA banner alongside system info, followed by a color palette
echo ""
echo -e "${BR}    ██╗  ██╗${BY} ██████╗ ${BG}██████╗ ${BC}██████╗ ${BM} █████╗ ${NC}   ${BW}${USER_NAME}${NC}@${BC}${HOST_NAME}${NC}"
echo -e "${BR}    ██║ ██╔╝${BY}██╔═══██╗${BG}██╔══██╗${BC}██╔══██╗${BM}██╔══██╗${NC}   ${W}──────────────────${NC}"
echo -e "${BR}    █████╔╝ ${BY}██║   ██║${BG}██║  ██║${BC}██████╔╝${BM}███████║${NC}   ${BR}OS${NC}        ${W}$OS${NC}"
echo -e "${BR}    ██╔═██╗ ${BY}██║   ██║${BG}██║  ██║${BC}██╔══██╗${BM}██╔══██║${NC}   ${BY}Kernel${NC}    ${W}$KERNEL${NC}"
echo -e "${BR}    ██║  ██╗${BY}╚██████╔╝${BG}██████╔╝${BC}██║  ██║${BM}██║  ██║${NC}   ${BG}Uptime${NC}    ${W}$UPTIME${NC}"
echo -e "${BR}    ╚═╝  ╚═╝${BY} ╚═════╝ ${BG}╚═════╝ ${BC}╚═╝  ╚═╝${BM}╚═╝  ╚═╝${NC}   ${BC}Shell${NC}     ${W}$SHELL_NAME${NC}"
echo -e "                                              ${BM}Terminal${NC}  ${W}$TERMINAL${NC}"
echo -e "   ${C}━━━ F R O M   C O D E   T O   C L O U D ━━━${NC}   ${BR}Editor${NC}    ${W}$EDITOR${NC}"
echo -e "                                              ${BY}Theme${NC}     ${W}$THEME${NC}"
echo -e "   ${W}Git${NC}       ${M}$GIT_USER${NC}"
echo -e "   ${W}Cloud${NC}     ${C}$CLOUD${NC}"
echo -e "   ${W}Node${NC}      ${G}$NODE_V${NC}  ${W}Python${NC}  ${B}$PYTHON_V${NC}  ${W}Go${NC}  ${C}$GO_V${NC}"
echo ""
echo -e "   ${BR}●${BY}●${BG}●${BC}●${BM}●${BB}●${NC}  ${R}●${Y}●${G}●${C}●${B}●${M}●${NC}"
echo ""
