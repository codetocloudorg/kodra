#!/usr/bin/env bash
#
# Kodra Restore Command
# Restore backed up dotfiles
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

source "$KODRA_DIR/lib/backup.sh"

show_help() {
    echo "Usage: kodra restore [command]"
    echo ""
    echo "Commands:"
    echo "  list              List all available backups"
    echo "  last              Restore from the most recent backup"
    echo "  <timestamp>       Restore from specific backup (e.g., 2026-02-09-14-30-00)"
    echo "  cleanup [days]    Delete backups older than N days (default: 30)"
    echo ""
    echo "Examples:"
    echo "  kodra restore                    # Interactive restore"
    echo "  kodra restore list               # List available backups"
    echo "  kodra restore last               # Restore most recent"
    echo "  kodra restore 2026-02-09-14-30-00"
    echo "  kodra restore cleanup 60         # Delete backups older than 60 days"
    echo ""
}

case "${1:-}" in
    list|--list|-l)
        list_backups
        ;;
    last|--last)
        restore_last_backup
        ;;
    cleanup)
        cleanup_old_backups "${2:-30}"
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        restore_interactive
        ;;
    *)
        # Assume it's a backup timestamp
        restore_backup "$1"
        ;;
esac
