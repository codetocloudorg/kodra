#!/usr/bin/env bash
#
# Kodra Wallpaper Manager
# Browse and set wallpapers
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
WALLPAPER_DIR="$KODRA_DIR/wallpapers"

source "$KODRA_DIR/lib/utils.sh"

# List all wallpapers
list_wallpapers() {
    echo "Available wallpapers:"
    echo ""
    local count=1
    shopt -s nullglob
    for wp in "$WALLPAPER_DIR"/*.svg "$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg; do
        [ -f "$wp" ] || continue
        local name=$(basename "$wp")
        echo "  $count) $name"
        ((count++))
    done
    shopt -u nullglob
}

# Get current wallpaper
get_current() {
    if command -v gsettings &> /dev/null; then
        local uri=$(gsettings get org.gnome.desktop.background picture-uri-dark 2>/dev/null || \
                    gsettings get org.gnome.desktop.background picture-uri 2>/dev/null)
        echo "${uri//\'/}" | sed 's|file://||'
    fi
}

# Set wallpaper
set_wallpaper() {
    local wallpaper="$1"
    
    # If just a name, look in wallpaper dir
    if [[ ! "$wallpaper" = /* ]]; then
        # Try exact match first
        if [ -f "$WALLPAPER_DIR/$wallpaper" ]; then
            wallpaper="$WALLPAPER_DIR/$wallpaper"
        else
            # Try with extensions
            for ext in svg png jpg jpeg; do
                if [ -f "$WALLPAPER_DIR/${wallpaper}.$ext" ]; then
                    wallpaper="$WALLPAPER_DIR/${wallpaper}.$ext"
                    break
                fi
            done
        fi
    fi
    
    if [ ! -f "$wallpaper" ]; then
        log_error "Wallpaper not found: $wallpaper"
        list_wallpapers
        exit 1
    fi
    
    log_info "Setting wallpaper: $(basename "$wallpaper")"
    
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper"
        gsettings set org.gnome.desktop.background picture-options "zoom"
        log_success "Wallpaper applied!"
    elif command -v plasma-apply-wallpaperimage &> /dev/null; then
        plasma-apply-wallpaperimage "$wallpaper"
        log_success "Wallpaper applied!"
    else
        log_error "No supported desktop environment found"
        exit 1
    fi
}

# Next wallpaper (cycle)
next_wallpaper() {
    local current=$(get_current)
    local wallpapers=("$WALLPAPER_DIR"/*.{svg,png,jpg,jpeg})
    local count=${#wallpapers[@]}
    local current_idx=0
    
    # Find current index
    for i in "${!wallpapers[@]}"; do
        if [[ "${wallpapers[$i]}" == "$current" ]]; then
            current_idx=$i
            break
        fi
    done
    
    # Get next
    local next_idx=$(( (current_idx + 1) % count ))
    set_wallpaper "${wallpapers[$next_idx]}"
}

# Random wallpaper
random_wallpaper() {
    local wallpapers=("$WALLPAPER_DIR"/*.{svg,png,jpg,jpeg})
    local count=${#wallpapers[@]}
    local idx=$((RANDOM % count))
    set_wallpaper "${wallpapers[$idx]}"
}

# Interactive selection
select_interactive() {
    if command -v gum &> /dev/null; then
        local wallpapers=$(ls -1 "$WALLPAPER_DIR" 2>/dev/null | grep -E '\.(svg|png|jpg|jpeg)$')
        local selected=$(echo "$wallpapers" | gum choose --height=12 --cursor.foreground="212")
        if [ -n "$selected" ]; then
            set_wallpaper "$selected"
        fi
    else
        list_wallpapers
        echo ""
        read -p "Enter wallpaper name or number: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            local wallpapers=("$WALLPAPER_DIR"/*.{svg,png,jpg,jpeg})
            set_wallpaper "${wallpapers[$((choice-1))]}"
        else
            set_wallpaper "$choice"
        fi
    fi
}

# Show help
show_help() {
    echo "Usage: kodra wallpaper [command]"
    echo ""
    echo "Commands:"
    echo "  list        List all wallpapers"
    echo "  set <name>  Set a specific wallpaper"
    echo "  next        Cycle to next wallpaper"
    echo "  random      Set a random wallpaper"
    echo "  current     Show current wallpaper"
    echo ""
    echo "Without arguments, opens interactive picker."
}

# Main
case "${1:-}" in
    list)
        list_wallpapers
        ;;
    set)
        if [ -z "${2:-}" ]; then
            log_error "Please specify a wallpaper name"
            exit 1
        fi
        set_wallpaper "$2"
        ;;
    next)
        next_wallpaper
        ;;
    random)
        random_wallpaper
        ;;
    current)
        echo "Current: $(get_current)"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        select_interactive
        ;;
esac
