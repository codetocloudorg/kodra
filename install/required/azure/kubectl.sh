#!/usr/bin/env bash
#
# kubectl Installer - Kubernetes CLI
# https://kubernetes.io/docs/tasks/tools/
#

set -e

if command -v kubectl &> /dev/null; then
    echo "kubectl already installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client | head -1)"
    exit 0
fi

echo "Installing kubectl..."

# Get latest stable version
KUBECTL_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
esac

# Download kubectl
curl -sLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"

# Verify checksum
curl -sLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl kubectl.sha256

# Setup completions directory
mkdir -p ~/.local/share/bash-completion/completions
mkdir -p ~/.config/zsh/completions

# Generate completions
kubectl completion bash > ~/.local/share/bash-completion/completions/kubectl
kubectl completion zsh > ~/.config/zsh/completions/_kubectl

# Verify
kubectl version --client

echo "kubectl installed successfully!"
echo "  Completions configured for bash and zsh"
echo "  Use 'k' alias for kubectl (configured by Kodra)"
