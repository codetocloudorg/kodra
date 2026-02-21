#!/usr/bin/env bash
#
# Kodra Screenshot Tool
# Take screenshots with various options
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
SCREENSHOT_DIR="${HOME}/Pictures/Screenshots"

source "$KODRA_DIR/lib/utils.sh"

# Ensure screenshot directory exists
mkdir -p "$SCREENSHOT_DIR"

# Generate filename
get_filename() {
    local prefix="${1:-screenshot}"
    echo "$SCREENSHOT_DIR/${prefix}_$(date +%Y-%m-%d_%H-%M-%S).png"
}

# Full screen screenshot
screenshot_full() {
    local output=$(get_filename "fullscreen")
    
    if command -v gnome-screenshot &>/dev/null; then
        gnome-screenshot -f "$output"
    elif command -v scrot &>/dev/null; then
        scrot "$output"
    elif command -v import &>/dev/null; then
        import -window root "$output"
    else
        log_error "No screenshot tool found. Install: sudo apt install gnome-screenshot"
        exit 1
    fi
    
    log_success "Screenshot saved: $output"
    
    # Copy to clipboard if xclip available
    if command -v xclip &>/dev/null; then
        xclip -selection clipboard -t image/png -i "$output"
        log_info "Copied to clipboard"
    fi
}

# Region selection screenshot
screenshot_region() {
    local output=$(get_filename "region")
    
    if command -v gnome-screenshot &>/dev/null; then
        gnome-screenshot -a -f "$output"
    elif command -v scrot &>/dev/null; then
        scrot -s "$output"
    elif command -v flameshot &>/dev/null; then
        flameshot gui -p "$SCREENSHOT_DIR"
        return
    else
        log_error "No screenshot tool found. Install: sudo apt install gnome-screenshot"
        exit 1
    fi
    
    if [ -f "$output" ]; then
        log_success "Screenshot saved: $output"
        
        if command -v xclip &>/dev/null; then
            xclip -selection clipboard -t image/png -i "$output"
            log_info "Copied to clipboard"
        fi
    fi
}

# Active window screenshot
screenshot_window() {
    local output=$(get_filename "window")
    
    if command -v gnome-screenshot &>/dev/null; then
        gnome-screenshot -w -f "$output"
    elif command -v scrot &>/dev/null; then
        scrot -u "$output"
    else
        log_error "No screenshot tool found. Install: sudo apt install gnome-screenshot"
        exit 1
    fi
    
    log_success "Screenshot saved: $output"
    
    if command -v xclip &>/dev/null; then
        xclip -selection clipboard -t image/png -i "$output"
        log_info "Copied to clipboard"
    fi
}

# Delayed screenshot
screenshot_delay() {
    local delay="${1:-5}"
    local output=$(get_filename "delayed")
    
    log_info "Taking screenshot in $delay seconds..."
    
    if command -v gnome-screenshot &>/dev/null; then
        gnome-screenshot -d "$delay" -f "$output"
    elif command -v scrot &>/dev/null; then
        scrot -d "$delay" "$output"
    else
        sleep "$delay"
        screenshot_full
        return
    fi
    
    log_success "Screenshot saved: $output"
}

# Open screenshot folder
open_folder() {
    if command -v xdg-open &>/dev/null; then
        xdg-open "$SCREENSHOT_DIR"
    else
        echo "Screenshots: $SCREENSHOT_DIR"
        ls -la "$SCREENSHOT_DIR"
    fi
}

# Interactive mode
interactive_mode() {
    if ! command -v gum &>/dev/null; then
        show_help
        exit 0
    fi
    
    local choice=$(gum choose \
        "Full screen" \
        "Select region" \
        "Active window" \
        "Delayed (5s)" \
        "Open folder")
    
    case "$choice" in
        "Full screen")
            screenshot_full
            ;;
        "Select region")
            screenshot_region
            ;;
        "Active window")
            screenshot_window
            ;;
        "Delayed (5s)")
            screenshot_delay 5
            ;;
        "Open folder")
            open_folder
            ;;
    esac
}

# Show help
show_help() {
    echo "Usage: kodra screenshot [command]"
    echo ""
    echo "Commands:"
    echo "  full              Capture full screen"
    echo "  region            Select area to capture"
    echo "  window            Capture active window"
    echo "  delay [seconds]   Delayed capture (default: 5s)"
    echo "  folder            Open screenshots folder"
    echo ""
    echo "Screenshots saved to: $SCREENSHOT_DIR"
    echo ""
    echo "Without arguments, opens interactive menu."
}

# Main
case "${1:-}" in
    full|f)
        screenshot_full
        ;;
    region|r|area|select)
        screenshot_region
        ;;
    window|w|active)
        screenshot_window
        ;;
    delay|d)
        screenshot_delay "${2:-5}"
        ;;
    folder|dir|open)
        open_folder
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        interactive_mode
        ;;
esac
