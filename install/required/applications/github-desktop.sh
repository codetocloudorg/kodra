#!/usr/bin/env bash
#
# Install GitHub Desktop
# Visual Git client from GitHub
#

source "${KODRA_DIR:-$HOME/.kodra}/lib/utils.sh"

if command -v github-desktop &> /dev/null || dpkg -l github-desktop &> /dev/null; then
    log_info "GitHub Desktop already installed"
    exit 0
fi

log_info "Installing GitHub Desktop..."

# GitHub Desktop for Linux - using shiftkey releases (community fork)
# https://github.com/shiftkey/desktop

ARCH=$(dpkg --print-architecture)
if [ "$ARCH" != "amd64" ]; then
    log_warning "GitHub Desktop only available for amd64 architecture"
    log_info "Consider using lazygit (already installed) for terminal Git UI"
    exit 0
fi

# Get latest release version
LATEST_RELEASE=$(curl -s https://api.github.com/repos/shiftkey/desktop/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_RELEASE" ]; then
    log_warning "Could not fetch latest GitHub Desktop release"
    exit 0
fi

# Remove 'release-' prefix if present
VERSION="${LATEST_RELEASE#release-}"

log_info "Downloading GitHub Desktop $VERSION..."

# Download the deb package
DEB_URL="https://github.com/shiftkey/desktop/releases/download/${LATEST_RELEASE}/GitHubDesktop-linux-amd64-${VERSION}.deb"
TEMP_DEB="/tmp/github-desktop.deb"

if curl -sL "$DEB_URL" -o "$TEMP_DEB"; then
    sudo dpkg -i "$TEMP_DEB" 2>/dev/null || sudo apt-get install -f -y
    rm -f "$TEMP_DEB"
    
    log_success "GitHub Desktop installed!"
    echo "  Visual Git client for managing repositories"
    echo "  Launch from applications menu or run: github-desktop"
else
    log_warning "Failed to download GitHub Desktop"
    rm -f "$TEMP_DEB"
    exit 0
fi
