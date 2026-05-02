#!/usr/bin/env bash
#
# Kodra Config Layering
# Manages the defaults → theme → user configuration hierarchy
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_DEFAULTS_DIR="$KODRA_DIR/defaults"
KODRA_USER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

# Apply config for an application
# Uses layering: defaults → theme → user overrides
# Args: $1 = app name (e.g., "ghostty", "tmux")
apply_config() {
    local app="$1"
    local target_dir="$HOME/.config/$app"
    local defaults_dir="$KODRA_DEFAULTS_DIR/$app"
    local theme_dir=""
    local user_dir="$KODRA_USER_CONFIG_DIR/$app"

    # Get current theme
    local current_theme=""
    if [ -f "$KODRA_USER_CONFIG_DIR/theme" ]; then
        current_theme=$(cat "$KODRA_USER_CONFIG_DIR/theme")
    fi

    if [ -n "$current_theme" ] && [ -d "$KODRA_DIR/themes/$current_theme" ]; then
        theme_dir="$KODRA_DIR/themes/$current_theme"
    fi

    # Ensure target directory exists
    mkdir -p "$target_dir"

    # Layer 1: Copy defaults
    if [ -d "$defaults_dir" ]; then
        for file in "$defaults_dir"/*; do
            [ -f "$file" ] || continue
            local filename=$(basename "$file")
            cp "$file" "$target_dir/$filename"
        done
    fi

    # Layer 2: Apply theme overrides (theme files named for the app)
    if [ -n "$theme_dir" ]; then
        # Convention: themes/<name>/<app>.conf or themes/<name>/<app>/
        if [ -f "$theme_dir/${app}.conf" ]; then
            cp "$theme_dir/${app}.conf" "$target_dir/theme"
        fi
        if [ -d "$theme_dir/$app" ]; then
            for file in "$theme_dir/$app"/*; do
                [ -f "$file" ] || continue
                cp "$file" "$target_dir/"
            done
        fi
    fi

    # Layer 3: User overrides (never touched by Kodra updates)
    # Users create files in ~/.config/kodra/<app>/ which are imported
    # by the app's config (via include/source directives)
    if [ -d "$user_dir" ]; then
        for file in "$user_dir"/*; do
            [ -f "$file" ] || continue
            local filename=$(basename "$file")
            cp "$file" "$target_dir/$filename"
        done
    fi
}

# Apply all configs
apply_all_configs() {
    for app_dir in "$KODRA_DEFAULTS_DIR"/*/; do
        [ -d "$app_dir" ] || continue
        local app=$(basename "$app_dir")
        apply_config "$app"
    done
}

# Show current config layer status
show_config_status() {
    local current_theme=""
    if [ -f "$KODRA_USER_CONFIG_DIR/theme" ]; then
        current_theme=$(cat "$KODRA_USER_CONFIG_DIR/theme")
    fi

    echo "Config Layering Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Defaults: $KODRA_DEFAULTS_DIR"
    echo "  Theme:    ${current_theme:-none}"
    echo "  User:     $KODRA_USER_CONFIG_DIR"
    echo ""

    echo "  Applications with defaults:"
    for app_dir in "$KODRA_DEFAULTS_DIR"/*/; do
        [ -d "$app_dir" ] || continue
        local app=$(basename "$app_dir")
        local has_theme="✗"
        local has_user="✗"

        if [ -n "$current_theme" ] && { [ -f "$KODRA_DIR/themes/$current_theme/${app}.conf" ] || [ -d "$KODRA_DIR/themes/$current_theme/$app" ]; }; then
            has_theme="✔"
        fi
        if [ -d "$KODRA_USER_CONFIG_DIR/$app" ] && [ "$(ls -A "$KODRA_USER_CONFIG_DIR/$app" 2>/dev/null)" ]; then
            has_user="✔"
        fi

        echo "    $app  [default:✔] [theme:$has_theme] [user:$has_user]"
    done
}
