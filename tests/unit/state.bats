#!/usr/bin/env bats
#
# Unit tests for lib/state.sh
#

load '../helpers/setup'

@test "state: init_state creates state file" {
    source "$KODRA_DIR/lib/state.sh"
    init_state
    [ -f "$KODRA_STATE_FILE" ]
}

@test "state: init_state is idempotent" {
    source "$KODRA_DIR/lib/state.sh"
    init_state
    local first_content
    first_content=$(cat "$KODRA_STATE_FILE")
    init_state
    local second_content
    second_content=$(cat "$KODRA_STATE_FILE")
    [ "$first_content" = "$second_content" ]
}

@test "state: mark_installed and is_installed round-trip" {
    source "$KODRA_DIR/lib/state.sh"
    init_state
    mark_installed "test-component"
    run is_installed "test-component"
    assert_success
}

@test "state: is_installed rejects unknown component" {
    source "$KODRA_DIR/lib/state.sh"
    init_state
    run is_installed "never-installed-xyz"
    assert_failure
}

@test "state: mark_failed records failure" {
    source "$KODRA_DIR/lib/state.sh"
    init_state
    mark_failed "broken-thing" "segfault"
    # Verify failure was recorded (in JSON or fallback log)
    if command -v jq &>/dev/null; then
        run jq '.failed | length' "$KODRA_STATE_FILE"
        assert_output "1"
    else
        [ -f "$XDG_CONFIG_HOME/kodra/install.log" ]
        grep -q "broken-thing" "$XDG_CONFIG_HOME/kodra/install.log"
    fi
}
