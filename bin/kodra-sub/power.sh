#!/usr/bin/env bash
#
# Kodra Power - Power profile management
# Uses powerprofilesctl for GNOME power management
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
ICON_PERF="🚀"
ICON_BALANCED="⚖️"
ICON_SAVER="🔋"
ICON_CHECK="✓"

show_help() {
    echo "Usage: kodra power [profile]"
    echo ""
    echo "Profiles:"
    echo "  performance    High performance mode (max power)"
    echo "  balanced       Balanced mode (default)"
    echo "  power-saver    Power saving mode (battery life)"
    echo ""
    echo "Examples:"
    echo "  kodra power              # Show current profile"
    echo "  kodra power performance  # Switch to performance"
    echo "  kodra power balanced     # Switch to balanced"
    echo "  kodra power power-saver  # Switch to power saver"
}

check_powerprofilesctl() {
    if ! command -v powerprofilesctl &>/dev/null; then
        echo -e "${RED}Error:${NC} powerprofilesctl not found."
        echo ""
        echo "On Ubuntu, install with:"
        echo "  sudo apt install power-profiles-daemon"
        exit 1
    fi
}

get_current_profile() {
    powerprofilesctl get 2>/dev/null || echo "unknown"
}

show_current() {
    local current=$(get_current_profile)
    local icon=""
    local color=""
    
    case "$current" in
        performance)
            icon="$ICON_PERF"
            color="$RED"
            ;;
        balanced)
            icon="$ICON_BALANCED"
            color="$GREEN"
            ;;
        power-saver)
            icon="$ICON_SAVER"
            color="$YELLOW"
            ;;
        *)
            icon="❓"
            color="$WHITE"
            ;;
    esac
    
    echo ""
    echo -e "${PURPLE}⚡ Kodra Power Profile${NC}"
    echo ""
    echo -e "  Current: ${color}$icon $current${NC}"
    echo ""
    echo -e "${CYAN}Available profiles:${NC}"
    
    # Show all profiles with indicator
    for profile in performance balanced power-saver; do
        local p_icon=""
        local p_color="$WHITE"
        local indicator=""
        
        case "$profile" in
            performance)
                p_icon="$ICON_PERF"
                ;;
            balanced)
                p_icon="$ICON_BALANCED"
                ;;
            power-saver)
                p_icon="$ICON_SAVER"
                ;;
        esac
        
        if [ "$profile" = "$current" ]; then
            p_color="$GREEN"
            indicator=" ${GREEN}$ICON_CHECK${NC}"
        fi
        
        echo -e "  ${p_color}$p_icon $profile${NC}$indicator"
    done
    
    echo ""
    echo -e "${WHITE}Usage:${NC} kodra power <profile>"
}

set_profile() {
    local profile="$1"
    
    # Validate profile
    case "$profile" in
        performance|balanced|power-saver)
            ;;
        perf|high)
            profile="performance"
            ;;
        normal|default)
            profile="balanced"
            ;;
        saver|save|low|battery)
            profile="power-saver"
            ;;
        *)
            echo -e "${RED}Error:${NC} Unknown profile '$profile'"
            echo ""
            show_help
            exit 1
            ;;
    esac
    
    local icon=""
    case "$profile" in
        performance) icon="$ICON_PERF" ;;
        balanced) icon="$ICON_BALANCED" ;;
        power-saver) icon="$ICON_SAVER" ;;
    esac
    
    echo -e "${CYAN}Setting power profile to:${NC} $icon $profile"
    
    if powerprofilesctl set "$profile" 2>/dev/null; then
        echo -e "${GREEN}✓ Power profile set to $profile${NC}"
    else
        echo -e "${RED}✗ Failed to set power profile${NC}"
        echo ""
        echo "You may need to run with sudo or check if power-profiles-daemon is running:"
        echo "  sudo systemctl status power-profiles-daemon"
        exit 1
    fi
}

# Check for powerprofilesctl
check_powerprofilesctl

# Parse arguments
case "${1:-}" in
    -h|--help|help)
        show_help
        ;;
    "")
        show_current
        ;;
    *)
        set_profile "$1"
        ;;
esac
