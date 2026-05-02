#!/usr/bin/env bash
#
# Kodra Utility Functions
# Core helpers used across all Kodra scripts: logging, version checks,
# sudo management, installer execution, shell integration, and PATH setup.
#

# Source Homebrew if available (ensures brew is in PATH after fresh install)
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
fi

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# Print an informational message in blue
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Print a success message in green
log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

# Print a warning message in yellow
log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Print an error message in red
log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Ubuntu 24.04+
check_ubuntu_version() {
    if [ ! -f /etc/os-release ]; then
        log_warning "Could not detect OS version"
        return 0
    fi
    
    . /etc/os-release
    
    if [ "$ID" != "ubuntu" ]; then
        log_warning "Kodra is designed for Ubuntu. Detected: $ID"
        return 0
    fi
    
    VERSION_NUM=$(echo "$VERSION_ID" | cut -d. -f1)
    if [ "$VERSION_NUM" -lt 24 ]; then
        log_error "Kodra requires Ubuntu 24.04 or newer. Detected: $VERSION_ID"
        return 1
    fi
    
    log_success "Ubuntu $VERSION_ID detected"
}

# Check internet connection
check_internet_connection() {
    # Try ping first, then fall back to curl (ping may not work in containers)
    if ping -c 1 -W 3 github.com &> /dev/null; then
        log_success "Internet connection available"
    elif curl -s --max-time 5 https://github.com &> /dev/null; then
        log_success "Internet connection available"
    else
        log_error "No internet connection detected"
        return 1
    fi
}

# Check sudo access
check_sudo_access() {
    # Try non-interactive first (works for passwordless sudo like Azure VMs)
    if sudo -n true 2>/dev/null; then
        log_success "sudo access confirmed (passwordless)"
        return 0
    fi
    
    # If we have a TTY, try interactive sudo
    if [ -t 0 ] || [ -e /dev/tty ]; then
        if sudo -v &> /dev/null; then
            log_success "sudo access confirmed"
            return 0
        fi
    fi
    
    log_error "sudo access required"
    return 1
}

# Start a background process to keep sudo credentials alive
# This prevents multiple password prompts during long installations
# The PID is stored in KODRA_SUDO_KEEPALIVE_PID for cleanup
start_sudo_keepalive() {
    # Try non-interactive first (works for passwordless sudo like Azure VMs)
    if sudo -n true 2>/dev/null; then
        log_success "Sudo access available (passwordless)"
        # Still start keepalive in case there are time-limited credentials
        (
            while true; do
                sudo -n true 2>/dev/null
                sleep 50
            done
        ) &
        export KODRA_SUDO_KEEPALIVE_PID=$!
        return 0
    fi
    
    # If we have a TTY, prompt for password once
    if [ -t 0 ] || [ -e /dev/tty ]; then
        echo -e "${CYAN}[INFO]${NC} Requesting sudo access (you'll only need to enter your password once)..."
        if ! sudo -v; then
            log_error "Failed to obtain sudo access"
            return 1
        fi
    else
        log_error "No TTY available and passwordless sudo not configured"
        return 1
    fi
    
    # Start background process to refresh sudo timestamp every 50 seconds
    # (default sudo timeout is 5 minutes, so 50 seconds is safe)
    (
        while true; do
            sudo -n true 2>/dev/null
            sleep 50
        done
    ) &
    export KODRA_SUDO_KEEPALIVE_PID=$!
    log_success "Sudo credentials cached for this session"
}

# Stop the sudo keepalive background process
stop_sudo_keepalive() {
    if [ -n "$KODRA_SUDO_KEEPALIVE_PID" ]; then
        kill "$KODRA_SUDO_KEEPALIVE_PID" 2>/dev/null || true
        unset KODRA_SUDO_KEEPALIVE_PID
    fi
}

# Track failed installations for summary
export KODRA_FAILED_INSTALLS=""
export KODRA_INSTALL_COUNT=0
export KODRA_FAIL_COUNT=0

# Run an installer script with error tracking
# Always returns 0 so the main install never halts mid-run.
# Failures are tracked in KODRA_FAIL_COUNT for the completion summary.
# Arguments:
#   $1 - Path to installer script
#   $@ - Additional arguments passed to the script
# Returns: 0 always (failures tracked in KODRA_FAIL_COUNT)
run_installer() {
    local script="$1"
    shift
    
    if [ ! -f "$script" ]; then
        log_warning "Installer not found: $script"
        return 0
    fi
    
    local name=$(basename "$script" .sh)
    log_info "Installing $name..."
    
    ((KODRA_INSTALL_COUNT++)) || true
    
    # Capture output for debugging
    local output_file="/tmp/kodra-install-${name}.log"
    
    # Ensure Homebrew is in PATH for sub-scripts
    if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null)" || true
        export PATH
    fi
    
    if bash "$script" "$@" >> "$output_file" 2>&1; then
        log_success "$name installed"
        rm -f "$output_file"  # Clean up on success
    else
        local exit_code=$?
        ((KODRA_FAIL_COUNT++)) || true
        KODRA_FAILED_INSTALLS="${KODRA_FAILED_INSTALLS}${name} (exit: ${exit_code})\n"
        
        # Log failure details
        echo "" >> "$KODRA_LOG_FILE"
        echo "=== FAILED: $name (exit code: $exit_code) ===" >> "$KODRA_LOG_FILE"
        cat "$output_file" >> "$KODRA_LOG_FILE" 2>/dev/null || true
        echo "=== END $name ===" >> "$KODRA_LOG_FILE"
        
        log_error "Failed to install $name"
        if [ "${KODRA_DEBUG:-false}" = "true" ]; then
            log_warning "  Details saved to: $output_file"
        fi
    fi
    
    # Always continue — failures are tracked in KODRA_FAIL_COUNT
    return 0
}

# Add a directory to PATH in .bashrc and .zshrc using marker blocks
# Idempotent — safe to call multiple times; existing blocks are updated in place
# Arguments:
#   $1 - Directory to add to PATH
add_to_path() {
    local dir="$1"
    local marker_start="# >>> kodra path: $dir >>>"
    local marker_end="# <<< kodra path: $dir <<<"
    local block="$marker_start
export PATH=\"$dir:\$PATH\"
$marker_end"
    
    for config in "$HOME/.bashrc" "$HOME/.zshrc"; do
        [ -f "$config" ] && _kodra_update_shell_config "$config" "$marker_start" "$marker_end" "$block"
    done
}

# Add Kodra shell integration to .bashrc, .zshrc, and .profile
# Injects a source line for kodra.sh wrapped in marker blocks so it
# can be updated or removed cleanly on re-runs
add_shell_integration() {
    local kodra_dir="${KODRA_DIR:-$HOME/.kodra}"
    local marker_start="# >>> kodra initialize >>>"
    local marker_end="# <<< kodra initialize <<<"
    
    local shell_block
    shell_block=$(cat <<BLOCK
$marker_start
# !! Contents within this block are managed by Kodra. Do not edit. !!
[ -f "$kodra_dir/configs/shell/kodra.sh" ] && source "$kodra_dir/configs/shell/kodra.sh"
$marker_end
BLOCK
)
    
    # Add to .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        _kodra_update_shell_config "$HOME/.bashrc" "$marker_start" "$marker_end" "$shell_block"
    fi
    
    # Add to .zshrc (create if zsh is installed but no .zshrc)
    if command -v zsh &>/dev/null; then
        touch "$HOME/.zshrc"
        _kodra_update_shell_config "$HOME/.zshrc" "$marker_start" "$marker_end" "$shell_block"
    fi
    
    # Add XDG_DATA_DIRS to ~/.profile for GNOME session (Flatpak app launcher)
    if [ -f "$HOME/.profile" ]; then
        local profile_marker_start="# >>> kodra profile >>>"
        local profile_marker_end="# <<< kodra profile <<<"
        local profile_block
        profile_block=$(cat <<BLOCK
$profile_marker_start
# !! Contents within this block are managed by Kodra. Do not edit. !!
if [ -d "/var/lib/flatpak/exports/share" ]; then
    export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:\$HOME/.local/share/flatpak/exports/share:\${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
fi
$profile_marker_end
BLOCK
)
        _kodra_update_shell_config "$HOME/.profile" "$profile_marker_start" "$profile_marker_end" "$profile_block"
    fi
    
    # Create completion directories
    mkdir -p "$HOME/.local/share/bash-completion/completions"
    mkdir -p "$HOME/.config/zsh/completions"
}

# Replace or append a marker-delimited block in a shell config file
# Arguments:
#   $1 - File path (e.g., ~/.bashrc)
#   $2 - Marker start string
#   $3 - Marker end string
#   $4 - Full block content (including markers)
_kodra_update_shell_config() {
    local file="$1"
    local marker_start="$2"
    local marker_end="$3"
    local block="$4"
    
    if grep -q "$marker_start" "$file" 2>/dev/null; then
        # Block exists — replace it (handles updates)
        local tmp=$(mktemp)
        awk -v start="$marker_start" -v end="$marker_end" -v block="$block" '
            $0 ~ start { skip=1; print block; next }
            $0 ~ end { skip=0; next }
            !skip { print }
        ' "$file" > "$tmp"
        mv "$tmp" "$file"
    else
        # Block doesn't exist — append it
        echo "" >> "$file"
        echo "$block" >> "$file"
    fi
}

# Check if a command is available on PATH
# Arguments: $1 - command name
is_installed() {
    command -v "$1" &> /dev/null
}

# Check if a Flatpak app is installed by searching the app list
# Arguments: $1 - Flatpak app ID or substring
is_flatpak_installed() {
    flatpak list --app 2>/dev/null | grep -q "$1"
}

# Get the latest release tag from a GitHub repository
# Arguments: $1 - owner/repo (e.g., "charmbracelet/gum")
# Returns: tag name string (e.g., "v0.14.0")
get_github_release() {
    local repo="$1"
    curl -s --max-time 10 "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Download and install a .deb package from a URL
# Falls back to apt-get -f to resolve broken dependencies
# Arguments: $1 - URL of the .deb file
install_deb() {
    local url="$1"
    local temp_deb=$(mktemp)
    
    curl -sL --max-time 60 "$url" -o "$temp_deb"
    sudo dpkg -i "$temp_deb" || sudo apt-get install -f -y
    rm -f "$temp_deb"
}

# Create a directory (and parents) if it doesn't already exist
# Arguments: $1 - directory path
ensure_dir() {
    mkdir -p "$1"
}
