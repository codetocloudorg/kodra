#!/usr/bin/env bash
#
# Kodra Refresh - Hot-reload components without logout
# Part of #48 Theme Hot-Swap
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

# Refresh terminal (reload Ghostty config)
refresh_terminal() {
    if command -v ghostty &>/dev/null; then
        # Ghostty watches config files, send signal to reload
        pkill -USR1 ghostty 2>/dev/null || true
        log_success "Ghostty config reloaded"
    fi
}

# Refresh Starship prompt
refresh_starship() {
    # Starship reloads on each prompt, but we can force it
    if [ -n "$STARSHIP_SHELL" ]; then
        log_info "Starship will reload on next prompt"
    else
        log_info "Starship config updated (new terminals will use it)"
    fi
}

# Refresh tmux
refresh_tmux() {
    if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null 2>&1; then
        if [ -f "$HOME/.config/tmux/tmux.conf" ]; then
            tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null && \
                log_success "Tmux configuration reloaded" || \
                log_warn "Could not reload tmux config"
        fi
    fi
}

# Refresh VS Code theme
refresh_vscode() {
    # VS Code reads settings.json live, but we can trigger Developer: Reload Window
    if pgrep -x "code" &>/dev/null; then
        log_info "VS Code settings updated (reload window with Ctrl+Shift+P > Reload)"
        # Could use code --command but that opens a new window
    fi
}

# Refresh btop
refresh_btop() {
    if pgrep -x "btop" &>/dev/null; then
        # btop reads config on start, needs restart
        log_info "btop will use new theme on next launch"
    fi
}

# Refresh neovim
refresh_nvim() {
    if command -v nvim &>/dev/null; then
        # Check if nvim has a server running
        local nvim_sockets=$(find /tmp -maxdepth 1 -name "nvim.*" -type s 2>/dev/null | head -1)
        if [ -n "$nvim_sockets" ]; then
            # Send command to reload colorscheme
            nvim --server "$nvim_sockets" --remote-send ":source ~/.config/nvim/init.lua<CR>" 2>/dev/null || true
            log_info "Neovim config reloaded (if running)"
        fi
    fi
}

# Refresh GNOME desktop settings
refresh_desktop() {
    if command -v gsettings &>/dev/null && [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
        # GNOME settings are applied immediately via gsettings
        log_success "Desktop settings already live"
    fi
}

# Full refresh after theme change
refresh_all() {
    log_info "Refreshing all components..."
    echo ""
    
    refresh_terminal
    refresh_starship
    refresh_tmux
    refresh_vscode
    refresh_btop
    refresh_nvim
    refresh_desktop
    
    echo ""
    log_success "Theme hot-swap complete!"
    echo "Most changes are now active. For full effect:"
    echo "  - Open new terminal tabs/windows"
    echo "  - Reload VS Code (Ctrl+Shift+P > Reload Window)"
    echo "  - Restart btop if running"
}

# Show usage
show_help() {
    echo "Usage: kodra refresh [component]"
    echo ""
    echo "Components:"
    echo "  all        Refresh all components (default)"
    echo "  terminal   Reload Ghostty config"
    echo "  starship   Update prompt"
    echo "  tmux       Reload tmux config"
    echo "  vscode     VS Code theme hint"
    echo "  btop       btop theme hint"
    echo "  nvim       Reload neovim config"
    echo "  desktop    GNOME desktop settings"
    echo ""
}

# Main
case "${1:-all}" in
    all|"")
        refresh_all
        ;;
    terminal|ghostty)
        refresh_terminal
        ;;
    starship|prompt)
        refresh_starship
        ;;
    tmux)
        refresh_tmux
        ;;
    vscode|code)
        refresh_vscode
        ;;
    btop)
        refresh_btop
        ;;
    nvim|neovim)
        refresh_nvim
        ;;
    desktop|gnome)
        refresh_desktop
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        log_error "Unknown component: $1"
        show_help
        exit 1
        ;;
esac
