#!/usr/bin/env bash
#
# Kodra Desktop Setup
# Beautiful GNOME desktop for developers
#
# Note: We don't use set -e because gsettings failures are cosmetic
# (keys may not exist in all GNOME versions) and shouldn't kill the script

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
    dconf-cli \
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

# Install Blur my Shell (beautiful blur effects)
BLUR_DIR="$HOME/.local/share/gnome-shell/extensions/blur-my-shell@aunetx"
if [ ! -d "$BLUR_DIR" ]; then
    echo "   Downloading Blur my Shell..."
    mkdir -p "$BLUR_DIR"
    curl -sL "https://extensions.gnome.org/extension-data/blur-my-shellaunetx.v66.shell-extension.zip" -o /tmp/blur-my-shell.zip 2>/dev/null || true
    if [ -f /tmp/blur-my-shell.zip ]; then
        unzip -qo /tmp/blur-my-shell.zip -d "$BLUR_DIR" 2>/dev/null || true
        rm -f /tmp/blur-my-shell.zip
        echo "   ✓ Blur my Shell installed"
    fi
fi

# Install TopHat (system monitor in top bar)
TOPHAT_DIR="$HOME/.local/share/gnome-shell/extensions/tophat@fflewddur.github.io"
if [ ! -d "$TOPHAT_DIR" ]; then
    echo "   Downloading TopHat (system monitor)..."
    mkdir -p "$TOPHAT_DIR"
    curl -sL "https://extensions.gnome.org/extension-data/tophatfflewddur.github.io.v14.shell-extension.zip" -o /tmp/tophat.zip 2>/dev/null || true
    if [ -f /tmp/tophat.zip ]; then
        unzip -qo /tmp/tophat.zip -d "$TOPHAT_DIR" 2>/dev/null || true
        rm -f /tmp/tophat.zip
        echo "   ✓ TopHat installed (CPU/RAM/Network in top bar)"
    fi
fi

# Install Alphabetical App Grid  
ALPHA_GRID_DIR="$HOME/.local/share/gnome-shell/extensions/AlphabeticalAppGrid@stuarthayhurst"
if [ ! -d "$ALPHA_GRID_DIR" ]; then
    echo "   Downloading Alphabetical App Grid..."
    mkdir -p "$ALPHA_GRID_DIR"
    curl -sL "https://extensions.gnome.org/extension-data/AlphabeticalAppGridstuarthayhurst.v37.shell-extension.zip" -o /tmp/alpha-grid.zip 2>/dev/null || true
    if [ -f /tmp/alpha-grid.zip ]; then
        unzip -qo /tmp/alpha-grid.zip -d "$ALPHA_GRID_DIR" 2>/dev/null || true
        rm -f /tmp/alpha-grid.zip
        echo "   ✓ Alphabetical App Grid installed"
    fi
fi

# Install Space Bar (workspace indicator)
SPACE_BAR_DIR="$HOME/.local/share/gnome-shell/extensions/space-bar@luchrioh"
if [ ! -d "$SPACE_BAR_DIR" ]; then
    echo "   Downloading Space Bar (workspace indicator)..."
    mkdir -p "$SPACE_BAR_DIR"
    curl -sL "https://extensions.gnome.org/extension-data/space-barluchrioh.v28.shell-extension.zip" -o /tmp/space-bar.zip 2>/dev/null || true
    if [ -f /tmp/space-bar.zip ]; then
        unzip -qo /tmp/space-bar.zip -d "$SPACE_BAR_DIR" 2>/dev/null || true
        rm -f /tmp/space-bar.zip
        echo "   ✓ Space Bar installed (workspace indicator in top bar)"
    fi
fi

# -----------------------------------------------------------------------------
# Configure GNOME for macOS Feel
# -----------------------------------------------------------------------------
echo "⚙️  Applying desktop settings..."

# Dark mode (like macOS dark mode)
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

# Accent color (purple for Tokyo Night default theme)
# Available: blue, teal, green, yellow, orange, red, pink, purple, slate
gsettings set org.gnome.desktop.interface accent-color 'purple' 2>/dev/null || true

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

# 6 fixed workspaces (more predictable than dynamic)
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 6

# Edge tiling (window snapping)
gsettings set org.gnome.mutter edge-tiling true

# Disable Night Light (user can enable if desired)
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false 2>/dev/null || true

# Disable extension update notifications (we curate extensions)
gsettings set org.gnome.shell disable-extension-version-validation true 2>/dev/null || true

# -----------------------------------------------------------------------------
# Disable Default Ubuntu Extensions (cleaner look)
# -----------------------------------------------------------------------------
echo "🧹 Cleaning up default extensions..."

gnome-extensions disable ubuntu-dock@ubuntu.com 2>/dev/null || true
gnome-extensions disable ubuntu-appindicators@ubuntu.com 2>/dev/null || true
gnome-extensions disable tiling-assistant@ubuntu.com 2>/dev/null || true
gnome-extensions disable ding@rastersoft.com 2>/dev/null || true

# -----------------------------------------------------------------------------
# Clean Up App Grid (remove junk entries)
# -----------------------------------------------------------------------------
echo "📱 Organizing app grid..."

# Hide broken/duplicate desktop entries
HIDDEN_APPS=(
    "btop.desktop"
    "nvim.desktop" 
    "vim.desktop"
    "org.gnome.Extensions.desktop"
    "gnome-language-selector.desktop"
    "software-properties-drivers.desktop"
    "software-properties-gtk.desktop"
    "update-manager.desktop"
    "usb-creator-gtk.desktop"
    "yelp.desktop"
    "debian-xterm.desktop"
    "debian-uxterm.desktop"
    "display-im6.q16.desktop"
    "org.gnome.Tour.desktop"
)

mkdir -p "$HOME/.local/share/applications"
for app in "${HIDDEN_APPS[@]}"; do
    if [ -f "/usr/share/applications/$app" ] || [ -f "/var/lib/flatpak/exports/share/applications/$app" ]; then
        echo "[Desktop Entry]
Hidden=true" > "$HOME/.local/share/applications/$app"
    fi
done
echo "   ✓ App grid cleaned up"

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

# Enable Dash to Dock extension (replaces Ubuntu Dock)
gnome-extensions enable dash-to-dock@micxgx.gmail.com 2>/dev/null || true

# Configure dock using dconf (works even if schemas aren't loaded yet)
# This writes directly to the dconf database, bypassing schema validation
DCONF_DOCK_PATH="/org/gnome/shell/extensions/dash-to-dock/"
if command -v dconf &> /dev/null; then
    echo "   Writing dock configuration via dconf..."
    dconf write "${DCONF_DOCK_PATH}dock-position" "'BOTTOM'" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}multi-monitor" "false" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}extend-height" "false" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}dash-max-icon-size" "48" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}dock-fixed" "false" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}autohide" "true" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}intellihide" "true" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}autohide-in-fullscreen" "true" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}animation-time" "0.2" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}hide-delay" "0.2" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}show-delay" "0.25" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}pressure-threshold" "100" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}running-indicator-style" "'DOTS'" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}running-indicator-dominant-color" "true" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}click-action" "'focus-or-previews'" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}scroll-action" "'cycle-windows'" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}middle-click-action" "'launch'" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}transparency-mode" "'DYNAMIC'" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}background-opacity" "0.6" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}custom-background-color" "true" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}background-color" "'rgb(30,30,30)'" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}show-favorites" "true" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}show-running" "true" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}show-trash" "false" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}show-mounts" "false" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}show-apps-at-top" "false" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}show-show-apps-button" "true" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}custom-theme-shrink" "true" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}unity-backlit-items" "false" 2>/dev/null || true
    dconf write "${DCONF_DOCK_PATH}apply-custom-theme" "false" 2>/dev/null || true
    echo "   ✓ Dock settings written"
else
    # Fallback: try gsettings if dconf not available
    if gsettings list-schemas 2>/dev/null | grep -q "org.gnome.shell.extensions.dash-to-dock"; then
        "$KODRA_DATA_DIR/configure-dock.sh" 2>/dev/null || true
    fi
fi

# -----------------------------------------------------------------------------
# Configure Dock Favorites (Clean developer apps only)
# -----------------------------------------------------------------------------
echo "📌 Setting up dock favorites..."

# Desktop file locations (order matters - prefer flatpak)
DESKTOP_DIRS=(
    "/var/lib/flatpak/exports/share/applications"
    "$HOME/.local/share/applications"
    "/usr/share/applications"
    "/usr/local/share/applications"
)

# Helper: find first existing desktop file from variants
find_app() {
    local variants=("$@")
    for variant in "${variants[@]}"; do
        for dir in "${DESKTOP_DIRS[@]}"; do
            if [ -f "$dir/$variant" ]; then
                echo "$variant"
                return 0
            fi
        done
    done
    return 1
}

# Kodra's curated dock apps - grouped by app, picks first found
INSTALLED_APPS=()

# File Manager
app=$(find_app "org.gnome.Nautilus.desktop") && INSTALLED_APPS+=("$app")

# Brave Browser
app=$(find_app "com.brave.Browser.desktop" "brave-browser.desktop") && INSTALLED_APPS+=("$app")

# Ghostty Terminal
app=$(find_app "com.mitchellh.ghostty.desktop" "ghostty.desktop") && INSTALLED_APPS+=("$app")

# VS Code
app=$(find_app "code.desktop") && INSTALLED_APPS+=("$app")

# Neovim
app=$(find_app "nvim.desktop" "neovim.desktop") && INSTALLED_APPS+=("$app")

# GitHub Desktop
app=$(find_app "io.github.shiftey.Desktop.desktop" "github-desktop.desktop") && INSTALLED_APPS+=("$app")

# Spotify
app=$(find_app "com.spotify.Client.desktop" "spotify.desktop") && INSTALLED_APPS+=("$app")

# Discord
app=$(find_app "com.discordapp.Discord.desktop" "discord.desktop") && INSTALLED_APPS+=("$app")

# Settings (always last)
app=$(find_app "org.gnome.Settings.desktop" "gnome-control-center.desktop") && INSTALLED_APPS+=("$app")

# Set dock favorites if we found any
if [ ${#INSTALLED_APPS[@]} -gt 0 ]; then
    FAVORITES_LIST=$(printf "'%s'," "${INSTALLED_APPS[@]}")
    FAVORITES_LIST="[${FAVORITES_LIST%,}]"
    gsettings set org.gnome.shell favorite-apps "$FAVORITES_LIST" 2>/dev/null || true
    echo "   ✓ Dock favorites set (${#INSTALLED_APPS[@]} apps)"
else
    echo "   ℹ No dock apps found yet - run 'kodra desktop' after installing apps"
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
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>Return', '<Control><Alt>t']" 2>/dev/null || true

# Screenshot shortcuts (macOS-like: Cmd+Shift+3/4/5)
# Note: GNOME 46+ moved screenshots to org.gnome.shell.keybindings
# Try both schemas for compatibility
gsettings set org.gnome.shell.keybindings screenshot "['<Shift><Super>3', 'Print']" 2>/dev/null || \
    gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot "['<Shift><Super>3', 'Print']" 2>/dev/null || true
gsettings set org.gnome.shell.keybindings screenshot-window "['<Shift><Super>5', '<Alt>Print']" 2>/dev/null || \
    gsettings set org.gnome.settings-daemon.plugins.media-keys window-screenshot "['<Shift><Super>5', '<Alt>Print']" 2>/dev/null || true
gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Shift><Super>4', '<Shift>Print']" 2>/dev/null || \
    gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot "['<Shift><Super>4', '<Shift>Print']" 2>/dev/null || true

# Screenshot save location (only if gnome-screenshot schema exists)
mkdir -p "$HOME/Pictures/Screenshots"
gsettings set org.gnome.gnome-screenshot auto-save-directory "$HOME/Pictures/Screenshots" 2>/dev/null || true

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
gnome-extensions enable blur-my-shell@aunetx 2>/dev/null && echo "  ✓ Blur my Shell" || true
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null && echo "  ✓ User Themes" || true
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com 2>/dev/null && echo "  ✓ AppIndicator" || true

# Configure Blur my Shell (subtle, not distracting)
gsettings set org.gnome.shell.extensions.blur-my-shell.overview blur true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock sigma 30 2>/dev/null || true
gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur false 2>/dev/null || true

echo ""
echo "For the best experience, also install from Extension Manager:"
echo "  • Rounded Window Corners - softer windows"  
echo "  • Just Perfection - fine-tune the shell"
echo ""
echo "Then run: ~/.local/share/kodra/configure-dock.sh"
EXTSCRIPT
chmod +x "$KODRA_DATA_DIR/setup-extensions.sh"

# -----------------------------------------------------------------------------
# Final touches
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Enable Extensions via gsettings (works before logout)
# -----------------------------------------------------------------------------
echo "🧩 Enabling GNOME extensions..."

# Get current enabled extensions (if any)
CURRENT_EXTENSIONS=$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null || echo "@as []")

# Our curated extensions to enable
KODRA_EXTENSIONS=(
    "dash-to-dock@micxgx.gmail.com"
    "blur-my-shell@aunetx"
    "tactile@lundal.io"
    "user-theme@gnome-shell-extensions.gcampax.github.com"
)

# Build new extensions array
NEW_EXTENSIONS="["
for ext in "${KODRA_EXTENSIONS[@]}"; do
    NEW_EXTENSIONS+="'$ext', "
done

# Also preserve any existing extensions that aren't Ubuntu defaults
if [[ "$CURRENT_EXTENSIONS" != "@as []" ]]; then
    # Extract existing extensions, skip Ubuntu defaults
    EXISTING=$(echo "$CURRENT_EXTENSIONS" | tr -d "[]' " | tr ',' '\n' | grep -v "ubuntu-dock\|ubuntu-appindicators\|ding@\|tiling-assistant" | tr '\n' ',' || true)
    if [ -n "$EXISTING" ]; then
        for ext in $(echo "$EXISTING" | tr ',' ' '); do
            if [[ ! " ${KODRA_EXTENSIONS[*]} " =~ " $ext " ]] && [ -n "$ext" ]; then
                NEW_EXTENSIONS+="'$ext', "
            fi
        done
    fi
fi

# Remove trailing comma and close array
NEW_EXTENSIONS="${NEW_EXTENSIONS%, }]"

# Apply the extensions
gsettings set org.gnome.shell enabled-extensions "$NEW_EXTENSIONS" 2>/dev/null || true
echo "   ✓ Extensions enabled: dash-to-dock, blur-my-shell, tactile, user-themes"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🍎 macOS-Style Desktop Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  ✓ Window buttons moved to left (macOS style)"
echo "  ✓ Papirus icons installed"
echo "  ✓ GNOME Tweaks installed"
echo "  ✓ Dark mode enabled"
echo "  ✓ Keyboard shortcuts configured"
echo "  ✓ Extensions auto-enabled (Dash to Dock, Blur, Tactile)"
echo "  ✓ Dock configured (bottom-center, auto-hide)"
echo ""
echo "  → Log out and log back in to see your new desktop!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
