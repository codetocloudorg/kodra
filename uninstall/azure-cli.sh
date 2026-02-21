#!/usr/bin/env bash
#
# Uninstall Azure CLI
#

set -e

echo "Removing Azure CLI..."

# Logout from Azure
if command -v az &>/dev/null; then
    az logout 2>/dev/null || true
    az account clear 2>/dev/null || true
fi

# Remove packages
sudo apt-get purge -y azure-cli 2>/dev/null || true
sudo apt-get autoremove -y

# Remove repository
sudo rm -f /etc/apt/sources.list.d/azure-cli.sources
sudo rm -f /etc/apt/sources.list.d/azure-cli.list
sudo rm -f /etc/apt/keyrings/microsoft.gpg
sudo rm -f /usr/share/keyrings/microsoft-archive-keyring.gpg

# Remove Azure config
read -p "Remove Azure credentials (~/.azure)? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/.azure
    echo "Azure credentials removed."
fi

echo "Azure CLI uninstalled."
