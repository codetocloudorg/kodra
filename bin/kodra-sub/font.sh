#!/usr/bin/env bash
#
# Kodra Font Manager
# Change terminal and system fonts
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

# Common Nerd Fonts
NERD_FONTS=(
    "JetBrainsMono Nerd Font"
    "FiraCode Nerd Font"
    "Hack Nerd Font"
    "CascadiaCode Nerd Font"
    "SourceCodePro Nerd Font"
    "UbuntuMono Nerd Font"
    "RobotoMono Nerd Font"
    "Inconsolata Nerd Font"
    "Meslo Nerd Font"
    "VictorMono Nerd Font"
)

# List available fonts
list_fonts() {
    echo "Available Nerd Fonts:"
    echo ""
    
    local count=1
    for font in "${NERD_FONTS[@]}"; do
        # Check if installed
        if fc-list 2>/dev/null | grep -qi "${font%% *}"; then
            echo "  $count) $font ✓ (installed)"
        else
            echo "  $count) $font"
        fi
        ((count++))
    done
    
    echo ""
    echo "System fonts:"
    fc-list : family 2>/dev/null | grep -i nerd | sort -u | head -10 | sed 's/^/  /'
}

# Get current font
get_current() {
    local ghostty_config="$HOME/.config/ghostty/config"
    
    if [ -f "$ghostty_config" ]; then
        local font=$(grep "^font-family" "$ghostty_config" | head -1 | cut -d'=' -f2 | xargs)
        echo "Current font: $font"
    else
        echo "Current font: (using default)"
    fi
}

# Set font
set_font() {
    local font="$1"
    
    if [ -z "$font" ]; then
        log_error "Please specify a font name"
        list_fonts
        exit 1
    fi
    
    # Check if font exists
    if ! fc-list 2>/dev/null | grep -qi "${font%% *}"; then
        log_warning "Font '$font' may not be installed"
        echo "Install with: brew install font-${font,,}-nerd-font"
    fi
    
    log_info "Setting font to: $font"
    
    # Update Ghostty config
    local ghostty_config="$HOME/.config/ghostty/config"
    if [ -f "$ghostty_config" ]; then
        # Replace or add font-family line
        if grep -q "^font-family" "$ghostty_config"; then
            sed -i "s/^font-family.*/font-family = $font/" "$ghostty_config" 2>/dev/null || \
            sed -i '' "s/^font-family.*/font-family = $font/" "$ghostty_config"
        else
            echo "font-family = $font" >> "$ghostty_config"
        fi
        log_success "Updated Ghostty config"
    fi
    
    # Update GNOME monospace font
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.interface monospace-font-name "$font 11" 2>/dev/null || true
        log_success "Updated GNOME monospace font"
    fi
    
    echo ""
    echo "Restart Ghostty to apply changes"
}

# Interactive selection
select_interactive() {
    if ! command -v gum &>/dev/null; then
        list_fonts
        echo ""
        read -p "Enter font name: " font
        [ -n "$font" ] && set_font "$font"
        return
    fi
    
    get_current
    echo ""
    
    local selected=$(printf '%s\n' "${NERD_FONTS[@]}" | gum choose --height=12 --cursor.foreground="212")
    
    if [ -n "$selected" ]; then
        set_font "$selected"
    fi
}

# Show help
show_help() {
    echo "Usage: kodra font [command]"
    echo ""
    echo "Commands:"
    echo "  list                List available fonts"
    echo "  set <name>          Set terminal font"
    echo "  current             Show current font"
    echo ""
    echo "Without arguments, opens interactive picker."
    echo ""
    echo "Examples:"
    echo "  kodra font                          # Interactive selection"
    echo "  kodra font set \"JetBrainsMono Nerd Font\""
    echo "  kodra font list"
}

# Main
case "${1:-}" in
    list|ls)
        list_fonts
        ;;
    set)
        shift
        set_font "$*"
        ;;
    current)
        get_current
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        select_interactive
        ;;
esac
