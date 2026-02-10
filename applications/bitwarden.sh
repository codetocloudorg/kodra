#!/usr/bin/env bash
#
# Bitwarden Installer
# Open-source password manager
# https://bitwarden.com/
#

set -e

# Check if already installed
if flatpak list 2>/dev/null | grep -q "com.bitwarden.desktop"; then
    echo "Bitwarden already installed (Flatpak)"
    exit 0
fi

if snap list 2>/dev/null | grep -q "bitwarden"; then
    echo "Bitwarden already installed (Snap)"
    exit 0
fi

# Install via Flatpak (preferred)
if command -v flatpak &> /dev/null; then
    flatpak install -y flathub com.bitwarden.desktop
    echo "Bitwarden installed via Flatpak!"
else
    # Fallback to Snap
    sudo snap install bitwarden
    echo "Bitwarden installed via Snap!"
fi

# Also install CLI
if command -v npm &> /dev/null; then
    npm install -g @bitwarden/cli
    echo "Bitwarden CLI installed!"
fi
