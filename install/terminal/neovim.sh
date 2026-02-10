#!/usr/bin/env bash
#
# Neovim Installer
# Hyperextensible Vim-based text editor
# https://neovim.io/
#

set -e

if command -v nvim &> /dev/null; then
    echo "Neovim already installed: $(nvim --version | head -1)"
    exit 0
fi

# Install latest stable Neovim via Homebrew (recommended for latest version)
if command -v brew &> /dev/null; then
    brew install neovim
else
    # Fallback: Install from Ubuntu repos or PPA
    sudo add-apt-repository -y ppa:neovim-ppa/stable
    sudo apt-get update
    sudo apt-get install -y neovim
fi

# Install dependencies for plugins
sudo apt-get install -y python3-neovim

# Create config directory
mkdir -p "$HOME/.config/nvim"

# Copy Kodra's Neovim configuration if available
if [ -f "$KODRA_DIR/configs/nvim/init.lua" ]; then
    cp "$KODRA_DIR/configs/nvim/init.lua" "$HOME/.config/nvim/init.lua"
fi

# Set as default editor
if ! grep -q "EDITOR=nvim" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export EDITOR=nvim' >> "$HOME/.bashrc"
fi
if ! grep -q "EDITOR=nvim" "$HOME/.zshrc" 2>/dev/null; then
    echo 'export EDITOR=nvim' >> "$HOME/.zshrc"
fi

# Verify installation
nvim --version | head -1

echo ""
echo "Neovim installed successfully!"
echo ""
echo "Get started:"
echo "  nvim              Open Neovim"
echo "  nvim file.txt     Edit a file"
echo "  :Tutor            Run the built-in tutorial"
