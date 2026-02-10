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

# Colors
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
B='\033[0;34m'
M='\033[0;35m'
C='\033[0;36m'
W='\033[0;37m'
BR='\033[1;31m'
BG='\033[1;32m'
BY='\033[1;33m'
BB='\033[1;34m'
BM='\033[1;35m'
BC='\033[1;36m'
BW='\033[1;37m'
NC='\033[0m'

# Get system info
get_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$PRETTY_NAME"
    else
        uname -s
    fi
}

get_kernel() {
    uname -r
}

get_uptime() {
    uptime -p 2>/dev/null | sed 's/up //' || uptime | awk -F'( |,|:)+' '{print $6"h "$7"m"}'
}

get_shell() {
    basename "$SHELL"
}

get_terminal() {
    if [ -n "$TERM_PROGRAM" ]; then
        echo "$TERM_PROGRAM"
    elif [ -n "$TERMINAL" ]; then
        echo "$TERMINAL"
    else
        echo "${TERM:-unknown}"
    fi
}

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

get_theme() {
    KODRA_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
    if [ -f "$KODRA_CONFIG/theme" ]; then
        cat "$KODRA_CONFIG/theme"
    else
        echo "tokyo-night"
    fi
}

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

get_git_user() {
    git config --global user.name 2>/dev/null || echo "Not configured"
}

get_node_version() {
    node --version 2>/dev/null | tr -d 'v' || echo "-"
}

get_python_version() {
    python3 --version 2>/dev/null | cut -d' ' -f2 || echo "-"
}

get_go_version() {
    go version 2>/dev/null | awk '{print $3}' | tr -d 'go' || echo "-"
}

# Display
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

# Print with logo
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
