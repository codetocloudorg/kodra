#!/usr/bin/env bash
#
# Kodra UI Functions
# Beautiful CLI that makes installation feel premium
#

# Ensure TERM is set (needed for clear, tput, etc.)
export TERM="${TERM:-xterm-256color}"

# Installation progress tracking
export KODRA_TOTAL_STEPS=12
export KODRA_CURRENT_STEP=0
export KODRA_START_TIME=$(date +%s)
export KODRA_SECTION_START_TIME=$(date +%s)
export KODRA_SECTION_TIMES=""
export KODRA_CURRENT_SECTION=""

# Colors for visual appeal - Tokyo Night palette
C_CYAN='\033[38;5;51m'        # Bright cyan for accents
C_PURPLE='\033[38;5;141m'     # Soft purple for headers
C_GREEN='\033[38;5;114m'      # Muted green for success
C_YELLOW='\033[38;5;221m'     # Warm yellow for warnings
C_BLUE='\033[38;5;111m'       # Soft blue for sections
C_GRAY='\033[38;5;243m'       # Subtle gray for secondary
C_DIM='\033[38;5;238m'        # Very dim for backgrounds
C_WHITE='\033[38;5;255m'      # Pure white for emphasis
C_RED='\033[38;5;167m'        # Soft red for errors
C_PINK='\033[38;5;212m'       # Pink for highlights
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM_TEXT='\033[2m'

# Box drawing characters
BOX_TL='╭'
BOX_TR='╮'
BOX_BL='╰'
BOX_BR='╯'
BOX_H='─'
BOX_V='│'
BOX_BULLET='●'
BOX_CHECK='✓'
BOX_CROSS='✗'
BOX_ARROW='→'
BOX_DOT='·'

# Display the Kodra banner with typing effect
show_banner() {
    # Get version from VERSION file
    local version="0.0.1"
    if [ -f "$KODRA_DIR/VERSION" ]; then
        version=$(cat "$KODRA_DIR/VERSION" | tr -d '\n')
    fi
    
    clear 2>/dev/null || true
    echo ""
    
    # Animated banner reveal
    local lines=(
        "\033[38;5;196m    ██╗  ██╗\033[38;5;208m ██████╗ \033[38;5;226m██████╗ \033[38;5;46m██████╗ \033[38;5;51m █████╗ \033[0m"
        "\033[38;5;196m    ██║ ██╔╝\033[38;5;208m██╔═══██╗\033[38;5;226m██╔══██╗\033[38;5;46m██╔══██╗\033[38;5;51m██╔══██╗\033[0m"
        "\033[38;5;196m    █████╔╝ \033[38;5;208m██║   ██║\033[38;5;226m██║  ██║\033[38;5;46m██████╔╝\033[38;5;51m███████║\033[0m"
        "\033[38;5;196m    ██╔═██╗ \033[38;5;208m██║   ██║\033[38;5;226m██║  ██║\033[38;5;46m██╔══██╗\033[38;5;51m██╔══██║\033[0m"
        "\033[38;5;196m    ██║  ██╗\033[38;5;208m╚██████╔╝\033[38;5;226m██████╔╝\033[38;5;46m██║  ██║\033[38;5;51m██║  ██║\033[0m"
        "\033[38;5;196m    ╚═╝  ╚═╝\033[38;5;208m ╚═════╝ \033[38;5;226m╚═════╝ \033[38;5;46m╚═╝  ╚═╝\033[38;5;51m╚═╝  ╚═╝\033[0m"
    )
    
    for line in "${lines[@]}"; do
        echo -e "$line"
        sleep 0.03
    done
    
    echo -e "                                                    ${C_GRAY}v${version}${C_RESET}"
    echo ""
    sleep 0.1
    echo -e "    ${C_DIM}${BOX_TL}$(printf '%0.s─' {1..63})${BOX_TR}${C_RESET}"
    echo -e "    ${C_DIM}${BOX_V}${C_RESET}       ${C_PURPLE}${C_BOLD}A  C O D E  T O  C L O U D  P R O J E C T${C_RESET}           ${C_DIM}${BOX_V}${C_RESET}"
    echo -e "    ${C_DIM}${BOX_BL}$(printf '%0.s─' {1..63})${BOX_BR}${C_RESET}"
    echo ""
    sleep 0.1
    echo -e "    ${C_CYAN}${BOX_BULLET}${C_RESET} ${C_WHITE}Agentic Azure engineering${C_RESET}"
    echo -e "    ${C_GRAY}  Cloud-native tools for the modern developer${C_RESET}"
    echo ""
    sleep 0.2
}

# Display modern progress bar with gradient
show_progress() {
    local current=$1
    local total=$2
    local width=40
    
    # Cap at 100% to handle overflow gracefully
    [ $current -gt $total ] && current=$total
    
    local percent=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    # Calculate ETA based on elapsed time
    local elapsed=$(($(date +%s) - KODRA_START_TIME))
    local eta_text=""
    if [ $current -gt 0 ] && [ $elapsed -gt 0 ]; then
        local avg_per_step=$((elapsed / current))
        local remaining=$(((total - current) * avg_per_step))
        if [ $remaining -gt 60 ]; then
            eta_text=" ${C_DIM}~$((remaining / 60))m left${C_RESET}"
        elif [ $remaining -gt 0 ]; then
            eta_text=" ${C_DIM}~${remaining}s left${C_RESET}"
        fi
    fi
    
    printf "    ${C_DIM}[${C_RESET}"
    # Gradient fill
    for ((i=0; i<filled; i++)); do
        if [ $i -lt $((width/3)) ]; then
            printf "\033[38;5;212m█${C_RESET}"
        elif [ $i -lt $((width*2/3)) ]; then
            printf "\033[38;5;141m█${C_RESET}"
        else
            printf "\033[38;5;111m█${C_RESET}"
        fi
    done
    printf "${C_DIM}"
    printf '%*s' "$empty" | tr ' ' '░'
    printf "${C_RESET}${C_DIM}]${C_RESET} ${C_WHITE}%3d%%${C_RESET}${eta_text}\n" "$percent"
}

# Format elapsed time nicely
format_duration() {
    local seconds=$1
    if [ $seconds -ge 60 ]; then
        printf "%dm %ds" $((seconds / 60)) $((seconds % 60))
    else
        printf "%ds" $seconds
    fi
}

# Display a section header with modern styling
section() {
    local title="$1"
    local emoji="${2:-🔧}"
    
    # Complete previous section timing
    if [ -n "$KODRA_CURRENT_SECTION" ]; then
        local section_elapsed=$(($(date +%s) - KODRA_SECTION_START_TIME))
        KODRA_SECTION_TIMES="${KODRA_SECTION_TIMES}${KODRA_CURRENT_SECTION}:${section_elapsed};"
    fi
    
    KODRA_CURRENT_STEP=$((KODRA_CURRENT_STEP + 1))
    KODRA_SECTION_START_TIME=$(date +%s)
    KODRA_CURRENT_SECTION="$title"
    
    # Section transition
    echo ""
    echo ""
    
    # Top border with gradient
    printf "    ${C_PINK}${BOX_TL}"
    printf '%0.s─' {1..65}
    printf "${BOX_TR}${C_RESET}\n"
    
    # Title row
    printf "    ${C_PINK}${BOX_V}${C_RESET}  ${emoji}  ${C_WHITE}${C_BOLD}%-52s${C_RESET}  ${C_DIM}%d/%d${C_RESET}  ${C_PINK}${BOX_V}${C_RESET}\n" "$title" "$KODRA_CURRENT_STEP" "$KODRA_TOTAL_STEPS"
    
    # Bottom border
    printf "    ${C_PINK}${BOX_BL}"
    printf '%0.s─' {1..65}
    printf "${BOX_BR}${C_RESET}\n"
    
    echo ""
    show_progress $KODRA_CURRENT_STEP $KODRA_TOTAL_STEPS
    echo ""
}

# Install gum for interactive CLI
install_gum() {
    if command -v gum &> /dev/null; then
        return 0
    fi
    
    echo -e "    ${C_CYAN}◆${C_RESET} ${C_WHITE}Installing interactive CLI...${C_RESET}"
    
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y gum > /dev/null 2>&1
    echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} ${C_DIM}Interactive CLI ready${C_RESET}"
}

# Show what's being installed (live status)
show_installing() {
    local name="$1"
    local desc="${2:-}"
    
    if [ -n "$desc" ]; then
        printf "    ${C_CYAN}◆${C_RESET} ${C_WHITE}%-20s${C_RESET} ${C_DIM}${BOX_DOT} ${desc}${C_RESET}\n" "$name"
    else
        printf "    ${C_CYAN}◆${C_RESET} ${C_WHITE}%s${C_RESET}\n" "$name"
    fi
}

# Show installation success
show_installed() {
    local name="$1"
    printf "    ${C_GREEN}${BOX_CHECK}${C_RESET} ${C_DIM}%s${C_RESET}\n" "$name"
}

# Show a tool group being installed with nice formatting
show_tools_group() {
    local tools="$1"
    echo ""
    echo -e "    ${C_BLUE}${BOX_ARROW}${C_RESET} ${C_WHITE}${tools}${C_RESET}"
    echo -e "    ${C_DIM}$(printf '%0.s─' {1..55})${C_RESET}"
}

# Theme selection
select_theme() {
    # Non-interactive mode or no TTY - use default
    if [ "${NONINTERACTIVE:-0}" = "1" ] || ! command -v gum &> /dev/null || ! ( exec 0</dev/tty ) 2>/dev/null; then
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
    # Non-interactive mode or no TTY - use popular defaults
    if [ "${NONINTERACTIVE:-0}" = "1" ] || ! command -v gum &> /dev/null || ! ( exec 0</dev/tty ) 2>/dev/null; then
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
    # Non-interactive mode or no TTY - use Docker (recommended for Azure/Dev Containers)
    if [ "${NONINTERACTIVE:-0}" = "1" ] || ! command -v gum &> /dev/null || ! ( exec 0</dev/tty ) 2>/dev/null; then
        echo "docker"
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

# Confirmation before installation - modern card design
confirm_installation() {
    echo ""
    
    # Modern card header
    printf "    ${C_PURPLE}${BOX_TL}"
    printf '%0.s─' {1..65}
    printf "${BOX_TR}${C_RESET}\n"
    printf "    ${C_PURPLE}${BOX_V}${C_RESET}  ${C_WHITE}${C_BOLD}📋  Installation Plan${C_RESET}%45s${C_PURPLE}${BOX_V}${C_RESET}\n" ""
    printf "    ${C_PURPLE}${BOX_V}${C_DIM}"
    printf '%0.s─' {1..65}
    printf "${C_RESET}${C_PURPLE}${BOX_V}${C_RESET}\n"
    
    # Configuration
    printf "    ${C_PURPLE}${BOX_V}${C_RESET}  ${C_CYAN}Theme${C_RESET}           ${C_WHITE}%-46s${C_RESET}${C_PURPLE}${BOX_V}${C_RESET}\n" "$KODRA_THEME"
    printf "    ${C_PURPLE}${BOX_V}${C_RESET}  ${C_CYAN}Containers${C_RESET}      ${C_WHITE}%-46s${C_RESET}${C_PURPLE}${BOX_V}${C_RESET}\n" "$KODRA_CONTAINER_RUNTIME"
    if [ -n "$OPTIONAL_APPS" ]; then
        printf "    ${C_PURPLE}${BOX_V}${C_RESET}  ${C_CYAN}Optional${C_RESET}        ${C_WHITE}%-46s${C_RESET}${C_PURPLE}${BOX_V}${C_RESET}\n" "$OPTIONAL_APPS"
    fi
    
    # Divider
    printf "    ${C_PURPLE}${BOX_V}${C_DIM}"
    printf '%0.s─' {1..65}
    printf "${C_RESET}${C_PURPLE}${BOX_V}${C_RESET}\n"
    
    # What's included
    printf "    ${C_PURPLE}${BOX_V}${C_RESET}  ${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}Package managers (Homebrew, Flatpak, mise)${C_RESET}%16s${C_PURPLE}${BOX_V}${C_RESET}\n" ""
    printf "    ${C_PURPLE}${BOX_V}${C_RESET}  ${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}Modern terminal (Ghostty, Neovim, Starship)${C_RESET}%14s${C_PURPLE}${BOX_V}${C_RESET}\n" ""
    printf "    ${C_PURPLE}${BOX_V}${C_RESET}  ${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}CLI tools (bat, eza, fzf, ripgrep, lazygit)${C_RESET}%14s${C_PURPLE}${BOX_V}${C_RESET}\n" ""
    printf "    ${C_PURPLE}${BOX_V}${C_RESET}  ${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}Cloud tools (Azure CLI, azd, kubectl, Helm)${C_RESET}%15s${C_PURPLE}${BOX_V}${C_RESET}\n" ""
    printf "    ${C_PURPLE}${BOX_V}${C_RESET}  ${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}IaC tools (Terraform, OpenTofu, Bicep)${C_RESET}%19s${C_PURPLE}${BOX_V}${C_RESET}\n" ""
    printf "    ${C_PURPLE}${BOX_V}${C_RESET}  ${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}Beautiful GNOME desktop configuration${C_RESET}%21s${C_PURPLE}${BOX_V}${C_RESET}\n" ""
    
    # Card footer
    printf "    ${C_PURPLE}${BOX_BL}"
    printf '%0.s─' {1..65}
    printf "${BOX_BR}${C_RESET}\n"
    echo ""
    
    # Auto-confirm if running non-interactively
    if [ "${NONINTERACTIVE:-0}" = "1" ] || [ "${KODRA_AUTOCONFIRM:-0}" = "1" ] || ! ( exec 0</dev/tty ) 2>/dev/null; then
        echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} ${C_DIM}Auto-confirmed (non-interactive mode)${C_RESET}"
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
        read -p "    Ready? (Y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            echo ""
            echo -e "    ${C_YELLOW}Installation cancelled.${C_RESET}"
            echo ""
            exit 0
        fi
    fi
    
    echo ""
    echo -e "    ${C_GREEN}${BOX_ARROW}${C_RESET} ${C_WHITE}Launching installation...${C_RESET}"
    echo ""
    sleep 0.5
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

# Show completion message with premium installation summary
show_completion() {
    local end_time=$(date +%s)
    local elapsed=$((end_time - KODRA_START_TIME))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))
    
    # Complete final section timing
    if [ -n "$KODRA_CURRENT_SECTION" ]; then
        local section_elapsed=$(($(date +%s) - KODRA_SECTION_START_TIME))
        KODRA_SECTION_TIMES="${KODRA_SECTION_TIMES}${KODRA_CURRENT_SECTION}:${section_elapsed};"
    fi
    
    echo ""
    echo ""
    
    local border_color="$C_GREEN"
    local status_icon="✨"
    local status_text="Installation Complete!"
    if [ "${KODRA_FAIL_COUNT:-0}" -gt 0 ]; then
        border_color="$C_YELLOW"
        status_icon="⚠️"
        status_text="Installation Complete (with warnings)"
    fi
    
    # Success banner with gradient border
    printf "    ${border_color}${BOX_TL}"
    printf '%0.s─' {1..65}
    printf "${BOX_TR}${C_RESET}\n"
    printf "    ${border_color}${BOX_V}${C_RESET}%67s${border_color}${BOX_V}${C_RESET}\n" ""
    printf "    ${border_color}${BOX_V}${C_RESET}   ${status_icon}  ${C_WHITE}${C_BOLD}%-57s${C_RESET}   ${border_color}${BOX_V}${C_RESET}\n" "$status_text"
    printf "    ${border_color}${BOX_V}${C_RESET}%67s${border_color}${BOX_V}${C_RESET}\n" ""
    printf "    ${border_color}${BOX_BL}"
    printf '%0.s─' {1..65}
    printf "${BOX_BR}${C_RESET}\n"
    
    echo ""
    
    # Stats card
    printf "    ${C_DIM}${BOX_TL}"
    printf '%0.s─' {1..65}
    printf "${BOX_TR}${C_RESET}\n"
    printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_BLUE}STATS${C_RESET}%58s${C_DIM}${BOX_V}${C_RESET}\n" ""
    printf "    ${C_DIM}${BOX_V}  "
    printf '%0.s─' {1..63}
    printf "${BOX_V}${C_RESET}\n"
    
    # Time
    if [ $minutes -gt 0 ]; then
        printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_CYAN}⏱${C_RESET}  Duration          ${C_WHITE}%dm %ds${C_RESET}%35s${C_DIM}${BOX_V}${C_RESET}\n" "$minutes" "$seconds" ""
    else
        printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_CYAN}⏱${C_RESET}  Duration          ${C_WHITE}%ds${C_RESET}%39s${C_DIM}${BOX_V}${C_RESET}\n" "$seconds" ""
    fi
    
    # Component count
    local success_count=$((${KODRA_INSTALL_COUNT:-0} - ${KODRA_FAIL_COUNT:-0}))
    printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_GREEN}${BOX_CHECK}${C_RESET}  Installed          ${C_WHITE}%d${C_RESET} components%24s${C_DIM}${BOX_V}${C_RESET}\n" "$success_count" ""
    
    if [ "${KODRA_FAIL_COUNT:-0}" -gt 0 ]; then
        printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_RED}${BOX_CROSS}${C_RESET}  Failed             ${C_WHITE}%d${C_RESET} components%24s${C_DIM}${BOX_V}${C_RESET}\n" "$KODRA_FAIL_COUNT" ""
    fi
    
    printf "    ${C_DIM}${BOX_BL}"
    printf '%0.s─' {1..65}
    printf "${BOX_BR}${C_RESET}\n"
    
    echo ""
    
    # Tools available card
    printf "    ${C_DIM}${BOX_TL}"
    printf '%0.s─' {1..65}
    printf "${BOX_TR}${C_RESET}\n"
    printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_BLUE}READY TO USE${C_RESET}%51s${C_DIM}${BOX_V}${C_RESET}\n" ""
    printf "    ${C_DIM}${BOX_V}  "
    printf '%0.s─' {1..63}
    printf "${BOX_V}${C_RESET}\n"
    
    # Check which tools are available
    command -v ghostty &>/dev/null && printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_GREEN}${BOX_CHECK}${C_RESET}  Ghostty terminal with Starship prompt%20s${C_DIM}${BOX_V}${C_RESET}\n" ""
    command -v code &>/dev/null && printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_GREEN}${BOX_CHECK}${C_RESET}  VS Code with cloud-native extensions%22s${C_DIM}${BOX_V}${C_RESET}\n" ""
    command -v az &>/dev/null && printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_GREEN}${BOX_CHECK}${C_RESET}  Azure CLI, azd, Terraform, Bicep%25s${C_DIM}${BOX_V}${C_RESET}\n" ""
    command -v docker &>/dev/null && printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_GREEN}${BOX_CHECK}${C_RESET}  Docker, kubectl, Helm, k9s%32s${C_DIM}${BOX_V}${C_RESET}\n" ""
    command -v bat &>/dev/null && printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_GREEN}${BOX_CHECK}${C_RESET}  Modern CLI (bat, eza, fzf, lazygit)%22s${C_DIM}${BOX_V}${C_RESET}\n" ""
    
    printf "    ${C_DIM}${BOX_BL}"
    printf '%0.s─' {1..65}
    printf "${BOX_BR}${C_RESET}\n"
    
    # Show failures if any
    if [ "${KODRA_FAIL_COUNT:-0}" -gt 0 ] && [ -n "$KODRA_FAILED_INSTALLS" ]; then
        echo ""
        printf "    ${C_YELLOW}${BOX_TL}"
        printf '%0.s─' {1..65}
        printf "${BOX_TR}${C_RESET}\n"
        printf "    ${C_YELLOW}${BOX_V}${C_RESET}  ${C_YELLOW}FAILED COMPONENTS${C_RESET}%46s${C_YELLOW}${BOX_V}${C_RESET}\n" ""
        printf "    ${C_YELLOW}${BOX_V}  "
        printf '%0.s─' {1..63}
        printf "${BOX_V}${C_RESET}\n"
        
        echo -e "$KODRA_FAILED_INSTALLS" | while read -r line; do
            [ -n "$line" ] && printf "    ${C_YELLOW}${BOX_V}${C_RESET}  ${C_RED}${BOX_CROSS}${C_RESET}  %-59s${C_YELLOW}${BOX_V}${C_RESET}\n" "$line"
        done
        
        printf "    ${C_YELLOW}${BOX_V}${C_RESET}%67s${C_YELLOW}${BOX_V}${C_RESET}\n" ""
        printf "    ${C_YELLOW}${BOX_V}${C_RESET}  ${C_DIM}Run 'kodra resume' to retry failed components${C_RESET}%14s${C_YELLOW}${BOX_V}${C_RESET}\n" ""
        printf "    ${C_YELLOW}${BOX_BL}"
        printf '%0.s─' {1..65}
        printf "${BOX_BR}${C_RESET}\n"
    fi
    
    echo ""
}

# Show error message
show_error() {
    local message="$1"
    printf "    ${C_RED}${BOX_CROSS}${C_RESET} ${C_RED}%s${C_RESET}\n" "$message"
}

# Show warning message
show_warning() {
    local message="$1"
    printf "    ${C_YELLOW}!${C_RESET} ${C_YELLOW}%s${C_RESET}\n" "$message"
}

# Show success message
show_success() {
    local message="$1"
    printf "    ${C_GREEN}${BOX_CHECK}${C_RESET} ${C_WHITE}%s${C_RESET}\n" "$message"
}

# Show info message
show_info() {
    local message="$1"
    printf "    ${C_DIM}${BOX_DOT}${C_RESET} ${C_GRAY}%s${C_RESET}\n" "$message"
}

# Pre-flight check display
show_preflight() {
    echo ""
    printf "    ${C_DIM}${BOX_TL}"
    printf '%0.s─' {1..65}
    printf "${BOX_TR}${C_RESET}\n"
    printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_CYAN}PRE-FLIGHT CHECKS${C_RESET}%45s${C_DIM}${BOX_V}${C_RESET}\n" ""
    printf "    ${C_DIM}${BOX_V}  "
    printf '%0.s─' {1..63}
    printf "${BOX_V}${C_RESET}\n"
}

# Single preflight check result
show_check() {
    local name="$1"
    local status="$2"  # "ok", "warn", "fail"
    local detail="${3:-}"
    
    local icon="${C_GREEN}${BOX_CHECK}${C_RESET}"
    [ "$status" = "warn" ] && icon="${C_YELLOW}!${C_RESET}"
    [ "$status" = "fail" ] && icon="${C_RED}${BOX_CROSS}${C_RESET}"
    
    if [ -n "$detail" ]; then
        printf "    ${C_DIM}${BOX_V}${C_RESET}  ${icon}  %-25s ${C_DIM}%s${C_RESET}%*s${C_DIM}${BOX_V}${C_RESET}\n" "$name" "$detail" $((32 - ${#detail})) ""
    else
        printf "    ${C_DIM}${BOX_V}${C_RESET}  ${icon}  %-55s${C_DIM}${BOX_V}${C_RESET}\n" "$name"
    fi
}

# End preflight section
end_preflight() {
    printf "    ${C_DIM}${BOX_BL}"
    printf '%0.s─' {1..65}
    printf "${BOX_BR}${C_RESET}\n"
    echo ""
}

# Show a spinner during an operation
spin() {
    local message="$1"
    shift
    
    if command -v gum &> /dev/null; then
        gum spin --spinner dot --spinner.foreground="212" --title "    $message" -- "$@"
    else
        printf "    ${C_CYAN}◆${C_RESET} %s" "$message"
        "$@"
        printf " ${C_GREEN}${BOX_CHECK}${C_RESET}\n"
    fi
}