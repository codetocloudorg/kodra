# Uninstallation Guide

How to cleanly remove Kodra from your system.

## Quick Uninstall

The easiest way to uninstall:

```bash
curl -fsSL https://kodra.codetocloud.io/boot.sh | bash
```

Select **Uninstall** from the menu.

## Direct Uninstall

If you still have Kodra installed:

```bash
bash ~/.kodra/uninstall.sh
```

## What Gets Removed

### Removed by Default

| Component | Location |
|-----------|----------|
| **Kodra core** | `~/.kodra/` |
| **Kodra configs** | `~/.config/kodra/` |
| **Shell integration** | Lines in `~/.bashrc`, `~/.zshrc` |
| **Desktop shortcuts** | `~/.local/share/applications/kodra*` |
| **PATH entries** | Kodra bin directory |

### NOT Removed (Your Data)

These are preserved to avoid data loss:

| Component | Reason |
|-----------|--------|
| **Azure CLI** | May have credentials, other projects use it |
| **Docker** | May have containers, images, volumes |
| **VS Code** | Your projects and settings |
| **Git configs** | Your identity and credentials |
| **GitHub CLI** | Auth tokens and configs |

### Optionally Removed

The uninstaller will ask if you want to remove:

- **Themes applied** — Reset to Ubuntu defaults
- **Wallpapers** — Restored to Ubuntu wallpaper
- **GNOME extensions** — Tactile, Dash to Dock, etc.
- **Starship prompt** — Revert to default bash prompt
- **Ghostty** — Remove terminal (falls back to GNOME Terminal)

## Restoring Backups

Kodra backs up your dotfiles before modifying them. To restore:

```bash
# List available backups
kodra restore list

# Restore most recent backup
kodra restore last

# Interactive restore
kodra restore
```

### Manual Backup Restoration

Backups are stored in `~/.kodra/backups/YYYY-MM-DD-HH-MM-SS/`:

```bash
# See what was backed up
ls ~/.kodra/backups/

# Restore specific file
cp ~/.kodra/backups/2026-02-09-14-30-00/.bashrc ~/.bashrc
```

## Complete Clean Removal

If you want to remove everything including tools:

```bash
# Run uninstaller first
bash ~/.kodra/uninstall.sh

# Then optionally remove individual tools:

# Remove Ghostty
sudo apt remove ghostty

# Remove Docker
sudo apt remove docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker

# Remove Azure CLI
sudo apt remove azure-cli

# Remove VS Code
sudo apt remove code

# Remove Homebrew (if installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Remove mise
rm -rf ~/.local/share/mise ~/.config/mise

# Remove Starship
rm -f ~/.local/bin/starship
```

## Resetting Desktop

If you only want to reset the desktop appearance:

```bash
# Reset GNOME to defaults
dconf reset -f /org/gnome/

# Reset just the theme
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.interface icon-theme

# Reset wallpaper
gsettings reset org.gnome.desktop.background picture-uri
gsettings reset org.gnome.desktop.background picture-uri-dark
```

## Troubleshooting

### Uninstaller Not Found

```bash
# If ~/.kodra was deleted, download fresh
git clone https://github.com/codetocloudorg/kodra.git /tmp/kodra
bash /tmp/kodra/uninstall.sh
rm -rf /tmp/kodra
```

### Shell Still Shows Kodra Prompt

Edit your shell config:

```bash
# For bash
nano ~/.bashrc
# Remove lines between: # Kodra START ... # Kodra END

# For zsh
nano ~/.zshrc
# Remove Kodra-related lines

# Reload shell
source ~/.bashrc  # or ~/.zshrc
```

### Ghostty Still Default Terminal

```bash
# Reset default terminal
sudo update-alternatives --config x-terminal-emulator
# Select gnome-terminal
```

### GNOME Extensions Still Active

```bash
# Disable extensions
gnome-extensions disable tactile@olejorgenb.github.io
gnome-extensions disable dash-to-dock@micxgx.gmail.com

# Or remove them
gnome-extensions uninstall tactile@olejorgenb.github.io
```

## Reinstalling

If you change your mind, reinstall anytime:

```bash
wget -qO- https://kodra.codetocloud.io/boot.sh | bash
```

Your backed-up configs will still be available in `~/.kodra/backups/` if the directory wasn't deleted.

## Getting Help

- **Discord**: [Join our community](https://discord.gg/vwfwq2EpXJ)
- **Issues**: [GitHub Issues](https://github.com/codetocloudorg/kodra/issues)

---

*Developed by [Code To Cloud](https://www.codetocloud.io)*
