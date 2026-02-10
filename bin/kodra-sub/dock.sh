#!/usr/bin/env bash
#
# Kodra Dock - Configure dock favorites
# Only shows installed apps, keeps it clean
#

set -e

# Colors
C='\033[0;36m'
G='\033[0;32m'
Y='\033[0;33m'
R='\033[0;31m'
W='\033[0;37m'
NC='\033[0m'

echo ""
echo -e "${C}📌 Kodra Dock Configuration${NC}"
echo -e "${W}────────────────────────────────────────${NC}"

# Check if GNOME
if ! command -v gnome-shell &> /dev/null; then
    echo -e "${R}✖ GNOME Shell not detected${NC}"
    exit 1
fi

# Kodra's curated dock apps - clean developer setup
# Only adds apps that are actually installed
KODRA_DOCK_APPS=(
    # File manager first
    "org.gnome.Nautilus.desktop"
    
    # Terminal
    "com.mitchellh.ghostty.desktop"
    "ghostty.desktop"
    
    # Browser
    "com.brave.Browser.desktop"
    "brave-browser.desktop"
    
    # Editors
    "code.desktop"
    "nvim.desktop"
    "neovim.desktop"
    
    # Dev tools
    "io.github.shiftey.Desktop.desktop"
    "github-desktop.desktop"
    
    # Media & Chat
    "com.spotify.Client.desktop"
    "spotify.desktop"
    "com.discordapp.Discord.desktop"
    "discord.desktop"
    
    # System
    "org.gnome.Settings.desktop"
)

# Desktop file locations
DESKTOP_DIRS=(
    "/var/lib/flatpak/exports/share/applications"
    "/usr/share/applications"
    "/usr/local/share/applications"
    "$HOME/.local/share/applications"
)

INSTALLED_APPS=()
echo ""
echo -e "${W}Finding installed apps...${NC}"

for app in "${KODRA_DOCK_APPS[@]}"; do
    for dir in "${DESKTOP_DIRS[@]}"; do
        if [ -f "$dir/$app" ]; then
            # Extract app name from desktop file
            APP_NAME=$(grep -m1 "^Name=" "$dir/$app" 2>/dev/null | cut -d'=' -f2 || echo "$app")
            echo -e "  ${G}✓${NC} $APP_NAME"
            INSTALLED_APPS+=("$app")
            break
        fi
    done
done

echo ""

if [ ${#INSTALLED_APPS[@]} -eq 0 ]; then
    echo -e "${Y}No matching apps found.${NC}"
    echo -e "Install apps with kodra first, then run ${C}kodra dock${NC} again."
    exit 0
fi

# Build favorites list
FAVORITES_LIST=$(printf "'%s'," "${INSTALLED_APPS[@]}")
FAVORITES_LIST="[${FAVORITES_LIST%,}]"

# Apply
gsettings set org.gnome.shell favorite-apps "$FAVORITES_LIST"

echo -e "${G}✓ Dock updated with ${#INSTALLED_APPS[@]} apps${NC}"
echo ""
echo -e "${W}To customize further:${NC}"
echo -e "  • Right-click apps → Add to Favorites"
echo -e "  • Drag apps to reorder"
echo -e "  • Right-click → Remove from Favorites"
echo ""
