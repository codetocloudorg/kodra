#!/usr/bin/env bash
#
# Kodra Resume Command
# Resume incomplete installations or retry failed components
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

source "$KODRA_DIR/lib/utils.sh"
source "$KODRA_DIR/lib/state.sh"

show_help() {
    echo "Usage: kodra resume [command]"
    echo ""
    echo "Commands:"
    echo "  status      Show installation status"
    echo "  retry       Retry failed components"
    echo "  clear       Clear installation state (fresh start)"
    echo ""
    echo "Examples:"
    echo "  kodra resume          # Show status and offer to retry"
    echo "  kodra resume status   # Just show status"
    echo "  kodra resume retry    # Retry all failed components"
    echo "  kodra resume clear    # Clear state for fresh install"
    echo ""
}

retry_failed() {
    local failed=$(get_failed_components)
    
    if [ -z "$failed" ]; then
        log_info "No failed components to retry"
        return 0
    fi
    
    echo ""
    echo "Failed components to retry:"
    echo "$failed" | while read comp; do
        echo "  - $comp"
    done
    echo ""
    
    local confirm=""
    if command -v gum &> /dev/null; then
        if gum confirm "Retry these components? (y/N)"; then
            confirm="y"
        fi
    else
        read -p "Retry these components? (y/N) " confirm
    fi
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        return 0
    fi
    
    echo ""
    log_info "Retrying failed components..."
    echo ""
    
    # Map component names to install scripts
    echo "$failed" | while read comp; do
        local script=""
        
        # Find the install script for this component
        case "$comp" in
            azure-cli)    script="$KODRA_DIR/install/required/azure/azure-cli.sh" ;;
            azd|azure-developer-cli) script="$KODRA_DIR/install/required/azure/azure-developer-cli.sh" ;;
            terraform)    script="$KODRA_DIR/install/required/azure/terraform.sh" ;;
            kubectl)      script="$KODRA_DIR/install/required/azure/kubectl.sh" ;;
            helm)         script="$KODRA_DIR/install/required/azure/helm.sh" ;;
            k9s)          script="$KODRA_DIR/install/required/azure/k9s.sh" ;;
            docker)       script="$KODRA_DIR/applications/docker-ce.sh" ;;
            ghostty)      script="$KODRA_DIR/install/terminal/ghostty.sh" ;;
            vscode)       script="$KODRA_DIR/install/required/applications/vscode.sh" ;;
            github-cli)   script="$KODRA_DIR/install/required/applications/github-cli.sh" ;;
            *)
                # Try to find by name
                script=$(find "$KODRA_DIR/install" -name "*$comp*.sh" -type f | head -1)
                ;;
        esac
        
        if [ -n "$script" ] && [ -f "$script" ]; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Retrying: $comp"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            if bash "$script"; then
                mark_installed "$comp"
                log_success "$comp installed successfully"
            else
                log_error "$comp failed again"
            fi
            echo ""
        else
            log_warning "Could not find install script for: $comp"
        fi
    done
    
    show_install_status
}

interactive_resume() {
    show_install_status
    
    if has_incomplete_install; then
        echo ""
        local failed=$(get_failed_components)
        
        if [ -n "$failed" ]; then
            echo "Options:"
            echo "  1) Retry failed components"
            echo "  2) Clear state and start fresh"
            echo "  3) Exit"
            echo ""
            
            local choice=""
            if command -v gum &> /dev/null; then
                choice=$(gum choose "Retry failed" "Clear and start fresh" "Exit")
            else
                read -p "Choose (1-3): " num
                case "$num" in
                    1) choice="Retry failed" ;;
                    2) choice="Clear and start fresh" ;;
                    *) choice="Exit" ;;
                esac
            fi
            
            case "$choice" in
                "Retry failed")
                    retry_failed
                    ;;
                "Clear and start fresh")
                    clear_state
                    echo ""
                    echo "Run 'kodra' or the install command to start fresh."
                    ;;
                *)
                    echo "Exiting."
                    ;;
            esac
        else
            log_info "Installation incomplete but no specific failures recorded."
            echo ""
            echo "You can:"
            echo "  • Run the full installer again: bash ~/.kodra/install.sh"
            echo "  • Clear state: kodra resume clear"
        fi
    else
        log_success "No incomplete installation detected"
    fi
}

case "${1:-}" in
    status|--status|-s)
        show_install_status
        ;;
    retry|--retry|-r)
        retry_failed
        ;;
    clear|--clear|-c)
        clear_state
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        interactive_resume
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
