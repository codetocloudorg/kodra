#!/usr/bin/env bats
#
# Security tests — Dockerfile and container hardening
#

load '../helpers/setup'

@test "security/container: Dockerfile final stage does not run as root" {
    local dockerfile="$KODRA_DIR/Dockerfile"
    [ -f "$dockerfile" ] || skip "No Dockerfile"
    # Last USER directive should not be root
    local last_user
    last_user=$(grep -i '^USER' "$dockerfile" | tail -1 | awk '{print $2}')
    [ -n "$last_user" ] || fail "No USER directive — container runs as root"
    [ "$last_user" != "root" ] || fail "Dockerfile final USER is root"
}

@test "security/container: no secrets in Dockerfile" {
    local dockerfile="$KODRA_DIR/Dockerfile"
    [ -f "$dockerfile" ] || skip "No Dockerfile"
    local pattern='(API_KEY|SECRET|TOKEN|PASSWORD|PRIVATE_KEY)\s*='
    local violations
    violations=$(grep -En "$pattern" "$dockerfile" 2>/dev/null || true)
    [ -z "$violations" ] || fail "Secrets in Dockerfile:\n$violations"
}

@test "security/container: Dockerfile base image is pinned" {
    local dockerfile="$KODRA_DIR/Dockerfile"
    [ -f "$dockerfile" ] || skip "No Dockerfile"
    # FROM should use a specific tag, not just :latest
    local from_line
    from_line=$(grep -i '^FROM' "$dockerfile" | head -1)
    # Should have a version tag like ubuntu:24.04
    [[ "$from_line" =~ :[0-9] ]] || fail "Base image not version-pinned: $from_line"
}
