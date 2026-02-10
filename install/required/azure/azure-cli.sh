#!/usr/bin/env bash
#
# Azure CLI Installer
# https://docs.microsoft.com/cli/azure/install-azure-cli-linux
#

set -e

if command -v az &> /dev/null; then
    version=$(az version -o tsv 2>/dev/null | head -1 || az --version 2>/dev/null | head -1)
    echo "Azure CLI already installed: $version"
    exit 0
fi

# Install via Microsoft's official script
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify installation
az version

echo "Azure CLI installed successfully!"
echo "Run 'az login' to authenticate with Azure"
