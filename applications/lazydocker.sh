#!/usr/bin/env bash
#
# lazydocker Installer
# Terminal UI for Docker
# https://github.com/jesseduffield/lazydocker
#

set -e

if command -v lazydocker &> /dev/null; then
    echo "lazydocker already installed: $(lazydocker --version)"
    exit 0
fi

# Install via Homebrew (cross-platform, always latest)
if command -v brew &> /dev/null; then
    brew install lazydocker
else
    # Fallback: Install binary directly
    LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazydocker.tar.gz lazydocker
    sudo mv lazydocker /usr/local/bin/
    rm lazydocker.tar.gz
fi

echo "lazydocker installed successfully!"
echo "Run 'lazydocker' to launch the terminal UI"
