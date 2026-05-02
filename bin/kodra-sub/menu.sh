#!/usr/bin/env bash
#
# Kodra Menu - Interactive main menu
# Uses gum for a beautiful TUI that dispatches to other kodra subcommands.
# Requires gum to be installed.
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Source UI library
source "$KODRA_DIR/lib/ui.sh" 2>/dev/null || true

# Colors
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Check for gum
if ! command -v gum &>/dev/null; then
    echo -e "${YELLOW}gum is required for interactive menus.${NC}"
    echo "Install with: brew install gum"
    exit 1
fi

# Display the top-level menu with ASCII banner and dispatch selection
show_main_menu() {
    clear
    echo ""
    echo -e "${PURPLE}    ██╗  ██╗ ██████╗ ██████╗ ██████╗  █████╗${NC}"
    echo -e "${PURPLE}    ██║ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗${NC}"
    echo -e "${PURPLE}    █████╔╝ ██║   ██║██║  ██║██████╔╝███████║${NC}"
    echo -e "${PURPLE}    ██╔═██╗ ██║   ██║██║  ██║██╔══██╗██╔══██║${NC}"
    echo -e "${PURPLE}    ██║  ██╗╚██████╔╝██████╔╝██║  ██║██║  ██║${NC}"
    echo -e "${PURPLE}    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝${NC}"
    echo ""
    
    CHOICE=$(gum choose \
        "🎨 Theme" \
        "🖼️  Wallpaper" \
        "🖥️  Desktop" \
        "📦 Install Apps" \
        "🔄 Update" \
        "⚡ Power" \
        "🌙 Night Light" \
        "🩺 Doctor" \
        "ℹ️  System Info" \
        "❓ Help" \
        "🚪 Exit" \
        --header "Select an option:" \
        --cursor "▶ " \
        --cursor.foreground="135")
    
    case "$CHOICE" in
        "🎨 Theme")
            show_theme_menu
            ;;
        "🖼️  Wallpaper")
            bash "$KODRA_DIR/bin/kodra-sub/wallpaper.sh"
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        "🖥️  Desktop")
            show_desktop_menu
            ;;
        "📦 Install Apps")
            show_install_menu
            ;;
        "🔄 Update")
            bash "$KODRA_DIR/bin/kodra-sub/update.sh"
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        "⚡ Power")
            bash "$KODRA_DIR/bin/kodra-sub/power.sh"
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        "🌙 Night Light")
            bash "$KODRA_DIR/bin/kodra-sub/nightlight.sh"
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        "🩺 Doctor")
            bash "$KODRA_DIR/bin/kodra-sub/doctor.sh"
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        "ℹ️  System Info")
            bash "$KODRA_DIR/bin/kodra-sub/fetch.sh"
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        "❓ Help")
            bash "$KODRA_DIR/bin/kodra" help
            read -p "Press Enter to continue..."
            show_main_menu
            ;;
        "🚪 Exit")
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
    esac
}

# Show theme selection submenu, populated from themes/ directory
show_theme_menu() {
    clear
    echo -e "${PURPLE}🎨 Theme Selection${NC}"
    echo ""
    
    # List available themes
    THEMES_DIR="$KODRA_DIR/themes"
    THEMES=()
    # Collect theme directories (null-delimited for safe handling of special chars)
    while IFS= read -r -d '' theme; do
        name=$(basename "$theme")
        THEMES+=("$name")
    done < <(find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
    
    if [ ${#THEMES[@]} -eq 0 ]; then
        echo "No themes found."
        read -p "Press Enter to continue..."
        show_main_menu
        return
    fi
    
    THEMES+=("← Back")
    
    CHOICE=$(gum choose "${THEMES[@]}" \
        --header "Select a theme:" \
        --cursor "▶ " \
        --cursor.foreground="135")
    
    if [ "$CHOICE" = "← Back" ]; then
        show_main_menu
    else
        bash "$KODRA_DIR/bin/kodra-sub/theme.sh" "$CHOICE"
        read -p "Press Enter to continue..."
        show_main_menu
    fi
}

# Show desktop configuration submenu (refresh, setup, dock, extensions)
show_desktop_menu() {
    clear
    echo -e "${PURPLE}🖥️ Desktop Configuration${NC}"
    echo ""
    
    CHOICE=$(gum choose \
        "🔄 Refresh Desktop" \
        "🚀 Setup Desktop" \
        "📌 Configure Dock" \
        "🧩 Manage Extensions" \
        "← Back" \
        --header "Select an option:" \
        --cursor "▶ " \
        --cursor.foreground="135")
    
    case "$CHOICE" in
        "🔄 Refresh Desktop")
            bash "$KODRA_DIR/bin/kodra-sub/desktop.sh" refresh
            ;;
        "🚀 Setup Desktop")
            bash "$KODRA_DIR/bin/kodra-sub/desktop.sh" setup
            ;;
        "📌 Configure Dock")
            bash "$KODRA_DIR/bin/kodra-sub/desktop.sh" dock
            ;;
        "🧩 Manage Extensions")
            bash "$KODRA_DIR/bin/kodra-sub/desktop.sh" extensions
            ;;
        "← Back")
            show_main_menu
            return
            ;;
    esac
    
    read -p "Press Enter to continue..."
    show_desktop_menu
}

# Show application installer submenu, populated from applications/ directory
show_install_menu() {
    clear
    echo -e "${PURPLE}📦 Install Applications${NC}"
    echo ""
    
    # List available applications
    APPS_DIR="$KODRA_DIR/applications"
    APPS=()
    while IFS= read -r -d '' app; do
        name=$(basename "$app" .sh)
        APPS+=("$name")
    done < <(find "$APPS_DIR" -name "*.sh" -print0 | sort -z)
    
    if [ ${#APPS[@]} -eq 0 ]; then
        echo "No applications available."
        read -p "Press Enter to continue..."
        show_main_menu
        return
    fi
    
    APPS+=("← Back")
    
    CHOICE=$(gum choose "${APPS[@]}" \
        --header "Select an application to install:" \
        --cursor "▶ " \
        --cursor.foreground="135")
    
    if [ "$CHOICE" = "← Back" ]; then
        show_main_menu
    else
        bash "$KODRA_DIR/bin/kodra-sub/install.sh" "$CHOICE"
        read -p "Press Enter to continue..."
        show_install_menu
    fi
}

# Run main menu
show_main_menu
