#!/usr/bin/env bash
#
# Azure Storage Explorer Installer
# https://azure.microsoft.com/products/storage/storage-explorer/
#

set -e

# Check if already installed via snap
if snap list 2>/dev/null | grep -q "storage-explorer"; then
    echo "Azure Storage Explorer already installed"
    exit 0
fi

# Install via snap (official distribution method)
sudo snap install storage-explorer

echo "Azure Storage Explorer installed successfully!"
echo "Launch with: storage-explorer"
