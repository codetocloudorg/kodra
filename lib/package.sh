#!/usr/bin/env bash
#
# Kodra Package Management Helpers
# DRY utilities for apt, snap, deb, and flatpak installations
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Source utils for logging
if [ -f "$KODRA_DIR/lib/utils.sh" ]; then
    source "$KODRA_DIR/lib/utils.sh"
fi

# Check if a package is installed via apt
# Args: $1 = package name
is_apt_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Check if a snap is installed
# Args: $1 = snap name
is_snap_installed() {
    snap list "$1" &>/dev/null
}

# Check if a flatpak is installed
# Args: $1 = flatpak app id
is_flatpak_installed() {
    flatpak list --app | grep -q "$1"
}

# Install apt package(s) with idempotency
# Args: $@ = package name(s)
install_apt() {
    local packages=("$@")
    local to_install=()
    
    for pkg in "${packages[@]}"; do
        if ! is_apt_installed "$pkg"; then
            to_install+=("$pkg")
        fi
    done
    
    if [ ${#to_install[@]} -eq 0 ]; then
        log_info "All packages already installed"
        return 0
    fi
    
    log_info "Installing: ${to_install[*]}"
    sudo apt-get install -y -qq "${to_install[@]}"
}

# Add apt repository safely
# Args: $1 = repo line, $2 = key URL (optional), $3 = list name
add_apt_repo() {
    local repo="$1"
    local key_url="$2"
    local list_name="$3"
    local list_file="/etc/apt/sources.list.d/${list_name}.list"
    
    # Skip if already added
    if [ -f "$list_file" ]; then
        log_info "Repository already added: $list_name"
        return 0
    fi
    
    # Add GPG key if provided
    if [ -n "$key_url" ]; then
        local keyring="/etc/apt/keyrings/${list_name}.gpg"
        sudo mkdir -p /etc/apt/keyrings
        
        if [[ "$key_url" == *.asc ]]; then
            # ASCII armored key
            curl -fsSL "$key_url" | sudo gpg --dearmor -o "$keyring"
        else
            # Binary key
            curl -fsSL "$key_url" | sudo tee "$keyring" > /dev/null
        fi
        
        # Update repo line to include keyring
        repo=$(echo "$repo" | sed "s|\[|\[signed-by=$keyring |")
    fi
    
    # Add repository
    echo "$repo" | sudo tee "$list_file" > /dev/null
    log_success "Added repository: $list_name"
    
    # Update package lists
    sudo apt-get update -qq
}

# Install .deb file from URL
# Args: $1 = URL, $2 = package name (for idempotency check)
install_deb_url() {
    local url="$1"
    local pkg_name="$2"
    
    # Check if already installed
    if [ -n "$pkg_name" ] && is_apt_installed "$pkg_name"; then
        log_info "$pkg_name already installed"
        return 0
    fi
    
    local tmp_deb="/tmp/kodra-install-$$.deb"
    
    log_info "Downloading: $url"
    wget -q -O "$tmp_deb" "$url" || curl -fsSL -o "$tmp_deb" "$url"
    
    log_info "Installing .deb package..."
    sudo dpkg -i "$tmp_deb" || sudo apt-get install -f -y
    
    rm -f "$tmp_deb"
    log_success "Installed from .deb"
}

# Install local .deb file
# Args: $1 = path to .deb
install_deb_file() {
    local deb_path="$1"
    
    if [ ! -f "$deb_path" ]; then
        log_error "File not found: $deb_path"
        return 1
    fi
    
    log_info "Installing: $deb_path"
    sudo dpkg -i "$deb_path" || sudo apt-get install -f -y
    log_success "Installed .deb"
}

# Install snap package
# Args: $1 = snap name, $2 = channel (optional, default: stable), $3 = flags (optional, e.g., --classic)
install_snap() {
    local name="$1"
    local channel="${2:-stable}"
    local flags="$3"
    
    if is_snap_installed "$name"; then
        log_info "$name snap already installed"
        return 0
    fi
    
    log_info "Installing snap: $name"
    sudo snap install "$name" --channel="$channel" $flags
    log_success "Installed snap: $name"
}

# Install flatpak application
# Args: $1 = app id (e.g., com.spotify.Client), $2 = remote (optional, default: flathub)
install_flatpak() {
    local app_id="$1"
    local remote="${2:-flathub}"
    
    # Ensure flatpak is installed
    if ! command -v flatpak &>/dev/null; then
        install_apt flatpak
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi
    
    if is_flatpak_installed "$app_id"; then
        log_info "$app_id already installed"
        return 0
    fi
    
    log_info "Installing flatpak: $app_id"
    flatpak install -y "$remote" "$app_id"
    
    # Refresh desktop database so app appears in launcher immediately
    refresh_flatpak_desktop_database
    
    log_success "Installed flatpak: $app_id"
}

# Refresh desktop database for Flatpak apps
# Call this after installing Flatpak apps to ensure they appear in launcher
refresh_flatpak_desktop_database() {
    # Ensure XDG_DATA_DIRS includes Flatpak paths
    export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    
    # Update desktop database
    if command -v update-desktop-database &>/dev/null; then
        sudo update-desktop-database /var/lib/flatpak/exports/share/applications 2>/dev/null || true
        update-desktop-database "$HOME/.local/share/flatpak/exports/share/applications" 2>/dev/null || true
    fi
}

# Remove apt package
# Args: $1 = package name, $2 = purge configs (optional, default: false)
remove_apt() {
    local pkg="$1"
    local purge="${2:-false}"
    
    if ! is_apt_installed "$pkg"; then
        log_info "$pkg not installed"
        return 0
    fi
    
    if [ "$purge" = "true" ]; then
        sudo apt-get purge -y "$pkg"
    else
        sudo apt-get remove -y "$pkg"
    fi
    
    log_success "Removed: $pkg"
}

# Remove snap
# Args: $1 = snap name
remove_snap() {
    local name="$1"
    
    if ! is_snap_installed "$name"; then
        log_info "$name snap not installed"
        return 0
    fi
    
    sudo snap remove "$name"
    log_success "Removed snap: $name"
}

# Remove flatpak
# Args: $1 = app id
remove_flatpak() {
    local app_id="$1"
    
    if ! is_flatpak_installed "$app_id"; then
        log_info "$app_id not installed"
        return 0
    fi
    
    flatpak uninstall -y "$app_id"
    log_success "Removed flatpak: $app_id"
}

# Update all package managers
update_all() {
    log_info "Updating apt packages..."
    sudo apt-get update -qq && sudo apt-get upgrade -y -qq
    
    if command -v snap &>/dev/null; then
        log_info "Updating snaps..."
        sudo snap refresh
    fi
    
    if command -v flatpak &>/dev/null; then
        log_info "Updating flatpaks..."
        flatpak update -y
    fi
    
    log_success "All packages updated"
}
