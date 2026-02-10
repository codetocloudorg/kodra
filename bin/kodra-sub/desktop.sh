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
    echo "  dock        Configure bottom dock"
    echo "  tiling      Configure window tiling + show shortcuts"
    echo "  login       Customize login screen (dark theme, wallpaper)"
    echo "  extensions  Enable recommended GNOME extensions"
    echo "  reset       Reset to default GNOME settings"
    echo ""
    echo "Examples:"
    echo "  kodra desktop setup       # Full desktop setup"
    echo "  kodra desktop tiling      # Configure window tiling"
    echo "  kodra desktop login       # Customize login screen"
    echo "  kodra desktop dock        # Just configure the dock"
}

setup_desktop() {
    log_info "Running full desktop setup..."
    bash "$KODRA_DIR/install/desktop/gnome-setup.sh"
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
    setup|"")
        setup_desktop
        ;;
    dock)
        configure_dock
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
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
