# Installation Guide

Complete guide to installing Kodra on Ubuntu 24.04+.

## Quick Install

The fastest way to install Kodra:

```bash
wget -qO- https://kodra.codetocloud.io/boot.sh | bash
```

This runs the interactive installer with a premium command-line experience:
- Pre-flight checks showing system compatibility
- Progress tracking with ETA estimates  
- Live installation status with tool checkmarks
- Completion summary with stats and ready-to-use tools

## Requirements

| Requirement | Minimum |
|-------------|---------|
| **OS** | Ubuntu 24.04 LTS or newer |
| **Disk** | 10GB free space |
| **RAM** | 4GB (8GB recommended) |
| **Internet** | Required for installation |
| **Privileges** | sudo access |

## Installation Methods

### Method 1: One-Line Install (Recommended)

```bash
wget -qO- https://kodra.codetocloud.io/boot.sh | bash
```

### Method 2: Direct Install

```bash
# Clone the repository
git clone https://github.com/codetocloudorg/kodra.git ~/.kodra

# Run the installer
cd ~/.kodra
./install.sh
```

### Method 3: Custom Install

```bash
# Minimal install (skip optional apps)
KODRA_MINIMAL=1 ./install.sh

# Pre-select theme
KODRA_THEME="ghostty-blue" ./install.sh

# Skip specific tools
KODRA_SKIP="spotify,discord" ./install.sh

# Debug mode (continue on errors, verbose output)
./install.sh --debug
```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `KODRA_THEME` | Pre-select theme | `tokyo-night`, `ghostty-blue`, `catppuccin`, `gruvbox`, `nord`, `rose-pine` |
| `KODRA_MINIMAL` | Skip optional apps | `1` |
| `KODRA_SKIP` | Comma-separated apps to skip | `spotify,discord` |
| `KODRA_SKIP_BACKUP` | Don't backup existing dotfiles | `1` |
| `KODRA_DIR` | Custom install location | `~/.kodra` (default) |

## What Gets Installed

### Core Tools (Always Installed)

| Category | Tools |
|----------|-------|
| **Terminal** | Ghostty, Starship prompt, Nerd Fonts |
| **Editor** | VS Code with 13 extensions, Neovim |
| **Azure** | Azure CLI, azd, Bicep, PowerShell 7 |
| **Containers** | Docker CE, lazydocker |
| **Git** | GitHub CLI, lazygit |
| **CLI** | bat, eza, fzf, ripgrep, zoxide, fastfetch, btop, jq |
| **Desktop** | ULauncher, Dash to Dock, Blur my Shell, TopHat, Tactile |

### Optional Tools

Selected during interactive install:

| Tool | Description |
|------|-------------|
| **Terraform** | Infrastructure as Code |
| **OpenTofu** | Open-source Terraform fork |
| **kubectl** | Kubernetes CLI |
| **Helm** | Kubernetes package manager |
| **k9s** | Kubernetes TUI |
| **GitHub Desktop** | Git GUI |
| **Spotify** | Music streaming |
| **Discord** | Community chat |

## Installation Locations

| Component | Location |
|-----------|----------|
| **Kodra core** | `~/.kodra/` |
| **Configs** | `~/.config/kodra/` |
| **State file** | `~/.config/kodra/state.json` |
| **Install logs** | `~/.config/kodra/install.log` |
| **Backups** | `~/.kodra/backups/` |
| **Themes** | `~/.kodra/themes/` |
| **Wallpapers** | `~/.kodra/wallpapers/` |

## Post-Install Setup

After installation completes, you'll be guided through:

1. **Git configuration** — Set name and email
2. **GitHub CLI login** — `gh auth login`
3. **Azure CLI login** — `az login`
4. **Theme selection** — Pick your preferred look

You can re-run this setup anytime:

```bash
kodra setup
```

## Learning the Shortcuts

Kodra includes 50+ shell aliases and keyboard shortcuts to boost your productivity:

```bash
# Quick examples
??           # Ask GitHub Copilot for shell commands
lg           # Launch lazygit
azd-up       # Deploy to Azure
gs           # git status
```

See the **[Full Cheat Sheet](CHEATSHEET.md)** for all aliases, keyboard shortcuts, and keybindings.

## Verifying Installation

Check that everything is working:

```bash
# Run health check
kodra doctor

# Run with auto-fix for common issues
kodra doctor --fix

# Show installed version
kodra version

# Display system info
kodra fetch
```

## Troubleshooting

### Installation Failed Mid-Way

Kodra tracks progress and can resume:

```bash
# Check what failed
kodra resume status

# Retry failed components
kodra resume retry

# Start fresh
kodra resume clear
```

### Permission Denied

```bash
# Ensure you have sudo access
sudo -v

# If running from git clone, make executable
chmod +x install.sh
```

### Package Conflicts

```bash
# Run in debug mode for verbose output
./install.sh --debug

# Check logs
cat ~/.config/kodra/install.log
```

### Desktop Not Updating

```bash
# Restart GNOME Shell
# Press Alt+F2, type 'r', press Enter

# Or log out and back in
```

## Updating

Keep Kodra and all tools updated:

```bash
# Update everything
kodra update

# Or via boot menu
wget -qO- https://kodra.codetocloud.io/boot.sh | bash
# Select "Update"
```

## Getting Help

- **Discord**: [Join our community](https://discord.gg/vwfwq2EpXJ)
- **Issues**: [GitHub Issues](https://github.com/codetocloudorg/kodra/issues)
- **Docs**: [README](https://github.com/codetocloudorg/kodra)

---

*Developed by [Code To Cloud](https://www.codetocloud.io)*
