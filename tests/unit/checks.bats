#!/usr/bin/env bats
#
# Unit tests for lib/checks.sh
#

load '../helpers/setup'

@test "checks: command_exists finds bash" {
    source "$KODRA_DIR/lib/checks.sh"
    run command_exists bash
    assert_success
}

@test "checks: command_exists rejects nonexistent command" {
    source "$KODRA_DIR/lib/checks.sh"
    run command_exists nonexistent_command_xyz_999
    assert_failure
}

@test "checks: is_x86_64 or is_arm detects architecture" {
    source "$KODRA_DIR/lib/checks.sh"
    # One of these must succeed on any system
    is_x86_64 || is_arm || skip "Unknown architecture: $(uname -m)"
}

@test "checks: get_ubuntu_version returns a value" {
    source "$KODRA_DIR/lib/checks.sh"
    run get_ubuntu_version
    assert_success
    # Should be numeric-ish (e.g., "24.04" or "0" on non-Ubuntu)
    [[ "$output" =~ ^[0-9] ]]
}

@test "checks: check_disk_space passes with low threshold" {
    source "$KODRA_DIR/lib/checks.sh"
    run check_disk_space 1
    assert_success
}
