#!/usr/bin/env bash
#
# GDM Login Screen Customization
# Makes the Ubuntu login screen match Kodra's dark developer aesthetic
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

# Copy wallpaper to system location
WALLPAPER_SRC="$KODRA_DIR/wallpapers/$WALLPAPER"
WALLPAPER_EXT="${WALLPAPER##*.}"
WALLPAPER_DEST="/usr/share/backgrounds/kodra-login.$WALLPAPER_EXT"

if [ -f "$WALLPAPER_SRC" ]; then
    sudo cp "$WALLPAPER_SRC" "$WALLPAPER_DEST"
    echo "✓ Login wallpaper set"
fi

# Create GDM CSS customization
# Ubuntu 24.04 uses gnome-shell theme for GDM
GDM_CSS="/usr/share/gnome-shell/theme/Yaru/gnome-shell.css"
GDM_CSS_BACKUP="/usr/share/gnome-shell/theme/Yaru/gnome-shell.css.kodra-backup"

# Also try ubuntu-specific path
if [ ! -f "$GDM_CSS" ]; then
    GDM_CSS="/usr/share/gnome-shell/theme/ubuntu.css"
    GDM_CSS_BACKUP="/usr/share/gnome-shell/theme/ubuntu.css.kodra-backup"
fi

# Backup original if not already done
if [ -f "$GDM_CSS" ] && [ ! -f "$GDM_CSS_BACKUP" ]; then
    sudo cp "$GDM_CSS" "$GDM_CSS_BACKUP"
    echo "✓ Original CSS backed up"
fi

# Create Kodra GDM CSS overrides
sudo mkdir -p /usr/share/gnome-shell/theme/kodra
cat << EOF | sudo tee /usr/share/gnome-shell/theme/kodra/gdm.css > /dev/null
/* Kodra GDM Login Screen Theme */
/* Dark developer aesthetic */

/* Lock screen / Login background */
#lockDialogGroup {
    background: #0d1117 url('file:///usr/share/backgrounds/kodra-login.$WALLPAPER_EXT');
    background-size: cover;
    background-position: center;
}

/* Fallback solid color */
.login-dialog {
    background-color: #0d1117;
}

/* User list styling */
.login-dialog-user-list {
    background-color: rgba(13, 17, 23, 0.85);
    border-radius: 12px;
    padding: 12px;
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.4);
}

.login-dialog-user-list-item {
    color: #e6edf3;
    border-radius: 8px;
    padding: 8px 12px;
}

.login-dialog-user-list-item:hover,
.login-dialog-user-list-item:focus {
    background-color: rgba(88, 166, 255, 0.15);
}

.login-dialog-user-list-item:active,
.login-dialog-user-list-item:selected {
    background-color: rgba(88, 166, 255, 0.25);
    color: #58a6ff;
}

/* Username label */
.login-dialog-user-list-item .login-dialog-timed-login-indicator,
.login-dialog-user-list-item .login-dialog-username {
    color: #e6edf3;
    font-weight: 500;
}

/* Password entry */
.login-dialog-prompt-entry {
    background-color: rgba(22, 27, 34, 0.9);
    border: 1px solid #30363d;
    border-radius: 8px;
    color: #e6edf3;
    padding: 8px 12px;
}

.login-dialog-prompt-entry:focus {
    border-color: #58a6ff;
    box-shadow: 0 0 0 2px rgba(88, 166, 255, 0.3);
}

/* Prompt label */
.login-dialog-prompt-label {
    color: #8b949e;
    font-size: 11px;
}

/* Login button */
.modal-dialog-button {
    background-color: #238636;
    border: none;
    border-radius: 8px;
    color: #ffffff;
    font-weight: 600;
    padding: 8px 16px;
}

.modal-dialog-button:hover {
    background-color: #2ea043;
}

.modal-dialog-button:active {
    background-color: #238636;
}

/* Panel at top */
#panel {
    background-color: rgba(13, 17, 23, 0.8);
    color: #e6edf3;
}

/* Clock on lock screen */
.clock {
    color: #e6edf3;
    font-weight: 300;
}

.clock-time {
    font-size: 72px;
    font-weight: 200;
    color: #e6edf3;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
}

.clock-date {
    font-size: 24px;
    color: #8b949e;
}

/* Notification banners */
.notification-banner {
    background-color: rgba(22, 27, 34, 0.95);
    border-radius: 12px;
    color: #e6edf3;
    border: 1px solid #30363d;
}

/* Message dialog (like "wrong password") */
.message-dialog-content {
    background-color: rgba(22, 27, 34, 0.95);
    border-radius: 12px;
    color: #e6edf3;
}

/* Power/session buttons */
.system-menu-action {
    color: #e6edf3;
}

.system-menu-action:hover {
    background-color: rgba(88, 166, 255, 0.15);
}

/* Accessibility menu */
.popup-menu {
    background-color: rgba(22, 27, 34, 0.95);
    border: 1px solid #30363d;
    border-radius: 12px;
}

.popup-menu-item {
    color: #e6edf3;
}

.popup-menu-item:hover {
    background-color: rgba(88, 166, 255, 0.15);
}
EOF

echo "✓ Kodra GDM theme created"

# Create a script to apply GDM theme (needs to be run after each GNOME Shell update)
cat << 'SCRIPT' | sudo tee /usr/local/bin/kodra-gdm-apply > /dev/null
#!/usr/bin/env bash
# Apply Kodra GDM theme
# Run this after GNOME Shell updates

set -e

GDM_RESOURCE="/usr/share/gnome-shell/gnome-shell-theme.gresource"
WORKDIR=$(mktemp -d)

if [ ! -f "$GDM_RESOURCE" ]; then
    echo "GDM resource not found, trying alternative method..."
    
    # Alternative: modify Yaru theme directly
    YARU_CSS="/usr/share/gnome-shell/theme/Yaru/gnome-shell.css"
    KODRA_CSS="/usr/share/gnome-shell/theme/kodra/gdm.css"
    
    if [ -f "$YARU_CSS" ] && [ -f "$KODRA_CSS" ]; then
        # Append Kodra CSS if not already added
        if ! grep -q "Kodra GDM" "$YARU_CSS"; then
            echo "" | sudo tee -a "$YARU_CSS" > /dev/null
            echo "/* Kodra GDM Customizations */" | sudo tee -a "$YARU_CSS" > /dev/null
            cat "$KODRA_CSS" | sudo tee -a "$YARU_CSS" > /dev/null
            echo "✓ GDM theme applied via CSS append"
        else
            echo "Kodra GDM theme already applied"
        fi
    fi
    exit 0
fi

# Extract current theme
cd "$WORKDIR"
gresource extract "$GDM_RESOURCE" /org/gnome/shell/theme/gnome-shell.css > gnome-shell.css 2>/dev/null || true

# Append Kodra customizations
if [ -f "gnome-shell.css" ]; then
    cat /usr/share/gnome-shell/theme/kodra/gdm.css >> gnome-shell.css
    
    # Create gresource XML
    cat > gnome-shell-theme.gresource.xml << 'GRES'
<?xml version="1.0" encoding="UTF-8"?>
<gresources>
  <gresource prefix="/org/gnome/shell/theme">
    <file>gnome-shell.css</file>
  </gresource>
</gresources>
GRES

    # Compile new resource
    glib-compile-resources gnome-shell-theme.gresource.xml
    
    # Backup and replace
    sudo cp "$GDM_RESOURCE" "${GDM_RESOURCE}.kodra-backup"
    sudo cp gnome-shell-theme.gresource "$GDM_RESOURCE"
    
    echo "✓ GDM theme compiled and applied"
fi

# Cleanup
rm -rf "$WORKDIR"

echo "Changes will take effect after restart or 'sudo systemctl restart gdm3'"
SCRIPT

sudo chmod +x /usr/local/bin/kodra-gdm-apply

# Apply the theme
/usr/local/bin/kodra-gdm-apply

# Set GDM to use dark theme
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
logo='/usr/share/backgrounds/kodra-login.$WALLPAPER_EXT'
EOF

# Update dconf database
sudo dconf update 2>/dev/null || true

echo ""
echo "✅ Login screen customized!"
echo "   - Dark theme applied"
echo "   - Kodra wallpaper set"  
echo "   - GitHub-style colors"
echo ""
echo "   Changes take effect after restart or: sudo systemctl restart gdm3"
