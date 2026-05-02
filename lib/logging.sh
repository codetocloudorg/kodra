#!/usr/bin/env bash
#
# Kodra Structured Logging
# Provides timestamped install logging with automatic archival.
# Logs are written to a temp file during install and archived to
# ~/.config/kodra/logs/ on completion (last 10 kept).
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"
KODRA_LOG_DIR="$KODRA_CONFIG_DIR/logs"
KODRA_INSTALL_LOG_FILE="${KODRA_INSTALL_LOG_FILE:-/tmp/kodra-install.log}"

# Source utils for color logging
if [ -f "$KODRA_DIR/lib/utils.sh" ]; then
    source "$KODRA_DIR/lib/utils.sh"
fi

# Initialize the install log — creates a timestamped permanent log file
# and resets the temp log. Call once at the start of an install session.
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

# Finalize the install log — records duration, copies to permanent archive,
# and prunes old logs (keeps the 10 most recent)
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

# Append a timestamped message to the install log file
# Arguments: $1 - message string
log_to_file() {
    local message="$1"
    local timestamp="[$(date '+%Y-%m-%d %H:%M:%S')]"
    echo "$timestamp $message" >> "$KODRA_INSTALL_LOG_FILE" 2>/dev/null || true
}

# Run a script with output capture — logs START/OK/FAIL to the install log
# On failure, appends the script's full output for debugging
# Arguments: $1 - script path, $@ - arguments to pass
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

# Display the last N lines of the install log (useful for error context)
# Arguments: $1 - number of lines (default: 20)
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
