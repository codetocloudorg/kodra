#!/usr/bin/env bash
#
# Kodra Dock - Configure dock favorites
# Only shows installed apps, keeps it clean
#

set -e

# Colors
C='\033[0;36m'   # Cyan - headings
G='\033[0;32m'   # Green - success
Y='\033[0;33m'   # Yellow - warnings
R='\033[0;31m'   # Red - errors
W='\033[0;37m'   # White - body text
NC='\033[0m'     # Reset

echo ""
echo -e "${C}📌 Kodra Dock Configuration${NC}"
echo -e "${W}────────────────────────────────────────${NC}"

# Check if GNOME
if ! command -v gnome-shell &> /dev/null; then
    echo -e "${R}✖ GNOME Shell not detected${NC}"
    exit 1
fi

# Desktop file locations — Flatpak paths are checked first so Flatpak
# versions are preferred over native .deb installs
DESKTOP_DIRS=(
    "/var/lib/flatpak/exports/share/applications"
    "$HOME/.local/share/applications"
    "/usr/share/applications"
    "/usr/local/share/applications"
)

# Find the first existing .desktop file from a list of variant names
# Arguments:
#   $@ - One or more .desktop filename variants to search for
# Returns: Prints the first match; exits 1 if none found
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

# Look up an app by name, add to INSTALLED_APPS if found, and log the result
# Arguments:
#   $1 - Human-readable app name (for display)
#   $@ - Remaining args are .desktop filename variants
add_app() {
    local name="$1"
    shift
    local app
    app=$(find_app "$@")
    if [ -n "$app" ]; then
        echo -e "  ${G}✓${NC} $name"
        INSTALLED_APPS+=("$app")
        return 0
    fi
    return 1
}

INSTALLED_APPS=()
echo ""
echo -e "${W}Finding installed apps...${NC}"

# Add apps - only first variant found per app
add_app "Files" "org.gnome.Nautilus.desktop"
add_app "Brave" "com.brave.Browser.desktop" "brave-browser.desktop"
add_app "Ghostty" "com.mitchellh.ghostty.desktop" "ghostty.desktop"
add_app "VS Code" "code.desktop"
add_app "Neovim" "nvim.desktop" "neovim.desktop"
add_app "GitHub Desktop" "io.github.shiftey.Desktop.desktop" "github-desktop.desktop"
add_app "Spotify" "com.spotify.Client.desktop" "spotify.desktop"
add_app "Discord" "com.discordapp.Discord.desktop" "discord.desktop"
add_app "Settings" "org.gnome.Settings.desktop" "gnome-control-center.desktop"

echo ""

if [ ${#INSTALLED_APPS[@]} -eq 0 ]; then
    echo -e "${Y}No matching apps found.${NC}"
    echo -e "Install apps with kodra first, then run ${C}kodra dock${NC} again."
    exit 0
fi

# Build a gsettings-compatible array string from the matched apps
FAVORITES_LIST=$(printf "'%s'," "${INSTALLED_APPS[@]}")
FAVORITES_LIST="[${FAVORITES_LIST%,}]"  # Strip trailing comma and wrap

# Apply the favorites list to GNOME Shell
gsettings set org.gnome.shell favorite-apps "$FAVORITES_LIST"

echo -e "${G}✓ Dock updated with ${#INSTALLED_APPS[@]} apps${NC}"
echo ""
echo -e "${W}To customize further:${NC}"
echo -e "  • Right-click apps → Add to Favorites"
echo -e "  • Drag apps to reorder"
echo -e "  • Right-click → Remove from Favorites"
echo ""
