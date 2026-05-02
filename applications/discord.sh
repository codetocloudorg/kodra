#!/usr/bin/env bash
#
# Discord Installer
# Communication for developer communities
#

set -e

# Check if already installed
if flatpak list 2>/dev/null | grep -q "com.discordapp.Discord"; then
    echo "Discord already installed (Flatpak)"
    exit 0
fi

# Install via Flatpak
if command -v flatpak &> /dev/null; then
    flatpak install -y flathub com.discordapp.Discord
    echo "Discord installed via Flatpak!"
else
    # Fallback: Download .deb
    TMP_DISCORD=$(mktemp "${TMPDIR:-/tmp}/kodra-discord.XXXXXX.deb")
    trap 'rm -f "$TMP_DISCORD"' EXIT
    curl -fsSL -o "$TMP_DISCORD" "https://discord.com/api/download?platform=linux&format=deb"
    sudo dpkg -i "$TMP_DISCORD" || sudo apt-get install -f -y
    rm -f "$TMP_DISCORD"
    echo "Discord installed!"
fi
