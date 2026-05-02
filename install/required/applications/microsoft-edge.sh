#!/usr/bin/env bash
#
# Install Microsoft Edge Browser
#

source "${KODRA_DIR:-$HOME/.kodra}/lib/utils.sh"

if command -v microsoft-edge-stable &> /dev/null; then
    log_info "Microsoft Edge already installed"
    exit 0
fi

log_info "Installing Microsoft Edge..."

# Install prerequisites
sudo apt-get install -y curl apt-transport-https

# Add Microsoft GPG key
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | \
    sudo gpg --dearmor -o /usr/share/keyrings/microsoft-edge-keyring.gpg

# Add Microsoft Edge repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge-keyring.gpg] https://packages.microsoft.com/repos/edge stable main" | \
    sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null

# Update and install
sudo apt-get update
sudo apt-get install -y microsoft-edge-stable

log_success "Microsoft Edge installed!"
echo "  Chromium-based browser with enterprise features"
