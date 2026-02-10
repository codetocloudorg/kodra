#!/usr/bin/env bash
#
# Spotify Installer
# Music for coding
#

set -e

# Check if already installed
if flatpak list 2>/dev/null | grep -q "com.spotify.Client"; then
    echo "Spotify already installed (Flatpak)"
    exit 0
fi

if snap list 2>/dev/null | grep -q "spotify"; then
    echo "Spotify already installed (Snap)"
    exit 0
fi

# Install via Flatpak (preferred)
if command -v flatpak &> /dev/null; then
    flatpak install -y flathub com.spotify.Client
    echo "Spotify installed via Flatpak!"
else
    # Fallback to Snap
    sudo snap install spotify
    echo "Spotify installed via Snap!"
fi
