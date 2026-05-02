#!/usr/bin/env bash
#
# Kodra Migration Runner
# Executes pending migrations in timestamp order.
# Each migration runs exactly once, tracked via .done state files
# in $XDG_CONFIG_HOME/kodra/migrations/. On fresh installs, use
# "init" to mark all existing migrations as complete.
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
MIGRATIONS_DIR="$KODRA_DIR/migrations"
STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra/migrations"

source "$KODRA_DIR/lib/utils.sh"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# List migrations that have not yet been marked as complete
# Returns: newline-separated migration names, sorted numerically
list_pending() {
    local pending=()
    if [ -d "$MIGRATIONS_DIR" ] && [ "$(ls -A "$MIGRATIONS_DIR"/*.sh 2>/dev/null)" ]; then
        for migration in "$MIGRATIONS_DIR"/*.sh; do
            local name=$(basename "$migration" .sh)
            if [ ! -f "$STATE_DIR/$name.done" ]; then
                pending+=("$name")
            fi
        done
    fi
    printf '%s\n' "${pending[@]}" | sort -n
}

# Execute a single migration script and record completion
# Arguments:
#   $1 - Migration name (filename without .sh)
# Returns: 0 on success, 1 on failure
run_migration() {
    local name="$1"
    local script="$MIGRATIONS_DIR/${name}.sh"
    
    if [ ! -f "$script" ]; then
        log_error "Migration not found: $name"
        return 1
    fi
    
    log_info "Running migration: $name"
    
    if bash "$script"; then
        touch "$STATE_DIR/$name.done"  # Record successful completion
        log_success "Migration complete: $name"
        return 0
    else
        log_error "Migration failed: $name"
        return 1
    fi
}

# Display status of all migrations (completed vs pending)
show_status() {
    echo ""
    echo -e "${BLUE}Migration Status${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local total=0
    local completed=0
    local pending=0
    
    if [ -d "$MIGRATIONS_DIR" ] && [ "$(ls -A "$MIGRATIONS_DIR"/*.sh 2>/dev/null)" ]; then
        for migration in "$MIGRATIONS_DIR"/*.sh; do
            local name=$(basename "$migration" .sh)
            total=$((total + 1))
            if [ -f "$STATE_DIR/$name.done" ]; then
                echo -e "  ${GREEN}✔${NC} $name"
                completed=$((completed + 1))
            else
                echo -e "  ${YELLOW}○${NC} $name (pending)"
                pending=$((pending + 1))
            fi
        done
    fi
    
    echo ""
    echo "Total: $total | Completed: $completed | Pending: $pending"
    echo ""
}

# Main
case "${1:-run}" in
    run)
        pending=$(list_pending)
        if [ -z "$pending" ]; then
            log_info "No pending migrations"
            exit 0
        fi
        
        log_info "Running pending migrations..."
        echo "$pending" | while read -r name; do
            [ -n "$name" ] && run_migration "$name"
        done
        log_success "All migrations complete"
        ;;
    --init|init)
        # Mark all existing migrations as complete (fresh install)
        # This prevents old migrations from running on a new install
        if [ -d "$MIGRATIONS_DIR" ] && [ "$(ls -A "$MIGRATIONS_DIR"/*.sh 2>/dev/null)" ]; then
            for migration in "$MIGRATIONS_DIR"/*.sh; do
                local_name=$(basename "$migration" .sh)
                touch "$STATE_DIR/$local_name.done"
            done
            log_info "Marked all migrations as complete (fresh install)"
        else
            log_info "No migrations to initialize"
        fi
        ;;
    status)
        show_status
        ;;
    list)
        list_pending
        ;;
    *)
        echo "Usage: kodra migrate [run|init|status|list]"
        exit 1
        ;;
esac
