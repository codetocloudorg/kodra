#!/usr/bin/env bats
#
# Security tests — file permissions and ownership
#

load '../helpers/setup'

@test "security/perms: no world-writable files in repository" {
    local violations
    violations=$(find "$KODRA_DIR" -path "$KODRA_DIR/.git" -prune -o \
        -type f -perm -0002 -print 2>/dev/null)
    [ -z "$violations" ] || fail "World-writable files found:\n$violations"
}

@test "security/perms: shell scripts are not setuid/setgid" {
    local violations
    violations=$(find "$KODRA_DIR" -path "$KODRA_DIR/.git" -prune -o \
        -name "*.sh" \( -perm -4000 -o -perm -2000 \) -print 2>/dev/null)
    [ -z "$violations" ] || fail "Setuid/setgid scripts found:\n$violations"
}

@test "security/perms: bin/kodra is executable" {
    [ -x "$KODRA_DIR/bin/kodra" ]
}
