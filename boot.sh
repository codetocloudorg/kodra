#!/usr/bin/env bash
#
# Kodra Bootstrap Script
# A Code To Cloud Project ☁️
# https://kodra.codetocloud.io
#
# Usage: 
#   wget -qO- https://kodra.codetocloud.io/boot.sh | bash
#   curl -fsSL https://kodra.codetocloud.io/boot.sh | bash
#
# Options:
#   --install    Skip menu, go straight to install
#   --uninstall  Skip menu, go straight to uninstall
#   --update     Skip menu, go straight to update
#

set -e

# Parse arguments
KODRA_ACTION=""
for arg in "$@"; do
    case $arg in
        --install|-i)
            KODRA_ACTION="install"
            shift
            ;;
        --uninstall|--remove|-u)
            KODRA_ACTION="uninstall"
            shift
            ;;
        --update|-U)
            KODRA_ACTION="update"
            shift
            ;;
    esac
done

KODRA_REPO="https://github.com/codetocloudorg/kodra.git"
KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Colors
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_PURPLE='\033[0;35m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'
C_GRAY='\033[0;90m'

# Clear screen for clean start
clear 2>/dev/null || true

# Animated gradient banner
echo ""
echo -e "\033[38;5;196m    ██╗  ██╗ ██████╗ ██████╗ ██████╗  █████╗ \033[0m"
echo -e "\033[38;5;202m    ██║ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗\033[0m"
echo -e "\033[38;5;208m    █████╔╝ ██║   ██║██║  ██║██████╔╝███████║\033[0m"
echo -e "\033[38;5;214m    ██╔═██╗ ██║   ██║██║  ██║██╔══██╗██╔══██║\033[0m"
echo -e "\033[38;5;220m    ██║  ██╗╚██████╔╝██████╔╝██║  ██║██║  ██║\033[0m"
echo -e "\033[38;5;226m    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝\033[0m"
echo ""
echo -e "\033[38;5;51m    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[38;5;147m        ☁️  F R O M   C O D E   T O   C L O U D  ☁️\033[0m"
echo -e "\033[38;5;51m    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo -e "    ${C_GRAY}Agentic cloud-native engineering for Azure${C_RESET}"
echo -e "    ${C_GRAY}Azure • Kubernetes • Containers • IaC${C_RESET}"
echo ""

# Helper functions
show_step() {
    echo -e "    ${C_CYAN}▶${C_RESET} $1"
}

show_done() {
    echo -e "    ${C_GREEN}✔${C_RESET} $1"
}

show_warn() {
    echo -e "    ${C_YELLOW}⚠${C_RESET} $1"
}

# Check for Ubuntu 24.04+
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        show_warn "Kodra is designed for Ubuntu. Your OS: $ID"
        read -p "    Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        show_done "Ubuntu detected: $VERSION_ID"
    fi
    
    VERSION_NUM=$(echo "$VERSION_ID" | cut -d. -f1)
    if [ "$VERSION_NUM" -lt 24 ]; then
        show_warn "Kodra requires Ubuntu 24.04+. Your version: $VERSION_ID"
        read -p "    Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi
echo ""

# Check for required tools
show_step "Checking prerequisites..."
for cmd in git curl; do
    if ! command -v $cmd &> /dev/null; then
        show_step "Installing $cmd..."
        sudo apt-get update
        sudo apt-get install -y $cmd
    fi
done
show_done "Prerequisites ready"

# Clone or update repository
echo ""
if [ -d "$KODRA_DIR" ]; then
    show_step "Updating existing Kodra installation..."
    cd "$KODRA_DIR"
    echo -e "    ${C_GRAY}Fetching latest changes from GitHub...${C_RESET}"
    git pull --progress < /dev/null
    show_done "Repository updated"
    KODRA_EXISTS=true
else
    show_step "Downloading Kodra from GitHub..."
    echo -e "    ${C_GRAY}This may take a moment on slower connections...${C_RESET}"
    git clone --progress "$KODRA_REPO" "$KODRA_DIR" < /dev/null 2>&1
    show_done "Repository cloned to $KODRA_DIR"
    KODRA_EXISTS=false
fi

# Action menu
cd "$KODRA_DIR"

# Reconnect stdin to terminal for interactive prompts (wget pipe consumes stdin)
if [ ! -t 0 ] && ( exec < /dev/tty ) 2>/dev/null; then
    exec < /dev/tty
fi

# If action was specified via command line, skip menu
if [ -n "$KODRA_ACTION" ]; then
    case "$KODRA_ACTION" in
        install)
            echo -e "    ${C_PURPLE}Starting installation...${C_RESET}"
            echo ""
            bash ./install.sh "$@"
            ;;
        uninstall)
            echo -e "    ${C_YELLOW}Preparing to uninstall...${C_RESET}"
            echo ""
            bash ./uninstall.sh
            ;;
        update)
            echo -e "    ${C_CYAN}Updating Kodra...${C_RESET}"
            echo ""
            bash ./bin/kodra update
            ;;
    esac
    exit 0
fi

echo ""
echo -e "    ${C_WHITE}What would you like to do?${C_RESET}"
echo ""

# Install gum for beautiful menus if not already installed
if ! command -v gum &> /dev/null; then
    show_step "Installing gum for beautiful menus..."
    echo -e "    ${C_GRAY}Setting up Charm repository...${C_RESET}"
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
    echo -e "    ${C_GRAY}Updating package lists...${C_RESET}"
    sudo apt-get update
    echo -e "    ${C_GRAY}Installing gum...${C_RESET}"
    sudo apt-get install -y gum
    show_done "gum installed"
fi

# Show menu based on installation status
if [ "$KODRA_EXISTS" = true ]; then
    # Kodra already installed - show full menu
    CHOICE=$(gum choose --height=8 --cursor.foreground="51" \
        "🚀 Fresh Install    (reinstall everything)" \
        "🔄 Update           (update Kodra & tools)" \
        "🎨 Change Theme     (switch themes)" \
        "🗑️  Uninstall        (remove Kodra)" \
        "❌ Exit")
else
    # Fresh install
    CHOICE=$(gum choose --height=5 --cursor.foreground="51" \
        "🚀 Install Kodra    (full installation)" \
        "❌ Exit")
fi

echo ""

case "$CHOICE" in
    *"Fresh Install"*|*"Install Kodra"*)
        echo -e "    ${C_PURPLE}Starting installation...${C_RESET}"
        echo ""
        sleep 1
        bash ./install.sh "$@"
        ;;
    *"Update"*)
        echo -e "    ${C_CYAN}Updating Kodra...${C_RESET}"
        echo ""
        bash ./bin/kodra update
        ;;
    *"Change Theme"*)
        bash ./bin/kodra theme
        ;;
    *"Uninstall"*)
        echo -e "    ${C_YELLOW}Preparing to uninstall...${C_RESET}"
        echo ""
        bash ./uninstall.sh
        ;;
    *"Exit"*|*)
        echo -e "    ${C_GRAY}Goodbye! Run again anytime.${C_RESET}"
        exit 0
        ;;
esac
