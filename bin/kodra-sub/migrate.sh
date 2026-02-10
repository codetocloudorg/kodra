#!/usr/bin/env bash
#
# Kodra Migration Script
# Run upgrade migrations
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
MIGRATIONS_DIR="$KODRA_DIR/migrations"
MIGRATIONS_FILE="$KODRA_CONFIG_DIR/migrations_run"

source "$KODRA_DIR/lib/utils.sh"

mkdir -p "$KODRA_CONFIG_DIR"
touch "$MIGRATIONS_FILE"

# Initialize migrations (mark all as run for fresh installs)
if [ "$1" = "--init" ]; then
    for migration in "$MIGRATIONS_DIR"/*.sh; do
        if [ -f "$migration" ]; then
            name=$(basename "$migration")
            echo "$name" >> "$MIGRATIONS_FILE"
        fi
    done
    exit 0
fi

# Run pending migrations
for migration in "$MIGRATIONS_DIR"/*.sh; do
    if [ -f "$migration" ]; then
        name=$(basename "$migration")
        
        # Check if already run
        if grep -q "^$name$" "$MIGRATIONS_FILE" 2>/dev/null; then
            continue
        fi
        
        log_info "Running migration: $name"
        bash "$migration"
        echo "$name" >> "$MIGRATIONS_FILE"
        log_success "Migration complete: $name"
    fi
done
