#!/usr/bin/env bats
#
# Unit tests for lib/package.sh
#

load '../helpers/setup'

@test "package: is_apt_installed detects bash" {
    source "$KODRA_DIR/lib/package.sh"
    run is_apt_installed "bash"
    assert_success
}

@test "package: is_apt_installed rejects nonexistent package" {
    source "$KODRA_DIR/lib/package.sh"
    run is_apt_installed "nonexistent-package-xyz-999"
    assert_failure
}
