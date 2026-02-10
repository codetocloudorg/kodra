#!/usr/bin/env bash
#
# Install Brave Browser
#

source "${KODRA_DIR:-$HOME/.kodra}/lib/utils.sh"

if command -v brave-browser &> /dev/null; then
    log_info "Brave browser already installed"
    exit 0
fi

log_info "Installing Brave browser..."

# Install prerequisites
sudo apt-get install -y curl apt-transport-https

# Add Brave GPG key
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

# Add Brave repository
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
    sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null

# Update and install
sudo apt-get update
sudo apt-get install -y brave-browser

# Set as default browser
if command -v xdg-settings &> /dev/null; then
    xdg-settings set default-web-browser brave-browser.desktop 2>/dev/null || true
fi

# Also set via update-alternatives
if command -v update-alternatives &> /dev/null; then
    sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/brave-browser 200 2>/dev/null || true
    sudo update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/brave-browser 200 2>/dev/null || true
fi

log_success "Brave browser installed and set as default!"
echo "  Privacy-focused browsing with built-in ad blocking"
