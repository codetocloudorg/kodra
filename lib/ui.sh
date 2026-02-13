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

# Box width for consistent alignment (safe for 80-col terminals)
BOX_WIDTH=60

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
    echo -e "    ${C_DIM}${BOX_TL}$(printf '%0.s─' $(seq 1 $BOX_WIDTH))${BOX_TR}${C_RESET}"
    local sub_pad=$(( (BOX_WIDTH - 43) / 2 ))  # 43 = 41 (text) + 2 (bookend spaces)
    local sub_pad_r=$(( BOX_WIDTH - 43 - sub_pad ))
    printf "    ${C_DIM}${BOX_V}${C_RESET} %*s${C_PURPLE}${C_BOLD}A  C O D E  T O  C L O U D  P R O J E C T${C_RESET}%*s ${C_DIM}${BOX_V}${C_RESET}\n" "$sub_pad" "" "$sub_pad_r" ""
    echo -e "    ${C_DIM}${BOX_BL}$(printf '%0.s─' $(seq 1 $BOX_WIDTH))${BOX_BR}${C_RESET}"
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
    printf '%*s' "$empty" | tr ' ' '.'
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
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_TR}${C_RESET}\n"
    
    # Title row - calculate padding dynamically
    local title_len=${#title}
    local step_text="$KODRA_CURRENT_STEP/$KODRA_TOTAL_STEPS"
    local step_len=${#step_text}
    local content_len=$((4 + title_len + 2 + step_len))  # emoji+spaces + title + spaces + step
    local padding=$((BOX_WIDTH - content_len - 2))  # -2 for border spacing
    [ $padding -lt 0 ] && padding=0
    printf "    ${C_PINK}${BOX_V}${C_RESET}  ${emoji}  ${C_WHITE}${C_BOLD}%s${C_RESET}%*s${C_DIM}%s${C_RESET}  ${C_PINK}${BOX_V}${C_RESET}\n" "$title" "$padding" "" "$step_text"
    
    # Bottom border
    printf "    ${C_PINK}${BOX_BL}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
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
    echo -e "    ${C_DIM}$(printf '%0.s─' $(seq 1 $((BOX_WIDTH - 4))))${C_RESET}"
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
    
    # Helper to print a boxed line with auto-padding
    print_box_line() {
        local color="$1"
        local content="$2"
        # Strip ANSI escape codes for length calculation
        local stripped
        stripped=$(printf '%b' "$content" | sed 's/\x1b\[[0-9;]*m//g')
        local content_len=${#stripped}
        local padding=$((BOX_WIDTH - content_len - 2))  # -2 for left/right spacing
        [ $padding -lt 0 ] && padding=0
        printf "    ${color}${BOX_V}${C_RESET} %b%*s ${color}${BOX_V}${C_RESET}\n" "$content" "$padding" ""
    }
    
    # Modern card header
    printf "    ${C_PURPLE}${BOX_TL}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_TR}${C_RESET}\n"
    print_box_line "$C_PURPLE" "${C_WHITE}${C_BOLD}📋  Installation Plan${C_RESET}"
    printf "    ${C_PURPLE}${BOX_V}${C_DIM}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${C_RESET}${C_PURPLE}${BOX_V}${C_RESET}\n"
    
    # Configuration
    print_box_line "$C_PURPLE" "${C_CYAN}Theme${C_RESET}           ${C_WHITE}$KODRA_THEME${C_RESET}"
    print_box_line "$C_PURPLE" "${C_CYAN}Containers${C_RESET}      ${C_WHITE}$KODRA_CONTAINER_RUNTIME${C_RESET}"
    if [ -n "$OPTIONAL_APPS" ]; then
        print_box_line "$C_PURPLE" "${C_CYAN}Optional${C_RESET}        ${C_WHITE}$OPTIONAL_APPS${C_RESET}"
    fi
    
    # Divider
    printf "    ${C_PURPLE}${BOX_V}${C_DIM}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${C_RESET}${C_PURPLE}${BOX_V}${C_RESET}\n"
    
    # What's included
    print_box_line "$C_PURPLE" "${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}Package managers (Homebrew, Flatpak, mise)${C_RESET}"
    print_box_line "$C_PURPLE" "${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}Modern terminal (Ghostty, Neovim, Starship)${C_RESET}"
    print_box_line "$C_PURPLE" "${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}CLI tools (bat, eza, fzf, ripgrep, lazygit)${C_RESET}"
    print_box_line "$C_PURPLE" "${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}Cloud tools (Azure CLI, azd, kubectl, Helm)${C_RESET}"
    print_box_line "$C_PURPLE" "${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}IaC tools (Terraform, OpenTofu, Bicep)${C_RESET}"
    print_box_line "$C_PURPLE" "${C_DIM}${BOX_BULLET}${C_RESET} ${C_GRAY}Beautiful GNOME desktop configuration${C_RESET}"
    
    # Card footer
    printf "    ${C_PURPLE}${BOX_BL}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_BR}${C_RESET}\n"
    echo ""
    
    # Auto-confirm if running non-interactively
    if [ "${NONINTERACTIVE:-0}" = "1" ] || [ "${KODRA_AUTOCONFIRM:-0}" = "1" ] || ! ( exec 0</dev/tty ) 2>/dev/null; then
        echo -e "    ${C_GREEN}${BOX_CHECK}${C_RESET} ${C_DIM}Auto-confirmed (non-interactive mode)${C_RESET}"
        return 0
    fi
    
    if command -v gum &> /dev/null; then
        if ! gum confirm --prompt.foreground="212" "Ready to ship to Azure? (Y/n)"; then
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
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_TR}${C_RESET}\n"
    printf "    ${border_color}${BOX_V}${C_RESET}%*s${border_color}${BOX_V}${C_RESET}\n" "$BOX_WIDTH" ""
    local status_len=${#status_text}
    local status_pad=$(((BOX_WIDTH - status_len - 4) / 2))  # -4 for emoji(2) + spaces(2)
    local status_pad_r=$((BOX_WIDTH - status_len - 4 - status_pad))
    printf "    ${border_color}${BOX_V}${C_RESET}%*s${status_icon}  ${C_WHITE}${C_BOLD}%s${C_RESET}%*s${border_color}${BOX_V}${C_RESET}\n" "$status_pad" "" "$status_text" "$status_pad_r" ""
    printf "    ${border_color}${BOX_V}${C_RESET}%*s${border_color}${BOX_V}${C_RESET}\n" "$BOX_WIDTH" ""
    printf "    ${border_color}${BOX_BL}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_BR}${C_RESET}\n"
    
    echo ""
    
    # Stats card
    printf "    ${C_DIM}${BOX_TL}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_TR}${C_RESET}\n"
    printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_BLUE}STATS${C_RESET}%*s${C_DIM}${BOX_V}${C_RESET}\n" "$((BOX_WIDTH - 7))" ""
    printf "    ${C_DIM}${BOX_V}  "
    printf '%0.s─' $(seq 1 $((BOX_WIDTH - 2)))
    printf "${BOX_V}${C_RESET}\n"
    
    # Time
    local time_str
    if [ $minutes -gt 0 ]; then
        time_str="${minutes}m ${seconds}s"
    else
        time_str="${seconds}s"
    fi
    printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_CYAN}⏱${C_RESET}  Duration          ${C_WHITE}%s${C_RESET}%*s${C_DIM}${BOX_V}${C_RESET}\n" "$time_str" "$((BOX_WIDTH - 24 - ${#time_str}))" ""
    
    # Component count
    local success_count=$((${KODRA_INSTALL_COUNT:-0} - ${KODRA_FAIL_COUNT:-0}))
    local comp_str="${success_count} components"
    printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_GREEN}${BOX_CHECK}${C_RESET}  Installed          ${C_WHITE}%s${C_RESET}%*s${C_DIM}${BOX_V}${C_RESET}\n" "$comp_str" "$((BOX_WIDTH - 24 - ${#comp_str}))" ""
    
    if [ "${KODRA_FAIL_COUNT:-0}" -gt 0 ]; then
        local fail_str="${KODRA_FAIL_COUNT} components"
        printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_RED}${BOX_CROSS}${C_RESET}  Failed             ${C_WHITE}%s${C_RESET}%*s${C_DIM}${BOX_V}${C_RESET}\n" "$fail_str" "$((BOX_WIDTH - 24 - ${#fail_str}))" ""
    fi
    
    printf "    ${C_DIM}${BOX_BL}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_BR}${C_RESET}\n"
    
    echo ""
    
    # Tools available card
    printf "    ${C_DIM}${BOX_TL}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_TR}${C_RESET}\n"
    printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_BLUE}READY TO USE${C_RESET}%*s${C_DIM}${BOX_V}${C_RESET}\n" "$((BOX_WIDTH - 14))" ""
    printf "    ${C_DIM}${BOX_V}  "
    printf '%0.s─' $(seq 1 $((BOX_WIDTH - 2)))
    printf "${BOX_V}${C_RESET}\n"
    
    # Helper for tool lines
    print_tool_line() {
        local text="$1"
        local text_len=${#text}
        local pad=$((BOX_WIDTH - 5 - text_len))  # 5 = "  ✓  " (2+1+2)
        [ $pad -lt 0 ] && pad=0
        printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_GREEN}${BOX_CHECK}${C_RESET}  %s%*s${C_DIM}${BOX_V}${C_RESET}\n" "$text" "$pad" ""
    }
    
    # Check which tools are available
    command -v ghostty &>/dev/null && print_tool_line "Ghostty terminal with Starship prompt"
    command -v code &>/dev/null && print_tool_line "VS Code with cloud-native extensions"
    command -v az &>/dev/null && print_tool_line "Azure CLI, azd, Terraform, Bicep"
    command -v docker &>/dev/null && print_tool_line "Docker, kubectl, Helm, k9s"
    command -v bat &>/dev/null && print_tool_line "Modern CLI (bat, eza, fzf, lazygit)"
    
    printf "    ${C_DIM}${BOX_BL}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_BR}${C_RESET}\n"
    
    # Show failures if any
    if [ "${KODRA_FAIL_COUNT:-0}" -gt 0 ] && [ -n "$KODRA_FAILED_INSTALLS" ]; then
        echo ""
        printf "    ${C_YELLOW}${BOX_TL}"
        printf '%0.s─' $(seq 1 $BOX_WIDTH)
        printf "${BOX_TR}${C_RESET}\n"
        printf "    ${C_YELLOW}${BOX_V}${C_RESET}  ${C_YELLOW}FAILED COMPONENTS${C_RESET}%*s${C_YELLOW}${BOX_V}${C_RESET}\n" "$((BOX_WIDTH - 19))" ""
        printf "    ${C_YELLOW}${BOX_V}  "
        printf '%0.s─' $(seq 1 $((BOX_WIDTH - 2)))
        printf "${BOX_V}${C_RESET}\n"
        
        echo -e "$KODRA_FAILED_INSTALLS" | while read -r line; do
            if [ -n "$line" ]; then
                local line_len=${#line}
                local pad=$((BOX_WIDTH - 5 - line_len))  # 5 = "  ✗  " (2+1+2)
                [ $pad -lt 0 ] && pad=0
                printf "    ${C_YELLOW}${BOX_V}${C_RESET}  ${C_RED}${BOX_CROSS}${C_RESET}  %s%*s${C_YELLOW}${BOX_V}${C_RESET}\n" "$line" "$pad" ""
            fi
        done
        
        printf "    ${C_YELLOW}${BOX_V}${C_RESET}%*s${C_YELLOW}${BOX_V}${C_RESET}\n" "$BOX_WIDTH" ""
        local resume_text="Run 'kodra resume' to retry failed components"
        printf "    ${C_YELLOW}${BOX_V}${C_RESET}  ${C_DIM}%s${C_RESET}%*s${C_YELLOW}${BOX_V}${C_RESET}\n" "$resume_text" "$((BOX_WIDTH - 2 - ${#resume_text}))" ""
        printf "    ${C_YELLOW}${BOX_BL}"
        printf '%0.s─' $(seq 1 $BOX_WIDTH)
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
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_TR}${C_RESET}\n"
    printf "    ${C_DIM}${BOX_V}${C_RESET}  ${C_CYAN}PRE-FLIGHT CHECKS${C_RESET}%*s${C_DIM}${BOX_V}${C_RESET}\n" "$((BOX_WIDTH - 19))" ""
    printf "    ${C_DIM}${BOX_V}  "
    printf '%0.s─' $(seq 1 $((BOX_WIDTH - 2)))
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
        local content="${name} ${detail}"
        local content_len=$((${#name} + 1 + ${#detail}))
        local pad=$((BOX_WIDTH - 5 - content_len))  # 5 = "  ✓  " (2+1+2)
        [ $pad -lt 0 ] && pad=0
        printf "    ${C_DIM}${BOX_V}${C_RESET}  ${icon}  %s ${C_DIM}%s${C_RESET}%*s${C_DIM}${BOX_V}${C_RESET}\n" "$name" "$detail" "$pad" ""
    else
        local pad=$((BOX_WIDTH - 5 - ${#name}))  # 5 = "  ✓  " (2+1+2)
        [ $pad -lt 0 ] && pad=0
        printf "    ${C_DIM}${BOX_V}${C_RESET}  ${icon}  %s%*s${C_DIM}${BOX_V}${C_RESET}\n" "$name" "$pad" ""
    fi
}

# End preflight section
end_preflight() {
    printf "    ${C_DIM}${BOX_BL}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
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