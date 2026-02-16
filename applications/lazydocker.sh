#!/usr/bin/env bash
#
# lazydocker Installer
# Terminal UI for Docker
# https://github.com/jesseduffield/lazydocker
#

set -e

# Install lazydocker if not present
if ! command -v lazydocker &> /dev/null; then
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
fi

# Always create desktop file
if command -v lazydocker &>/dev/null; then
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/lazydocker.desktop" << 'EOF'
[Desktop Entry]
Name=LazyDocker
GenericName=Docker Client
Comment=Simple terminal UI for docker commands
Exec=lazydocker
Terminal=true
Type=Application
Keywords=docker;container;
Icon=docker
Categories=Development;
EOF
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

echo "lazydocker installed successfully!"
echo "Run 'lazydocker' to launch the terminal UI"
