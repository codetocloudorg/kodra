#!/usr/bin/env bash
#
# Azure Developer CLI (azd) Installer
# https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd
#

set -e

if command -v azd &> /dev/null; then
    echo "Azure Developer CLI already installed: $(azd version)"
    exit 0
fi

# Install via official script
curl -fsSL https://aka.ms/install-azd.sh | bash

# Add to PATH for current session
export PATH="$HOME/.azd/bin:$PATH"

# Verify installation
azd version

echo "Azure Developer CLI (azd) installed successfully!"
echo ""
echo "Get started:"
echo "  azd init        Initialize a new project"
echo "  azd up          Provision and deploy"
echo "  azd templates   Browse templates"
