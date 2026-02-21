# Contributing to Kodra

Thank you for your interest in contributing to Kodra! 🚀

Kodra is a **Code To Cloud** project, maintained under the MIT License.

**Website:** [kodra.codetocloud.io](https://kodra.codetocloud.io)

## Current Version

**v0.4.2** - See [VERSION](VERSION) for the current release.

## Versioning

Kodra follows [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH
```

| Type | When to increment | Example |
|------|-------------------|---------|
| **MAJOR** | Breaking changes, major rewrites | 1.0.0 |
| **MINOR** | New features, new tools added | 0.1.0 |
| **PATCH** | Bug fixes, documentation updates | 0.0.2 |

When contributing, update the VERSION file appropriately based on your changes.

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code.

## Reporting Issues

### Before Opening an Issue

1. **Check existing issues** - Your problem may already be reported
2. **Run with debug mode** to capture detailed logs:
   ```bash
   ./install.sh --debug
   ```
3. **Gather system information**:
   ```bash
   lsb_release -a
   kodra version
   cat ~/.config/kodra/install.log | tail -100
   ```

### Issue Template

When opening an issue, please include:

```markdown
## Description
[Clear description of the problem]

## Steps to Reproduce
1. [First step]
2. [Second step]
3. [etc.]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## System Information
- Ubuntu Version: [e.g., 24.04.3 LTS]
- Kodra Version: [e.g., 0.0.1]
- Installation Mode: [normal/debug]

## Logs
[Paste relevant log output or attach /tmp/kodra-install-*.log]
```

### Issue Labels

| Label | Description |
|-------|-------------|
| `bug` | Something isn't working |
| `enhancement` | New feature or improvement |
| `documentation` | Documentation updates needed |
| `installer` | Issues with installation scripts |
| `theme` | Theme-related issues |
| `good first issue` | Good for newcomers |

## Contributing Code

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test on a fresh Ubuntu 24.04 installation
5. Run `./tests/test.sh` to validate
6. Commit with clear messages
7. Update VERSION if appropriate
8. Push to your fork and open a Pull Request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/kodra.git ~/.kodra

# Create a branch
cd ~/.kodra
git checkout -b feature/your-feature

# Test changes
./install.sh
```

## Project Structure

```
kodra/
├── boot.sh                     # Bootstrap (one-liner entry)
├── install.sh                  # Main orchestrator
├── lib/
│   ├── utils.sh               # Helper functions
│   └── ui.sh                  # UI/gum functions
├── install/
│   ├── required/              # Always installed
│   │   ├── applications/      # Core apps (VS Code, etc.)
│   │   ├── azure/             # Azure tools
│   │   └── package-managers/  # Flatpak, Homebrew, mise
│   ├── terminal/              # Shell & terminal setup
│   └── desktop/               # GUI & desktop
├── applications/              # Optional app installers
├── configs/                   # Config templates
├── themes/                    # Theme bundles
├── bin/
│   ├── kodra                  # Main CLI
│   └── kodra-sub/             # Subcommands
├── migrations/                # Upgrade scripts
└── uninstall/                 # Removal scripts
```

## Adding a New Application

1. Create `applications/your-app.sh`:

```bash
#!/usr/bin/env bash
#
# Your App Installer
# https://your-app-website.com/
#

set -e

# Check if already installed
if command -v your-app &> /dev/null; then
    echo "Your App already installed"
    exit 0
fi

# Install logic here
# Prefer: Flatpak > apt > Homebrew > direct download

echo "Your App installed successfully!"
```

2. Create corresponding `uninstall/your-app.sh` if cleanup is needed.

## Adding a New Theme

See the comprehensive [Theme Creation Guide](docs/THEME_GUIDE.md) for detailed instructions.

Quick overview:
1. Create `themes/your-theme/` directory
2. Add required files:
   - `ghostty.conf` - Terminal colors
   - `starship.toml` - Prompt configuration  
   - `vscode-settings.json` - VS Code theme settings
3. Optional: Add `tmux.conf`, btop theme, wallpapers
4. Update theme mappings in `bin/kodra-sub/theme.sh`
5. Test with `kodra theme your-theme`

## Adding a New Command

1. Create `bin/kodra-sub/your-command.sh`:

```bash
#!/usr/bin/env bash
#
# Kodra Your Command
# Brief description
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

show_help() {
    echo "Usage: kodra your-command [options]"
    echo ""
    echo "Options:"
    echo "  help    Show this help"
}

case "${1:-}" in
    help|--help|-h)
        show_help
        ;;
    *)
        # Your command logic
        ;;
esac
```

2. Add to dispatcher in `bin/kodra`:

```bash
your-command)
    shift
    bash "$KODRA_DIR/bin/kodra-sub/your-command.sh" "$@"
    ;;
```

3. Add to help message in `show_help()` function
4. Update tab completions in `configs/completions/`
5. Document in `docs/CHEATSHEET.md`

## Bug Reports

### Before opening a bug report

1. Check existing issues - your problem may already be reported
2. Run `kodra doctor` to identify common issues
3. Try running with debug mode:
   ```bash
   ./install.sh --debug
   ```
4. Check the troubleshooting guide: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

### What to include

```markdown
## Description
[Clear description of the problem]

## Steps to Reproduce
1. [First step]
2. [Second step]
3. [etc.]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## System Information
- Ubuntu Version: [e.g., 24.04.3 LTS]
- Kodra Version: [run `kodra version`]
- Installation Mode: [normal/debug/minimal]

## Logs
[Paste relevant log output or run:]
cat ~/.config/kodra/install.log | nc termbin.com 9999
```

## Coding Guidelines

- Use `set -e` at the start of scripts
- Check if tools are already installed before installing
- Use idempotent operations (safe to run multiple times)
- Log with `log_info`, `log_success`, `log_error` from `lib/utils.sh`
- Test both fresh installs and upgrades
- Prefer official installation methods

## Commit Messages

Use clear, descriptive commit messages:

```
feat: add Azure Functions Core Tools installer
fix: correct Homebrew PATH on Ubuntu 24.04
docs: update README with new Azure tools
refactor: simplify Docker installation script
```

## Testing

Before submitting:

1. Test on fresh Ubuntu 24.04 VM
2. Test the upgrade path (`kodra update`)
3. Test uninstallation if applicable
4. Verify `kodra doctor` passes

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Kodra** - A Code To Cloud Project ☁️

[kodra.codetocloud.io](https://kodra.codetocloud.io) | [Discord](https://discord.gg/vwfwq2EpXJ) | [GitHub](https://github.com/codetocloudorg)

*Developed by [Code To Cloud](https://www.codetocloud.io)*
