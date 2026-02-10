#!/usr/bin/env bash
#
# Kodra MOTD Configuration
# Configure the terminal startup banner style
#

KODRA_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
MOTD_FILE="$KODRA_CONFIG/motd"

# Colors
C='\033[0;36m'
G='\033[0;32m'
Y='\033[0;33m'
M='\033[0;35m'
NC='\033[0m'

# Get current style
get_current() {
    if [ -f "$MOTD_FILE" ]; then
        cat "$MOTD_FILE"
    else
        echo "banner"
    fi
}

# Set style
set_style() {
    mkdir -p "$KODRA_CONFIG"
    echo "$1" > "$MOTD_FILE"
    echo -e "${G}✔${NC} MOTD style set to: ${M}$1${NC}"
    echo -e "${C}Open a new terminal to see the change.${NC}"
}

# Show help
show_help() {
    echo ""
    echo -e "${C}Kodra MOTD Configuration${NC}"
    echo ""
    echo "Usage: kodra motd [style]"
    echo ""
    echo "Styles:"
    echo "  banner   Full ASCII art logo (default)"
    echo "  minimal  One-line info with tip"
    echo "  none     No startup message"
    echo ""
    echo "Current style: $(get_current)"
    echo ""
}

# Main
case "${1:-}" in
    banner|minimal|none)
        set_style "$1"
        ;;
    "")
        show_help
        ;;
    *)
        echo "Unknown style: $1"
        echo "Valid styles: banner, minimal, none"
        exit 1
        ;;
esac
