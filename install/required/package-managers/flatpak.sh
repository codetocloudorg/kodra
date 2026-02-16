#!/usr/bin/env bash
#
# Flatpak Installer
# Sandboxed application packaging
# https://flatpak.org/
#

set -e

if command -v flatpak &> /dev/null; then
    echo "Flatpak already installed: $(flatpak --version)"
    exit 0
fi

# Install flatpak
# Note: apt-get update already run by main install.sh
sudo apt-get install -y flatpak

# Add Flathub repository
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install GNOME Software plugin for Flatpak (optional, for GUI)
sudo apt-get install -y gnome-software-plugin-flatpak 2>/dev/null || true

# Ensure XDG_DATA_DIRS includes Flatpak paths for current session
# This allows desktop files to be found immediately after install
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# Update desktop database so apps appear in launcher
if command -v update-desktop-database &>/dev/null; then
    sudo update-desktop-database /var/lib/flatpak/exports/share/applications 2>/dev/null || true
    update-desktop-database "$HOME/.local/share/flatpak/exports/share/applications" 2>/dev/null || true
fi

echo ""
echo "Flatpak installed successfully!"
echo "Flathub repository added."
