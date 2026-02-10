#!/usr/bin/env bash
#
# ULauncher - Spotlight-style App Launcher
# Beautiful, fast app launcher bound to Super+Space
#

set -e

echo "🚀 Installing ULauncher..."

# Add ULauncher PPA
if ! grep -q "ulauncher" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    sudo add-apt-repository -y ppa:agornostal/ulauncher
    sudo apt-get update
fi

# Install
sudo apt-get install -y ulauncher

# Create config directory
mkdir -p "$HOME/.config/ulauncher"

# Configure ULauncher with dark theme
cat > "$HOME/.config/ulauncher/settings.json" << 'EOF'
{
    "blacklisted-desktop-dirs": "/usr/share/locale:/usr/share/app-install:/usr/share/kservices5:/usr/share/fk5:/usr/share/kservicetypes5:/usr/share/applications/screensavers:/usr/share/kde4:/usr/share/mimelnk",
    "clear-previous-query": true,
    "hotkey-show-app": "<Super>space",
    "render-on-screen": "mouse-pointer-monitor",
    "show-indicator-icon": false,
    "show-recent-apps": "3",
    "terminal-command": "ghostty -e",
    "theme-name": "dark"
}
EOF

# Create autostart entry
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/ulauncher.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=ULauncher
Comment=Application Launcher
Exec=ulauncher --hide-window
Icon=ulauncher
Terminal=false
Categories=Utility;
StartupNotify=false
X-GNOME-Autostart-enabled=true
EOF

# Start ULauncher in background (if display available)
if [ -n "$DISPLAY" ]; then
    ulauncher --hide-window &>/dev/null &
    disown
fi

echo "✓ ULauncher installed"
echo "  Press Super+Space to launch apps"
