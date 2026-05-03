# AGENTS.md - AI Coding Agent Guide for Kodra

This document provides guidance for AI coding agents working on the Kodra codebase.

## Project Overview

Kodra is a developer environment for Ubuntu that transforms a vanilla install into a beautiful, productive workspace. It focuses on:
- **Azure cloud development** (Azure CLI, kubectl, Terraform, etc.)
- **Docker/Kubernetes** workflows
- **Beautiful terminal experience** (Ghostty, Starship, modern CLI tools)
- **Consistent theming** across all applications

## Code Style

### Shell Scripts

All shell scripts should follow these conventions:

```bash
#!/usr/bin/env bash
#
# Script Name - Brief description
# Longer description if needed
#

set -e  # Exit on error

# Constants at top, UPPERCASE
KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Colors (consistent naming)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'  # No Color

# Functions use snake_case
my_function() {
    local var="$1"  # Use local for function variables
    # Function body
}

# Main logic at bottom
main() {
    # Entry point
}

main "$@"
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Script files | lowercase-kebab.sh | `night-light.sh` |
| Functions | snake_case | `show_help()` |
| Variables (local) | lowercase | `local theme_name` |
| Variables (global) | UPPERCASE | `KODRA_DIR` |
| Constants | UPPERCASE | `VERSION` |

### File Organization

```
kodra/
├── bin/
│   ├── kodra              # Main CLI dispatcher
│   └── kodra-sub/         # Subcommands
│       ├── theme.sh
│       ├── update.sh
│       └── ...
├── configs/
│   ├── shell/             # Shell configs (sourced)
│   ├── ghostty/           # Terminal config
│   ├── tmux/              # Tmux config
│   └── btop/              # System monitor
├── install/
│   ├── required/          # Core installs (always run)
│   ├── desktop/           # GNOME setup
│   └── terminal/          # Terminal tools
├── lib/
│   ├── ui.sh              # TUI components
│   ├── utils.sh           # Utility functions
│   ├── package.sh         # Package management
│   └── state.sh           # State management
├── themes/
│   └── <theme-name>/
│       ├── ghostty.conf   # Terminal colors
│       ├── starship.toml  # Prompt config
│       ├── vscode-settings.json
│       └── tmux.conf      # Tmux theme
├── applications/          # Optional app installers
│
│ # Web / SEO / AI Discovery
├── index.html             # Landing page (GitHub Pages)
├── 404.html               # Custom 404 page
├── sitemap.xml            # XML sitemap with image extensions
├── robots.txt             # Crawler directives
├── manifest.json          # PWA manifest
├── favicon.svg            # SVG favicon
├── llms.txt               # AI/LLM discovery (summary)
├── llms-full.txt          # AI/LLM discovery (full documentation)
├── CNAME                  # Custom domain (kodra.codetocloud.io)
└── assets/
    ├── favicon.ico.png    # PNG favicon (from codetocloud.io)
    ├── kodra-desktop.png  # Screenshot
    ├── kodra-terminal.png # Screenshot
    └── kodra-tools.png    # Screenshot
```

## Adding New Features

### New Theme

1. Create directory: `themes/<theme-name>/`
2. Required files:
   - `ghostty.conf` - Terminal colors
   - `starship.toml` - Prompt theme
   - `vscode-settings.json` - VS Code colors
   - `tmux.conf` - Tmux status bar theme (optional)
3. Optional: Add btop theme to `configs/btop/themes/<theme-name>.theme`
4. Optional: Add wallpapers to `wallpapers/<theme-name>/`

### New Kodra Command

1. Create script: `bin/kodra-sub/<command>.sh`
2. Make executable: `chmod +x bin/kodra-sub/<command>.sh`
3. Add case in `bin/kodra` dispatcher:
   ```bash
   <command>)
       shift
       bash "$KODRA_DIR/bin/kodra-sub/<command>.sh" "$@"
       ;;
   ```
4. Add to help message
5. Document in `docs/CHEATSHEET.md`

### New Shell Function

1. Add to `configs/shell/kodra.sh` or `configs/shell/aliases.sh`
2. Follow existing patterns for FZF integration
3. Document usage in function header

## Testing

### Local Testing

```bash
# Run basic tests
./tests/test.sh

# Full container test
./tests/test-full.sh

# Test on fresh Azure VM
./tests/test-azure-vm.sh
```

### Test Checklist

- [ ] Script has `set -e` for error handling
- [ ] Works on bash and zsh
- [ ] Idempotent (can run multiple times)
- [ ] Handles missing dependencies gracefully
- [ ] Uses `command -v` not `which` for portability

## UI Components

Use the UI library for consistent output:

```bash
source "$KODRA_DIR/lib/ui.sh"

# Progress indicators
show_progress "Installing packages..."

# Messages
show_success "Installation complete"
show_error "Something went wrong"
show_warning "Optional dependency missing"
show_info "Tip: Use kodra update to update"

# Spinners
spin "Downloading..."
```

## Theme Colors

Themes should define a consistent palette:

| Color Role | Usage |
|------------|-------|
| Background | Main terminal/editor background |
| Foreground | Primary text color |
| Accent 1 | Primary UI elements (buttons, highlights) |
| Accent 2 | Secondary UI elements |
| Selection | Text selection background |
| Red | Errors, deletions |
| Green | Success, additions |
| Yellow | Warnings, modifications |
| Blue | Info, links |
| Purple | Special, keywords |
| Cyan | Constants, strings |

## Common Patterns

### Safe File Operations

```bash
# Create directory if needed
mkdir -p "$KODRA_DIR/backups"

# Safe file copy with backup
if [ -f "$dest" ]; then
    cp "$dest" "$dest.bak"
fi
cp "$source" "$dest"
```

### Dependency Checks

```bash
# Check for required command
if ! command -v gum &>/dev/null; then
    echo "gum is required. Installing..."
    brew install gum
fi
```

### Config File Updates

```bash
# Append if not present
if ! grep -q "source ~/.kodra" "$HOME/.bashrc"; then
    echo 'source "$HOME/.kodra/configs/shell/kodra.sh"' >> "$HOME/.bashrc"
fi
```

## Don'ts

- Don't use `sudo` in scripts unless absolutely necessary
- Don't hardcode paths (use `$HOME`, `$KODRA_DIR`)
- Don't use `eval` with user input
- Don't store credentials in config files
- Don't break existing functionality when adding features
- Don't use Cursor editor references (use VS Code)

## SEO & AI Discovery

The site at `kodra.codetocloud.io` is served via GitHub Pages. When making changes that affect the website or project documentation:

### Files to Keep Updated

| File | Purpose | When to Update |
|------|---------|----------------|
| `index.html` | Landing page with structured data (JSON-LD) | New features, version bumps |
| `sitemap.xml` | XML sitemap with image extensions | Any content/URL change |
| `robots.txt` | Crawler directives | New pages or restricted paths |
| `manifest.json` | PWA manifest | Branding or icon changes |
| `llms.txt` | AI/LLM summary discovery | New features, commands, or links |
| `llms-full.txt` | Full AI/LLM documentation | Any significant project change |
| `404.html` | Custom 404 page | Branding changes |

### SEO Checklist for Changes

- Update `lastmod` in `sitemap.xml` when page content changes
- Keep structured data (JSON-LD) in `index.html` current — includes SoftwareApplication, Organization, BreadcrumbList, FAQPage, and WebSite schemas
- Ensure all `og:image` and `twitter:image` references point to existing files in `assets/`
- Favicon comes from codetocloud.io — stored as `assets/favicon.ico.png`
- All pages must link back to `https://www.codetocloud.io` (parent company)
- Update `llms.txt` and `llms-full.txt` when adding new commands, tools, or changing project metadata
- Keep canonical URLs trailing-slash consistent (`https://kodra.codetocloud.io/`)

### Version Bumps

When bumping versions, update these files: `VERSION`, `README.md`, `index.html` (structured data `softwareVersion` + hero badge), `lib/ui.sh`, `lib/state.sh`, `CHANGELOG.md`, `llms.txt`, `llms-full.txt`

## Resources

- [Kodra Website](https://kodra.codetocloud.io)
- [Code To Cloud (Parent Company)](https://www.codetocloud.io)
- [GitHub Repository](https://github.com/codetocloudorg/kodra)
- [LLMs.txt Standard](https://llmstxt.org)
- [Ghostty Documentation](https://ghostty.org/docs)
- [Starship Configuration](https://starship.rs/config/)
