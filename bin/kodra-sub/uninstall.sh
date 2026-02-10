#!/usr/bin/env bash
#
# Kodra Uninstall Script
# Remove applications
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

if [ -z "$1" ]; then
    echo "Usage: kodra uninstall <app>"
    echo ""
    echo "Applications with uninstall scripts:"
    echo ""
    for script in "$KODRA_DIR/uninstall/"*.sh; do
        if [ -f "$script" ]; then
            name=$(basename "$script" .sh)
            echo "  $name"
        fi
    done
    exit 0
fi

APP="$1"
SCRIPT="$KODRA_DIR/uninstall/${APP}.sh"

if [ ! -f "$SCRIPT" ]; then
    log_warning "No uninstall script for: $APP"
    echo ""
    echo "You may need to manually remove this application."
    echo "Check: apt, flatpak, snap, or the original installation method."
    exit 1
fi

read -p "Are you sure you want to uninstall $APP? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

log_info "Uninstalling $APP..."
bash "$SCRIPT"
log_success "$APP uninstalled!"
