#!/usr/bin/env bats
#
# Unit tests for lib/config.sh
#

load '../helpers/setup'

@test "config: library sources without error" {
    run bash -c "export KODRA_DIR='$KODRA_DIR'; source '$KODRA_DIR/lib/config.sh'"
    assert_success
}

@test "config: defaults directory exists" {
    [ -d "$KODRA_DIR/defaults" ] || skip "No defaults directory"
    local count
    count=$(find "$KODRA_DIR/defaults" -type f | wc -l)
    [ "$count" -gt 0 ]
}
