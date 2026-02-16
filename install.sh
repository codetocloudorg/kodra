#!/usr/bin/env bash
#
# Kodra Install Script
# A Code To Cloud Project ☁️
# https://kodra.codetocloud.io
#
# Main installation orchestrator
#
# Usage:
#   ./install.sh              Normal installation (stops on error)
#   ./install.sh --debug      Debug mode (logs failures, continues)
#   ./install.sh --resilient  Same as --debug
#

# Parse arguments
export KODRA_DEBUG="false"
for arg in "$@"; do
    case $arg in
        --debug|--resilient|-d)
            export KODRA_DEBUG="true"
            shift
            ;;
    esac
done

# Only set -e if NOT in debug mode
if [ "$KODRA_DEBUG" != "true" ]; then
    set -e
fi

export KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
export KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
export KODRA_LOG_FILE="/tmp/kodra-install-$(date +%Y%m%d-%H%M%S).log"

# Suppress apt noise (needrestart, dpkg prompts)
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Start logging everything to file
exec > >(tee -a "$KODRA_LOG_FILE") 2>&1

echo "$(printf '%0.s═' $(seq 1 60))"
echo "Kodra Installation Log"
echo "Started: $(date)"
echo "System: $(uname -a)"
echo "User: $USER"
echo "Log file: $KODRA_LOG_FILE"
[ "$KODRA_DEBUG" = "true" ] && echo "Mode: DEBUG (resilient - will continue on errors)"
echo "$(printf '%0.s═' $(seq 1 60))"
echo ""

# Error handler with verbose logging
kodra_error_handler() {
    local exit_code=$?
    local line_no=$1
    echo ""
    echo "╭$(printf '%0.s─' $(seq 1 60))╮"
    printf "│  %-58s│\n" "INSTALLATION ERROR"
    echo "╰$(printf '%0.s─' $(seq 1 60))╯"
    echo ""
    echo "❌ Error occurred at line $line_no (exit code: $exit_code)"
    echo ""
    echo "Log file saved at: $KODRA_LOG_FILE"
    echo ""
    echo "To share this log for debugging:"
    echo "  cat $KODRA_LOG_FILE | nc termbin.com 9999"
    echo ""
    echo "Or upload the file: $KODRA_LOG_FILE"
    echo ""
    
    # Save system info
    {
        echo ""
        echo "═══════════════════════════════════════════════════════════════════"
        echo "System Information at Error"
        echo "═══════════════════════════════════════════════════════════════════"
        echo "Ubuntu version: $(lsb_release -d 2>/dev/null || cat /etc/os-release)"
        echo "Architecture: $(uname -m)"
        echo "Disk space: $(df -h / | tail -1)"
        echo "Memory: $(free -h | grep Mem)"
        echo "Last 50 lines of dpkg log:"
        tail -50 /var/log/dpkg.log 2>/dev/null || echo "(not available)"
    } >> "$KODRA_LOG_FILE" 2>&1
    
    exit $exit_code
}
trap 'kodra_error_handler $LINENO' ERR

# Source utility functions
source "$KODRA_DIR/lib/utils.sh"
source "$KODRA_DIR/lib/ui.sh"

# Reconnect stdin to terminal for interactive prompts (needed when run via curl | bash)
# Skip if env vars are pre-set (non-interactive mode) or if /dev/tty can't be opened
if [ ! -t 0 ] && [ -z "$KODRA_THEME" ]; then
    # Test if /dev/tty can actually be opened (not just exists)
    if ( exec 0</dev/tty ) 2>/dev/null; then
        exec < /dev/tty
    fi
fi

# Prevent system sleep during installation
prevent_sleep() {
    if command -v gsettings &> /dev/null; then
        # Save current settings
        export KODRA_SAVED_IDLE_DELAY=$(gsettings get org.gnome.desktop.session idle-delay 2>/dev/null || echo "")
        export KODRA_SAVED_SCREENSAVER=$(gsettings get org.gnome.desktop.screensaver lock-enabled 2>/dev/null || echo "")
        
        # Disable sleep/lock during install
        gsettings set org.gnome.desktop.session idle-delay 0 2>/dev/null || true
        gsettings set org.gnome.desktop.screensaver lock-enabled false 2>/dev/null || true
    fi
}

# Restore sleep settings
restore_sleep() {
    if command -v gsettings &> /dev/null && [ -n "$KODRA_SAVED_IDLE_DELAY" ]; then
        gsettings set org.gnome.desktop.session idle-delay "$KODRA_SAVED_IDLE_DELAY" 2>/dev/null || true
        gsettings set org.gnome.desktop.screensaver lock-enabled "${KODRA_SAVED_SCREENSAVER:-true}" 2>/dev/null || true
    fi
}

# Ensure cleanup on exit (restore sleep settings, stop sudo keepalive)
cleanup_on_exit() {
    restore_sleep
    stop_sudo_keepalive
}
trap 'cleanup_on_exit' EXIT

# Prevent sleep during install
prevent_sleep

# Display banner
show_banner

# Initialize timing
KODRA_START_TIME=$(date +%s)
export KODRA_START_TIME

# -----------------------------------------------------------------------------
# Pre-flight checks
# -----------------------------------------------------------------------------
section "Pre-flight Checks" "🔍"

# Pre-flight checks with visual feedback
show_preflight

# Ubuntu version
ubuntu_version=$(lsb_release -rs 2>/dev/null || echo "unknown")
if check_ubuntu_version 2>/dev/null; then
    show_check "Ubuntu version" "ok" "$ubuntu_version"
else
    show_check "Ubuntu version" "fail" "$ubuntu_version"
    end_preflight
    echo -e "    ${C_RED}Kodra requires Ubuntu 24.04 or later${C_RESET}"
    exit 1
fi

# Internet connection
if check_internet_connection 2>/dev/null; then
    show_check "Internet connection" "ok"
else
    show_check "Internet connection" "fail"
    end_preflight
    echo -e "    ${C_RED}No internet connection detected${C_RESET}"
    exit 1
fi

# Sudo access
if check_sudo_access 2>/dev/null; then
    show_check "Sudo access" "ok"
else
    show_check "Sudo access" "fail"
    end_preflight
    echo -e "    ${C_RED}Sudo access required${C_RESET}"
    exit 1
fi

# Disk space (rough check)
available_gb=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | tr -d 'G')
if [ "$available_gb" -ge 10 ]; then
    show_check "Disk space" "ok" "${available_gb}GB available"
else
    show_check "Disk space" "warn" "${available_gb}GB (10GB+ recommended)"
fi

end_preflight

# Start sudo keepalive to avoid repeated password prompts
start_sudo_keepalive

# -----------------------------------------------------------------------------
# Install gum for beautiful CLI
# -----------------------------------------------------------------------------
install_gum

# -----------------------------------------------------------------------------
# User selections
# -----------------------------------------------------------------------------
section "Configuration" "⚙️"

# Theme selection
if [ -z "$KODRA_THEME" ]; then
    KODRA_THEME=$(select_theme)
fi
export KODRA_THEME

# Optional applications
if [ -z "$KODRA_MINIMAL" ]; then
    OPTIONAL_APPS=$(select_optional_apps)
fi
export OPTIONAL_APPS

# Container runtime (Docker CE recommended for Dev Containers)
if [ -z "$KODRA_CONTAINER_RUNTIME" ]; then
    KODRA_CONTAINER_RUNTIME=$(select_container_runtime)
fi
export KODRA_CONTAINER_RUNTIME

# Confirmation
confirm_installation

# -----------------------------------------------------------------------------
# Backup existing dotfiles
# -----------------------------------------------------------------------------
section "Backup" "💾"

source "$KODRA_DIR/lib/backup.sh"
BACKUP_DIR=$(backup_dotfiles)
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    show_success "Configs backed up"
    show_info "Location: $BACKUP_DIR"
fi

# -----------------------------------------------------------------------------
# System updates and base packages
# -----------------------------------------------------------------------------
section "System Updates" "📦"

show_tools_group "Preparing system environment"

# Suppress needrestart prompts during installation
# sudo strips env vars, so we configure needrestart directly
if [ -d /etc/needrestart/conf.d ]; then
    echo '$nrconf{restart} = "a";' | sudo tee /etc/needrestart/conf.d/kodra.conf >/dev/null
fi

# Cleanup any broken apt repos from previous failed installs
if [ -f /etc/apt/sources.list.d/ghostty.list ]; then
    show_info "Cleaning up previous install artifacts"
    sudo rm -f /etc/apt/sources.list.d/ghostty.list
    sudo rm -f /etc/apt/keyrings/ghostty.asc
fi

show_installing "Updating package lists"
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
show_installed "Package lists updated"

show_installing "Upgrading system packages"
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
show_installed "System packages upgraded"

show_installing "Installing build essentials"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release >/dev/null 2>&1
show_installed "Build essentials ready"

# -----------------------------------------------------------------------------
# Package Managers
# -----------------------------------------------------------------------------
section "Package Managers" "🍺"

show_tools_group "Setting up modern package managers"
run_installer "$KODRA_DIR/install/required/package-managers/flatpak.sh"
run_installer "$KODRA_DIR/install/required/package-managers/homebrew.sh"
run_installer "$KODRA_DIR/install/required/package-managers/mise.sh"

# -----------------------------------------------------------------------------
# Terminal Setup
# -----------------------------------------------------------------------------
section "Terminal Setup" "💻"

show_tools_group "Installing modern terminal environment"
for script in "$KODRA_DIR/install/terminal/"*.sh; do
    run_installer "$script"
done

# -----------------------------------------------------------------------------
# Required Applications
# -----------------------------------------------------------------------------
section "Core Applications" "🛠️"

show_tools_group "Development essentials (Brave, VS Code, GitHub)"
for script in "$KODRA_DIR/install/required/applications/"*.sh; do
    run_installer "$script"
done

# -----------------------------------------------------------------------------
# Azure & Cloud Tools
# -----------------------------------------------------------------------------
section "Azure & Cloud Tools" "☁️"

show_tools_group "Cloud-native toolchain (Azure CLI, Terraform, K8s)"
for script in "$KODRA_DIR/install/required/azure/"*.sh; do
    run_installer "$script"
done

# -----------------------------------------------------------------------------
# Container Runtime
# -----------------------------------------------------------------------------
section "Container Development" "🐳"

show_tools_group "Container runtime and management tools"
case "$KODRA_CONTAINER_RUNTIME" in
    docker)
        run_installer "$KODRA_DIR/applications/docker-ce.sh"
        ;;
    podman)
        run_installer "$KODRA_DIR/applications/podman.sh"
        ;;
esac

run_installer "$KODRA_DIR/applications/lazydocker.sh"

# -----------------------------------------------------------------------------
# Optional Applications
# -----------------------------------------------------------------------------
if [ -n "$OPTIONAL_APPS" ]; then
    section "Optional Applications" "✨"
    
    show_tools_group "Your selected applications"
    IFS=',' read -ra APPS <<< "$OPTIONAL_APPS"
    for app in "${APPS[@]}"; do
        app=$(echo "$app" | xargs) # trim whitespace
        if [ -f "$KODRA_DIR/applications/${app}.sh" ]; then
            run_installer "$KODRA_DIR/applications/${app}.sh"
        fi
    done
fi

# -----------------------------------------------------------------------------
# Desktop & Theme Setup
# -----------------------------------------------------------------------------
section "Desktop Environment" "🎨"

show_tools_group "Beautiful GNOME desktop with Tokyo Night theme"
for script in "$KODRA_DIR/install/desktop/"*.sh; do
    run_installer "$script"
done

show_installing "Applying $KODRA_THEME theme"
run_installer "$KODRA_DIR/bin/kodra-sub/theme.sh" "$KODRA_THEME"
show_success "$KODRA_THEME theme applied"

# -----------------------------------------------------------------------------
# Finalization
# -----------------------------------------------------------------------------
section "Finalizing" "🏁"

show_tools_group "Wrapping up installation"

# Refresh desktop database for Flatpak apps to appear in launcher
show_installing "Refreshing desktop database"
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
if command -v update-desktop-database &>/dev/null; then
    sudo update-desktop-database /var/lib/flatpak/exports/share/applications 2>/dev/null || true
    update-desktop-database "$HOME/.local/share/flatpak/exports/share/applications" 2>/dev/null || true
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi
show_installed "Desktop database refreshed"

# Create config directory
show_installing "Setting up configuration"
mkdir -p "$KODRA_CONFIG_DIR"
echo "$KODRA_THEME" > "$KODRA_CONFIG_DIR/theme"
echo "banner" > "$KODRA_CONFIG_DIR/motd"
date +%s > "$KODRA_CONFIG_DIR/installed_at"
show_installed "Configuration saved"

# Add bin to PATH  
add_to_path "$KODRA_DIR/bin"

# Create symlink in /usr/local/bin so kodra works system-wide
if [ ! -L /usr/local/bin/kodra ]; then
    show_installing "Creating kodra command"
    sudo ln -sf "$KODRA_DIR/bin/kodra" /usr/local/bin/kodra
    show_installed "kodra command available"
fi

# Add shell integration (aliases, completions, MOTD)
show_installing "Shell integration"
add_shell_integration
show_installed "Shell integration configured"

# Run migrations (for fresh installs, marks all as complete)
show_installing "Running migrations"
"$KODRA_DIR/bin/kodra-sub/migrate.sh" --init >/dev/null 2>&1
show_installed "Migrations complete"

# Show completion message
show_completion

# Save permanent log copy
PERMANENT_LOG="$KODRA_CONFIG_DIR/install.log"
cp "$KODRA_LOG_FILE" "$PERMANENT_LOG"
show_info "Log saved: ~/.config/kodra/install.log"

# Show failure summary if in debug mode
if [ "$KODRA_DEBUG" = "true" ] && [ -n "$KODRA_FAILED_INSTALLS" ]; then
    echo ""
    printf "    ${C_YELLOW}${BOX_TL}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_TR}${C_RESET}\n"
    printf "    ${C_YELLOW}${BOX_V}${C_RESET}  ${C_YELLOW}DEBUG: INSTALLATION SUMMARY${C_RESET}%*s${C_YELLOW}${BOX_V}${C_RESET}\n" "$((BOX_WIDTH - 28))" ""
    printf "    ${C_YELLOW}${BOX_V}  "
    printf '%0.s─' $(seq 1 $((BOX_WIDTH - 2)))
    printf "${BOX_V}${C_RESET}\n"
    printf "    ${C_YELLOW}${BOX_V}${C_RESET}  Attempted: %-*s${C_YELLOW}${BOX_V}${C_RESET}\n" "$((BOX_WIDTH - 14))" "$KODRA_INSTALL_COUNT installers"
    printf "    ${C_YELLOW}${BOX_V}${C_RESET}  Failed:    %-*s${C_YELLOW}${BOX_V}${C_RESET}\n" "$((BOX_WIDTH - 14))" "$KODRA_FAIL_COUNT installers"
    printf "    ${C_YELLOW}${BOX_V}${C_RESET}%*s${C_YELLOW}${BOX_V}${C_RESET}\n" "$BOX_WIDTH" ""
    echo -e "$KODRA_FAILED_INSTALLS" | while read -r line; do
        [ -n "$line" ] && printf "    ${C_YELLOW}${BOX_V}${C_RESET}  ${C_RED}${BOX_CROSS}${C_RESET} %-*s${C_YELLOW}${BOX_V}${C_RESET}\n" "$((BOX_WIDTH - 6))" "$line"
    done
    printf "    ${C_YELLOW}${BOX_V}${C_RESET}%*s${C_YELLOW}${BOX_V}${C_RESET}\n" "$BOX_WIDTH" ""
    printf "    ${C_YELLOW}${BOX_V}${C_RESET}  ${C_DIM}Logs: /tmp/kodra-install-*.log${C_RESET}%*s${C_YELLOW}${BOX_V}${C_RESET}\n" "$((BOX_WIDTH - 31))" ""
    printf "    ${C_YELLOW}${BOX_BL}"
    printf '%0.s─' $(seq 1 $BOX_WIDTH)
    printf "${BOX_BR}${C_RESET}\n"
fi

# First-run setup (GitHub login, Azure login, etc.)
echo ""
if ! ( exec 0</dev/tty ) 2>/dev/null; then
    # No TTY available (piped install via wget|bash or nohup)
    show_info "Skipped first-run (no TTY). Run 'kodra setup' anytime to configure."
    "$KODRA_DIR/bin/kodra-sub/first-run.sh" --skip
elif command -v gum &> /dev/null; then
    if gum confirm "Run first-time setup? (GitHub login, Azure auth, Git config) (Y/n)"; then
        "$KODRA_DIR/bin/kodra-sub/first-run.sh"
    else
        echo ""
        show_info "Skipped. Run 'kodra setup' anytime to configure."
        "$KODRA_DIR/bin/kodra-sub/first-run.sh" --skip
    fi
else
    read -p "Run first-time setup? (GitHub, Azure, Git) [Y/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        "$KODRA_DIR/bin/kodra-sub/first-run.sh"
    else
        echo "  Skipped. Run 'kodra setup' anytime to configure."
        "$KODRA_DIR/bin/kodra-sub/first-run.sh" --skip
    fi
fi
