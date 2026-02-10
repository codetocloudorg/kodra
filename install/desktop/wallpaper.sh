#!/usr/bin/env bash

# Kodra Wallpaper Setup
# Install and configure awesome dev wallpapers

set -euo pipefail

KODRA_DIR="${KODRA_DIR:-$HOME/.local/share/kodra}"
WALLPAPER_DIR="$KODRA_DIR/wallpapers"

# Ensure wallpaper directory exists
mkdir -p "$WALLPAPER_DIR"

echo "🖼️  Installing Kodra wallpapers..."

# Copy wallpapers
cp -r "$(dirname "$0")"/*.{png,jpg,svg} "$WALLPAPER_DIR/" 2>/dev/null || true

# Generate procedural wallpapers if ImageMagick is available
if command -v magick &>/dev/null || command -v convert &>/dev/null; then
    echo "   Generating procedural wallpapers..."
    
    CONVERT_CMD="convert"
    command -v magick &>/dev/null && CONVERT_CMD="magick"
    
    # Cyber Grid wallpaper
    $CONVERT_CMD -size 3840x2160 \
        xc:'#0d1117' \
        -fill 'none' -stroke '#58a6ff20' -strokewidth 1 \
        -draw "path 'M 0,0 L 3840,2160'" \
        -draw "path 'M 3840,0 L 0,2160'" \
        $(for i in $(seq 0 120 3840); do echo "-draw 'line $i,0 $i,2160'"; done) \
        $(for i in $(seq 0 120 2160); do echo "-draw 'line 0,$i 3840,$i'"; done) \
        -fill '#58a6ff' -font 'JetBrainsMono-NF' -pointsize 200 \
        -gravity center -annotate +0+0 '</>' \
        "$WALLPAPER_DIR/cyber-grid.png" 2>/dev/null || true
fi

# Set wallpaper based on theme
set_wallpaper() {
    local wallpaper="$1"
    
    if [[ -f "$wallpaper" ]]; then
        # GNOME
        if command -v gsettings &>/dev/null; then
            gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper"
            gsettings set org.gnome.desktop.background picture-options "zoom"
        fi
        
        # KDE Plasma
        if command -v plasma-apply-wallpaperimage &>/dev/null; then
            plasma-apply-wallpaperimage "$wallpaper"
        fi
        
        echo "✓ Wallpaper set: $(basename "$wallpaper")"
    fi
}

# Apply wallpaper based on current theme
CURRENT_THEME="${KODRA_THEME:-tokyo-night}"

case "$CURRENT_THEME" in
    tokyo-night|ghostty-blue)
        set_wallpaper "$WALLPAPER_DIR/wallpaper5.jpg"
        ;;
    *)
        set_wallpaper "$WALLPAPER_DIR/wallpaper5.jpg"
        ;;
esac

echo "✓ Wallpapers installed to $WALLPAPER_DIR"
