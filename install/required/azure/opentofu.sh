#!/usr/bin/env bash
#
# OpenTofu Installer
# Open-source Terraform alternative
# https://opentofu.org/docs/intro/install/
#

set -e

if command -v tofu &> /dev/null; then
    echo "OpenTofu already installed: $(tofu version | head -1)"
    exit 0
fi

# Install OpenTofu via official installer
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb
rm install-opentofu.sh

# Verify installation
tofu version

echo "OpenTofu installed successfully!"
echo ""
echo "OpenTofu is a drop-in replacement for Terraform."
echo "Commands are the same: tofu init, tofu plan, tofu apply"
