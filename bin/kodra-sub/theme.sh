#!/usr/bin/env bash
#
# Kodra Theme Switcher
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
THEMES_DIR="$KODRA_DIR/themes"

source "$KODRA_DIR/lib/utils.sh"

# Get current theme
get_current_theme() {
    if [ -f "$KODRA_CONFIG_DIR/theme" ]; then
        cat "$KODRA_CONFIG_DIR/theme"
    else
        echo "tokyo-night"
    fi
}

# List available themes
list_themes() {
    echo "Available themes:"
    echo ""
    for theme_dir in "$THEMES_DIR"/*/; do
        theme=$(basename "$theme_dir")
        if [ "$theme" = "$(get_current_theme)" ]; then
            echo "  ✓ $theme (current)"
        else
            echo "    $theme"
        fi
    done
}

# Apply a theme
apply_theme() {
    local theme="$1"
    local theme_dir="$THEMES_DIR/$theme"
    
    if [ ! -d "$theme_dir" ]; then
        log_error "Theme not found: $theme"
        list_themes
        exit 1
    fi
    
    log_info "Applying theme: $theme"
    
    # Ghostty (primary terminal)
    if [ -f "$theme_dir/ghostty.conf" ]; then
        mkdir -p "$HOME/.config/ghostty"
        cp "$theme_dir/ghostty.conf" "$HOME/.config/ghostty/theme"
        log_success "Ghostty theme applied"
    fi
    
    # Starship
    if [ -f "$theme_dir/starship.toml" ]; then
        mkdir -p "$HOME/.config"
        cp "$theme_dir/starship.toml" "$HOME/.config/starship.toml"
        log_success "Starship theme applied"
    fi
    
    # VS Code (if settings exist)
    if [ -f "$theme_dir/vscode-settings.json" ]; then
        VSCODE_DIR="$HOME/.config/Code/User"
        if [ -d "$VSCODE_DIR" ]; then
            # Merge theme settings
            if command -v jq &> /dev/null; then
                jq -s '.[0] * .[1]' "$VSCODE_DIR/settings.json" "$theme_dir/vscode-settings.json" > "$VSCODE_DIR/settings.json.tmp"
                mv "$VSCODE_DIR/settings.json.tmp" "$VSCODE_DIR/settings.json"
            fi
            log_success "VS Code theme applied"
        fi
    fi
    
    # GNOME/Desktop wallpaper
    local wallpaper_dir="$KODRA_DIR/wallpapers"
    local wallpaper=""
    
    # Map theme to wallpaper
    case "$theme" in
        tokyo-night)  wallpaper="$wallpaper_dir/wallpaper5.jpg" ;;   # Purple night
        ghostty-blue) wallpaper="$wallpaper_dir/wallpaper5.jpg" ;;   # Deep blue
        *)            wallpaper="$wallpaper_dir/wallpaper5.jpg" ;;   # Default
    esac
    
    if [ -f "$wallpaper" ]; then
        # gsettings may fail in containers or headless systems - that's OK
        if command -v gsettings &> /dev/null && [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
            if gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper" 2>/dev/null; then
                gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper" 2>/dev/null
                gsettings set org.gnome.desktop.background picture-options "zoom" 2>/dev/null
                log_success "Wallpaper applied"
            fi
        fi
    fi
    
    # Save current theme
    mkdir -p "$KODRA_CONFIG_DIR"
    echo "$theme" > "$KODRA_CONFIG_DIR/theme"
    
    echo ""
    log_success "Theme '$theme' applied!"
    echo "Restart your terminal to see changes."
}

# Interactive theme selection
select_theme_interactive() {
    if command -v gum &> /dev/null; then
        local themes=$(ls -1 "$THEMES_DIR")
        local selected=$(echo "$themes" | gum choose --height=8 --cursor.foreground="33")
        if [ -n "$selected" ]; then
            apply_theme "$selected"
        fi
    else
        list_themes
        echo ""
        read -p "Enter theme name: " theme_name
        if [ -n "$theme_name" ]; then
            apply_theme "$theme_name"
        fi
    fi
}

# Main
case "${1:-}" in
    list|--list|-l)
        list_themes
        ;;
    current|--current|-c)
        get_current_theme
        ;;
    "")
        select_theme_interactive
        ;;
    *)
        apply_theme "$1"
        ;;
esac
