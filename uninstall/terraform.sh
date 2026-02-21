#!/usr/bin/env bash
#
# Uninstall Terraform
#

set -e

echo "Removing Terraform..."

# Via apt (Hashicorp repo)
if dpkg -l terraform &>/dev/null 2>&1; then
    sudo apt-get purge -y terraform
fi

# Via Homebrew
if command -v brew &>/dev/null && brew list terraform &>/dev/null 2>&1; then
    brew uninstall terraform
fi

# Direct install
sudo rm -f /usr/local/bin/terraform
sudo rm -f /usr/bin/terraform

# Remove repository
sudo rm -f /etc/apt/sources.list.d/hashicorp.list
sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "Terraform uninstalled."
echo "Note: Terraform state files in your projects are not affected."
