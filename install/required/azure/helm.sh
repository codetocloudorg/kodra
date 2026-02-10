#!/usr/bin/env bash
#
# Helm Installer - Kubernetes Package Manager
# https://helm.sh/
#

set -e

if command -v helm &> /dev/null; then
    echo "Helm already installed: $(helm version --short)"
    exit 0
fi

echo "Installing Helm..."

# Prefer Homebrew (proper package management)
if command -v brew &> /dev/null; then
    brew install helm
else
    # Fallback: official install script
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Setup completions directory
mkdir -p ~/.local/share/bash-completion/completions
mkdir -p ~/.config/zsh/completions

# Generate completions
helm completion bash > ~/.local/share/bash-completion/completions/helm
helm completion zsh > ~/.config/zsh/completions/_helm

# Add popular Helm repos
echo "Adding common Helm repositories..."
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || true
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 2>/dev/null || true
helm repo add jetstack https://charts.jetstack.io 2>/dev/null || true
helm repo update

# Verify
helm version --short

echo "Helm installed successfully!"
echo "  Completions configured for bash and zsh"
echo "  Common repos added: bitnami, ingress-nginx, jetstack"
echo "  Use 'h' alias for helm (configured by Kodra)"
