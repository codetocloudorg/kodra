#!/usr/bin/env bash
#
# Migration: Update Ghostty installation method
# Date: 2026-05-01
# Description: Transition from GitHub-based .deb to official apt package
#

# Remove old ghostty apt sources that pointed to GitHub
if [ -f /etc/apt/sources.list.d/ghostty.list ]; then
    sudo rm -f /etc/apt/sources.list.d/ghostty.list 2>/dev/null || true
fi

# Remove old PPA key if present
if [ -f /etc/apt/keyrings/ghostty.gpg ]; then
    sudo rm -f /etc/apt/keyrings/ghostty.gpg 2>/dev/null || true
fi

# Add the official PPA for Ubuntu < 26.04
if [ -f /etc/os-release ]; then
    . /etc/os-release
    VERSION_NUM=$(echo "$VERSION_ID" | cut -d. -f1)
    
    if [ "$VERSION_NUM" -lt 26 ]; then
        # Use community PPA for older Ubuntu
        if ! grep -q "mkasberg/ghostty" /etc/apt/sources.list.d/*.list 2>/dev/null; then
            sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu 2>/dev/null || true
        fi
    fi
fi

echo "Ghostty installation source updated"
