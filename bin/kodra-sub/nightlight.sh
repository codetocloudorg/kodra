#!/usr/bin/env bash
#
# Kodra Night Light - Control GNOME Night Light
# Reduces blue light for better sleep
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Icons
ICON_SUN="☀️"
ICON_MOON="🌙"
ICON_CHECK="✓"

# gsettings schema for night light
SCHEMA="org.gnome.settings-daemon.plugins.color"

show_help() {
    echo "Usage: kodra nightlight [command]"
    echo ""
    echo "Commands:"
    echo "  (none)       Toggle night light on/off"
    echo "  on           Enable night light"
    echo "  off          Disable night light"
    echo "  status       Show current status"
    echo "  temp <K>     Set color temperature (1000-10000K)"
    echo "  schedule     Enable automatic scheduling"
    echo "  manual       Disable automatic scheduling"
    echo ""
    echo "Examples:"
    echo "  kodra nightlight           # Toggle"
    echo "  kodra nightlight on        # Enable"
    echo "  kodra nightlight temp 4500 # Warmer (more orange)"
    echo "  kodra nightlight temp 6500 # Cooler (neutral)"
}

check_gsettings() {
    if ! command -v gsettings &>/dev/null; then
        echo -e "${RED}Error:${NC} gsettings not found. GNOME is required."
        exit 1
    fi
}

get_enabled() {
    gsettings get "$SCHEMA" night-light-enabled 2>/dev/null | grep -q "true" && echo "true" || echo "false"
}

get_temperature() {
    # Temperature is stored as a uint32 value representing Kelvin
    local temp=$(gsettings get "$SCHEMA" night-light-temperature 2>/dev/null)
    # Remove 'uint32 ' prefix if present
    echo "${temp#uint32 }"
}

get_schedule_enabled() {
    gsettings get "$SCHEMA" night-light-schedule-automatic 2>/dev/null | grep -q "true" && echo "true" || echo "false"
}

show_status() {
    local enabled=$(get_enabled)
    local temp=$(get_temperature)
    local schedule=$(get_schedule_enabled)
    
    echo ""
    echo -e "${PURPLE}$ICON_MOON Kodra Night Light${NC}"
    echo ""
    
    if [ "$enabled" = "true" ]; then
        echo -e "  Status: ${GREEN}$ICON_CHECK Enabled${NC}"
    else
        echo -e "  Status: ${YELLOW}$ICON_SUN Disabled${NC}"
    fi
    
    echo -e "  Temperature: ${CYAN}${temp}K${NC}"
    
    if [ "$schedule" = "true" ]; then
        echo -e "  Schedule: ${GREEN}Automatic (sunset to sunrise)${NC}"
    else
        echo -e "  Schedule: ${YELLOW}Manual${NC}"
    fi
    
    echo ""
    echo -e "${WHITE}Temperature guide:${NC}"
    echo -e "  ${YELLOW}1000-3000K${NC}  Warm (candlelight/sunset)"
    echo -e "  ${CYAN}3000-4500K${NC}  Recommended for night"
    echo -e "  ${BLUE}4500-6500K${NC}  Neutral (daylight)"
    echo -e "  ${WHITE}6500K+${NC}      Cool (blue sky)"
}

set_enabled() {
    local state="$1"
    local icon=""
    local color=""
    local word=""
    
    if [ "$state" = "true" ]; then
        icon="$ICON_MOON"
        color="$GREEN"
        word="enabled"
    else
        icon="$ICON_SUN"
        color="$YELLOW"
        word="disabled"
    fi
    
    gsettings set "$SCHEMA" night-light-enabled "$state"
    echo -e "${color}$icon Night light ${word}${NC}"
}

toggle() {
    local current=$(get_enabled)
    if [ "$current" = "true" ]; then
        set_enabled false
    else
        set_enabled true
    fi
}

set_temperature() {
    local temp="$1"
    
    # Validate temperature
    if ! [[ "$temp" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error:${NC} Temperature must be a number (in Kelvin)"
        exit 1
    fi
    
    if [ "$temp" -lt 1000 ] || [ "$temp" -gt 10000 ]; then
        echo -e "${RED}Error:${NC} Temperature must be between 1000K and 10000K"
        exit 1
    fi
    
    # Set temperature
    gsettings set "$SCHEMA" night-light-temperature "uint32 $temp"
    
    local warmth=""
    if [ "$temp" -lt 3000 ]; then
        warmth="very warm"
    elif [ "$temp" -lt 4500 ]; then
        warmth="warm"
    elif [ "$temp" -lt 6500 ]; then
        warmth="neutral"
    else
        warmth="cool"
    fi
    
    echo -e "${GREEN}✓ Temperature set to ${CYAN}${temp}K${NC} (${warmth})"
    
    # Make sure night light is enabled
    if [ "$(get_enabled)" = "false" ]; then
        echo -e "${YELLOW}Note:${NC} Night light is currently disabled. Enable with: kodra nightlight on"
    fi
}

set_schedule() {
    local auto="$1"
    
    gsettings set "$SCHEMA" night-light-schedule-automatic "$auto"
    
    if [ "$auto" = "true" ]; then
        echo -e "${GREEN}✓ Automatic scheduling enabled (sunset to sunrise)${NC}"
    else
        echo -e "${GREEN}✓ Manual mode enabled${NC}"
    fi
}

# Check for gsettings
check_gsettings

# Parse arguments
case "${1:-}" in
    -h|--help|help)
        show_help
        ;;
    on|enable)
        set_enabled true
        ;;
    off|disable)
        set_enabled false
        ;;
    status)
        show_status
        ;;
    temp|temperature)
        if [ -z "${2:-}" ]; then
            echo "Current temperature: $(get_temperature)K"
            echo ""
            echo "Usage: kodra nightlight temp <kelvin>"
            echo "Example: kodra nightlight temp 4500"
        else
            set_temperature "$2"
        fi
        ;;
    schedule|auto)
        set_schedule true
        ;;
    manual)
        set_schedule false
        ;;
    "")
        toggle
        ;;
    *)
        # Check if argument looks like a temperature
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            set_temperature "$1"
        else
            echo -e "${RED}Error:${NC} Unknown command '$1'"
            echo ""
            show_help
            exit 1
        fi
        ;;
esac
