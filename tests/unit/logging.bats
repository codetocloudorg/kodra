#!/usr/bin/env bats
#
# Unit tests for lib/logging.sh
#

load '../helpers/setup'

@test "logging: start_install_log creates log file" {
    source "$KODRA_DIR/lib/logging.sh"
    start_install_log
    [ -f "$KODRA_INSTALL_LOG_FILE" ]
}

@test "logging: log_to_file writes timestamped entries" {
    source "$KODRA_DIR/lib/logging.sh"
    start_install_log
    log_to_file "hello from test"
    grep -q "hello from test" "$KODRA_INSTALL_LOG_FILE"
}

@test "logging: stop_install_log records completion" {
    source "$KODRA_DIR/lib/logging.sh"
    start_install_log
    log_to_file "mid-install"
    stop_install_log
    grep -q "Completed" "$KODRA_INSTALL_LOG_FILE"
}
