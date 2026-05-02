#!/usr/bin/env bats
#
# Unit tests for lib/utils.sh
#

load '../helpers/setup'

@test "utils: color variables are defined" {
    source "$KODRA_DIR/lib/utils.sh"
    [ -n "$RED" ]
    [ -n "$GREEN" ]
    [ -n "$YELLOW" ]
    [ -n "$BLUE" ]
    [ -n "$PURPLE" ]
    [ -n "$CYAN" ]
    [ -n "$NC" ]
}

@test "utils: log_info outputs with INFO tag" {
    source "$KODRA_DIR/lib/utils.sh"
    run log_info "test message"
    assert_success
    assert_output --partial "[INFO]"
    assert_output --partial "test message"
}

@test "utils: log_success outputs with OK tag" {
    source "$KODRA_DIR/lib/utils.sh"
    run log_success "done"
    assert_success
    assert_output --partial "[OK]"
}

@test "utils: log_warning outputs with WARN tag" {
    source "$KODRA_DIR/lib/utils.sh"
    run log_warning "caution"
    assert_success
    assert_output --partial "[WARN]"
}

@test "utils: log_error outputs with ERROR tag" {
    source "$KODRA_DIR/lib/utils.sh"
    run log_error "fail"
    assert_success
    assert_output --partial "[ERROR]"
}
