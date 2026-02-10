#!/usr/bin/env bash
#
# Kodra Uninstall Script
# Removes Kodra configuration (doesn't uninstall tools)
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

echo "Kodra Uninstaller"
echo "================="
echo ""
echo "This will remove Kodra configuration but NOT uninstall tools."
echo ""
echo "What will be removed:"
echo "  • ~/.kodra directory"
echo "  • ~/.config/kodra directory"
echo "  • Kodra lines from .bashrc and .zshrc"
echo ""
echo "What will NOT be removed:"
echo "  • Installed tools (docker, kubectl, etc.)"
echo "  • GNOME extensions"
echo "  • VS Code settings"
echo ""

# Handle input - when run via wget pipe, stdin is consumed but /dev/tty is available
if [ -t 0 ]; then
    # Interactive terminal - read normally  
    read -p "Continue? (y/N) " -n 1 -r
elif ( exec < /dev/tty ) 2>/dev/null; then
    # Piped execution (wget | bash) - use tty for user input
    exec < /dev/tty
    read -p "Continue? (y/N) " -n 1 -r
else
    # Non-interactive (Docker, CI) - read from stdin
    read -r REPLY
fi
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# Remove Kodra directory
if [ -d "$KODRA_DIR" ]; then
    echo "Removing $KODRA_DIR..."
    rm -rf "$KODRA_DIR"
fi

# Remove config directory
if [ -d "$KODRA_CONFIG_DIR" ]; then
    echo "Removing $KODRA_CONFIG_DIR..."
    rm -rf "$KODRA_CONFIG_DIR"
fi

# Remove from .bashrc
if [ -f "$HOME/.bashrc" ]; then
    echo "Cleaning .bashrc..."
    sed -i '/# Kodra/d' "$HOME/.bashrc"
    sed -i '/\.kodra/d' "$HOME/.bashrc"
fi

# Remove from .zshrc
if [ -f "$HOME/.zshrc" ]; then
    echo "Cleaning .zshrc..."
    sed -i '/# Kodra/d' "$HOME/.zshrc"
    sed -i '/\.kodra/d' "$HOME/.zshrc"
fi

# Restore GDM CSS if backup exists
GDM_BACKUPS=(
    "/usr/share/gnome-shell/theme/Yaru/gnome-shell.css.kodra-backup"
    "/usr/share/gnome-shell/theme/ubuntu.css.kodra-backup"
    "/usr/share/gnome-shell/gnome-shell-theme.gresource.kodra-backup"
)

for backup in "${GDM_BACKUPS[@]}"; do
    if [ -f "$backup" ]; then
        original="${backup%.kodra-backup}"
        echo "Restoring $original..."
        sudo mv "$backup" "$original"
    fi
done

# Remove Kodra wallpaper (could be .jpg or .svg)
sudo rm -f /usr/share/backgrounds/kodra-login.svg /usr/share/backgrounds/kodra-login.jpg 2>/dev/null

echo ""
echo "✓ Kodra configuration removed."
echo ""
echo "To fully remove installed tools, use:"
echo "  sudo apt remove docker-ce kubectl helm terraform"
echo "  brew uninstall <package>"
echo ""
