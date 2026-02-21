#!/usr/bin/env bash
#
# Uninstall GitHub CLI
#

set -e

echo "Removing GitHub CLI..."

# Logout first
if command -v gh &>/dev/null; then
    gh auth logout 2>/dev/null || true
fi

# Via apt
sudo apt-get purge -y gh 2>/dev/null || true

# Remove repository
sudo rm -f /etc/apt/sources.list.d/github-cli.list
sudo rm -f /usr/share/keyrings/githubcli-archive-keyring.gpg

# Remove config?
read -p "Remove GitHub CLI config (~/.config/gh)? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/.config/gh
    echo "GitHub CLI config removed."
fi

sudo apt-get autoremove -y
echo "GitHub CLI uninstalled."
