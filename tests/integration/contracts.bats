#!/usr/bin/env bats
#
# Contract tests — validate that cross-script calls use valid flags
# These tests catch issues like install.sh calling migrate.sh --init
# when migrate.sh doesn't implement --init.
#

load '../helpers/setup'

# Extracts all subcommand calls from install.sh and validates flags are accepted
@test "contract: install.sh calls to migrate.sh use valid flags" {
    local migrate="$KODRA_DIR/bin/kodra-sub/migrate.sh"
    [ -f "$migrate" ] || skip "migrate.sh not found"

    # install.sh calls: migrate.sh --init
    run bash "$migrate" --init
    assert_success
}

@test "contract: install.sh calls to theme.sh use valid flags" {
    local theme="$KODRA_DIR/bin/kodra-sub/theme.sh"
    [ -f "$theme" ] || skip "theme.sh not found"

    # theme.sh with a valid theme name should not crash on --help/usage
    run bash "$theme" --help 2>&1
    # Should not exit with "unknown flag" type errors
    refute_output --partial "unknown"
    refute_output --partial "invalid"
}

@test "contract: install.sh calls to first-run.sh accept --skip flag" {
    local firstrun="$KODRA_DIR/bin/kodra-sub/first-run.sh"
    [ -f "$firstrun" ] || skip "first-run.sh not found"

    # Verify --skip is handled (dry-run check: grep the case/flag handler)
    run grep -q "\-\-skip\|skip)" "$firstrun"
    assert_success
}

@test "contract: all scripts called by install.sh exist" {
    # Extract all kodra-sub script paths from install.sh
    local install="$KODRA_DIR/install.sh"
    [ -f "$install" ] || skip "install.sh not found"

    while IFS= read -r script_ref; do
        # Resolve $KODRA_DIR to actual path
        local resolved="${script_ref/\$KODRA_DIR/$KODRA_DIR}"
        resolved="${resolved/\"\$KODRA_DIR\"/$KODRA_DIR}"
        [ -f "$resolved" ] || fail "install.sh references missing script: $script_ref"
    done < <(grep -oP '"\$KODRA_DIR/bin/kodra-sub/[^"]+\.sh"' "$install" | tr -d '"')
}

@test "contract: dispatcher covers every script in kodra-sub/" {
    local dispatcher="$KODRA_DIR/bin/kodra"
    local subdir="$KODRA_DIR/bin/kodra-sub"

    while IFS= read -r script; do
        local name
        name=$(basename "$script" .sh)
        # Check dispatcher has a reference to this script
        run grep -q "$name" "$dispatcher"
        assert_success || fail "Script $name.sh has no dispatcher entry in bin/kodra"
    done < <(find "$subdir" -name "*.sh" -type f)
}

@test "contract: VERSION file matches all hardcoded versions" {
    local version
    version=$(cat "$KODRA_DIR/VERSION" | tr -d '\n')

    # lib/state.sh default version
    run grep "$version" "$KODRA_DIR/lib/state.sh"
    assert_success

    # lib/ui.sh fallback version
    run grep "$version" "$KODRA_DIR/lib/ui.sh"
    assert_success
}
