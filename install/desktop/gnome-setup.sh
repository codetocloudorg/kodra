#!/usr/bin/env bash
#
# Kodra Desktop Setup
# Beautiful GNOME desktop for developers
#

set -e

echo "✨ Setting up your developer desktop..."

# Check if GNOME is installed
if ! command -v gnome-shell &> /dev/null; then
    echo "GNOME Shell not detected, skipping desktop configuration"
    exit 0
fi

# -----------------------------------------------------------------------------
# Install GNOME Tweaks and Extensions
# -----------------------------------------------------------------------------
echo "📦 Installing GNOME customization tools..."

# Note: apt-get update already run by main install.sh
sudo apt-get install -y \
    gnome-tweaks \
    gnome-shell-extension-manager \
    gnome-shell-extension-prefs \
    gnome-shell-extensions \
    chrome-gnome-shell \
    dconf-editor \
    papirus-icon-theme \
    libfuse2 2>/dev/null || true

# Install Extension Manager via Flatpak for latest version
if command -v flatpak &> /dev/null; then
    echo "📥 Installing Extension Manager via Flatpak..."
    flatpak install -y flathub com.mattjakeman.ExtensionManager 2>/dev/null || true
fi

# -----------------------------------------------------------------------------
# Install Essential Extensions via CLI
# -----------------------------------------------------------------------------
echo "🧩 Installing GNOME extensions..."

# Function to install extension from zip
install_extension_zip() {
    local ext_id="$1"
    local ext_uuid="$2"
    local shell_version=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1)
    
    echo "   Installing: $ext_uuid"
    
    local ext_dir="$HOME/.local/share/gnome-shell/extensions/$ext_uuid"
    mkdir -p "$ext_dir"
    
    # Download extension
    local download_url="https://extensions.gnome.org/extension-data/${ext_uuid}.v${ext_id}.shell-extension.zip"
    curl -sL "https://extensions.gnome.org/download-extension/${ext_uuid}.shell-extension.zip?shell_version=${shell_version}" -o "/tmp/${ext_uuid}.zip" 2>/dev/null || true
    
    if [ -f "/tmp/${ext_uuid}.zip" ]; then
        unzip -qo "/tmp/${ext_uuid}.zip" -d "$ext_dir" 2>/dev/null || true
        rm -f "/tmp/${ext_uuid}.zip"
    fi
}

# Key extensions for macOS feel
echo "   Note: Extensions can be managed in Extension Manager app"

# Install Dash to Dock (essential for macOS dock)
DASH_TO_DOCK_DIR="$HOME/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com"
if [ ! -d "$DASH_TO_DOCK_DIR" ]; then
    echo "   Downloading Dash to Dock..."
    mkdir -p "$DASH_TO_DOCK_DIR"
    curl -sL "https://extensions.gnome.org/extension-data/dash-to-dockmicxgx.gmail.com.v84.shell-extension.zip" -o /tmp/dash-to-dock.zip 2>/dev/null || true
    if [ -f /tmp/dash-to-dock.zip ]; then
        unzip -qo /tmp/dash-to-dock.zip -d "$DASH_TO_DOCK_DIR" 2>/dev/null || true
        rm -f /tmp/dash-to-dock.zip
    fi
fi

# Install Tactile (window tiling - like Rectangle on macOS)
TACTILE_DIR="$HOME/.local/share/gnome-shell/extensions/tactile@lundal.io"
if [ ! -d "$TACTILE_DIR" ]; then
    echo "   Downloading Tactile (window tiling)..."
    mkdir -p "$TACTILE_DIR"
    # Tactile v3 for GNOME 45+
    curl -sL "https://extensions.gnome.org/extension-data/tactilelundal.io.v4.shell-extension.zip" -o /tmp/tactile.zip 2>/dev/null || true
    if [ -f /tmp/tactile.zip ]; then
        unzip -qo /tmp/tactile.zip -d "$TACTILE_DIR" 2>/dev/null || true
        rm -f /tmp/tactile.zip
        echo "   ✓ Tactile installed (Super+T to tile windows)"
    fi
fi

# -----------------------------------------------------------------------------
# Configure GNOME for macOS Feel
# -----------------------------------------------------------------------------
echo "⚙️  Applying desktop settings..."

# Dark mode (like macOS dark mode)
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

# Window controls on LEFT (macOS style) - close, minimize, maximize
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

# Fonts - clean and modern
gsettings set org.gnome.desktop.interface font-name 'Ubuntu 11'
gsettings set org.gnome.desktop.interface document-font-name 'Ubuntu 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Bold 11'

# Use Papirus icons (closer to macOS aesthetic)
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Cursor
gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
gsettings set org.gnome.desktop.interface cursor-size 24

# Animations - smooth like macOS
gsettings set org.gnome.desktop.interface enable-animations true

# Hot corners (like macOS Mission Control)
gsettings set org.gnome.desktop.interface enable-hot-corners true

# Center new windows (feels more intentional)
gsettings set org.gnome.mutter center-new-windows true

# Workspaces on all monitors (like macOS Spaces)
gsettings set org.gnome.mutter workspaces-only-on-primary false

# Dynamic workspaces (macOS Spaces style)
gsettings set org.gnome.mutter dynamic-workspaces true

# Edge tiling (window snapping)
gsettings set org.gnome.mutter edge-tiling true

# Night Light (like macOS Night Shift)
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic true

# -----------------------------------------------------------------------------
# Configure Dash to Dock (macOS Dock style)
# -----------------------------------------------------------------------------
echo "🚀 Configuring Dock..."

# Create dock configuration script
KODRA_DATA_DIR="$HOME/.local/share/kodra"
mkdir -p "$KODRA_DATA_DIR"

cat > "$KODRA_DATA_DIR/configure-dock.sh" << 'DOCKSCRIPT'
#!/usr/bin/env bash
# Kodra Dock Configuration
# Run after enabling Dash to Dock extension

echo "🚀 Configuring dock..."

# Enable the extension first
gnome-extensions enable dash-to-dock@micxgx.gmail.com 2>/dev/null || true
sleep 1

# Position - BOTTOM center (like macOS)
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'

# Only show on primary monitor
gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor false

# Centered dock (not extending to edges) - THE KEY SETTING
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false

# Icon size (48px like macOS default)
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48

# Intelligent autohide (like macOS)
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen true

# Animation time (smooth like macOS)
gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.2
gsettings set org.gnome.shell.extensions.dash-to-dock hide-delay 0.2
gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 0.25

# Pressure threshold for showing dock
gsettings set org.gnome.shell.extensions.dash-to-dock pressure-threshold 100

# Show running indicators (dots like macOS)
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DOTS'
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-dominant-color true

# Click action (like macOS - focus or show windows)
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-or-previews'
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'
gsettings set org.gnome.shell.extensions.dash-to-dock middle-click-action 'launch'

# Transparency (frosted glass effect)
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DYNAMIC'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.6

# Custom background color (dark like macOS)
gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color true
gsettings set org.gnome.shell.extensions.dash-to-dock background-color 'rgb(30,30,30)'

# Show favorites and running apps
gsettings set org.gnome.shell.extensions.dash-to-dock show-favorites true
gsettings set org.gnome.shell.extensions.dash-to-dock show-running true
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false

# Show apps button (macOS Launchpad style)
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top false
gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button true

# Shrink the dock (cleaner look)
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true

# Disable unity backlit items (cleaner)
gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items false

# Rounded corners
gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false

echo "✅ Dock configured! You may need to log out and back in."
DOCKSCRIPT
chmod +x "$KODRA_DATA_DIR/configure-dock.sh"

# Try to configure dock now (will work if extension schema exists)
if gsettings list-schemas 2>/dev/null | grep -q "org.gnome.shell.extensions.dash-to-dock"; then
    "$KODRA_DATA_DIR/configure-dock.sh" 2>/dev/null || true
fi

# -----------------------------------------------------------------------------
# Configure Tactile (Window Tiling)
# -----------------------------------------------------------------------------
echo "🪟 Configuring window tiling..."

cat > "$KODRA_DATA_DIR/configure-tiling.sh" << 'TILESCRIPT'
#!/usr/bin/env bash
# Kodra Window Tiling Configuration
# Tactile extension setup

echo "🪟 Configuring Tactile window tiling..."

# Enable the extension first
gnome-extensions enable tactile@lundal.io 2>/dev/null || true
sleep 1

# Check if Tactile schema exists
if ! gsettings list-schemas 2>/dev/null | grep -q "org.gnome.shell.extensions.tactile"; then
    echo "  Tactile schema not found - will be configured after restart"
    exit 0
fi

# Layout configuration
# Default 2x2 grid for quick snapping
gsettings set org.gnome.shell.extensions.tactile col-0 2
gsettings set org.gnome.shell.extensions.tactile col-1 2
gsettings set org.gnome.shell.extensions.tactile col-2 0
gsettings set org.gnome.shell.extensions.tactile col-3 0
gsettings set org.gnome.shell.extensions.tactile row-0 2
gsettings set org.gnome.shell.extensions.tactile row-1 2
gsettings set org.gnome.shell.extensions.tactile row-2 0

# Gap between tiled windows (clean look)
gsettings set org.gnome.shell.extensions.tactile gap-size 8

# Show grid overlay when tiling
gsettings set org.gnome.shell.extensions.tactile show-tiles true

echo "✅ Tactile configured!"
echo ""
echo "   Window Tiling Shortcuts:"
echo "   ──────────────────────────────────────"
echo "   Super + T       : Show tiling grid"
echo "   Super + ←/→     : Tile left/right half"
echo "   Super + ↑       : Maximize window"
echo "   Ctrl + Super + ←/→/↑/↓ : Tile to edges"
echo "   Ctrl + Alt + U/I/J/K   : Tile to corners"
echo ""
TILESCRIPT
chmod +x "$KODRA_DATA_DIR/configure-tiling.sh"

# Try to configure Tactile now
if gsettings list-schemas 2>/dev/null | grep -q "org.gnome.shell.extensions.tactile"; then
    "$KODRA_DATA_DIR/configure-tiling.sh" 2>/dev/null || true
fi

# -----------------------------------------------------------------------------
# Keyboard Shortcuts (macOS-style)
# -----------------------------------------------------------------------------
echo "⌨️  Setting up keyboard shortcuts..."

# Caps Lock as Escape (developer preference)
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"

# Open terminal with Super+Return (in addition to Ctrl+Alt+T)
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>Return', '<Control><Alt>t']"

# Screenshot shortcuts (macOS-like: Cmd+Shift+3/4/5)
gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot "['<Shift><Super>3', 'Print']"
gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot "['<Shift><Super>4', '<Shift>Print']"
gsettings set org.gnome.settings-daemon.plugins.media-keys window-screenshot "['<Shift><Super>5', '<Alt>Print']"

# Screenshot save location
mkdir -p "$HOME/Pictures/Screenshots"
gsettings set org.gnome.gnome-screenshot auto-save-directory "$HOME/Pictures/Screenshots"

# Window management shortcuts
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q', '<Alt>F4']"
gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>h']"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Control><Super>f']"
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"

# Window tiling shortcuts (like Rectangle/Magnet on macOS)
# Left half
gsettings set org.gnome.desktop.wm.keybindings move-to-side-w "['<Super>Left', '<Control><Super>Left']"
# Right half
gsettings set org.gnome.desktop.wm.keybindings move-to-side-e "['<Super>Right', '<Control><Super>Right']"
# Top half (custom - add via custom keybinding)
gsettings set org.gnome.desktop.wm.keybindings move-to-side-n "['<Control><Super>Up']"
# Bottom half
gsettings set org.gnome.desktop.wm.keybindings move-to-side-s "['<Control><Super>Down']"

# Move window to corners (quarter screen)
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-nw "['<Control><Alt>u']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-ne "['<Control><Alt>i']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-sw "['<Control><Alt>j']"
gsettings set org.gnome.desktop.wm.keybindings move-to-corner-se "['<Control><Alt>k']"

# Switch workspaces
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Control><Super>Left', '<Control><Alt>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Control><Super>Right', '<Control><Alt>Right']"

# Move window to workspace
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Shift><Control><Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Shift><Control><Super>Right']"

# Show activities (like macOS Mission Control)
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>space']"

# -----------------------------------------------------------------------------
# File Manager (Nautilus) Settings
# -----------------------------------------------------------------------------
echo "📁 Configuring file manager..."

gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view'
gsettings set org.gnome.nautilus.icon-view default-zoom-level 'large'
gsettings set org.gnome.nautilus.preferences show-hidden-files false
gsettings set org.gnome.nautilus.preferences show-create-link true
gsettings set org.gnome.nautilus.preferences show-delete-permanently false
gsettings set org.gnome.nautilus.list-view default-zoom-level 'small'

# -----------------------------------------------------------------------------
# Set Favorite Apps in Dock
# -----------------------------------------------------------------------------
echo "📌 Setting dock favorites..."

gsettings set org.gnome.shell favorite-apps "[\
'org.gnome.Nautilus.desktop', \
'ghostty.desktop', \
'code.desktop', \
'firefox_firefox.desktop', \
'google-chrome.desktop', \
'org.gnome.Settings.desktop'\
]"

# -----------------------------------------------------------------------------
# Apply Wallpaper
# -----------------------------------------------------------------------------
echo "🖼️  Setting wallpaper..."

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
WALLPAPER="$KODRA_DIR/wallpapers/wallpaper5.jpg"

if [ -f "$WALLPAPER" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
    gsettings set org.gnome.desktop.background picture-options "zoom"
    gsettings set org.gnome.desktop.screensaver picture-uri "file://$WALLPAPER"
fi

# -----------------------------------------------------------------------------
# Create Extensions Setup Helper
# -----------------------------------------------------------------------------
cat > "$KODRA_DATA_DIR/setup-extensions.sh" << 'EXTSCRIPT'
#!/usr/bin/env bash
# Kodra Extensions Setup Helper
# Enables recommended extensions for macOS-like experience

echo "🧩 Enabling GNOME extensions..."

# Enable extensions
gnome-extensions enable dash-to-dock@micxgx.gmail.com 2>/dev/null && echo "  ✓ Dash to Dock" || echo "  ⚠ Dash to Dock (install from Extension Manager)"
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null && echo "  ✓ User Themes" || true
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com 2>/dev/null && echo "  ✓ AppIndicator" || true

echo ""
echo "For the best experience, also install from Extension Manager:"
echo "  • Blur my Shell - beautiful blur effects"
echo "  • Rounded Window Corners - softer windows"  
echo "  • Just Perfection - fine-tune the shell"
echo ""
echo "Then run: ~/.local/share/kodra/configure-dock.sh"
EXTSCRIPT
chmod +x "$KODRA_DATA_DIR/setup-extensions.sh"

# -----------------------------------------------------------------------------
# Final touches
# -----------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🍎 macOS-Style Desktop Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ✓ Window buttons moved to left (macOS style)"
echo "  ✓ Papirus icons installed"
echo "  ✓ GNOME Tweaks installed"
echo "  ✓ Dark mode enabled"
echo "  ✓ Night Light enabled"
echo "  ✓ Keyboard shortcuts configured"
echo ""
echo "  Next steps for the FULL macOS experience:"
echo ""
echo "  1. Log out and log back in"
echo ""
echo "  2. Open Extension Manager and enable:"
echo "     → Dash to Dock (for bottom-center dock)"
echo "     → Blur my Shell (frosted glass effect)"
echo ""
echo "  3. After enabling Dash to Dock, run:"
echo "     ~/.local/share/kodra/configure-dock.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
