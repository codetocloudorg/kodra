#!/usr/bin/env bash
#
# Nerd Fonts Installer
# Iconic font aggregator, collection, and patcher
# https://www.nerdfonts.com/
#

set -e

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Check if fonts already installed
if fc-list | grep -qi "JetBrainsMono Nerd"; then
    echo "Nerd Fonts already installed"
    exit 0
fi

# Fonts to install
FONTS=(
    "JetBrainsMono"
    "FiraCode"
    "Hack"
    "CascadiaCode"
    "UbuntuMono"
)

echo "Installing Nerd Fonts..."

for font in "${FONTS[@]}"; do
    echo "  Downloading $font..."
    
    # Download from Nerd Fonts releases (use curl for better IPv4/IPv6 handling)
    curl -fsSL -o "/tmp/${font}.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"
    
    # Extract to fonts directory
    unzip -qo "/tmp/${font}.zip" -d "$FONT_DIR/${font}" -x "*.md" -x "*.txt" -x "LICENSE*" 2>/dev/null || true
    
    # Cleanup
    rm -f "/tmp/${font}.zip"
    
    echo "    ✓ $font installed"
done

# Rebuild font cache
echo "Rebuilding font cache..."
fc-cache -f

echo ""
echo "Nerd Fonts installed successfully!"
echo ""
echo "Available fonts:"
echo "  - JetBrainsMono Nerd Font (recommended)"
echo "  - FiraCode Nerd Font"
echo "  - Hack Nerd Font"
echo "  - CaskaydiaCove Nerd Font (Cascadia Code)"
echo "  - UbuntuMono Nerd Font"
echo ""
echo "Configure your terminal to use a Nerd Font for icons."
