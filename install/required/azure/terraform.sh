#!/usr/bin/env bash
#
# Terraform Installer
# https://developer.hashicorp.com/terraform/install
#

set -e

if command -v terraform &> /dev/null; then
    echo "Terraform already installed: $(terraform version | head -1)"
    exit 0
fi

# Add HashiCorp GPG key (use curl instead of wget for better IPv4/IPv6 handling)
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install Terraform
sudo apt-get update
sudo apt-get install -y terraform

# Enable tab completion
terraform -install-autocomplete 2>/dev/null || true

# Verify installation
terraform version

echo "Terraform installed successfully!"
