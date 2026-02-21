#!/usr/bin/env bash
#
# Uninstall kubectl
#

set -e

echo "Removing kubectl..."

# Remove kubectl
if command -v kubectl &>/dev/null; then
    # Via apt
    sudo apt-get purge -y kubectl 2>/dev/null || true
    
    # Via snap
    sudo snap remove kubectl 2>/dev/null || true
    
    # Direct install
    sudo rm -f /usr/local/bin/kubectl
fi

# Remove repository
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Remove config?
read -p "Remove kubectl config (~/.kube)? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/.kube
    echo "kubectl config removed."
fi

echo "kubectl uninstalled."
