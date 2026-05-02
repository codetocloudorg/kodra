#!/usr/bin/env bash
#
# Kodra Structured Logging
# Provides timestamped logging and script execution tracking
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
KODRA_LOG_DIR="$KODRA_CONFIG_DIR/logs"
KODRA_INSTALL_LOG_FILE="${KODRA_INSTALL_LOG_FILE:-/tmp/kodra-install.log}"

# Source utils for color logging
if [ -f "$KODRA_DIR/lib/utils.sh" ]; then
    source "$KODRA_DIR/lib/utils.sh"
fi

start_install_log() {
    mkdir -p "$KODRA_LOG_DIR"

    # Create timestamped permanent log
    local timestamp=$(date '+%Y%m%d-%H%M%S')
    export KODRA_PERMANENT_LOG="$KODRA_LOG_DIR/install-${timestamp}.log"

    # Start fresh temp log
    : > "$KODRA_INSTALL_LOG_FILE"

    export KODRA_START_TIME=$(date +%s)

    log_to_file "=== Kodra Installation Started: $(date '+%Y-%m-%d %H:%M:%S') ==="
    log_to_file "System: $(uname -a)"
    log_to_file "User: ${USER:-$(whoami)}"
}

stop_install_log() {
    local end_time=$(date +%s)
    local duration=$((end_time - ${KODRA_START_TIME:-$end_time}))
    local mins=$((duration / 60))
    local secs=$((duration % 60))

    log_to_file "=== Kodra Installation Completed: $(date '+%Y-%m-%d %H:%M:%S') ==="
    log_to_file "Duration: ${mins}m ${secs}s"

    # Copy to permanent log
    if [ -n "${KODRA_PERMANENT_LOG:-}" ]; then
        cp "$KODRA_INSTALL_LOG_FILE" "$KODRA_PERMANENT_LOG" 2>/dev/null || true
    fi

    # Clean old logs (keep last 10)
    if [ -d "$KODRA_LOG_DIR" ]; then
        ls -t "$KODRA_LOG_DIR"/install-*.log 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true
    fi

    echo ""
    log_success "Installation completed in ${mins}m ${secs}s"
    log_info "Log saved: $KODRA_PERMANENT_LOG"
}

log_to_file() {
    local message="$1"
    local timestamp="[$(date '+%Y-%m-%d %H:%M:%S')]"
    echo "$timestamp $message" >> "$KODRA_INSTALL_LOG_FILE" 2>/dev/null || true
}

# Run a script with logging - captures output and tracks success/failure
# Usage: run_logged "script_path" [args...]
run_logged() {
    local script="$1"
    shift

    if [ ! -f "$script" ]; then
        log_to_file "SKIP: $script (not found)"
        log_warning "Script not found: $script"
        return 0
    fi

    local name=$(basename "$script" .sh)
    export CURRENT_SCRIPT="$script"

    log_to_file "START: $script"

    local output_file="/tmp/kodra-run-${name}-$$.log"

    if bash "$script" "$@" >> "$output_file" 2>&1; then
        log_to_file "OK: $script"
        rm -f "$output_file"
        unset CURRENT_SCRIPT
        return 0
    else
        local exit_code=$?
        log_to_file "FAIL: $script (exit code: $exit_code)"

        # Append failure details to main log
        echo "" >> "$KODRA_INSTALL_LOG_FILE"
        echo "=== FAILED: $name (exit code: $exit_code) ===" >> "$KODRA_INSTALL_LOG_FILE"
        cat "$output_file" >> "$KODRA_INSTALL_LOG_FILE" 2>/dev/null || true
        echo "=== END $name ===" >> "$KODRA_INSTALL_LOG_FILE"

        rm -f "$output_file"
        unset CURRENT_SCRIPT
        return $exit_code
    fi
}

# Show last N lines of install log (for error display)
show_log_tail() {
    local lines="${1:-20}"
    if [ -f "$KODRA_INSTALL_LOG_FILE" ]; then
        echo ""
        echo "Last $lines lines of install log:"
        echo "─────────────────────────────────"
        tail -n "$lines" "$KODRA_INSTALL_LOG_FILE"
        echo "─────────────────────────────────"
    fi
}
