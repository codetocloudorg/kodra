#!/usr/bin/env bash
#
# Homebrew Installer
# The missing package manager for Linux
# https://brew.sh/
#

set -e

if command -v brew &> /dev/null; then
    echo "Homebrew already installed: $(brew --version | head -1)"
    exit 0
fi

# Install dependencies
# Note: apt-get update already run by main install.sh
sudo apt-get install -y build-essential procps curl file git

# Install Homebrew (non-interactive)
BREW_INSTALLER=$(mktemp "${TMPDIR:-/tmp}/kodra-homebrew.XXXXXX")
trap 'rm -f "$BREW_INSTALLER"' EXIT
curl -fsSL --max-time 30 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$BREW_INSTALLER"
NONINTERACTIVE=1 /bin/bash "$BREW_INSTALLER"

# Add Homebrew to PATH
BREW_PREFIX="/home/linuxbrew/.linuxbrew"
if [ -d "$BREW_PREFIX" ]; then
    eval "$($BREW_PREFIX/bin/brew shellenv)"
    
    # Add to shell configs
    for config in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$config" ]; then
            if ! grep -q "linuxbrew" "$config"; then
                echo "" >> "$config"
                echo '# Homebrew' >> "$config"
                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$config"
            fi
        fi
    done
fi

# Verify installation
brew --version

echo ""
echo "Homebrew installed successfully!"
echo ""
echo "Usage:"
echo "  brew install <package>    Install a package"
echo "  brew search <term>        Search for packages"
echo "  brew upgrade              Upgrade all packages"
