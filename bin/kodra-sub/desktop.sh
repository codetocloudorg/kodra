#!/usr/bin/env bash
#
# Kodra Desktop Setup Command
# Configure beautiful GNOME desktop
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_DATA_DIR="$HOME/.local/share/kodra"

source "$KODRA_DIR/lib/utils.sh"

show_help() {
    echo "Usage: kodra desktop [command]"
    echo ""
    echo "Configure your desktop for the best developer experience"
    echo ""
    echo "Commands:"
    echo "  setup       Run full desktop setup (themes, shortcuts, etc.)"
    echo "  refresh     Re-apply all desktop settings (extensions, dock, apps)"
    echo "  dock        Configure bottom dock with installed apps"
    echo "  tiling      Configure window tiling + show shortcuts"
    echo "  login       Customize login screen (dark theme, wallpaper)"
    echo "  extensions  Enable recommended GNOME extensions"
    echo "  reset       Reset to default GNOME settings"
    echo ""
    echo "Examples:"
    echo "  kodra desktop setup       # Full desktop setup (first time)"
    echo "  kodra desktop refresh     # Re-apply after update (use this!)"
    echo "  kodra desktop dock        # Just reconfigure the dock"
    echo "  kodra desktop tiling      # Configure window tiling"
}

setup_desktop() {
    log_info "Running full desktop setup..."
    bash "$KODRA_DIR/install/desktop/gnome-setup.sh"
}

refresh_desktop() {
    echo ""
    echo -e "\033[38;5;51m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "  \033[1m🔄 Kodra Desktop Refresh\033[0m"
    echo -e "\033[38;5;51m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    
    # 1. Refresh desktop database for Flatpak apps
    log_info "Refreshing desktop database..."
    export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    if command -v update-desktop-database &>/dev/null; then
        sudo update-desktop-database /var/lib/flatpak/exports/share/applications 2>/dev/null || true
        update-desktop-database "$HOME/.local/share/flatpak/exports/share/applications" 2>/dev/null || true
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    fi
    log_success "Desktop database refreshed"
    
    # 2. Enable GNOME extensions
    log_info "Enabling GNOME extensions..."
    EXTENSIONS=(
        "dash-to-dock@micxgx.gmail.com"
        "blur-my-shell@aunetx"
        "tactile@lundal.io"
        "tophat@fflewddur.github.io"
        "AlphabeticalAppGrid@stuarthayhurst"
        "space-bar@luchrioh"
    )
    
    for ext in "${EXTENSIONS[@]}"; do
        if [ -d "$HOME/.local/share/gnome-shell/extensions/$ext" ]; then
            gnome-extensions enable "$ext" 2>/dev/null && echo "  ✓ Enabled: $ext" || true
        fi
    done
    
    # Disable conflicting Ubuntu defaults
    gnome-extensions disable ubuntu-dock@ubuntu.com 2>/dev/null || true
    gnome-extensions disable ding@rastersoft.com 2>/dev/null || true
    log_success "Extensions configured"
    
    # 3. Configure dock
    log_info "Configuring dock..."
    if [ -f "$KODRA_DATA_DIR/configure-dock.sh" ]; then
        bash "$KODRA_DATA_DIR/configure-dock.sh" 2>/dev/null || true
    fi
    
    # 4. Set dock favorites with detected apps
    log_info "Setting dock favorites..."
    
    DESKTOP_DIRS=(
        "/var/lib/flatpak/exports/share/applications"
        "$HOME/.local/share/applications"
        "/usr/share/applications"
        "/usr/local/share/applications"
    )
    
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
    
    INSTALLED_APPS=()
    app=$(find_app "org.gnome.Nautilus.desktop") && INSTALLED_APPS+=("$app")
    app=$(find_app "com.brave.Browser.desktop" "brave-browser.desktop") && INSTALLED_APPS+=("$app")
    app=$(find_app "com.mitchellh.ghostty.desktop" "ghostty.desktop") && INSTALLED_APPS+=("$app")
    app=$(find_app "code.desktop") && INSTALLED_APPS+=("$app")
    app=$(find_app "io.github.shiftey.Desktop.desktop" "github-desktop.desktop") && INSTALLED_APPS+=("$app")
    app=$(find_app "com.spotify.Client.desktop" "spotify.desktop") && INSTALLED_APPS+=("$app")
    app=$(find_app "com.discordapp.Discord.desktop" "discord.desktop") && INSTALLED_APPS+=("$app")
    app=$(find_app "com.bitwarden.desktop.desktop") && INSTALLED_APPS+=("$app")
    app=$(find_app "org.gnome.Settings.desktop" "gnome-control-center.desktop") && INSTALLED_APPS+=("$app")
    
    if [ ${#INSTALLED_APPS[@]} -gt 0 ]; then
        FAVORITES_LIST=$(printf "'%s'," "${INSTALLED_APPS[@]}")
        FAVORITES_LIST="[${FAVORITES_LIST%,}]"
        gsettings set org.gnome.shell favorite-apps "$FAVORITES_LIST" 2>/dev/null || true
        log_success "Dock favorites set (${#INSTALLED_APPS[@]} apps)"
    fi
    
    # 5. Remove first-login autostart if present (we just ran it manually)
    rm -f "$HOME/.config/autostart/kodra-first-login.desktop" 2>/dev/null || true
    mkdir -p "$HOME/.config/kodra"
    date +%s > "$HOME/.config/kodra/first_login_complete"
    
    echo ""
    echo -e "\033[38;5;46m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "  \033[1m✨ Desktop Refresh Complete!\033[0m"
    echo -e "\033[38;5;46m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "  Changes applied:"
    echo "    ✓ Desktop database refreshed (Flatpak apps)"
    echo "    ✓ GNOME extensions enabled"
    echo "    ✓ Dock configured and favorites set"
    echo ""
    echo "  If you don't see changes yet:"
    echo "    • Press Alt+F2, type 'r', press Enter (restarts GNOME Shell)"
    echo "    • Or log out and log back in"
    echo ""
}

configure_dock() {
    if [ -f "$KODRA_DATA_DIR/configure-dock.sh" ]; then
        bash "$KODRA_DATA_DIR/configure-dock.sh"
    else
        log_error "Dock configuration script not found"
        echo "Run 'kodra desktop setup' first"
        exit 1
    fi
}

setup_extensions() {
    if [ -f "$KODRA_DATA_DIR/setup-extensions.sh" ]; then
        bash "$KODRA_DATA_DIR/setup-extensions.sh"
    else
        log_error "Extensions setup script not found"
        echo "Run 'kodra desktop setup' first"
        exit 1
    fi
}

customize_login_screen() {
    log_info "Customizing login screen..."
    if [ -f "$KODRA_DIR/install/desktop/login-screen.sh" ]; then
        bash "$KODRA_DIR/install/desktop/login-screen.sh"
    else
        log_error "Login screen script not found"
        exit 1
    fi
}

reset_desktop() {
    log_warning "This will reset GNOME to default settings"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Resetting GNOME settings..."
        
        # Reset button layout
        gsettings reset org.gnome.desktop.wm.preferences button-layout
        
        # Reset dock (if schema exists)
        if gsettings list-schemas | grep -q "org.gnome.shell.extensions.dash-to-dock"; then
            gsettings reset org.gnome.shell.extensions.dash-to-dock dock-position
            gsettings reset org.gnome.shell.extensions.dash-to-dock extend-height
        fi
        
        log_success "Desktop reset to defaults"
    fi
}

configure_tiling() {
    if [ -f "$KODRA_DATA_DIR/configure-tiling.sh" ]; then
        bash "$KODRA_DATA_DIR/configure-tiling.sh"
    else
        log_info "Tiling configuration will be set up..."
        # Show the shortcuts anyway
        echo ""
        echo "  Window Tiling Shortcuts:"
        echo "  ──────────────────────────────────────"
        echo "  Super + T           : Show Tactile tiling grid"
        echo "  Super + ←/→         : Tile left/right half"
        echo "  Super + ↑           : Maximize window"
        echo "  Ctrl + Super + ←/→/↑/↓ : Tile to screen edges"
        echo "  Ctrl + Alt + U/I/J/K   : Tile to corners"
        echo ""
        echo "  Workspace Navigation:"
        echo "  ──────────────────────────────────────"
        echo "  Ctrl + Super + ←/→     : Switch workspace"
        echo "  Shift + Ctrl + Super + ←/→ : Move window to workspace"
        echo ""
        echo "  Run 'kodra desktop setup' to configure Tactile extension."
    fi
}

# Main
case "${1:-}" in
    setup)
        setup_desktop
        ;;
    refresh|reload)
        refresh_desktop
        ;;
    dock)
        bash "$KODRA_DIR/bin/kodra-sub/dock.sh"
        ;;
    tiling|tile|windows)
        configure_tiling
        ;;
    login)
        customize_login_screen
        ;;
    extensions|ext)
        setup_extensions
        ;;
    reset)
        reset_desktop
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
