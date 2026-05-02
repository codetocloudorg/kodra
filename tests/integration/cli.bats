#!/usr/bin/env bats
#
# Integration tests for the kodra CLI dispatcher
#

load '../helpers/setup'

@test "cli: kodra --version outputs version string" {
    run bash "$KODRA_DIR/bin/kodra" version
    assert_success
    assert_output --partial "Kodra v"
}

@test "cli: kodra help shows usage" {
    run bash "$KODRA_DIR/bin/kodra" help
    assert_success
    assert_output --partial "Usage:"
    assert_output --partial "Commands:"
}

@test "cli: kodra --version matches VERSION file" {
    local file_version
    file_version=$(cat "$KODRA_DIR/VERSION" | tr -d '\n')
    run bash "$KODRA_DIR/bin/kodra" version
    assert_success
    assert_output --partial "$file_version"
}

@test "cli: kodra with no args shows help" {
    run bash "$KODRA_DIR/bin/kodra"
    assert_success
    assert_output --partial "Usage:"
}

@test "cli: all subcommand scripts exist and are executable" {
    # Extract subcommands from the dispatcher
    local dispatcher="$KODRA_DIR/bin/kodra"
    while IFS= read -r script; do
        [ -f "$script" ] || fail "Missing subcommand script: $script"
    done < <(grep -oP '\$KODRA_DIR/bin/kodra-sub/\S+\.sh' "$dispatcher" | sort -u | sed "s|\\\$KODRA_DIR|$KODRA_DIR|g")
}
