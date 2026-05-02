#!/usr/bin/env bash
#
# Ghostty Terminal Installer
# https://ghostty.org/
#
# Installation methods (in priority order):
#   - Ubuntu 26.04+: Official apt repository (ghostty package)
#   - Ubuntu 24.04:  Community PPA (ppa:mkasberg/ghostty-ubuntu)
#   - Ubuntu 24.04:  Fallback — pre-built .deb from GitHub releases
#   - macOS:         Homebrew cask
#
# Note: Ghostty is migrating off GitHub (2026). The GitHub .deb download
# is kept as a fallback until the new hosting platform is announced.
# Track: https://ghostty.org/ for updates on the migration.
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

echo "👻 Installing Ghostty..."

# Install Ghostty if not present
if ! command -v ghostty &>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - use Homebrew
        if command -v brew &>/dev/null; then
            brew install --cask ghostty
        else
            echo "❌ Homebrew required on macOS. Install from https://brew.sh"
            exit 1
        fi
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        VERSION_NUM=$(echo "$VERSION_ID" | cut -d. -f1)
        
        if [ "${ID}" != "ubuntu" ] && [[ "${ID_LIKE}" != *"ubuntu"* ]] && [[ "${ID_LIKE}" != *"debian"* ]]; then
            echo "❌ Unsupported distribution: $ID"
            echo "   Install Ghostty manually from https://ghostty.org/download"
            exit 1
        fi
        
        if [ "$VERSION_NUM" -ge 26 ]; then
            # Ubuntu 26.04+ — Ghostty is in the official universe repo
            echo "Installing from official Ubuntu repository..."
            sudo apt-get update -qq
            sudo apt-get install -y ghostty
        else
            # Ubuntu 24.04/25.x — Try PPA first, fall back to GitHub .deb
            echo "Installing Ghostty on Ubuntu $VERSION_ID..."
            
            # Method 1: Community PPA (preferred — auto-updates)
            if command -v add-apt-repository &>/dev/null; then
                echo "Trying community PPA..."
                if ! grep -q "mkasberg/ghostty" /etc/apt/sources.list.d/*.list 2>/dev/null; then
                    sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu 2>/dev/null || true
                    sudo apt-get update -qq 2>/dev/null || true
                fi
                
                if sudo apt-get install -y ghostty 2>/dev/null; then
                    echo "✅ Installed via PPA"
                else
                    echo "⚠️  PPA install failed, trying GitHub .deb..."
                    install_from_github_deb=true
                fi
            else
                install_from_github_deb=true
            fi
            
            # Method 2: Pre-built .deb from GitHub releases
            # Source: https://github.com/mkasberg/ghostty-ubuntu/releases
            if [ "${install_from_github_deb:-false}" = "true" ]; then
                echo "Downloading pre-built .deb from GitHub..."
                ARCH=$(dpkg --print-architecture)
                RELEASE_INFO=$(curl -fsSL https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest 2>/dev/null)
                
                if [ -n "$RELEASE_INFO" ]; then
                    # Find .deb matching architecture and Ubuntu version
                    DEB_URL=$(echo "$RELEASE_INFO" | grep -o "https://[^\"]*${ARCH}[^\"]*\.deb" | head -1)
                    
                    if [ -n "$DEB_URL" ]; then
                        DEB_FILE=$(mktemp "${TMPDIR:-/tmp}/kodra-ghostty.XXXXXX.deb")
                        echo "Downloading: $DEB_URL"
                        curl -fsSL -o "$DEB_FILE" "$DEB_URL"
                        sudo dpkg -i "$DEB_FILE" || sudo apt-get install -f -y
                        rm -f "$DEB_FILE"
                        echo "✅ Installed from GitHub .deb"
                    else
                        echo "❌ No .deb found for $ARCH"
                        echo "   Install manually from https://ghostty.org/download"
                        exit 1
                    fi
                else
                    echo "❌ Cannot reach GitHub API"
                    echo "   Install manually from https://ghostty.org/download"
                    exit 1
                fi
            fi
        fi
    else
        echo "❌ Cannot detect OS. Install Ghostty manually from https://ghostty.org/download"
        exit 1
    fi
    
    echo "✅ Ghostty installed: $(ghostty --version 2>/dev/null || echo 'unknown version')"
else
    echo "✅ Ghostty already installed: $(ghostty --version 2>/dev/null || echo 'unknown version')"
fi

# Set Ghostty as the default terminal emulator
if command -v update-alternatives &>/dev/null && command -v ghostty &>/dev/null; then
    GHOSTTY_PATH=$(command -v ghostty)
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$GHOSTTY_PATH" 100 2>/dev/null || true
    sudo update-alternatives --set x-terminal-emulator "$GHOSTTY_PATH" 2>/dev/null || true
    echo "✅ Ghostty set as default terminal"
fi

# Create config directory
mkdir -p "$HOME/.config/ghostty"

# Copy Kodra's Ghostty configuration
if [ -f "$KODRA_DIR/configs/ghostty/config" ]; then
    cp "$KODRA_DIR/configs/ghostty/config" "$HOME/.config/ghostty/config"
fi

# Apply current theme
CURRENT_THEME="${KODRA_THEME:-tokyo-night}"
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/kodra/theme" ]; then
    CURRENT_THEME=$(cat "${XDG_CONFIG_HOME:-$HOME/.config}/kodra/theme")
fi

if [ -f "$KODRA_DIR/themes/$CURRENT_THEME/ghostty.conf" ]; then
    cp "$KODRA_DIR/themes/$CURRENT_THEME/ghostty.conf" "$HOME/.config/ghostty/theme"
fi

echo "✅ Ghostty configured successfully!"
