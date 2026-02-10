#!/usr/bin/env bash
#
# Kodra Install Script
# Install additional applications
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

if [ -z "$1" ]; then
    echo "Usage: kodra install <app>"
    echo ""
    echo "Available applications:"
    echo ""
    for script in "$KODRA_DIR/applications/"*.sh; do
        name=$(basename "$script" .sh)
        echo "  $name"
    done
    exit 0
fi

APP="$1"
SCRIPT="$KODRA_DIR/applications/${APP}.sh"

if [ ! -f "$SCRIPT" ]; then
    log_error "Application not found: $APP"
    echo ""
    echo "Run 'kodra install' for available applications."
    exit 1
fi

log_info "Installing $APP..."
bash "$SCRIPT"
log_success "$APP installed!"
