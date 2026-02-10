#!/usr/bin/env bash
#
# Kodra Update Script
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

log_info "Updating Kodra..."

# Update Kodra repository
cd "$KODRA_DIR"
git pull --quiet
log_success "Kodra repository updated"

# Run migrations
bash "$KODRA_DIR/bin/kodra-sub/migrate.sh"

# Update system packages
log_info "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y
log_success "System packages updated"

# Update Homebrew if installed
if command -v brew &> /dev/null; then
    log_info "Updating Homebrew packages..."
    brew update
    brew upgrade
    log_success "Homebrew packages updated"
fi

# Update Flatpak if installed
if command -v flatpak &> /dev/null; then
    log_info "Updating Flatpak packages..."
    flatpak update -y
    log_success "Flatpak packages updated"
fi

# Update mise runtimes if installed
if command -v mise &> /dev/null; then
    log_info "Updating mise runtimes..."
    mise upgrade
    log_success "mise runtimes updated"
fi

# Update VS Code extensions
if command -v code &> /dev/null; then
    log_info "Updating VS Code extensions..."
    code --update-extensions 2>/dev/null || true
    log_success "VS Code extensions updated"
fi

echo ""
log_success "Kodra update complete!"
