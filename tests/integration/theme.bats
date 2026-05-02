#!/usr/bin/env bats
#
# Integration tests for theme system
#

load '../helpers/setup'

@test "theme: themes directory exists with at least one theme" {
    [ -d "$KODRA_DIR/themes" ]
    local count
    count=$(find "$KODRA_DIR/themes" -mindepth 1 -maxdepth 1 -type d | wc -l)
    [ "$count" -gt 0 ]
}

@test "theme: each theme has required config files" {
    for theme_dir in "$KODRA_DIR/themes"/*/; do
        local theme_name
        theme_name=$(basename "$theme_dir")
        [ -f "$theme_dir/ghostty.conf" ] || fail "$theme_name missing ghostty.conf"
        [ -f "$theme_dir/starship.toml" ] || fail "$theme_name missing starship.toml"
    done
}

@test "theme: theme list subcommand works" {
    [ -f "$KODRA_DIR/bin/kodra-sub/theme.sh" ] || skip "theme.sh not found"
    run bash "$KODRA_DIR/bin/kodra-sub/theme.sh" list 2>&1
    # Should list at least one theme or produce output
    assert_success
}

@test "theme: package manifests are non-empty" {
    [ -s "$KODRA_DIR/install/kodra-base.packages" ]
    local pkg_count
    pkg_count=$(grep -cv '^#\|^$' "$KODRA_DIR/install/kodra-base.packages")
    [ "$pkg_count" -gt 0 ]
}
