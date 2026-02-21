#!/usr/bin/env bash
#
# Uninstall Homebrew
#

set -e

echo "Removing Homebrew..."
echo ""
echo "WARNING: This will remove all Homebrew-installed packages."
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

if [ -d /home/linuxbrew/.linuxbrew ]; then
    # Use official uninstall script
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    
    # Remove from PATH in shell configs
    sed -i '/linuxbrew/d' ~/.bashrc 2>/dev/null || true
    sed -i '/linuxbrew/d' ~/.zshrc 2>/dev/null || true
    sed -i '/linuxbrew/d' ~/.profile 2>/dev/null || true
    
    echo "Homebrew uninstalled."
else
    echo "Homebrew not found."
fi
