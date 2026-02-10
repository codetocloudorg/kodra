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
sudo apt-get update
sudo apt-get install -y flatpak

# Add Flathub repository
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install GNOME Software plugin for Flatpak (optional, for GUI)
sudo apt-get install -y gnome-software-plugin-flatpak 2>/dev/null || true

echo ""
echo "Flatpak installed successfully!"
echo "Flathub repository added."
echo ""
echo "Note: A system restart may be required for Flatpak apps to appear in launcher."
