#!/usr/bin/env bash
#
# Kodra Uninstall Script
# Remove applications
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

# List available uninstall scripts
list_uninstalls() {
    echo "Applications with uninstall scripts:"
    echo ""
    for script in "$KODRA_DIR/uninstall/"*.sh; do
        if [ -f "$script" ]; then
            name=$(basename "$script" .sh)
            echo "  $name"
        fi
    done
}

# Interactive uninstall menu
interactive_uninstall() {
    if ! command -v gum &>/dev/null; then
        list_uninstalls
        return 1
    fi
    
    local apps=()
    for script in "$KODRA_DIR/uninstall/"*.sh; do
        if [ -f "$script" ]; then
            apps+=("$(basename "$script" .sh)")
        fi
    done
    
    if [ ${#apps[@]} -eq 0 ]; then
        log_error "No uninstall scripts found"
        return 1
    fi
    
    echo "Select applications to uninstall:"
    echo ""
    
    local selected=$(printf '%s\n' "${apps[@]}" | gum choose --no-limit --cursor.foreground="196" --header="Space to select, Enter to confirm")
    
    if [ -z "$selected" ]; then
        echo "No applications selected."
        return 0
    fi
    
    echo ""
    echo "Will uninstall:"
    echo "$selected" | while read -r app; do
        echo "  - $app"
    done
    echo ""
    
    if gum confirm "Proceed with uninstallation?"; then
        echo "$selected" | while read -r app; do
            echo ""
            log_info "Uninstalling $app..."
            bash "$KODRA_DIR/uninstall/${app}.sh"
            log_success "$app uninstalled!"
        done
    else
        echo "Cancelled."
    fi
}

# Uninstall by category
uninstall_category() {
    local category="$1"
    
    case "$category" in
        azure|cloud)
            echo "Uninstalling Azure/Cloud tools..."
            for app in azure-cli kubectl terraform; do
                if [ -f "$KODRA_DIR/uninstall/${app}.sh" ]; then
                    bash "$KODRA_DIR/uninstall/${app}.sh"
                fi
            done
            ;;
        docker|containers)
            echo "Uninstalling container tools..."
            for app in docker-ce podman lazydocker; do
                if [ -f "$KODRA_DIR/uninstall/${app}.sh" ]; then
                    bash "$KODRA_DIR/uninstall/${app}.sh"
                fi
            done
            ;;
        *)
            log_error "Unknown category: $category"
            echo "Available categories: azure, docker"
            exit 1
            ;;
    esac
}

show_help() {
    echo "Usage: kodra uninstall [app|options]"
    echo ""
    echo "Options:"
    echo "  (none)          Interactive selection menu"
    echo "  <app>           Uninstall specific app"
    echo "  --list          List available uninstall scripts"
    echo "  --category <c>  Uninstall by category (azure, docker)"
    echo "  --dry-run       Show what would be uninstalled"
    echo ""
    list_uninstalls
}

case "${1:-}" in
    "")
        interactive_uninstall
        ;;
    --list|-l|list)
        list_uninstalls
        ;;
    --category|-c)
        shift
        uninstall_category "$1"
        ;;
    --dry-run)
        echo "Dry run - would uninstall:"
        list_uninstalls
        ;;
    --help|-h|help)
        show_help
        ;;
    *)
        APP="$1"
        SCRIPT="$KODRA_DIR/uninstall/${APP}.sh"

        if [ ! -f "$SCRIPT" ]; then
            log_warning "No uninstall script for: $APP"
            echo ""
            echo "You may need to manually remove this application."
            echo "Check: apt, flatpak, snap, or the original installation method."
            exit 1
        fi

        read -p "Are you sure you want to uninstall $APP? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Cancelled."
            exit 0
        fi

        log_info "Uninstalling $APP..."
        bash "$SCRIPT"
        log_success "$APP uninstalled!"
        ;;
esac
