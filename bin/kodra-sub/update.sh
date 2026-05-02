#!/usr/bin/env bash
#
# Kodra Update Script
# Safely updates Kodra and system packages
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

# Pre-flight checks
check_network() {
    if ! curl -s --max-time 5 https://github.com &>/dev/null; then
        if ! ping -c 1 -W 3 github.com &>/dev/null; then
            log_error "No internet connection. Cannot update."
            exit 1
        fi
    fi
}

# Cache sudo credentials upfront (single prompt)
cache_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log_info "Sudo access needed for system updates..."
        sudo -v || { log_error "sudo access required"; exit 1; }
    fi
    # Keep-alive
    (while true; do sudo -n true 2>/dev/null; sleep 50; done) &
    SUDO_PID=$!
    trap "kill $SUDO_PID 2>/dev/null || true" EXIT
}

echo ""
log_info "Kodra Update"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check network connectivity
check_network

# Update Kodra repository safely
log_info "Updating Kodra repository..."
cd "$KODRA_DIR"

# Check for local modifications
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    log_warning "Local modifications detected in $KODRA_DIR"
    log_warning "Stashing changes before update..."
    git stash push -m "kodra-update-$(date +%Y%m%d-%H%M%S)" --quiet
    STASHED=true
fi

# Fetch and merge (fast-forward only — no force)
git fetch origin --quiet
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
UPSTREAM="origin/${KODRA_UPDATE_BRANCH:-main}"

if git merge-base --is-ancestor "$UPSTREAM" HEAD 2>/dev/null; then
    log_info "Already up to date"
elif git merge --ff-only "$UPSTREAM" --quiet 2>/dev/null; then
    log_success "Kodra repository updated"
else
    log_warning "Cannot fast-forward update. Trying rebase..."
    if git rebase "$UPSTREAM" --quiet 2>/dev/null; then
        log_success "Kodra repository updated (rebased)"
    else
        git rebase --abort 2>/dev/null || true
        log_error "Update conflict detected. Your local changes conflict with upstream."
        log_error "Manual resolution needed: cd $KODRA_DIR && git pull"
        exit 1
    fi
fi

# Restore stashed changes if any
if [ "${STASHED:-false}" = true ]; then
    if git stash pop --quiet 2>/dev/null; then
        log_info "Local changes restored"
    else
        log_warning "Could not restore local changes (conflict). Stash preserved."
        log_warning "Run: cd $KODRA_DIR && git stash pop"
    fi
fi

# Run migrations
log_info "Running migrations..."
bash "$KODRA_DIR/bin/kodra-sub/migrate.sh" run

# Cache sudo for system updates
cache_sudo

# Update system packages
log_info "Updating system packages..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
log_success "System packages updated"

# Update Homebrew if installed
if command -v brew &>/dev/null; then
    log_info "Updating Homebrew packages..."
    brew update --quiet
    brew upgrade --quiet
    log_success "Homebrew updated"
fi

# Update Flatpak if installed
if command -v flatpak &>/dev/null; then
    log_info "Updating Flatpak packages..."
    flatpak update -y --noninteractive 2>/dev/null || true
    log_success "Flatpak updated"
fi

# Update mise runtimes if installed
if command -v mise &>/dev/null; then
    log_info "Updating mise runtimes..."
    timeout 120 mise upgrade 2>/dev/null || log_warning "mise upgrade timed out or failed"
    log_success "mise runtimes updated"
fi

# Update VS Code extensions
if command -v code &>/dev/null; then
    log_info "Updating VS Code extensions..."
    timeout 60 code --update-extensions 2>/dev/null || true
    log_success "VS Code extensions updated"
fi

# Refresh desktop settings
if command -v gnome-shell &>/dev/null && [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
    log_info "Refreshing desktop settings..."
    bash "$KODRA_DIR/bin/kodra-sub/desktop.sh" refresh 2>/dev/null || true
fi

echo ""
log_success "Kodra update complete! 🎉"
echo ""
