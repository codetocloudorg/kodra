#!/usr/bin/env bash
#
# Postman Installer
# API development platform
# https://www.postman.com/
#

set -e

# Check if already installed
if flatpak list 2>/dev/null | grep -q "com.getpostman.Postman"; then
    echo "Postman already installed (Flatpak)"
    exit 0
fi

# Install via Flatpak
if command -v flatpak &> /dev/null; then
    flatpak install -y flathub com.getpostman.Postman
    echo "Postman installed via Flatpak!"
else
    # Fallback: Snap
    sudo snap install postman
    echo "Postman installed via Snap!"
fi
