#!/usr/bin/env bash
#
# Visual Studio Code Installer
# https://code.visualstudio.com/
#
# Installs VS Code with 12 essential extensions for cloud-native development
#

# Don't use set -e globally - we handle errors gracefully for extensions

if command -v code &> /dev/null; then
    echo "VS Code already installed: $(code --version | head -1)"
else
    # Download and install VS Code .deb
    wget -qO /tmp/vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo dpkg -i /tmp/vscode.deb || sudo apt-get install -f -y
    rm /tmp/vscode.deb

    # Verify installation
    code --version
fi

# Top 12 essential extensions for cloud-native Azure development
# Keep it lean - users can add more as needed
echo "Installing essential extensions..."

EXTENSIONS=(
    # AI - Your coding copilot
    "github.copilot"                       # AI code completion & chat
    
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
    
    # Look & Feel
    "github.github-vscode-theme"           # GitHub Dark theme
    "PKief.material-icon-theme"            # File icons
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
echo ""
echo "Essential tools ready:"
echo "  • AI assistance (Copilot)"
echo "  • Infrastructure as Code (Bicep, Terraform)"
echo "  • Containers (Docker, Kubernetes, Dev Containers)"
echo "  • Azure (azd integration)"
echo ""
echo "Add more extensions as needed: code --install-extension <id>"

# Always exit successfully - VS Code is installed even if some extensions failed
exit 0
