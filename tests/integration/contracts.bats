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

# ── CI Workflow hygiene ──────────────────────────────────────────

@test "contract: no deprecated GitHub Actions versions (Node.js 20 EOL)" {
    # These minimum versions support Node.js 24 (required after June 2, 2026)
    # actions/checkout: v5+, actions/upload-artifact: v6+, dorny/test-reporter: v2+
    local workflows_dir="$KODRA_DIR/.github/workflows"
    [ -d "$workflows_dir" ] || skip "No workflows directory"

    # Check for deprecated checkout versions
    if grep -rq "actions/checkout@v[1-4]" "$workflows_dir"; then
        fail "Deprecated actions/checkout found (need v5+ for Node.js 24)"
    fi

    # Check for deprecated upload-artifact versions
    if grep -rq "actions/upload-artifact@v[1-5]" "$workflows_dir"; then
        fail "Deprecated actions/upload-artifact found (need v6+ for Node.js 24)"
    fi

    # Check for deprecated test-reporter versions
    if grep -rq "dorny/test-reporter@v1" "$workflows_dir"; then
        fail "Deprecated dorny/test-reporter found (need v2+ for Node.js 24)"
    fi
}

@test "contract: install scripts with snap use timeout guard" {
    # Any script using 'snap install' must have a timeout or skip check
    # to prevent hanging in container/CI environments
    local found_unguarded=0

    while IFS= read -r script; do
        # Check the script has timeout or skip logic before snap install
        if ! grep -q "timeout\|WARN.*skip\|exit 0" "$script"; then
            found_unguarded=1
            echo "Missing timeout/skip guard: $script"
        fi
    done < <(grep -rl "snap install" "$KODRA_DIR/install/" 2>/dev/null || true)

    [ "$found_unguarded" -eq 0 ] || fail "Found snap install without timeout/skip guard"
}

@test "contract: scripts using systemctl enable/start have container detection" {
    # Docker CE and similar scripts that rely on systemd to start daemons
    # must detect container environments and skip gracefully
    local found_unguarded=0

    while IFS= read -r script; do
        if ! grep -q "dockerenv\|container\|/proc/1/cgroup\|is-system-running" "$script"; then
            found_unguarded=1
            echo "Missing container detection: $script"
        fi
    done < <(grep -rl "systemctl enable\|systemctl start" "$KODRA_DIR/applications/" "$KODRA_DIR/install/" 2>/dev/null || true)

    [ "$found_unguarded" -eq 0 ] || fail "Found systemctl enable/start without container detection"
}

@test "contract: CI workflows do not hardcode version numbers" {
    # Version checks in CI should use patterns (grep -qE '[0-9]+\.[0-9]+')
    # not hardcoded strings (grep -q '0.5.0') which break on bumps
    local workflows_dir="$KODRA_DIR/.github/workflows"
    [ -d "$workflows_dir" ] || skip "No workflows directory"

    # Look for grep commands checking a specific semver like "0.5.0" or "0.5.1"
    if grep -rn 'grep.*"[0-9]\+\.[0-9]\+\.[0-9]\+"' "$workflows_dir" 2>/dev/null | grep -v "grep -qE"; then
        fail "Found hardcoded version in workflow grep (use pattern match instead)"
    fi
}
