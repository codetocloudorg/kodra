#!/usr/bin/env bash
#
# Ghostty Terminal Installer
# https://ghostty.org/
# Uses pre-built .deb from https://github.com/mkasberg/ghostty-ubuntu
#

set -e

echo "👻 Installing Ghostty..."

# Install Ghostty if not present
if ! command -v ghostty &> /dev/null; then
    # Check OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - use Homebrew
        if command -v brew &> /dev/null; then
            brew install --cask ghostty
        else
            echo "Please install Homebrew first: https://brew.sh"
            exit 1
        fi
    elif [[ -f /etc/debian_version ]]; then
        # Ubuntu/Debian - use pre-built .deb from mkasberg/ghostty-ubuntu
        echo "Installing Ghostty on Ubuntu via pre-built .deb package..."
        
        # Get latest release info from mkasberg/ghostty-ubuntu
        RELEASE_INFO=$(curl -s https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest)
        
        # Determine architecture
        ARCH=$(dpkg --print-architecture)
        
        # Determine Ubuntu version
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            UBUNTU_VERSION="${VERSION_ID}"
        else
            UBUNTU_VERSION="24.04"
        fi
        
        # Map architecture for download URL
        case "$ARCH" in
            amd64) DEB_ARCH="amd64" ;;
            arm64) DEB_ARCH="arm64" ;;
            *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
        esac
        
        # Find the appropriate .deb URL for Ubuntu 24.04
        # Format: ghostty_X.X.X-X.ppa1_ARCH_24.04.deb
        DEB_URL=$(echo "$RELEASE_INFO" | grep -o "https://[^\"]*${DEB_ARCH}_24.04.deb" | head -1)
        
        if [ -z "$DEB_URL" ]; then
            echo "Could not find .deb package for Ubuntu 24.04 ${DEB_ARCH}"
            echo "Falling back to install script..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
        else
            echo "Downloading: $DEB_URL"
            DEB_FILE="/tmp/ghostty-ubuntu.deb"
            curl -fsSL -o "$DEB_FILE" "$DEB_URL"
            
            # Install the .deb package
            sudo dpkg -i "$DEB_FILE" || sudo apt-get install -f -y
            
            # Cleanup
            rm -f "$DEB_FILE"
            
            echo "✅ Ghostty installed from pre-built .deb package"
        fi
    fi
fi

# Always configure (even if already installed)

# Set Ghostty as the default terminal emulator
if command -v update-alternatives &> /dev/null && command -v ghostty &> /dev/null; then
    GHOSTTY_PATH=$(which ghostty)
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$GHOSTTY_PATH" 100 2>/dev/null || true
    sudo update-alternatives --set x-terminal-emulator "$GHOSTTY_PATH" 2>/dev/null || true
    echo "✅ Ghostty set as default terminal"
fi

# Create config directory
mkdir -p "$HOME/.config/ghostty"

# Copy Kodra's Ghostty configuration
KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
if [ -f "$KODRA_DIR/configs/ghostty/config" ]; then
    cp "$KODRA_DIR/configs/ghostty/config" "$HOME/.config/ghostty/config"
fi

# Copy theme
CURRENT_THEME="${KODRA_THEME:-tokyo-night}"
if [ -f "$KODRA_DIR/themes/$CURRENT_THEME/ghostty.conf" ]; then
    cp "$KODRA_DIR/themes/$CURRENT_THEME/ghostty.conf" "$HOME/.config/ghostty/theme"
fi

echo "✅ Ghostty installed successfully!"
echo "   Run 'ghostty' to launch"
