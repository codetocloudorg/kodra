#!/usr/bin/env bash
#
# Kodra Pre-flight Checks
# System validation before installation
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Source utils for logging
if [ -f "$KODRA_DIR/lib/utils.sh" ]; then
    source "$KODRA_DIR/lib/utils.sh"
fi

# Check if a command exists
# Args: $1 = command name
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if running on Ubuntu
is_ubuntu() {
    [ -f /etc/os-release ] && grep -q "ubuntu" /etc/os-release
}

# Check if running on ARM architecture
is_arm() {
    local arch=$(uname -m)
    [[ "$arch" == "aarch64" || "$arch" == "arm64" || "$arch" == arm* ]]
}

# Check if running on x86_64
is_x86_64() {
    [ "$(uname -m)" = "x86_64" ]
}

# Get Ubuntu version number
get_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${VERSION_ID:-0}"
    else
        echo "0"
    fi
}

# Check minimum Ubuntu version
# Args: $1 = minimum version (default: 24)
check_min_ubuntu_version() {
    local min_version="${1:-24}"
    local current=$(get_ubuntu_version | cut -d. -f1)
    
    [ "$current" -ge "$min_version" ]
}

# Check available disk space
# Args: $1 = minimum GB required (default: 10)
check_disk_space() {
    local min_gb="${1:-10}"
    local available_kb=$(df -k "$HOME" | tail -1 | awk '{print $4}')
    local available_gb=$((available_kb / 1024 / 1024))
    
    if [ "$available_gb" -ge "$min_gb" ]; then
        return 0
    else
        log_warning "Low disk space: ${available_gb}GB available (${min_gb}GB recommended)"
        return 1
    fi
}

# Check internet connectivity
# Args: $1 = host to ping (default: github.com)
check_internet() {
    local host="${1:-github.com}"
    
    if ping -c 1 -W 5 "$host" &> /dev/null; then
        return 0
    elif curl -s --max-time 5 "https://$host" &> /dev/null; then
        return 0
    else
        log_error "No internet connection"
        return 1
    fi
}

# Check if running as root (should NOT be)
check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "Do not run Kodra as root. Run as a normal user with sudo access."
        return 1
    fi
    return 0
}

# Check sudo access without password (or with cached password)
check_sudo() {
    if sudo -v &> /dev/null; then
        return 0
    else
        log_error "Sudo access required"
        return 1
    fi
}

# Check if running in a graphical environment
is_graphical() {
    [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]
}

# Check if GNOME is running
is_gnome() {
    [ "${XDG_CURRENT_DESKTOP:-}" = "GNOME" ] || [ "${XDG_CURRENT_DESKTOP:-}" = "ubuntu:GNOME" ]
}

# Check if running in WSL
is_wsl() {
    grep -qi microsoft /proc/version 2>/dev/null
}

# Check if running in Docker/container
is_container() {
    [ -f /.dockerenv ] || grep -q docker /proc/1/cgroup 2>/dev/null || [ -n "${container:-}" ]
}

# Retry a command with exponential backoff
# Args: $1 = max attempts, $2+ = command to run
retry() {
    local max_attempts=$1
    shift
    local attempt=1
    local delay=1
    
    while [ $attempt -le $max_attempts ]; do
        if "$@"; then
            return 0
        fi
        
        if [ $attempt -lt $max_attempts ]; then
            log_warning "Attempt $attempt failed. Retrying in ${delay}s..."
            sleep $delay
            delay=$((delay * 2))
        fi
        
        ((attempt++))
    done
    
    log_error "Failed after $max_attempts attempts: $*"
    return 1
}

# Download file with verification
# Args: $1 = URL, $2 = output path, $3 = optional sha256sum
download_file() {
    local url="$1"
    local output="$2"
    local expected_sha="${3:-}"
    
    # Create output directory
    mkdir -p "$(dirname "$output")"
    
    # Download
    if command_exists wget; then
        wget -q --show-progress -O "$output" "$url" || return 1
    elif command_exists curl; then
        curl -fsSL -o "$output" "$url" || return 1
    else
        log_error "Neither wget nor curl available"
        return 1
    fi
    
    # Verify checksum if provided
    if [ -n "$expected_sha" ]; then
        local actual_sha=$(sha256sum "$output" | cut -d' ' -f1)
        if [ "$actual_sha" != "$expected_sha" ]; then
            log_error "Checksum mismatch for $output"
            rm -f "$output"
            return 1
        fi
    fi
    
    return 0
}

# Run all pre-flight checks
# Returns: 0 if all pass, 1 if any fail
run_preflight_checks() {
    local failed=0
    
    echo ""
    echo "Running pre-flight checks..."
    echo ""
    
    # Check not root
    if check_not_root; then
        log_success "Not running as root"
    else
        ((failed++))
    fi
    
    # Check Ubuntu
    if is_ubuntu; then
        local version=$(get_ubuntu_version)
        if check_min_ubuntu_version 24; then
            log_success "Ubuntu $version detected"
        else
            log_warning "Ubuntu $version detected (24.04+ recommended)"
        fi
    else
        log_warning "Not Ubuntu - some features may not work"
    fi
    
    # Check architecture
    if is_x86_64; then
        log_success "x86_64 architecture"
    elif is_arm; then
        log_warning "ARM architecture - some tools may be unavailable"
    fi
    
    # Check disk space
    if check_disk_space 10; then
        log_success "Disk space OK"
    else
        ((failed++))
    fi
    
    # Check internet
    if check_internet; then
        log_success "Internet connection OK"
    else
        ((failed++))
    fi
    
    # Check sudo
    if check_sudo; then
        log_success "Sudo access OK"
    else
        ((failed++))
    fi
    
    # Check environment
    if is_container; then
        log_info "Running in container (desktop features disabled)"
    elif is_wsl; then
        log_info "Running in WSL (desktop features limited)"
    elif is_graphical; then
        log_success "Graphical environment detected"
    else
        log_info "No graphical environment (desktop features disabled)"
    fi
    
    echo ""
    
    if [ $failed -gt 0 ]; then
        log_error "$failed pre-flight check(s) failed"
        return 1
    fi
    
    log_success "All pre-flight checks passed"
    return 0
}
