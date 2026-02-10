#!/usr/bin/env bash
#
# Kodra UI Functions
# Beautiful CLI using gum (https://github.com/charmbracelet/gum)
#

# Ensure TERM is set (needed for clear, tput, etc.)
export TERM="${TERM:-xterm-256color}"

# Installation progress tracking
export KODRA_TOTAL_STEPS=10
export KODRA_CURRENT_STEP=0
export KODRA_START_TIME=$(date +%s)

# Colors for visual appeal
C_CYAN='\033[38;5;51m'
C_PURPLE='\033[38;5;141m'
C_GREEN='\033[38;5;46m'
C_YELLOW='\033[38;5;226m'
C_BLUE='\033[38;5;33m'
C_GRAY='\033[38;5;245m'
C_WHITE='\033[38;5;255m'
C_RESET='\033[0m'

# Display the Kodra banner
show_banner() {
    # Get version from VERSION file
    local version="0.0.1"
    if [ -f "$KODRA_DIR/VERSION" ]; then
        version=$(cat "$KODRA_DIR/VERSION" | tr -d '\n')
    fi
    
    clear 2>/dev/null || true
    echo ""
    echo -e "\033[38;5;196m    ██╗  ██╗\033[38;5;208m ██████╗ \033[38;5;226m██████╗ \033[38;5;46m██████╗ \033[38;5;51m █████╗ \033[0m"
    echo -e "\033[38;5;196m    ██║ ██╔╝\033[38;5;208m██╔═══██╗\033[38;5;226m██╔══██╗\033[38;5;46m██╔══██╗\033[38;5;51m██╔══██╗\033[0m"
    echo -e "\033[38;5;196m    █████╔╝ \033[38;5;208m██║   ██║\033[38;5;226m██║  ██║\033[38;5;46m██████╔╝\033[38;5;51m███████║\033[0m"
    echo -e "\033[38;5;196m    ██╔═██╗ \033[38;5;208m██║   ██║\033[38;5;226m██║  ██║\033[38;5;46m██╔══██╗\033[38;5;51m██╔══██║\033[0m"
    echo -e "\033[38;5;196m    ██║  ██╗\033[38;5;208m╚██████╔╝\033[38;5;226m██████╔╝\033[38;5;46m██║  ██║\033[38;5;51m██║  ██║\033[0m"
    echo -e "\033[38;5;196m    ╚═╝  ╚═╝\033[38;5;208m ╚═════╝ \033[38;5;226m╚═════╝ \033[38;5;46m╚═╝  ╚═╝\033[38;5;51m╚═╝  ╚═╝\033[0m"
    echo -e "                                                    ${C_GRAY}v${version}${C_RESET}"
    echo -e "    ${C_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo -e "    ${C_PURPLE}          A  C O D E  T O  C L O U D  P R O J E C T${C_RESET}"
    echo -e "    ${C_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo ""
    echo -e "    ${C_CYAN}Agentic Azure engineering using cloud-native tools${C_RESET}"
    echo -e "    ${C_GRAY}kodra.codetocloud.io${C_RESET}"
    echo -e "    ${C_GRAY}Developed by Code To Cloud${C_RESET}"
    echo ""
    sleep 1
}

# Display progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r    ${C_GRAY}[${C_RESET}"
    printf "${C_GREEN}%${filled}s${C_RESET}" | tr ' ' '█'
    printf "${C_GRAY}%${empty}s${C_RESET}" | tr ' ' '░'
    printf "${C_GRAY}]${C_RESET} ${C_WHITE}%3d%%${C_RESET}" "$percent"
}

# Display a section header with step counter
section() {
    local title="$1"
    local emoji="${2:-🔧}"
    
    KODRA_CURRENT_STEP=$((KODRA_CURRENT_STEP + 1))
    
    echo ""
    echo ""
    echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo -e "${C_WHITE}  ${emoji}  ${title}${C_RESET}"
    echo -e "${C_GRAY}     Step ${KODRA_CURRENT_STEP} of ${KODRA_TOTAL_STEPS}${C_RESET}"
    echo -e "${C_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo ""
    
    show_progress $KODRA_CURRENT_STEP $KODRA_TOTAL_STEPS
    echo ""
    echo ""
}

# Install gum for interactive CLI
install_gum() {
    if command -v gum &> /dev/null; then
        return 0
    fi
    
    echo -e "    ${C_CYAN}►${C_RESET} Installing interactive CLI tools..."
    
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y gum > /dev/null 2>&1
    echo -e "    ${C_GREEN}✓${C_RESET} Interactive CLI ready"
}

# Show what's being installed
show_installing() {
    local name="$1"
    local desc="${2:-}"
    
    if [ -n "$desc" ]; then
        echo -e "    ${C_CYAN}►${C_RESET} ${C_WHITE}${name}${C_RESET} ${C_GRAY}— ${desc}${C_RESET}"
    else
        echo -e "    ${C_CYAN}►${C_RESET} ${C_WHITE}${name}${C_RESET}"
    fi
}

# Show installation success
show_installed() {
    local name="$1"
    echo -e "    ${C_GREEN}✓${C_RESET} ${name} installed"
}

# Show a tool group being installed
show_tools_group() {
    local tools="$1"
    echo -e "    ${C_GRAY}Installing: ${tools}${C_RESET}"
}

# Theme selection
select_theme() {
    if ! command -v gum &> /dev/null; then
        echo "tokyo-night"
        return
    fi
    
    echo "Select a theme for your Kodra installation:" >&2
    
    local theme=$(gum choose --height=6 --cursor.foreground="212" \
        "tokyo-night  | Purple-blue Tokyo city lights" \
        "ghostty-blue | Deep navy with electric cyan" | awk -F'|' '{print $1}' | xargs)
    
    echo "$theme"
}

# Optional applications selection
select_optional_apps() {
    if ! command -v gum &> /dev/null; then
        echo "spotify,bitwarden"
        return
    fi
    
    echo "Select optional applications to install:" >&2
    
    local apps=$(gum choose --no-limit --height=15 --cursor.foreground="33" \
        "spotify" \
        "bitwarden" \
        "discord" \
        "slack" \
        "obs-studio" \
        "vlc" \
        "gimp" \
        "inkscape" \
        "postman" \
        "insomnia" \
        "dbeaver" \
        "mongodb-compass")
    
    # Convert newlines to commas
    echo "$apps" | tr '\n' ',' | sed 's/,$//'
}

# Container runtime selection
select_container_runtime() {
    if ! command -v gum &> /dev/null; then
        echo "docker"  # Default recommendation for Azure
        return
    fi
    
    echo "" >&2
    echo "Select container runtime:" >&2
    echo "(Docker CE is recommended for Dev Containers support)" >&2
    
    local runtime=$(gum choose --height=5 --cursor.foreground="33" \
        "docker" \
        "podman" \
        "none")
    
    echo "$runtime"
}

# Confirmation before installation
confirm_installation() {
    echo ""
    echo -e "${C_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo -e "${C_WHITE}  📋  Installation Summary${C_RESET}"
    echo -e "${C_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo ""
    echo -e "    ${C_CYAN}Theme:${C_RESET}             ${C_WHITE}$KODRA_THEME${C_RESET}"
    echo -e "    ${C_CYAN}Container Runtime:${C_RESET} ${C_WHITE}$KODRA_CONTAINER_RUNTIME${C_RESET}"
    if [ -n "$OPTIONAL_APPS" ]; then
        echo -e "    ${C_CYAN}Optional Apps:${C_RESET}     ${C_WHITE}$OPTIONAL_APPS${C_RESET}"
    fi
    echo ""
    echo -e "    ${C_GRAY}This will install:${C_RESET}"
    echo -e "    ${C_GRAY}  • Package managers (Homebrew, Flatpak, mise)${C_RESET}"
    echo -e "    ${C_GRAY}  • Modern terminal (Ghostty, Neovim, Starship)${C_RESET}"
    echo -e "    ${C_GRAY}  • CLI tools (bat, eza, fzf, ripgrep, lazygit)${C_RESET}"
    echo -e "    ${C_GRAY}  • Cloud tools (Azure CLI, azd, kubectl, Helm, k9s)${C_RESET}"
    echo -e "    ${C_GRAY}  • IaC tools (Terraform, OpenTofu, Bicep)${C_RESET}"
    echo -e "    ${C_GRAY}  • Beautiful GNOME desktop configuration${C_RESET}"
    echo ""
    
    # Auto-confirm if running non-interactively (KODRA_AUTOCONFIRM=1 or TTY unavailable)
    # Check if we can actually read from /dev/tty, not just if it exists
    if [ "${KODRA_AUTOCONFIRM:-0}" = "1" ] || ! ( exec 0</dev/tty ) 2>/dev/null; then
        echo -e "    ${C_GREEN}✓ Auto-confirmed (non-interactive mode)${C_RESET}"
        return 0
    fi
    
    if command -v gum &> /dev/null; then
        if ! gum confirm --prompt.foreground="212" "Ready to ship to Azure?"; then
            echo ""
            echo -e "    ${C_YELLOW}Installation cancelled.${C_RESET}"
            echo ""
            exit 0
        fi
    else
        read -p "    Proceed? (Y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo ""
            echo -e "    ${C_YELLOW}Installation cancelled.${C_RESET}"
            echo ""
            exit 0
        fi
    fi
    
    echo ""
    echo -e "    ${C_GREEN}Let's go! ☁️${C_RESET}"
    echo ""
    sleep 1
}

# Progress spinner for long operations
spin() {
    local message="$1"
    shift
    
    if command -v gum &> /dev/null; then
        gum spin --spinner dot --spinner.foreground="212" --title "    $message" -- "$@"
    else
        echo -e "    ${C_CYAN}►${C_RESET} $message"
        "$@"
    fi
}

# Show elapsed time
show_elapsed_time() {
    local end_time=$(date +%s)
    local elapsed=$((end_time - KODRA_START_TIME))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))
    
    if [ $minutes -gt 0 ]; then
        echo -e "    ${C_GRAY}Completed in ${minutes}m ${seconds}s${C_RESET}"
    else
        echo -e "    ${C_GRAY}Completed in ${seconds}s${C_RESET}"
    fi
}

# Format text with style
styled() {
    local style="$1"
    local text="$2"
    
    if command -v gum &> /dev/null; then
        gum style --foreground "$style" "$text"
    else
        echo "$text"
    fi
}

# Show completion message with installation summary
show_completion() {
    local end_time=$(date +%s)
    local elapsed=$((end_time - KODRA_START_TIME))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))
    
    echo ""
    echo ""
    
    # Determine success/partial success
    if [ "${KODRA_FAIL_COUNT:-0}" -gt 0 ]; then
        echo -e "${C_YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
        echo -e "${C_WHITE}  ⚠️  Installation Complete (with warnings)${C_RESET}"
        echo -e "${C_YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    else
        echo -e "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
        echo -e "${C_WHITE}  ✨  Installation Complete!${C_RESET}"
        echo -e "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    fi
    echo ""
    
    # Time and stats
    if [ $minutes -gt 0 ]; then
        echo -e "    ${C_CYAN}⏱${C_RESET}  Completed in ${C_WHITE}${minutes}m ${seconds}s${C_RESET}"
    else
        echo -e "    ${C_CYAN}⏱${C_RESET}  Completed in ${C_WHITE}${seconds}s${C_RESET}"
    fi
    
    local success_count=$((${KODRA_INSTALL_COUNT:-0} - ${KODRA_FAIL_COUNT:-0}))
    echo -e "    ${C_GREEN}✔${C_RESET}  ${C_WHITE}${success_count}${C_RESET} components installed"
    
    if [ "${KODRA_FAIL_COUNT:-0}" -gt 0 ]; then
        echo -e "    ${C_RED}✖${C_RESET}  ${C_WHITE}${KODRA_FAIL_COUNT}${C_RESET} components failed"
    fi
    
    echo ""
    echo -e "    ${C_WHITE}What's ready:${C_RESET}"
    
    # Check which tools are available and show them
    command -v ghostty &>/dev/null && echo -e "    ${C_GRAY}├─${C_RESET} Ghostty terminal with Starship prompt"
    command -v code &>/dev/null && echo -e "    ${C_GRAY}├─${C_RESET} VS Code with cloud-native extensions"
    command -v az &>/dev/null && echo -e "    ${C_GRAY}├─${C_RESET} Azure CLI$(command -v azd &>/dev/null && echo ", azd")$(command -v terraform &>/dev/null && echo ", Terraform")$(command -v bicep &>/dev/null && echo ", Bicep")"
    command -v docker &>/dev/null && echo -e "    ${C_GRAY}├─${C_RESET} Docker$(command -v kubectl &>/dev/null && echo ", kubectl")$(command -v helm &>/dev/null && echo ", Helm")$(command -v k9s &>/dev/null && echo ", k9s")"
    command -v bat &>/dev/null && echo -e "    ${C_GRAY}└─${C_RESET} Modern CLI (bat, eza, fzf, ripgrep, zoxide)"
    
    # Show failures if any
    if [ "${KODRA_FAIL_COUNT:-0}" -gt 0 ] && [ -n "$KODRA_FAILED_INSTALLS" ]; then
        echo ""
        echo -e "    ${C_YELLOW}Failed components:${C_RESET}"
        echo -e "$KODRA_FAILED_INSTALLS" | while read -r line; do
            [ -n "$line" ] && echo -e "    ${C_GRAY}└─${C_RESET} ${C_RED}$line${C_RESET}"
        done
        echo ""
        echo -e "    ${C_GRAY}Run 'kodra resume' to retry failed components${C_RESET}"
    fi
    
    echo ""
    echo -e "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo ""
}

# Show error message
show_error() {
    local message="$1"
    echo -e "    ${C_RED}✖${C_RESET} ${C_RED}$message${C_RESET}"
}

# Show warning message
show_warning() {
    local message="$1"
    echo -e "    ${C_YELLOW}⚠${C_RESET} ${C_YELLOW}$message${C_RESET}"
}

# Show success message
show_success() {
    local message="$1"
    echo -e "    ${C_GREEN}✔${C_RESET} ${C_WHITE}$message${C_RESET}"
}

# Show info message
show_info() {
    local message="$1"
    echo -e "    ${C_CYAN}ℹ${C_RESET} ${C_GRAY}$message${C_RESET}"
}