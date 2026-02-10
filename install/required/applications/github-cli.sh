#!/usr/bin/env bash
#
# GitHub CLI Installer
# https://cli.github.com/
#

set -e

if command -v gh &> /dev/null; then
    echo "GitHub CLI already installed: $(gh --version | head -1)"
    exit 0
fi

# Add GitHub CLI repository (use curl for better IPv4/IPv6 handling)
sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# Verify installation
gh --version

echo ""
echo "GitHub CLI installed successfully!"
echo "Run 'gh auth login' to authenticate"
