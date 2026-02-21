#!/usr/bin/env bash
#
# Uninstall Ghostty terminal
#

set -e

echo "Removing Ghostty..."

# Remove ghostty package
sudo apt-get purge -y ghostty 2>/dev/null || true

# Remove repository
sudo rm -f /etc/apt/sources.list.d/ghostty.list
sudo rm -f /etc/apt/keyrings/ghostty.asc

# Remove config?
read -p "Remove Ghostty config (~/.config/ghostty)? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/.config/ghostty
    echo "Ghostty config removed."
fi

sudo apt-get autoremove -y
echo "Ghostty uninstalled."
