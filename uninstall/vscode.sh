#!/usr/bin/env bash
#
# Uninstall VS Code
#

set -e

echo "Removing VS Code..."

# Via apt (official)
if dpkg -l code &>/dev/null 2>&1; then
    sudo apt-get purge -y code
fi

# Via snap
if snap list code &>/dev/null 2>&1; then
    sudo snap remove code
fi

# Via flatpak
if flatpak list | grep -q "com.visualstudio.code"; then
    flatpak uninstall -y com.visualstudio.code
fi

# Remove repository
sudo rm -f /etc/apt/sources.list.d/vscode.list
sudo rm -f /etc/apt/keyrings/vscode.gpg
sudo rm -f /usr/share/keyrings/packages.microsoft.gpg

# Remove config/extensions?
read -p "Remove VS Code settings and extensions (~/.config/Code, ~/.vscode)? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/.config/Code
    rm -rf ~/.vscode
    echo "VS Code settings removed."
fi

sudo apt-get autoremove -y
echo "VS Code uninstalled."
