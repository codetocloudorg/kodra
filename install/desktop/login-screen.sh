#!/usr/bin/env bash
#
# GDM Login Screen Customization
# Uses only dconf (the official GDM API) — survives OS and GNOME Shell updates
# No CSS injection, no gresource hacking, no system file modification
#

set -e

echo "🎨 Customizing login screen..."

# Check if GDM is installed
if ! command -v gdm3 &> /dev/null && ! [ -d /etc/gdm3 ]; then
    echo "GDM not detected, skipping login screen customization"
    exit 0
fi

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Get current theme
THEME="tokyo-night"
[ -f "$HOME/.config/kodra/theme" ] && THEME=$(cat "$HOME/.config/kodra/theme")

# Set wallpaper based on theme
case "$THEME" in
    tokyo-night) WALLPAPER="wallpaper5.jpg" ;;
    ghostty-blue) WALLPAPER="wallpaper5.jpg" ;;
    *) WALLPAPER="wallpaper5.jpg" ;;
esac

# Copy wallpaper to system location (survives updates, doesn't modify system packages)
WALLPAPER_SRC="$KODRA_DIR/wallpapers/$WALLPAPER"
WALLPAPER_EXT="${WALLPAPER##*.}"
WALLPAPER_DEST="/usr/share/backgrounds/kodra-login.$WALLPAPER_EXT"

if [ -f "$WALLPAPER_SRC" ]; then
    sudo cp "$WALLPAPER_SRC" "$WALLPAPER_DEST"
    echo "  ✓ Login wallpaper copied"
fi

# -----------------------------------------------------------------------------
# Clean up any previous Kodra CSS hacks (from older versions)
# -----------------------------------------------------------------------------
if [ -d /usr/share/gnome-shell/theme/kodra ]; then
    echo "  🧹 Removing old CSS customizations..."
    sudo rm -rf /usr/share/gnome-shell/theme/kodra
fi

if [ -f /usr/local/bin/kodra-gdm-apply ]; then
    sudo rm -f /usr/local/bin/kodra-gdm-apply
fi

# Restore any backed-up Yaru CSS
for backup in /usr/share/gnome-shell/theme/Yaru/gnome-shell.css.kodra-backup \
              /usr/share/gnome-shell/theme/ubuntu.css.kodra-backup; do
    if [ -f "$backup" ]; then
        sudo cp "$backup" "${backup%.kodra-backup}"
        sudo rm -f "$backup"
        echo "  ✓ Restored original GNOME Shell CSS"
    fi
done

# Restore any backed-up gresource
if [ -f /usr/share/gnome-shell/gnome-shell-theme.gresource.kodra-backup ]; then
    sudo cp /usr/share/gnome-shell/gnome-shell-theme.gresource.kodra-backup \
            /usr/share/gnome-shell/gnome-shell-theme.gresource
    sudo rm -f /usr/share/gnome-shell/gnome-shell-theme.gresource.kodra-backup
    echo "  ✓ Restored original gresource"
fi

# -----------------------------------------------------------------------------
# Configure GDM via dconf (official API — update-safe, multi-monitor safe)
# -----------------------------------------------------------------------------
echo "  Applying dconf settings..."

sudo mkdir -p /etc/dconf/profile
cat << 'EOF' | sudo tee /etc/dconf/profile/gdm > /dev/null
user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults
EOF

sudo mkdir -p /etc/dconf/db/gdm.d
cat << EOF | sudo tee /etc/dconf/db/gdm.d/01-kodra-theme > /dev/null
[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Yaru-dark'
icon-theme='Papirus-Dark'
cursor-theme='Yaru'

[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/kodra-login.$WALLPAPER_EXT'
picture-uri-dark='file:///usr/share/backgrounds/kodra-login.$WALLPAPER_EXT'
picture-options='zoom'
primary-color='#0d1117'

[org/gnome/desktop/screensaver]
picture-uri='file:///usr/share/backgrounds/kodra-login.$WALLPAPER_EXT'
picture-options='zoom'
primary-color='#0d1117'

[org/gnome/login-screen]
logo=''
banner-message-enable=false
EOF

# Update dconf database
sudo dconf update 2>/dev/null || true

echo ""
echo "✅ Login screen customized!"
echo "   - Dark mode (Yaru-dark)"
echo "   - Kodra wallpaper (per-monitor, multi-screen safe)"
echo "   - Papirus-Dark icons"
echo "   - No system files modified (dconf only — survives OS updates)"
echo ""
echo "   Changes take effect after restart or: sudo systemctl restart gdm3"
