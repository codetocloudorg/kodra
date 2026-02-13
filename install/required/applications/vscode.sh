#!/usr/bin/env bash
#
# Visual Studio Code Installer
# https://code.visualstudio.com/
#
# Installs VS Code with 13 essential extensions for cloud-native development
#

# Don't use set -e globally - we handle errors gracefully for extensions

if command -v code &> /dev/null; then
    echo "VS Code already installed: $(code --version | head -1)"
else
    # Download and install VS Code .deb (use curl for better IPv4/IPv6 handling)
    curl -fsSL -o /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo dpkg -i /tmp/vscode.deb || sudo apt-get install -f -y
    rm /tmp/vscode.deb

    # Verify installation
    code --version
fi

# Top 13 essential extensions for cloud-native Azure development
# Keep it lean - users can add more as needed
echo "Installing essential extensions..."

EXTENSIONS=(
    # AI - Your coding copilot
    "github.copilot"                       # AI code completion & chat
    "github.copilot-chat"                  # Copilot Chat
    
    # Infrastructure as Code
    "ms-azuretools.vscode-bicep"           # Bicep for Azure IaC
    "hashicorp.terraform"                  # Terraform/OpenTofu
    
    # Containers & Orchestration
    "ms-azuretools.vscode-docker"          # Docker support
    "ms-kubernetes-tools.vscode-kubernetes-tools"  # Kubernetes
    "ms-vscode-remote.remote-containers"   # Dev Containers
    
    # Azure
    "ms-azuretools.azure-dev"              # Azure Developer CLI (azd)
    
    # Git
    "eamodio.gitlens"                      # Git supercharged
    
    # Languages & Formats
    "ms-python.python"                     # Python (most used for cloud)
    "redhat.vscode-yaml"                   # YAML (K8s manifests, CI/CD)
    "esbenp.prettier-vscode"               # Code formatter
    
    # Look & Feel
    "enkia.tokyo-night"                    # Tokyo Night theme (default)
    "PKief.material-icon-theme"            # File icons
    "PKief.material-product-icons"         # Product icons
)

echo "  Installing ${#EXTENSIONS[@]} essential extensions..."
echo ""

installed=0
skipped=0

# Install extensions - don't fail on individual extension errors
for ext in "${EXTENSIONS[@]}"; do
    echo -n "  • $ext..."
    if timeout 60 code --install-extension "$ext" --force >/dev/null 2>&1; then
        ((installed++)) || true
        echo " ✓"
    else
        ((skipped++)) || true
        echo " ⚠ skipped"
    fi
done

echo ""
echo "✅ VS Code installed with $installed extensions ($skipped skipped)"

# Apply Tokyo Night theme settings
echo ""
echo "🎨 Applying Tokyo Night theme settings..."

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
VSCODE_SETTINGS_DIR="$HOME/.config/Code/User"
VSCODE_SETTINGS_FILE="$VSCODE_SETTINGS_DIR/settings.json"
KODRA_THEME_SETTINGS="$KODRA_DIR/themes/tokyo-night/vscode-settings.json"

mkdir -p "$VSCODE_SETTINGS_DIR"

if [ -f "$KODRA_THEME_SETTINGS" ]; then
    if [ -f "$VSCODE_SETTINGS_FILE" ]; then
        # Merge with existing settings (theme settings take precedence)
        if command -v jq &> /dev/null; then
            jq -s '.[0] * .[1]' "$VSCODE_SETTINGS_FILE" "$KODRA_THEME_SETTINGS" > "${VSCODE_SETTINGS_FILE}.tmp" 2>/dev/null && \
                mv "${VSCODE_SETTINGS_FILE}.tmp" "$VSCODE_SETTINGS_FILE" && \
                echo "  ✓ Tokyo Night theme applied (merged with existing settings)"
        else
            # No jq, just copy the theme settings
            cp "$KODRA_THEME_SETTINGS" "$VSCODE_SETTINGS_FILE"
            echo "  ✓ Tokyo Night theme applied"
        fi
    else
        cp "$KODRA_THEME_SETTINGS" "$VSCODE_SETTINGS_FILE"
        echo "  ✓ Tokyo Night theme applied"
    fi
else
    echo "  ⚠ Theme settings not found, using extension defaults"
fi

echo ""
echo "Essential tools ready:"
echo "  • AI assistance (Copilot + Copilot Chat)"
echo "  • Infrastructure as Code (Bicep, Terraform)"
echo "  • Containers (Docker, Kubernetes, Dev Containers)"
echo "  • Azure (azd integration)"
echo "  • Tokyo Night theme configured"
echo ""
echo "Add more extensions as needed: code --install-extension <id>"

# Always exit successfully - VS Code is installed even if some extensions failed
exit 0
