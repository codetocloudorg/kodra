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
TOFU_INSTALLER=$(mktemp "${TMPDIR:-/tmp}/kodra-opentofu.XXXXXX")
trap 'rm -f "$TOFU_INSTALLER"' EXIT
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o "$TOFU_INSTALLER"
chmod +x "$TOFU_INSTALLER"
"$TOFU_INSTALLER" --install-method deb

# Verify installation
tofu version

echo "OpenTofu installed successfully!"
echo ""
echo "OpenTofu is a drop-in replacement for Terraform."
echo "Commands are the same: tofu init, tofu plan, tofu apply"
