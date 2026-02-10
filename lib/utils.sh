#!/usr/bin/env bash
#
# Kodra Utility Functions
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

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

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

# Run an installer script (non-fatal in debug mode)
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
    
    if bash "$script" "$@" 2>&1 | tee -a "$output_file"; then
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
        
        if [ "${KODRA_DEBUG:-false}" = "true" ]; then
            log_warning "Failed: $name - continuing (debug mode)"
            log_warning "  Details saved to: $output_file"
            return 0  # Don't fail in debug mode
        else
            log_error "Failed to install $name"
            return 1
        fi
    fi
}

# Add directory to PATH in shell configs
add_to_path() {
    local dir="$1"
    local export_line="export PATH=\"$dir:\$PATH\""
    
    # Add to .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "$dir" "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo "# Kodra" >> "$HOME/.bashrc"
            echo "$export_line" >> "$HOME/.bashrc"
        fi
    fi
    
    # Add to .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "$dir" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# Kodra" >> "$HOME/.zshrc"
            echo "$export_line" >> "$HOME/.zshrc"
        fi
    fi
}

# Add shell integration (aliases, completions, MOTD)
add_shell_integration() {
    local kodra_dir="${KODRA_DIR:-$HOME/.kodra}"
    local source_line="[ -f \"$kodra_dir/configs/shell/kodra.sh\" ] && source \"$kodra_dir/configs/shell/kodra.sh\""
    
    # Add to .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "kodra.sh" "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo "# Kodra shell integration (aliases, completions, tips)" >> "$HOME/.bashrc"
            echo "$source_line" >> "$HOME/.bashrc"
        fi
    fi
    
    # Add to .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "kodra.sh" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# Kodra shell integration (aliases, completions, tips)" >> "$HOME/.zshrc"
            echo "$source_line" >> "$HOME/.zshrc"
        fi
    fi
    
    # Create completion directories
    mkdir -p "$HOME/.local/share/bash-completion/completions"
    mkdir -p "$HOME/.config/zsh/completions"
}

# Check if an app is already installed
is_installed() {
    command -v "$1" &> /dev/null
}

# Check if a flatpak app is installed
is_flatpak_installed() {
    flatpak list --app 2>/dev/null | grep -q "$1"
}

# Get latest GitHub release version
get_github_release() {
    local repo="$1"
    curl -s "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Download and install a .deb file
install_deb() {
    local url="$1"
    local temp_deb=$(mktemp)
    
    curl -sL "$url" -o "$temp_deb"
    sudo dpkg -i "$temp_deb" || sudo apt-get install -f -y
    rm -f "$temp_deb"
}

# Ensure a directory exists
ensure_dir() {
    mkdir -p "$1"
}
