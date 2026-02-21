#!/usr/bin/env bash
#
# Kodra GNOME Extensions Manager
# Part of #81 Extension Management
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

# Check if GNOME Shell is running
check_gnome() {
    if ! command -v gnome-extensions &>/dev/null; then
        log_error "gnome-extensions command not found"
        echo "Install it with: sudo apt install gnome-shell-extensions"
        exit 1
    fi
    
    if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
        log_error "No display detected. Run this in a graphical session."
        exit 1
    fi
}

# List all extensions
list_extensions() {
    check_gnome
    
    echo "Installed GNOME Extensions:"
    echo ""
    
    gnome-extensions list --user 2>/dev/null | while read -r ext; do
        local state=$(gnome-extensions info "$ext" 2>/dev/null | grep "State:" | cut -d: -f2 | xargs)
        local name=$(gnome-extensions info "$ext" 2>/dev/null | grep "Name:" | cut -d: -f2- | xargs)
        
        if [ "$state" = "ENABLED" ]; then
            echo -e "  \033[32m✓\033[0m $name ($ext)"
        else
            echo -e "  \033[90m○\033[0m $name ($ext)"
        fi
    done
    
    echo ""
    gnome-extensions list --system 2>/dev/null | while read -r ext; do
        local state=$(gnome-extensions info "$ext" 2>/dev/null | grep "State:" | cut -d: -f2 | xargs)
        local name=$(gnome-extensions info "$ext" 2>/dev/null | grep "Name:" | cut -d: -f2- | xargs)
        
        if [ "$state" = "ENABLED" ]; then
            echo -e "  \033[32m✓\033[0m $name (system)"
        fi
    done
}

# Enable an extension
enable_extension() {
    check_gnome
    local ext="$1"
    
    if [ -z "$ext" ]; then
        log_error "Usage: kodra extensions enable <extension-uuid>"
        echo ""
        echo "Available extensions:"
        gnome-extensions list 2>/dev/null
        exit 1
    fi
    
    if gnome-extensions enable "$ext" 2>/dev/null; then
        log_success "Enabled: $ext"
    else
        log_error "Failed to enable: $ext"
        exit 1
    fi
}

# Disable an extension
disable_extension() {
    check_gnome
    local ext="$1"
    
    if [ -z "$ext" ]; then
        log_error "Usage: kodra extensions disable <extension-uuid>"
        exit 1
    fi
    
    if gnome-extensions disable "$ext" 2>/dev/null; then
        log_success "Disabled: $ext"
    else
        log_error "Failed to disable: $ext"
        exit 1
    fi
}

# Install extension from extensions.gnome.org
install_extension() {
    local ext="$1"
    
    if [ -z "$ext" ]; then
        log_error "Usage: kodra extensions install <extension-uuid>"
        echo ""
        echo "Find extensions at: https://extensions.gnome.org"
        exit 1
    fi
    
    log_info "Installing extension: $ext"
    
    # Use gnome-extensions-cli if available, otherwise provide instructions
    if command -v gext &>/dev/null; then
        gext install "$ext"
        log_success "Extension installed"
    elif command -v gnome-extensions-app &>/dev/null; then
        gnome-extensions-app &
        log_info "Opening GNOME Extensions app..."
    else
        echo ""
        echo "To install extensions:"
        echo "  1. Install browser integration: sudo apt install gnome-browser-connector"
        echo "  2. Visit: https://extensions.gnome.org"
        echo "  3. Search for the extension and click install"
        echo ""
        echo "Or install gext: pip install gnome-extensions-cli"
    fi
}

# Uninstall extension
uninstall_extension() {
    check_gnome
    local ext="$1"
    
    if [ -z "$ext" ]; then
        log_error "Usage: kodra extensions uninstall <extension-uuid>"
        exit 1
    fi
    
    if gnome-extensions uninstall "$ext" 2>/dev/null; then
        log_success "Uninstalled: $ext"
    else
        log_error "Failed to uninstall: $ext"
        exit 1
    fi
}

# Show extension info
info_extension() {
    check_gnome
    local ext="$1"
    
    if [ -z "$ext" ]; then
        log_error "Usage: kodra extensions info <extension-uuid>"
        exit 1
    fi
    
    gnome-extensions info "$ext"
}

# Enable all installed extensions
enable_all() {
    check_gnome
    log_info "Enabling all installed extensions..."
    
    gnome-extensions list 2>/dev/null | while read -r ext; do
        gnome-extensions enable "$ext" 2>/dev/null && \
            echo "  ✓ $ext" || \
            echo "  ✗ $ext (failed)"
    done
    
    log_success "Done"
}

# Interactive extension picker
interactive_menu() {
    check_gnome
    
    if ! command -v gum &>/dev/null; then
        list_extensions
        return
    fi
    
    local action=$(gum choose \
        "List extensions" \
        "Enable extension" \
        "Disable extension" \
        "Enable all" \
        "Open GNOME Extensions app" \
        "Exit" \
        --cursor.foreground="33")
    
    case "$action" in
        "List extensions")
            list_extensions
            ;;
        "Enable extension")
            local disabled=$(gnome-extensions list 2>/dev/null | while read -r ext; do
                local state=$(gnome-extensions info "$ext" 2>/dev/null | grep "State:" | cut -d: -f2 | xargs)
                [ "$state" != "ENABLED" ] && echo "$ext"
            done)
            if [ -n "$disabled" ]; then
                local selected=$(echo "$disabled" | gum choose --cursor.foreground="33")
                [ -n "$selected" ] && enable_extension "$selected"
            else
                log_info "All extensions are already enabled"
            fi
            ;;
        "Disable extension")
            local enabled=$(gnome-extensions list 2>/dev/null | while read -r ext; do
                local state=$(gnome-extensions info "$ext" 2>/dev/null | grep "State:" | cut -d: -f2 | xargs)
                [ "$state" = "ENABLED" ] && echo "$ext"
            done)
            if [ -n "$enabled" ]; then
                local selected=$(echo "$enabled" | gum choose --cursor.foreground="33")
                [ -n "$selected" ] && disable_extension "$selected"
            else
                log_info "No extensions are enabled"
            fi
            ;;
        "Enable all")
            enable_all
            ;;
        "Open GNOME Extensions app")
            if command -v gnome-extensions-app &>/dev/null; then
                gnome-extensions-app &
            else
                xdg-open "https://extensions.gnome.org/local/" &
            fi
            ;;
        "Exit"|"")
            ;;
    esac
}

# Show help
show_help() {
    echo "Usage: kodra extensions <command> [args]"
    echo ""
    echo "Commands:"
    echo "  list              List installed extensions"
    echo "  enable <uuid>     Enable an extension"
    echo "  disable <uuid>    Disable an extension"
    echo "  install <uuid>    Install from extensions.gnome.org"
    echo "  uninstall <uuid>  Remove an extension"
    echo "  info <uuid>       Show extension details"
    echo "  enable-all        Enable all installed extensions"
    echo ""
    echo "Examples:"
    echo "  kodra extensions list"
    echo "  kodra extensions enable dash-to-dock@micxgx.gmail.com"
    echo "  kodra extensions disable blur-my-shell@aunetx"
    echo ""
}

# Main
case "${1:-}" in
    list|ls)
        list_extensions
        ;;
    enable)
        shift
        enable_extension "$@"
        ;;
    disable)
        shift
        disable_extension "$@"
        ;;
    install|add)
        shift
        install_extension "$@"
        ;;
    uninstall|remove)
        shift
        uninstall_extension "$@"
        ;;
    info|show)
        shift
        info_extension "$@"
        ;;
    enable-all)
        enable_all
        ;;
    help|-h|--help)
        show_help
        ;;
    "")
        interactive_menu
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
