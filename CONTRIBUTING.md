# Contributing to Kodra

Thank you for your interest in contributing to Kodra! This guide covers everything you need to know to contribute effectively.

## Table of Contents

- [Getting Started](#getting-started)
- [Architecture Overview](#architecture-overview)
- [Development Setup](#development-setup)
- [Code Standards](#code-standards)
- [Key Systems](#key-systems)
- [Adding Features](#adding-features)
- [Testing](#testing)
- [Pull Request Guidelines](#pull-request-guidelines)

---

## Getting Started

Kodra is a developer environment for Ubuntu that transforms a vanilla install into a beautiful, productive workspace. It focuses on Azure cloud development, Docker/Kubernetes workflows, and a premium terminal experience.

### Prerequisites

- Ubuntu 24.04+ (or a container/VM for testing)
- Git
- Basic shell scripting knowledge

### Quick Start

```bash
# Clone the repository
git clone https://github.com/codetocloudorg/kodra.git
cd kodra

# Test in a container (safe, no system changes)
docker run -it --rm -v $(pwd):/kodra ubuntu:24.04 bash
# Inside container: cd /kodra && bash install.sh --debug
```

---

## Architecture Overview

### Directory Structure

```
kodra/
├── bin/
│   ├── kodra                  # Main CLI dispatcher
│   ├── kodra-user-init        # Per-user initialization (system-wide installs)
│   └── kodra-sub/             # Subcommand scripts (one per command)
├── configs/
│   ├── shell/                 # Shell integration (aliases, functions, MOTD)
│   ├── ghostty/               # Terminal config (referenced by defaults/)
│   ├── tmux/                  # Tmux configuration
│   └── btop/                  # System monitor themes
├── defaults/
│   ├── ghostty/               # Base Ghostty config (Layer 1)
│   ├── shell/                 # Shell config documentation
│   ├── tmux/                  # Base tmux config
│   └── starship/              # Base Starship prompt config
├── install/
│   ├── kodra-base.packages    # Declarative apt package list
│   ├── kodra-brew.packages    # Declarative Homebrew package list
│   ├── kodra-flatpak.packages # Optional Flatpak apps
│   ├── system-wide.sh         # Multi-user system-wide installer
│   ├── required/              # Core installations (always run)
│   ├── desktop/               # GNOME desktop setup
│   └── terminal/              # Terminal tools (Ghostty, Starship, etc.)
├── lib/
│   ├── utils.sh               # Core utilities (logging, checks)
│   ├── ui.sh                  # TUI components (progress, spinners)
│   ├── logging.sh             # Structured logging system
│   ├── config.sh              # Config layering engine
│   ├── package.sh             # Package management helpers
│   ├── state.sh               # Installation state tracking
│   └── backup.sh              # Backup utilities
├── migrations/
│   └── YYYYMMDDHHMMSS.sh     # Timestamped upgrade scripts
├── themes/
│   └── <theme-name>/          # Theme packages (colors + configs)
├── applications/              # Optional application installers
├── wallpapers/                # Theme wallpapers
├── tests/                     # Test scripts
├── boot.sh                    # Remote bootstrap (curl installer)
└── install.sh                 # Main installation orchestrator
```

### Design Principles

1. **Idempotent** — Every script can run multiple times safely
2. **Non-destructive** — Updates never overwrite user customizations
3. **Resilient** — Failures are logged and recoverable; install continues
4. **Multi-user** — System-wide install at `/opt/kodra`, per-user config at `~/.config/kodra/`
5. **Declarative** — Package lists in manifest files, not buried in scripts
6. **Layered configs** — Defaults → Theme → User overrides

### Configuration Layering

Kodra uses a three-layer configuration system:

```
┌─────────────────────────────┐
│  Layer 3: User Overrides    │  ~/.config/kodra/<app>/
│  (Never touched by Kodra)   │
├─────────────────────────────┤
│  Layer 2: Theme             │  themes/<name>/<app>.conf
│  (Applied by kodra theme)   │
├─────────────────────────────┤
│  Layer 1: Defaults          │  defaults/<app>/config
│  (Managed by Kodra)         │
└─────────────────────────────┘
```

Updates only change Layer 1. Themes override Layer 1. User configs override everything.

### Multi-User Deployment

```
System-wide (/opt/kodra)          Per-user (~/.config/kodra/)
┌────────────────────────┐        ┌──────────────────────────┐
│ bin/kodra              │        │ theme (preference file)  │
│ lib/ (shared libs)     │        │ shell/ (custom aliases)  │
│ defaults/ (base cfg)   │        │ ghostty/ (user tweaks)   │
│ themes/ (all themes)   │        │ migrations/ (state)      │
│ install/ (scripts)     │        │ initialized (marker)     │
└────────────────────────┘        └──────────────────────────┘
         ↓                                   ↓
  Available to ALL users          Personal to each user
  via /etc/profile.d/            Created by `kodra setup`
```

---

## Development Setup

### Local Development

```bash
# Clone and work locally
git clone https://github.com/codetocloudorg/kodra.git ~/.kodra
cd ~/.kodra

# Set KODRA_DIR to your dev copy
export KODRA_DIR="$HOME/.kodra"

# Test a specific script
bash bin/kodra-sub/doctor.sh

# Test the theme system
bash bin/kodra-sub/theme.sh tokyo-night
```

### Container Testing

```bash
# Full integration test
docker run -it --rm \
  -v $(pwd):/root/.kodra \
  -e KODRA_DIR=/root/.kodra \
  ubuntu:24.04 \
  bash -c "cd /root/.kodra && bash install.sh --debug --skip-desktop"

# Quick script test
docker run -it --rm \
  -v $(pwd):/root/.kodra \
  ubuntu:24.04 \
  bash -c "source /root/.kodra/lib/utils.sh && check_ubuntu_version"
```

---

## Code Standards

### Shell Scripts

All scripts MUST:

```bash
#!/usr/bin/env bash
#
# Script Name - Brief description
# Longer description if needed
#

set -e  # Exit on error (unless --debug mode)

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"
```

### Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Script files | lowercase-kebab.sh | `night-light.sh` |
| Functions | snake_case | `show_help()` |
| Local variables | lowercase | `local theme_name` |
| Global/exported | UPPERCASE | `KODRA_DIR` |
| Constants | UPPERCASE | `VERSION` |

### Critical Rules

1. **Always use `--max-time`** on `curl`/`wget` calls (10s for APIs, 30s for downloads, 60s for large files)
2. **Never pipe curl to bash** — download, verify, then execute
3. **Never use `eval`** with user-supplied strings — use `bash -c` with timeout
4. **Never use `git reset --hard`** for updates — use merge or rebase
5. **Use marker blocks** for shell config modifications (idempotent)
6. **Use `command -v`** not `which` for portability
7. **Always quote variables** — `"$var"` not `$var`
8. **Use `local`** for function variables
9. **Add `|| true`** only when you genuinely expect failures (not to silence bugs)
10. **Test display availability** with proper grouping: `{ [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; }`

### Marker Blocks for Shell Config

When modifying `.bashrc`/`.zshrc`, use the idempotent marker pattern:

```bash
# >>> kodra initialize >>>
# !! Contents within this block are managed by Kodra. Do not edit. !!
[ -f "/opt/kodra/configs/shell/kodra.sh" ] && source "/opt/kodra/configs/shell/kodra.sh"
# <<< kodra initialize <<<
```

The `_kodra_update_shell_config()` helper in `lib/utils.sh` manages these blocks automatically.

### Aliases Policy

- POSIX-overriding aliases (`cat`, `ls`) are enabled by default but opt-out via `KODRA_POSIX_ALIASES=false`
- The `find→fd` alias is **disabled by default** (breaks scripts) — opt-in via `KODRA_ALIAS_FIND=true`
- All aliases are conditional on the tool being installed (`command -v`)

---

## Key Systems

### Migration System

Migrations handle breaking changes between Kodra versions. They run once and are tracked via state files.

#### Creating a Migration

```bash
# Name format: YYYYMMDDHHMMSS.sh (UTC timestamp)
touch migrations/$(date -u +%Y%m%d%H%M%S).sh
chmod +x migrations/$(date -u +%Y%m%d%H%M%S).sh
```

```bash
#!/usr/bin/env bash
#
# Migration: Brief description of what this does
# Date: YYYY-MM-DD
# Description: Detailed explanation of why this migration exists
#

# Your migration logic here
# - Migrations MUST be idempotent
# - Migrations run as the current user (not root)
# - Use sudo only when absolutely necessary
# - Always handle the case where the migration is not applicable

echo "Migration complete: brief description"
```

#### Running Migrations

```bash
kodra migrate          # Run all pending migrations
kodra migrate status   # Show migration status
kodra migrate list     # List pending migrations
```

State is tracked at `~/.config/kodra/migrations/<name>.done` (touch files).

### Structured Logging

The `lib/logging.sh` library provides:

```bash
source "$KODRA_DIR/lib/logging.sh"

start_install_log              # Initialize logging session
run_logged "path/to/script.sh" # Run script with full logging
log_to_file "message"          # Append to log
show_log_tail 20               # Display last 20 lines
stop_install_log               # Finalize and save permanent log
```

Logs are saved to `~/.config/kodra/logs/` (last 10 retained).

### Package Manifests

Packages are declared in manifest files:

- `install/kodra-base.packages` — apt packages
- `install/kodra-brew.packages` — Homebrew packages
- `install/kodra-flatpak.packages` — Optional Flatpak apps

Format: one package per line, `#` for comments, blank lines ignored.

To read a manifest programmatically:
```bash
mapfile -t packages < <(grep -v '^#' "$KODRA_DIR/install/kodra-base.packages" | grep -v '^$')
sudo apt-get install -y "${packages[@]}"
```

### Error Handling

The installer uses ERR/EXIT traps that:
- Show the failed command and script
- Display log tail for context
- Offer interactive recovery (retry, view log, upload for support)
- Clean up resources (sudo keepalive, screen lock)

---

## Adding Features

### New Theme

1. Create directory: `themes/<theme-name>/`
2. Required files:
   - `ghostty.conf` — Terminal colors (Ghostty format)
   - `starship.toml` — Prompt theme
   - `vscode-settings.json` — VS Code colors
3. Optional files:
   - `tmux.conf` — Tmux status bar theme
   - `btop.theme` — btop color scheme
4. Optional: Add wallpapers to `wallpapers/<theme-name>/`
5. Update `bin/kodra-sub/theme.sh` mappings if needed

### New CLI Command

1. Create script: `bin/kodra-sub/<command>.sh`
2. Make executable: `chmod +x bin/kodra-sub/<command>.sh`
3. Add case in `bin/kodra` dispatcher
4. Add to `show_help()` in `bin/kodra`
5. Document in `docs/CHEATSHEET.md`

### New Package

Add to the appropriate manifest file:
- System tool → `install/kodra-base.packages`
- Modern CLI tool → `install/kodra-brew.packages`
- Desktop app → `install/kodra-flatpak.packages`

### New Migration

When making a change that requires action on existing installs:
```bash
# Generate timestamp
TIMESTAMP=$(date -u +%Y%m%d%H%M%S)
touch "migrations/${TIMESTAMP}.sh"
chmod +x "migrations/${TIMESTAMP}.sh"
# Edit the migration script
```

---

## Testing

### Local Testing

```bash
# Syntax check all scripts
find . -name "*.sh" -exec bash -n {} \;

# Run the doctor
bash bin/kodra-sub/doctor.sh

# Run basic tests
bash tests/test.sh
```

### Container Testing (Recommended)

```bash
# Full integration test (headless)
docker run -it --rm \
  -v $(pwd):/root/.kodra \
  -e KODRA_DIR=/root/.kodra \
  -e DEBIAN_FRONTEND=noninteractive \
  ubuntu:24.04 \
  bash -c "apt-get update && apt-get install -y sudo curl git && \
           cd /root/.kodra && bash install.sh --debug --skip-desktop"

# Test system-wide install
docker run -it --rm \
  -v $(pwd):/tmp/kodra-source \
  ubuntu:24.04 \
  bash -c "apt-get update && apt-get install -y sudo curl git && \
           cp -a /tmp/kodra-source /root/.kodra && \
           export KODRA_DIR=/root/.kodra && \
           sudo bash /root/.kodra/install/system-wide.sh && \
           kodra doctor"

# Test migrations
docker run -it --rm \
  -v $(pwd):/root/.kodra \
  -e KODRA_DIR=/root/.kodra \
  ubuntu:24.04 \
  bash -c "source /root/.kodra/lib/utils.sh && \
           bash /root/.kodra/bin/kodra-sub/migrate.sh status"
```

### Test Checklist

Before submitting a PR:

- [ ] All scripts pass `bash -n` syntax check
- [ ] Scripts are idempotent (can run multiple times)
- [ ] Network operations have timeouts
- [ ] No `curl | bash` patterns
- [ ] No `eval` with dynamic content
- [ ] No `git reset --hard`
- [ ] Shell config changes use marker blocks
- [ ] New packages added to manifest files
- [ ] Works in container (headless, no DISPLAY)
- [ ] Breaking changes have an accompanying migration

---

## Pull Request Guidelines

### Commit Messages

Use conventional commits:
```
feat: add support for custom fonts
fix: resolve theme switching on Wayland
docs: update contributing guide
refactor: migrate to marker-based shell integration
```

### PR Checklist

- [ ] Branch from `main`
- [ ] Descriptive PR title
- [ ] Tests pass in container
- [ ] No breaking changes without migration
- [ ] Documentation updated if applicable
- [ ] Scripts pass shellcheck (if available)

### Review Criteria

PRs are evaluated on:
1. **Safety** — Does it handle errors? Does it have timeouts?
2. **Idempotency** — Can it run multiple times without side effects?
3. **Non-destructiveness** — Does it respect user customizations?
4. **Portability** — Does it work on Ubuntu 24.04+?
5. **Clarity** — Is the code readable without excessive comments?

---

## Versioning

Kodra uses semantic versioning (`MAJOR.MINOR.PATCH`):

- **MAJOR**: Breaking changes that require user action
- **MINOR**: New features, new themes, new commands
- **PATCH**: Bug fixes, security patches, documentation

The version is stored in the `VERSION` file at the repository root.

---

## Getting Help

- **Issues**: https://github.com/codetocloudorg/kodra/issues
- **Discussions**: https://github.com/codetocloudorg/kodra/discussions
- **Website**: https://kodra.codetocloud.io

---

*Thank you for making Kodra better! Every contribution helps developers have a more beautiful and productive environment.* ✨
