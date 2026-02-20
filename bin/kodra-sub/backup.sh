#!/usr/bin/env bash
#
# Kodra Backup Command
# Create and manage backups, export dotfiles
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

source "$KODRA_DIR/lib/backup.sh"

show_help() {
    echo "Usage: kodra backup [command] [options]"
    echo ""
    echo "Commands:"
    echo "  create            Create a new backup of current dotfiles"
    echo "  list              List all available backups"
    echo "  export [file]     Export dotfiles to portable tarball"
    echo "  import <file>     Import dotfiles from tarball"
    echo "  dconf             Backup GNOME dconf settings"
    echo "  dconf-restore <f> Restore dconf settings from file"
    echo "  cleanup [days]    Delete backups older than N days (default: 30)"
    echo ""
    echo "Examples:"
    echo "  kodra backup create              # Backup current dotfiles"
    echo "  kodra backup export              # Export to ~/kodra-dotfiles-DATE.tar.gz"
    echo "  kodra backup export ~/backup.tar.gz"
    echo "  kodra backup import ~/backup.tar.gz"
    echo "  kodra backup dconf               # Backup GNOME settings"
    echo "  kodra backup cleanup 60          # Delete backups older than 60 days"
    echo ""
}

case "${1:-help}" in
    create|new)
        backup_dotfiles
        ;;
    list|ls)
        list_backups
        ;;
    export)
        export_dotfiles_tarball "${2:-}"
        ;;
    import)
        import_dotfiles_tarball "${2:-}"
        ;;
    dconf|gsettings)
        backup_dconf "${2:-}"
        ;;
    dconf-restore|dconf-import)
        restore_dconf "${2:-}"
        ;;
    cleanup|clean)
        cleanup_old_backups "${2:-30}"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
