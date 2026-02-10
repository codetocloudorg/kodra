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

# Start logging everything to file
exec > >(tee -a "$KODRA_LOG_FILE") 2>&1

echo "═══════════════════════════════════════════════════════════════════"
echo "Kodra Installation Log"
echo "Started: $(date)"
echo "System: $(uname -a)"
echo "User: $USER"
echo "Log file: $KODRA_LOG_FILE"
[ "$KODRA_DEBUG" = "true" ] && echo "Mode: DEBUG (resilient - will continue on errors)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# Error handler with verbose logging
kodra_error_handler() {
    local exit_code=$?
    local line_no=$1
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                    INSTALLATION ERROR                            ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
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

show_info "Checking system requirements..."
check_ubuntu_version
show_success "Ubuntu version OK"
check_internet_connection
show_success "Internet connection OK"
check_sudo_access
show_success "Sudo access OK"

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
    show_success "Configs backed up to: $BACKUP_DIR"
    show_info "Run 'kodra restore' to recover if needed"
fi

# -----------------------------------------------------------------------------
# System updates and base packages
# -----------------------------------------------------------------------------
section "System Updates" "📦"

# Cleanup any broken apt repos from previous failed installs
if [ -f /etc/apt/sources.list.d/ghostty.list ]; then
    show_info "Removing broken Ghostty apt repo from previous install..."
    sudo rm -f /etc/apt/sources.list.d/ghostty.list
    sudo rm -f /etc/apt/keyrings/ghostty.asc
fi

show_info "Updating package lists..."
sudo apt-get update -qq
show_info "Upgrading installed packages..."
sudo apt-get upgrade -y -qq
sudo apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

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

show_tools_group "Installing modern terminal tools"
for script in "$KODRA_DIR/install/terminal/"*.sh; do
    run_installer "$script"
done

# -----------------------------------------------------------------------------
# Required Applications
# -----------------------------------------------------------------------------
section "Core Applications" "🛠️"

show_tools_group "Installing development essentials"
for script in "$KODRA_DIR/install/required/applications/"*.sh; do
    run_installer "$script"
done

# -----------------------------------------------------------------------------
# Azure & Cloud Tools
# -----------------------------------------------------------------------------
section "Azure & Cloud Tools" "☁️"

show_tools_group "Installing cloud-native toolchain"
for script in "$KODRA_DIR/install/required/azure/"*.sh; do
    run_installer "$script"
done

# -----------------------------------------------------------------------------
# Container Runtime
# -----------------------------------------------------------------------------
section "Container Development" "🐳"

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
    
    show_tools_group "Installing your selected applications"
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

show_tools_group "Configuring beautiful GNOME desktop"
for script in "$KODRA_DIR/install/desktop/"*.sh; do
    run_installer "$script"
done

show_info "Applying $KODRA_THEME theme..."
run_installer "$KODRA_DIR/bin/kodra-sub/theme.sh" "$KODRA_THEME"
show_success "Theme applied successfully"

# -----------------------------------------------------------------------------
# Finalization
# -----------------------------------------------------------------------------
section "Finalizing" "🏁"

# Create config directory
mkdir -p "$KODRA_CONFIG_DIR"
echo "$KODRA_THEME" > "$KODRA_CONFIG_DIR/theme"
echo "banner" > "$KODRA_CONFIG_DIR/motd"
date +%s > "$KODRA_CONFIG_DIR/installed_at"

# Add bin to PATH  
add_to_path "$KODRA_DIR/bin"

# Add shell integration (aliases, completions, MOTD)
add_shell_integration

# Run migrations (for fresh installs, marks all as complete)
show_info "Running migrations..."
"$KODRA_DIR/bin/kodra-sub/migrate.sh" --init
show_success "Setup complete"

# Show completion message
show_completion

# Save permanent log copy
PERMANENT_LOG="$KODRA_CONFIG_DIR/install.log"
cp "$KODRA_LOG_FILE" "$PERMANENT_LOG"
echo ""
echo "📋 Installation log saved to: $PERMANENT_LOG"

# Show failure summary if in debug mode
if [ "$KODRA_DEBUG" = "true" ] && [ -n "$KODRA_FAILED_INSTALLS" ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    echo "  ⚠️  INSTALLATION SUMMARY (Debug Mode)"
    echo "═══════════════════════════════════════════════════════════════════"
    echo ""
    echo "  Attempted: $KODRA_INSTALL_COUNT installers"
    echo "  Failed:    $KODRA_FAIL_COUNT installers"
    echo ""
    echo "  Failed components:"
    echo -e "$KODRA_FAILED_INSTALLS" | while read -r line; do
        [ -n "$line" ] && echo "    ❌ $line"
    done
    echo ""
    echo "  Individual failure logs saved to: /tmp/kodra-install-*.log"
    echo "═══════════════════════════════════════════════════════════════════"
fi

# First-run setup (GitHub login, Azure login, etc.)
echo ""
if command -v gum &> /dev/null; then
    if gum confirm "Run first-time setup? (GitHub login, Azure auth, Git config)"; then
        "$KODRA_DIR/bin/kodra-sub/first-run.sh"
    else
        echo ""
        echo "  Skipped. Run 'kodra setup' anytime to configure."
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
