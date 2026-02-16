# Changelog

All notable changes to Kodra will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.3.2]: https://github.com/codetocloudorg/kodra/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/codetocloudorg/kodra/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/codetocloudorg/kodra/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/codetocloudorg/kodra/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/codetocloudorg/kodra/releases/tag/v0.1.0
