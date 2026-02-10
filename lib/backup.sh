#!/usr/bin/env bash
#
# Kodra Backup System
# Backs up dotfiles before modification for safe recovery
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_BACKUP_DIR="$KODRA_DIR/backups"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

# Files/directories to back up before modifying
BACKUP_TARGETS=(
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.gitconfig"
    "$HOME/.config/ghostty"
    "$HOME/.config/starship.toml"
    "$HOME/.config/Code/User/settings.json"
    "$HOME/.config/nvim"
)

# Source utils for logging
if [ -f "$KODRA_DIR/lib/utils.sh" ]; then
    source "$KODRA_DIR/lib/utils.sh"
else
    # Fallback logging if utils not available
    log_info() { echo "[INFO] $1"; }
    log_success() { echo "[OK] $1"; }
    log_warning() { echo "[WARN] $1"; }
    log_error() { echo "[ERROR] $1"; }
fi

# Create timestamped backup directory
# Returns: path to backup directory
create_backup_dir() {
    local timestamp=$(date +%Y-%m-%d-%H-%M-%S)
    local backup_path="$KODRA_BACKUP_DIR/$timestamp"
    
    mkdir -p "$backup_path"
    echo "$backup_path"
}

# Back up a single file or directory
# Args: $1 = source path, $2 = backup directory
backup_item() {
    local source="$1"
    local backup_dir="$2"
    
    if [ ! -e "$source" ]; then
        return 0  # Nothing to back up
    fi
    
    # Create relative path structure
    local relative_path="${source#$HOME/}"
    local dest_dir="$backup_dir/$(dirname "$relative_path")"
    
    mkdir -p "$dest_dir"
    
    if cp -r "$source" "$dest_dir/" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Back up all target files before installation
# Returns: path to backup directory (empty if skipped)
backup_dotfiles() {
    # Skip if user opted out
    if [ "$KODRA_SKIP_BACKUP" = "1" ]; then
        log_info "Backup skipped (KODRA_SKIP_BACKUP=1)"
        return 0
    fi
    
    local backup_dir=$(create_backup_dir)
    local backed_up=0
    local failed=0
    
    log_info "Backing up existing configs..."
    
    for target in "${BACKUP_TARGETS[@]}"; do
        if [ -e "$target" ]; then
            if backup_item "$target" "$backup_dir"; then
                ((backed_up++))
            else
                ((failed++))
                log_warning "Failed to back up: $target"
            fi
        fi
    done
    
    if [ $backed_up -gt 0 ]; then
        # Save backup metadata
        echo "timestamp=$(date -Iseconds)" > "$backup_dir/.kodra-backup"
        echo "version=$(cat "$KODRA_DIR/VERSION" 2>/dev/null || echo "unknown")" >> "$backup_dir/.kodra-backup"
        echo "files=$backed_up" >> "$backup_dir/.kodra-backup"
        
        log_success "Backed up $backed_up items to $backup_dir"
        
        # Save last backup location for quick restore
        mkdir -p "$KODRA_CONFIG_DIR"
        echo "$backup_dir" > "$KODRA_CONFIG_DIR/last-backup"
    else
        # Remove empty backup dir
        rmdir "$backup_dir" 2>/dev/null
        log_info "No existing configs to back up"
    fi
    
    echo "$backup_dir"
}

# List all available backups
list_backups() {
    if [ ! -d "$KODRA_BACKUP_DIR" ]; then
        echo "No backups found."
        return 1
    fi
    
    local count=0
    echo ""
    echo "Available backups:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    for backup in "$KODRA_BACKUP_DIR"/*/; do
        if [ -d "$backup" ] && [ -f "$backup/.kodra-backup" ]; then
            local name=$(basename "$backup")
            local files=$(grep "^files=" "$backup/.kodra-backup" 2>/dev/null | cut -d= -f2)
            echo "  $name  ($files files)"
            ((count++))
        fi
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ $count -eq 0 ]; then
        echo "No backups found."
        return 1
    fi
    
    echo "Total: $count backups"
    return 0
}

# Restore from a specific backup
# Args: $1 = backup name (timestamp)
restore_backup() {
    local backup_name="$1"
    local backup_dir="$KODRA_BACKUP_DIR/$backup_name"
    
    if [ ! -d "$backup_dir" ]; then
        log_error "Backup not found: $backup_name"
        list_backups
        return 1
    fi
    
    log_info "Restoring from backup: $backup_name"
    
    local restored=0
    local failed=0
    
    # Restore each backed up item
    for item in "$backup_dir"/* "$backup_dir"/.[!.]*; do
        [ -e "$item" ] || continue
        [ "$(basename "$item")" = ".kodra-backup" ] && continue
        
        local relative_path="${item#$backup_dir/}"
        local dest="$HOME/$relative_path"
        
        # Create parent directory if needed
        mkdir -p "$(dirname "$dest")"
        
        if cp -r "$item" "$dest" 2>/dev/null; then
            ((restored++))
            log_success "Restored: $relative_path"
        else
            ((failed++))
            log_error "Failed to restore: $relative_path"
        fi
    done
    
    echo ""
    if [ $restored -gt 0 ]; then
        log_success "Restored $restored items from backup"
    fi
    if [ $failed -gt 0 ]; then
        log_warning "$failed items failed to restore"
    fi
    
    return 0
}

# Restore from last backup
restore_last_backup() {
    local last_backup_file="$KODRA_CONFIG_DIR/last-backup"
    
    if [ ! -f "$last_backup_file" ]; then
        log_error "No recent backup found"
        list_backups
        return 1
    fi
    
    local last_backup=$(cat "$last_backup_file")
    local backup_name=$(basename "$last_backup")
    
    restore_backup "$backup_name"
}

# Interactive restore using gum or fallback
restore_interactive() {
    if [ ! -d "$KODRA_BACKUP_DIR" ]; then
        log_error "No backups directory found"
        return 1
    fi
    
    local backups=()
    for backup in "$KODRA_BACKUP_DIR"/*/; do
        if [ -d "$backup" ] && [ -f "$backup/.kodra-backup" ]; then
            backups+=("$(basename "$backup")")
        fi
    done
    
    if [ ${#backups[@]} -eq 0 ]; then
        log_error "No backups available"
        return 1
    fi
    
    local selected=""
    
    if command -v gum &> /dev/null; then
        echo "Select a backup to restore:"
        selected=$(printf '%s\n' "${backups[@]}" | gum choose --height=10)
    else
        echo ""
        echo "Available backups:"
        local i=1
        for b in "${backups[@]}"; do
            echo "  $i) $b"
            ((i++))
        done
        echo ""
        read -p "Enter number to restore (1-${#backups[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#backups[@]} ]; then
            selected="${backups[$((choice-1))]}"
        fi
    fi
    
    if [ -n "$selected" ]; then
        echo ""
        if command -v gum &> /dev/null; then
            if gum confirm "Restore from $selected?"; then
                restore_backup "$selected"
            else
                echo "Restore cancelled."
            fi
        else
            read -p "Restore from $selected? (y/N) " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                restore_backup "$selected"
            else
                echo "Restore cancelled."
            fi
        fi
    else
        echo "No backup selected."
    fi
}

# Clean up old backups (older than N days)
# Args: $1 = days (default: 30)
cleanup_old_backups() {
    local days="${1:-30}"
    
    if [ ! -d "$KODRA_BACKUP_DIR" ]; then
        return 0
    fi
    
    local old_backups=()
    local cutoff=$(date -d "-$days days" +%Y-%m-%d 2>/dev/null || date -v-${days}d +%Y-%m-%d)
    
    for backup in "$KODRA_BACKUP_DIR"/*/; do
        if [ -d "$backup" ]; then
            local backup_date=$(basename "$backup" | cut -d- -f1-3)
            if [[ "$backup_date" < "$cutoff" ]]; then
                old_backups+=("$backup")
            fi
        fi
    done
    
    if [ ${#old_backups[@]} -eq 0 ]; then
        log_info "No backups older than $days days"
        return 0
    fi
    
    echo ""
    echo "Found ${#old_backups[@]} backups older than $days days:"
    for b in "${old_backups[@]}"; do
        echo "  - $(basename "$b")"
    done
    echo ""
    
    local confirm=""
    if command -v gum &> /dev/null; then
        if gum confirm "Delete these old backups?"; then
            confirm="y"
        fi
    else
        read -p "Delete these old backups? (y/N) " confirm
    fi
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        for b in "${old_backups[@]}"; do
            rm -rf "$b"
            log_success "Deleted: $(basename "$b")"
        done
        log_success "Cleaned up ${#old_backups[@]} old backups"
    else
        echo "Cleanup cancelled."
    fi
}
