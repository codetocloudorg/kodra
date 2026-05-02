# Changelog

All notable changes to Kodra will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.2] - 2026-05-02

### Added
- **Microsoft Edge** — Native apt installer with Microsoft GPG key and stable channel
- **Dock favorites fix** — Run `kodra dock` during first-run wizard when GNOME session is active, ensuring favorites apply reliably

### Fixed
- **Dock not populating after install** — `gsettings` calls during install fail silently without an active GNOME session; now handled by the first-run wizard

## [0.5.1] - 2026-05-02

### Added
- **BATS testing framework** — 43 tests across unit, integration, and security suites with JUnit XML reports
- **Security scanning** — Supply chain validation, secret detection, permission audits, Dockerfile hardening
- **CI/CD pipeline** — 4-job pipeline with ShellCheck, Hadolint, BATS, Docker build; optimized for free runners (~2.5 min)
- **`kodra ci-report`** — Pull GitHub Actions logs and generate markdown remediation reports with pattern matching
- **`kodra migrate --init`** — Mark all migrations complete on fresh installs (prevents stale migrations running)
- **Code To Cloud branding** — ASCII banners and stage markers in CI terminal output

### Fixed
- **Ghostty installer** — Restored GitHub `.deb` release fallback when PPA is unavailable
- **Azure Storage Explorer** — Gracefully skips when snapd is unavailable (container/CI environments)
- **Migration runner** — Added missing `--init` flag (was causing E2E minimal install failures)
- **CI container jobs** — Set `shell: bash` default (was falling back to `sh`, breaking process substitution)
- **CI job summary** — Fixed `grep -c` multiline arithmetic and `${var^}` bash-only expansion

### Security
- ShellCheck static analysis on all shell scripts in CI
- Hadolint Dockerfile linting in CI
- BATS security tests: world-writable files, setuid binaries, eval safety, HTTPS enforcement, GPG verification

## [0.5.0] - 2026-05-01

### Added
- **Migration system** — Timestamped upgrade scripts (`migrations/`) with state tracking; run once per version
- **Config layering** — Three-layer system (defaults → theme → user) for non-destructive updates
- **Multi-user deployment** — System-wide install to `/opt/kodra` with per-user initialization
- **Structured logging** — `lib/logging.sh` with `run_logged()`, timestamped logs, and log retention
- **Error trap system** — Interactive recovery on install failure (retry, view log, upload for support)
- **Package manifests** — Declarative `kodra-base.packages`, `kodra-brew.packages`, `kodra-flatpak.packages`
- **Config library** — `lib/config.sh` with `apply_config()` and `show_config_status()`
- **System-wide installer** — `install/system-wide.sh` for multi-user environments

### Changed
- **Ghostty installer** — Updated for post-GitHub era (official apt repo on 26.04+, PPA on 24.04)
- **Update script** — Replaced dangerous `git reset --hard` with safe `merge --ff-only` + stash
- **Aliases** — POSIX-overriding aliases now opt-in/out (`KODRA_POSIX_ALIASES`); `find→fd` disabled by default
- **Shell integration** — Uses marker blocks (`# >>> kodra >>>`) for idempotent .bashrc/.zshrc modifications
- **Doctor checks** — Replaced `eval` with `timeout bash -c` for safety; sudo check is non-interactive
- **Network operations** — All curl/wget calls now have `--max-time` timeouts
- **CLI dispatcher** — Detects system-wide install (`/opt/kodra`) automatically

### Fixed
- **theme.sh** — OR operator precedence bug in DISPLAY/WAYLAND check
- **theme.sh** — JSON validation before jq merge (prevents corrupt VS Code settings)
- **Duplicate bashrc lines** — No longer appends duplicate entries on re-runs
- **Security** — Eliminated all `curl | bash` patterns (download → verify → execute)
- **Aliases** — Replaced deprecated `netstat` with `ss`; quoted `$PATH` expansion

### Security
- Removed `eval` usage in doctor.sh (code injection risk)
- Added network timeouts to prevent hanging on bad connections
- Safe download pattern for all external scripts (zoxide, mise)
- Error handler no longer silently swallows failures

## [0.4.2] - 2026-02-21

### Fixed
- **GitHub Copilot CLI installer** now handles missing dependencies gracefully
  - Tries gh extension first (requires `gh auth login`)
  - Falls back to npm install if available
  - No longer fails the overall installation if neither method works
  - Provides helpful instructions for manual installation later

### Added
- Azure VM test script for feature branch QA (`tests/test-feature-branch.sh`)
- Bug report template (`tests/BUG_REPORT.md`)

### Changed
- Improved install resilience - optional components don't fail the install

## [0.4.1] - 2026-02-17

### Changed
- **GitHub Copilot CLI installer** switched from Homebrew (`brew install copilot-cli`) to npm (`npm install -g @github/copilot`)
  - Aligns with official install method at https://github.com/github/copilot-cli
  - npm is more cross-platform and doesn't require Homebrew as a prerequisite

## [0.4.0] - 2026-02-16

### Added
- **`kodra repair` command** - Re-apply all configurations without reinstalling apps
  - Shell integration, desktop files, terminal configs, VS Code settings
  - GNOME extensions, dock favorites, login screen
  - Options: `--shell`, `--desktop`, `--login`, `--apps`, `--vscode`, `--terminal`
- **Login screen customization** via `kodra repair --login`
  - Syncs desktop wallpaper to login screen
  - Multi-monitor safe (per-screen, not stretched)
  - Dark theme with Papirus icons
- Desktop files for CLI tools (appear in app launcher)
  - Neovim, btop, lazygit, lazydocker, k9s

### Fixed
- Flatpak apps now appear in launcher (XDG_DATA_DIRS persisted in ~/.profile)
- GNOME extensions activate after reboot
- Configs apply even if tools already installed (ghostty, starship, neovim)
- Dock favorites persist correctly
- Removed Bitwarden from default dock (Brave was already there)

### Changed
- SEO improvements for kodra.codetocloud.io
  - Updated meta description and hero tagline
  - Enhanced Open Graph and Twitter cards
  - JSON-LD structured data
- Restructured install scripts for better idempotency

## [0.3.2] - 2026-02-16

### Fixed
- Flatpak apps now appear in launcher immediately after install
- GNOME extensions activate properly after first login
- Dock favorites correctly detect all installed apps
- Removed duplicate hardcoded dock favorites

### Added
- First-login autostart script for post-reboot configuration
- `kodra desktop refresh` command for re-applying settings after update
- `kodra update` now automatically runs desktop refresh
- Clear user instructions about first-login setup
- XDG_DATA_DIRS fix for Flatpak desktop file discovery

## [0.3.1] - 2026-02-15

### Fixed
- Azure VM test cleanup improvements
- WSL detection edge cases

## [0.3.0] - 2026-02-10

### Added
- WSL edition for Windows developers
- Ghostty Blue theme
- Login screen customization (`kodra desktop login`)
- Debug/resilient install mode (`--debug` flag)
- Resume incomplete installations (`kodra resume`)
- Beautiful fastfetch system info

### Changed
- Improved installation progress UI
- Better error handling and logging
- Faster package installation with parallel downloads

## [0.2.0] - 2026-01-20

### Added
- Theme system (Tokyo Night, Ghostty Blue)
- Wallpaper management
- MOTD banner customization
- Docker CE and Podman support (user selectable)
- Optional applications (Spotify, Discord, Bitwarden, Postman)

### Changed
- Reorganized installer scripts
- Improved backup/restore functionality

## [0.1.0] - 2026-01-01

### Added
- Initial release
- One-command installation
- Azure CLI, azd, Terraform, Bicep, Helm, kubectl
- GitHub CLI with Copilot CLI
- Ghostty terminal with Starship prompt
- VS Code with cloud-native extensions
- Modern CLI tools (bat, eza, fzf, ripgrep, etc.)
- GNOME desktop customization
- Window tiling and keyboard shortcuts

---

[0.5.0]: https://github.com/codetocloudorg/kodra/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/codetocloudorg/kodra/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/codetocloudorg/kodra/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/codetocloudorg/kodra/compare/v0.3.2...v0.4.0
[0.3.2]: https://github.com/codetocloudorg/kodra/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/codetocloudorg/kodra/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/codetocloudorg/kodra/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/codetocloudorg/kodra/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/codetocloudorg/kodra/releases/tag/v0.1.0
