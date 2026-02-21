#!/usr/bin/env bash
#
# Kodra Wallpaper Manager
# Browse and set wallpapers with theme support
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
WALLPAPER_DIR="$KODRA_DIR/wallpapers"
STATE_FILE="$KODRA_DIR/.state/wallpaper"

source "$KODRA_DIR/lib/utils.sh"

# Get current theme
get_current_theme() {
    local state_file="$KODRA_DIR/.state/theme"
    if [ -f "$state_file" ]; then
        cat "$state_file"
    else
        echo "tokyo-night"
    fi
}

# Get wallpapers for current context (theme-specific or all)
get_wallpapers() {
    local theme=$(get_current_theme)
    local theme_wp_dir="$WALLPAPER_DIR/$theme"
    
    shopt -s nullglob
    local wallpapers=()
    
    # Theme-specific first
    if [ -d "$theme_wp_dir" ]; then
        for wp in "$theme_wp_dir"/*.{svg,png,jpg,jpeg,webp}; do
            [ -f "$wp" ] && wallpapers+=("$wp")
        done
    fi
    
    # Global wallpapers
    for wp in "$WALLPAPER_DIR"/*.{svg,png,jpg,jpeg,webp}; do
        [ -f "$wp" ] && wallpapers+=("$wp")
    done
    
    shopt -u nullglob
    
    # Return unique list
    printf '%s\n' "${wallpapers[@]}" | sort -u
}

# List all wallpapers
list_wallpapers() {
    local theme=$(get_current_theme)
    local theme_wp_dir="$WALLPAPER_DIR/$theme"
    local count=1
    
    echo "Wallpapers (theme: $theme):"
    echo ""
    
    # Theme-specific
    if [ -d "$theme_wp_dir" ]; then
        echo "  Theme wallpapers:"
        shopt -s nullglob
        for wp in "$theme_wp_dir"/*.{svg,png,jpg,jpeg,webp}; do
            [ -f "$wp" ] || continue
            local name=$(basename "$wp")
            echo "    $count) $name"
            ((count++))
        done
        shopt -u nullglob
        echo ""
    fi
    
    # Global
    echo "  Global wallpapers:"
    shopt -s nullglob
    for wp in "$WALLPAPER_DIR"/*.{svg,png,jpg,jpeg,webp}; do
        [ -f "$wp" ] || continue
        local name=$(basename "$wp")
        echo "    $count) $name"
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

# Save wallpaper state
save_state() {
    local wallpaper="$1"
    mkdir -p "$(dirname "$STATE_FILE")"
    echo "$wallpaper" > "$STATE_FILE"
}

# Set wallpaper
set_wallpaper() {
    local wallpaper="$1"
    local theme=$(get_current_theme)
    
    # If just a name, look in theme-specific then global wall dir
    if [[ ! "$wallpaper" = /* ]]; then
        local found=false
        
        # Try theme-specific directory first
        local theme_wp_dir="$WALLPAPER_DIR/$theme"
        if [ -d "$theme_wp_dir" ]; then
            if [ -f "$theme_wp_dir/$wallpaper" ]; then
                wallpaper="$theme_wp_dir/$wallpaper"
                found=true
            else
                for ext in svg png jpg jpeg webp; do
                    if [ -f "$theme_wp_dir/${wallpaper}.$ext" ]; then
                        wallpaper="$theme_wp_dir/${wallpaper}.$ext"
                        found=true
                        break
                    fi
                done
            fi
        fi
        
        # Try global directory
        if [ "$found" = false ]; then
            if [ -f "$WALLPAPER_DIR/$wallpaper" ]; then
                wallpaper="$WALLPAPER_DIR/$wallpaper"
            else
                for ext in svg png jpg jpeg webp; do
                    if [ -f "$WALLPAPER_DIR/${wallpaper}.$ext" ]; then
                        wallpaper="$WALLPAPER_DIR/${wallpaper}.$ext"
                        break
                    fi
                done
            fi
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
        save_state "$wallpaper"
        log_success "Wallpaper applied!"
    elif command -v plasma-apply-wallpaperimage &> /dev/null; then
        plasma-apply-wallpaperimage "$wallpaper"
        save_state "$wallpaper"
        log_success "Wallpaper applied!"
    else
        log_error "No supported desktop environment found"
        exit 1
    fi
}

# Next wallpaper (cycle forward)
next_wallpaper() {
    local current=$(get_current)
    mapfile -t wallpapers < <(get_wallpapers)
    local count=${#wallpapers[@]}
    
    if [ "$count" -eq 0 ]; then
        log_error "No wallpapers found"
        exit 1
    fi
    
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

# Previous wallpaper (cycle backward)
prev_wallpaper() {
    local current=$(get_current)
    mapfile -t wallpapers < <(get_wallpapers)
    local count=${#wallpapers[@]}
    
    if [ "$count" -eq 0 ]; then
        log_error "No wallpapers found"
        exit 1
    fi
    
    local current_idx=0
    
    # Find current index
    for i in "${!wallpapers[@]}"; do
        if [[ "${wallpapers[$i]}" == "$current" ]]; then
            current_idx=$i
            break
        fi
    done
    
    # Get previous (with wraparound)
    local prev_idx
    if [ "$current_idx" -eq 0 ]; then
        prev_idx=$((count - 1))
    else
        prev_idx=$((current_idx - 1))
    fi
    set_wallpaper "${wallpapers[$prev_idx]}"
}

# Random wallpaper
random_wallpaper() {
    mapfile -t wallpapers < <(get_wallpapers)
    local count=${#wallpapers[@]}
    
    if [ "$count" -eq 0 ]; then
        log_error "No wallpapers found"
        exit 1
    fi
    
    local idx=$((RANDOM % count))
    set_wallpaper "${wallpapers[$idx]}"
}

# Interactive selection
select_interactive() {
    local theme=$(get_current_theme)
    
    if command -v gum &> /dev/null; then
        # Build list with theme-specific and global wallpapers
        local wallpapers=$(get_wallpapers | xargs -n1 basename | sort -u)
        
        echo "Select wallpaper (theme: $theme)"
        local selected=$(echo "$wallpapers" | gum choose --height=12 --cursor.foreground="212")
        if [ -n "$selected" ]; then
            set_wallpaper "$selected"
        fi
    else
        list_wallpapers
        echo ""
        read -p "Enter wallpaper name: " choice
        if [ -n "$choice" ]; then
            set_wallpaper "$choice"
        fi
    fi
}

# Show help
show_help() {
    echo "Usage: kodra wallpaper [command]"
    echo ""
    echo "Commands:"
    echo "  list        List all wallpapers (theme-specific + global)"
    echo "  set <name>  Set a specific wallpaper"
    echo "  next        Cycle to next wallpaper"
    echo "  prev        Cycle to previous wallpaper"
    echo "  random      Set a random wallpaper"
    echo "  current     Show current wallpaper"
    echo "  theme       List wallpapers for current theme"
    echo ""
    echo "Wallpapers can be organized by theme:"
    echo "  ~/.kodra/wallpapers/<theme-name>/*.png"
    echo ""
    echo "Without arguments, opens interactive picker."
}

# List theme-specific wallpapers only
theme_wallpapers() {
    local theme=$(get_current_theme)
    local theme_wp_dir="$WALLPAPER_DIR/$theme"
    
    echo "Wallpapers for theme: $theme"
    echo ""
    
    if [ -d "$theme_wp_dir" ]; then
        local count=1
        shopt -s nullglob
        for wp in "$theme_wp_dir"/*.{svg,png,jpg,jpeg,webp}; do
            [ -f "$wp" ] || continue
            echo "  $count) $(basename "$wp")"
            ((count++))
        done
        shopt -u nullglob
        
        if [ "$count" -eq 1 ]; then
            echo "  (no theme-specific wallpapers)"
            echo ""
            echo "Add wallpapers to: $theme_wp_dir/"
        fi
    else
        echo "  (no theme directory)"
        echo ""
        echo "Create: $theme_wp_dir/"
        echo "Add wallpapers matching your theme"
    fi
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
    prev)
        prev_wallpaper
        ;;
    random)
        random_wallpaper
        ;;
    current)
        echo "Current: $(get_current)"
        ;;
    theme)
        theme_wallpapers
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        select_interactive
        ;;
esac
