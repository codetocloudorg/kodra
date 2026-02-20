#!/usr/bin/env bash
#
# Kodra Cleanup Tool
# Clear system caches and free up space
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

# Track total space freed
TOTAL_FREED=0

# Format bytes to human readable
format_bytes() {
    local bytes=$1
    if [ "$bytes" -gt 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1073741824" | bc) GB"
    elif [ "$bytes" -gt 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc) MB"
    elif [ "$bytes" -gt 1024 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc) KB"
    else
        echo "$bytes bytes"
    fi
}

# Get directory size
get_size() {
    du -sb "$1" 2>/dev/null | cut -f1 || echo 0
}

# Clean apt cache
clean_apt() {
    echo "Cleaning apt cache..."
    
    if command -v apt &>/dev/null; then
        local before=$(get_size /var/cache/apt/archives 2>/dev/null || echo 0)
        
        sudo apt clean 2>/dev/null || true
        sudo apt autoremove -y 2>/dev/null || true
        
        local after=$(get_size /var/cache/apt/archives 2>/dev/null || echo 0)
        local freed=$((before - after))
        
        if [ "$freed" -gt 0 ]; then
            TOTAL_FREED=$((TOTAL_FREED + freed))
            log_success "  Freed $(format_bytes $freed) from apt cache"
        else
            log_info "  apt cache already clean"
        fi
    else
        log_info "  apt not available"
    fi
}

# Clean snap cache
clean_snap() {
    echo "Cleaning snap cache..."
    
    if command -v snap &>/dev/null; then
        # Remove old snap revisions
        local count=0
        snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}' | while read snapname revision; do
            sudo snap remove "$snapname" --revision="$revision" 2>/dev/null && ((count++)) || true
        done
        
        if [ "$count" -gt 0 ]; then
            log_success "  Removed $count old snap revisions"
        else
            log_info "  No old snap revisions"
        fi
    else
        log_info "  snap not available"
    fi
}

# Clean flatpak cache
clean_flatpak() {
    echo "Cleaning flatpak..."
    
    if command -v flatpak &>/dev/null; then
        flatpak uninstall --unused -y 2>/dev/null || true
        log_success "  Cleaned unused flatpak runtimes"
    else
        log_info "  flatpak not available"
    fi
}

# Clean journal logs
clean_journal() {
    echo "Cleaning system logs..."
    
    if command -v journalctl &>/dev/null; then
        local before=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.?\d*[GMK]' | head -1)
        
        sudo journalctl --vacuum-time=7d 2>/dev/null || true
        
        local after=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.?\d*[GMK]' | head -1)
        log_success "  Cleaned logs older than 7 days ($before -> $after)"
    else
        log_info "  journalctl not available"
    fi
}

# Clean temp files
clean_temp() {
    echo "Cleaning temp files..."
    
    local freed=0
    
    # User temp
    if [ -d "$HOME/.cache" ]; then
        local before=$(get_size "$HOME/.cache")
        
        # Clean specific cache dirs (safe ones)
        rm -rf "$HOME/.cache/thumbnails"/* 2>/dev/null || true
        rm -rf "$HOME/.cache/pip"/* 2>/dev/null || true
        rm -rf "$HOME/.cache/go-build"/* 2>/dev/null || true
        rm -rf "$HOME/.cache/yarn"/* 2>/dev/null || true
        rm -rf "$HOME/.cache/npm"/* 2>/dev/null || true
        
        local after=$(get_size "$HOME/.cache")
        freed=$((before - after))
    fi
    
    # /tmp cleanup (only user files)
    find /tmp -user "$USER" -type f -atime +7 -delete 2>/dev/null || true
    
    if [ "$freed" -gt 0 ]; then
        TOTAL_FREED=$((TOTAL_FREED + freed))
        log_success "  Freed $(format_bytes $freed) from cache"
    else
        log_info "  Cache already clean"
    fi
}

# Clean Docker
clean_docker() {
    echo "Cleaning Docker..."
    
    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        docker system prune -f 2>/dev/null || true
        log_success "  Cleaned unused Docker data"
    else
        log_info "  Docker not running"
    fi
}

# Clean homebrew
clean_brew() {
    echo "Cleaning Homebrew..."
    
    if command -v brew &>/dev/null; then
        brew cleanup --prune=7 2>/dev/null || true
        log_success "  Cleaned old Homebrew downloads"
    else
        log_info "  Homebrew not available"
    fi
}

# Show disk usage
show_usage() {
    echo "Disk usage:"
    echo ""
    df -h / | sed 's/^/  /'
    echo ""
    
    echo "Largest directories in home:"
    du -sh "$HOME"/* 2>/dev/null | sort -rh | head -10 | sed 's/^/  /'
}

# Clean all
clean_all() {
    echo ""
    echo "━━━ Kodra Cleanup ━━━"
    echo ""
    
    clean_apt
    clean_snap
    clean_flatpak
    clean_journal
    clean_temp
    clean_docker
    clean_brew
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━"
    
    if [ "$TOTAL_FREED" -gt 0 ]; then
        log_success "Total freed: $(format_bytes $TOTAL_FREED)"
    else
        log_info "System was already clean"
    fi
    
    echo ""
    show_usage
}

# Interactive mode
interactive_mode() {
    if ! command -v gum &>/dev/null; then
        clean_all
        return
    fi
    
    echo "Select what to clean:"
    echo ""
    
    local choices=$(gum choose --no-limit --height=10 \
        "apt cache" \
        "snap cache" \
        "flatpak" \
        "journal logs" \
        "temp files" \
        "Docker" \
        "Homebrew")
    
    if [ -z "$choices" ]; then
        log_info "Nothing selected"
        exit 0
    fi
    
    echo ""
    
    while IFS= read -r choice; do
        case "$choice" in
            "apt cache") clean_apt ;;
            "snap cache") clean_snap ;;
            "flatpak") clean_flatpak ;;
            "journal logs") clean_journal ;;
            "temp files") clean_temp ;;
            "Docker") clean_docker ;;
            "Homebrew") clean_brew ;;
        esac
    done <<< "$choices"
    
    echo ""
    if [ "$TOTAL_FREED" -gt 0 ]; then
        log_success "Total freed: $(format_bytes $TOTAL_FREED)"
    fi
}

# Show help
show_help() {
    echo "Usage: kodra cleanup [command]"
    echo ""
    echo "Commands:"
    echo "  all         Clean everything (default)"
    echo "  apt         Clean apt cache"
    echo "  snap        Clean snap cache"
    echo "  flatpak     Clean unused flatpak runtimes"
    echo "  journal     Clean old system logs"
    echo "  temp        Clean temp/cache files"
    echo "  docker      Clean Docker unused data"
    echo "  brew        Clean Homebrew cache"
    echo "  usage       Show disk usage"
    echo ""
    echo "Without arguments, opens interactive selection."
}

# Main
case "${1:-}" in
    all)
        clean_all
        ;;
    apt)
        clean_apt
        ;;
    snap)
        clean_snap
        ;;
    flatpak)
        clean_flatpak
        ;;
    journal|logs)
        clean_journal
        ;;
    temp|cache)
        clean_temp
        ;;
    docker)
        clean_docker
        ;;
    brew|homebrew)
        clean_brew
        ;;
    usage|disk)
        show_usage
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        if [ -n "${1:-}" ]; then
            clean_all
        else
            interactive_mode
        fi
        ;;
esac
