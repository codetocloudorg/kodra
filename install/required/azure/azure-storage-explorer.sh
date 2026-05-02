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

# Snap requires a fully functional snapd — test with an actual snap command
# systemctl may report "active" even when snap is broken in containers
if ! command -v snap &>/dev/null; then
    echo "[WARN] snap not installed — skipping Azure Storage Explorer"
    echo "Install manually on a full system: sudo snap install storage-explorer"
    exit 0
fi

# Test snap connectivity with timeout (catches broken snapd in containers)
if ! timeout 10 snap list &>/dev/null; then
    echo "[WARN] snapd not functional (container environment?) — skipping Azure Storage Explorer"
    echo "Install manually on a full system: sudo snap install storage-explorer"
    exit 0
fi

# Install via snap with timeout (large GUI app, give it 120s)
if ! timeout 120 sudo snap install storage-explorer; then
    echo "[WARN] snap install timed out or failed — skipping Azure Storage Explorer"
    echo "Install manually: sudo snap install storage-explorer"
    exit 0
fi

echo "Azure Storage Explorer installed successfully!"
echo "Launch with: storage-explorer"
