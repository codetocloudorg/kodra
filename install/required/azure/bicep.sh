#!/usr/bin/env bash
#
# Bicep CLI Installer
# Azure's native Infrastructure as Code language
# https://learn.microsoft.com/azure/azure-resource-manager/bicep/install
#

set -e

# Check if bicep is already available (either standalone or via az)
if command -v bicep &> /dev/null; then
    echo "Bicep already installed: $(bicep --version)"
    exit 0
fi

if command -v az &> /dev/null && az bicep version &> /dev/null; then
    echo "Bicep already installed via Azure CLI: $(az bicep version 2>&1 | head -1)"
    exit 0
fi

# Install Bicep via Azure CLI (recommended method)
if command -v az &> /dev/null; then
    az bicep install
    az bicep upgrade || true  # upgrade may fail if already latest
    
    # Verify via az bicep (the recommended way)
    az bicep version
    
    # Create symlink so 'bicep' command works directly
    BICEP_PATH="$HOME/.azure/bin/bicep"
    if [[ -f "$BICEP_PATH" ]] && [[ ! -f "$HOME/.local/bin/bicep" ]]; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$BICEP_PATH" "$HOME/.local/bin/bicep"
        echo "Created symlink: ~/.local/bin/bicep -> ~/.azure/bin/bicep"
    fi
else
    # Fallback: Install standalone
    curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
    chmod +x bicep
    mkdir -p "$HOME/.local/bin"
    mv bicep "$HOME/.local/bin/bicep"
    
    # Verify standalone installation
    "$HOME/.local/bin/bicep" --version
fi

echo "Bicep CLI installed successfully!"
echo ""
echo "Get started:"
echo "  bicep build main.bicep     Compile to ARM JSON"
echo "  bicep decompile main.json  Convert ARM to Bicep"
echo "  az deployment group create --template-file main.bicep"
