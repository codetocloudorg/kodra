#!/usr/bin/env bash
#
# k9s Installer - Terminal UI for Kubernetes
# https://k9scli.io/
#

set -e

if command -v k9s &> /dev/null; then
    echo "k9s already installed: $(k9s version --short 2>/dev/null || k9s version | head -1)"
    exit 0
fi

echo "Installing k9s..."

# Try Homebrew first (works on both Linux and macOS)
if command -v brew &> /dev/null; then
    brew install derailed/k9s/k9s
else
    # Fallback: direct binary install
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep -Po '"tag_name": "\K[^"]*')
    
    # Detect architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
    esac
    
    # Download and install
    curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz" | \
        sudo tar xzf - -C /usr/local/bin k9s
    
    sudo chmod +x /usr/local/bin/k9s
fi

# Setup completions
mkdir -p ~/.local/share/bash-completion/completions
mkdir -p ~/.config/zsh/completions
k9s completion bash > ~/.local/share/bash-completion/completions/k9s 2>/dev/null || true
k9s completion zsh > ~/.config/zsh/completions/_k9s 2>/dev/null || true

# Verify installation
k9s version --short 2>/dev/null || k9s version

# Create desktop file for app launcher
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/k9s.desktop" << 'EOF'
[Desktop Entry]
Name=K9s
GenericName=Kubernetes CLI
Comment=Kubernetes cluster manager
Exec=k9s
Terminal=true
Type=Application
Keywords=kubernetes;k8s;cluster;
Icon=utilities-terminal
Categories=Development;
EOF
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo "k9s installed successfully!"
echo "  Completions configured for bash and zsh"
echo "  Run 'k9s' to launch Kubernetes cluster UI"
