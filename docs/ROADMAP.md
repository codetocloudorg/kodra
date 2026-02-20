# Kodra Roadmap

> Development roadmap and improvement tracking for Kodra.

## Priority Legend
- 🔴 **P0** - Critical for v0.2.0
- 🟡 **P1** - Important for adoption
- 🟢 **P2** - Nice to have

---

## 📋 Core Infrastructure

### #1 Backup System for Dotfiles 🔴 P0
- [x] Create `lib/backup.sh` with backup utilities
- [x] Backup to `~/.kodra/backups/YYYY-MM-DD-HH-MM-SS/`
- [x] Back up: `.bashrc`, `.zshrc`, `.gitconfig`, `.config/ghostty/`
- [x] Create `kodra restore` command
- [x] Add `KODRA_SKIP_BACKUP=1` env var option
- [x] Auto-cleanup backups older than 30 days

### #2 Modularize Installation Scripts 🔴 P0
- [x] Directory structure under `install/`
- [x] Each script is idempotent
- [x] Scripts source `lib/utils.sh`
- [x] Scripts respect `KODRA_SKIP` env var

### #3 Comprehensive Utility Library 🔴 P0 ✅
- [x] `lib/utils.sh` - Basic utilities
- [x] `lib/ui.sh` - TUI components
- [x] Add `command_exists()` function
- [x] Add `is_arm()` architecture detection
- [x] Add `retry()` for failed commands
- [x] Add `download_file()` with verification
- [x] Create `lib/package.sh` for apt/snap/deb helpers
- [x] Create `lib/checks.sh` for pre-flight checks

### #4 Smart Error Handling & Recovery 🔴 P0 ✅
- [x] Trap handlers for errors
- [x] Installation logging to file
- [x] Track installed components in state
- [x] Track failed components in state
- [x] Save state to `~/.kodra/state.json`
- [x] Create `kodra resume` command
- [x] Add `--continue-on-error` flag (via `--debug`/`--resilient`)
- [x] Show installation summary on completion

### #5 Uninstall Scripts per Component 🟡 P1 ✅
- [x] Create `uninstall/` mirroring `install/`
- [x] Each install has matching uninstall
- [x] Interactive uninstall menu
- [x] Options: uninstall all, by category, specific tool
- [ ] Option to keep or remove configs
- [ ] Restore backed up dotfiles
- [x] Add `--dry-run` flag

### #7 Health Check & Doctor Command 🟡 P1 ✅
- [x] `kodra doctor` exists
- [x] Check all installed tools accessible
- [x] Verify shell config loaded
- [x] Check Azure CLI login status
- [x] Check Docker daemon running
- [x] Check kubectl cluster connection
- [x] Check disk space
- [x] Check internet connectivity
- [x] Add `--fix` flag for auto-remediation
- [x] Provide fix suggestions for failures

### #8 ARM Architecture Support 🟢 P2
- [ ] Detect ARM architecture
- [ ] Use ARM-compatible packages
- [ ] Skip x86-only applications
- [ ] Test on Raspberry Pi 4/5
- [ ] Test on ARM cloud instances
- [ ] Document ARM limitations

### #9 Testing Framework 🟡 P1
- [x] `tests/test.sh` for local tests
- [x] `tests/test-full.sh` for container tests
- [x] Add GitHub Actions CI workflow
- [x] Test on Ubuntu 24.04
- [ ] Test on Ubuntu 22.04 LTS
- [ ] Add CI badge to README

### #10 Interactive Boot Menu 🟡 P1 ✅
- [x] Implement gum-based interactive menu in boot.sh
- [x] Menu options: Install, Update, Change Theme, Uninstall, Exit
- [x] Handle TTY detection for piped vs direct execution
- [x] Support both `curl | bash` and direct `./boot.sh` execution
- [x] Graceful fallback when no TTY available

---

## 🎨 Website

### #11 Video Demonstration 🔴 P0
- [ ] Record 2-3 min demo video
- [ ] Show fresh Ubuntu → themed desktop
- [ ] Demo Azure CLI, Docker, k9s
- [ ] Host on YouTube
- [ ] Add "Watch Demo" button to site
- [ ] Create GIF preview for README

### #12 Screenshot Gallery 🔴 P0
- [ ] Screenshots for each theme
- [ ] Desktop + terminal + VS Code per theme
- [ ] Azure CLI in action
- [ ] k9s dashboard
- [ ] lazydocker interface
- [ ] Add carousel to homepage
- [ ] Optimize as WebP with lazy loading

### #12 Documentation Site 🟡 P1
- [ ] Create `/docs` section
- [ ] Getting Started guide
- [ ] Installation guide
- [ ] Commands reference
- [ ] Troubleshooting guide
- [ ] FAQ section
- [ ] Search functionality
- [ ] Mobile responsive

### #13 Blog/Changelog Section 🟢 P2
- [ ] Add `/blog` section
- [ ] RSS feed support
- [ ] Changelog page
- [ ] Launch announcement post

### #14 SEO & Discoverability 🟡 P1
- [x] sitemap.xml exists
- [x] robots.txt exists
- [x] Add meta tags (title, description, OG)
- [x] Add structured data (JSON-LD)
- [ ] Submit to Google Search Console
- [ ] Add analytics (Plausible)

### #15 Social Proof & Testimonials 🟢 P2
- [ ] Add testimonials section
- [ ] GitHub star count widget
- [ ] Discord member count
- [ ] "As used by" section

### #16 Landing Page Improvements 🟡 P1 ✅
- [x] Add hero section with video/screenshot
- [x] "How It Works" 3-step section
- [ ] "Why Kodra?" benefits section
- [x] FAQ section
- [ ] Improve mobile responsiveness

---

## 🚀 Features

### #17 Interactive Setup Wizard 🔴 P0
- [x] gum installed during setup
- [x] Interactive theme selection
- [x] Multi-select for optional apps
- [x] Confirmation before install
- [ ] Progress indicators during install
- [ ] Success screen with next steps

### #18 Configuration Profiles 🟢 P2
- [ ] Create `~/.kodra/profiles/` directory
- [ ] Profiles as JSON files
- [ ] `kodra profile save <name>`
- [ ] `kodra profile load <name>`
- [ ] `kodra profile list`
- [ ] Ship default profiles (Full, Minimal, AKS Dev)

### #19 Shell Completions 🟢 P2 ✅
- [x] Bash completion for `kodra`
- [x] Zsh completion for `kodra`
- [x] Tab complete themes, commands
- [x] Install completions during setup/repair

### #20 Update Notifications 🟢 P2
- [ ] Check for updates on shell startup (daily)
- [ ] Compare local vs GitHub release
- [ ] Non-intrusive notification
- [ ] `KODRA_CHECK_UPDATES=0` to disable

### #21 Telemetry (Opt-in) 🟢 P2
- [ ] Opt-in during setup
- [ ] Anonymous: Ubuntu version, Kodra version, theme
- [ ] No PII
- [ ] `kodra telemetry on/off/status`

### #22 Dotfiles Sync Feature 🟢 P2
- [ ] `kodra sync init` - Create GitHub repo
- [ ] `kodra sync push` - Push config
- [ ] `kodra sync pull` - Pull config
- [ ] Exclude secrets
- [ ] Handle conflicts

---

## 📚 Documentation

### #23 Comprehensive README 🔴 P0
- [x] Basic installation instructions
- [x] Feature list
- [ ] Add badges (version, Ubuntu, license, CI)
- [ ] Add demo GIF
- [ ] Commands reference table
- [ ] Environment variables table
- [ ] Troubleshooting section
- [ ] Link to docs site

### #24 CONTRIBUTING.md Guide 🟡 P1
- [x] Basic contributing guide exists
- [x] How to report bugs
- [x] How to add new tools
- [x] How to create themes
- [ ] Code style guide
- [ ] Development setup

### #25 Troubleshooting Guide 🟡 P1 ✅
- [x] Installation failures
- [x] Azure CLI login issues
- [x] Docker permission issues
- [x] Theme not applying
- [x] GNOME extension issues
- [ ] Link from error messages

---

## 🔧 Technical Debt

### #29 Code Quality Improvements 🟡 P1
- [ ] Add ShellCheck to CI
- [ ] Fix all ShellCheck warnings
- [ ] Standardize function naming
- [ ] Add comments to complex sections
- [ ] Remove duplicate code
- [ ] Follow Google Shell Style Guide

### #30 Performance Optimizations 🟢 P2
- [ ] Parallel installs where possible
- [ ] Cache apt package lists
- [ ] Download files concurrently
- [ ] Skip checks on re-install
- [ ] Reduce shell startup time

---

## 📊 Metrics

### #31 Track Installation Metrics 🟢 P2
- [ ] Total installations (with consent)
- [ ] Ubuntu version distribution
- [ ] Popular themes
- [ ] Installation success rate
- [ ] Show public stats on website

---

## 🎨 Design

### #32 Redesign CLI Output 🟢 P2
- [x] Basic colored output
- [ ] Consistent color scheme
- [ ] ASCII art headers
- [ ] Spinner animations
- [ ] Box drawing for sections
- [ ] 80-char width consistency

---

## 🔐 Security

### #33 Security Audit 🟡 P1 ✅
- [x] Review all download URLs (HTTPS only)
- [x] Verify GPG signatures on packages
- [x] Don't run scripts with eval
- [x] Sanitize user input
- [x] Don't store credentials
- [x] Add SECURITY.md
- [x] Set up Dependabot

---

## 🖥️ Shell & Terminal Enhancements

### #34 Tab-Cycle Completion 🔴 P0 ✅
- [x] Add `menu-complete` to inputrc
- [x] Add `menu-complete-backward` for Shift+Tab
- [x] Set `menu-complete-display-prefix on`

### #35 Dynamic Theme Loading 🔴 P0 ✅
- [x] Ghostty `config-file` directive for theme import
- [x] Theme updates without terminal restart
- [x] Create theme-specific ghostty configs

### #36 Enhanced Shell Aliases 🔴 P0 ✅
- [x] `open()` - Silent xdg-open wrapper with background
- [x] `n()` - Smart nvim (dir or file)
- [x] `zd()` - zoxide with visual feedback and icons
- [x] `t` - tmux attach or new session
- [x] `fe()` - Fuzzy edit file (implemented as `fe()`)

### #37 SSH Port Forwarding Functions 🟡 P1 ✅
- [x] `fip` - Forward local port to remote
- [x] `dip` - Dynamic SOCKS proxy
- [x] `lip` - List active port forwards

### #38 Media Transcoding Functions 🟡 P1 ✅
- [x] `img2jpg` - Convert images to JPEG
- [x] `img2png` - Convert images to PNG
- [x] `img2webp` - Convert images to WebP
- [x] `compress` - Smart file/folder compression
- [x] `transcode-video-1080p` - Video transcoding
- [x] `transcode-video-720p` - Video transcoding

### #39 Disk Utilities 🟢 P2
- [ ] `iso2sd` - Write ISO to USB drive
- [ ] `format-drive` - Safe drive formatter with prompts

### Existing Shell Functions ✅ (Already Implemented)
The following shell functions already exist in `configs/shell/kodra.sh`:
- [x] `zz()` - Fuzzy cd with zoxide + fzf
- [x] `fco()` - Fuzzy git branch checkout
- [x] `fkill()` - Fuzzy process kill
- [x] `dsh()` - Fuzzy docker container shell
- [x] `fe()` - Fuzzy edit file with bat preview
- [x] `fgl()` - Fuzzy git log browser
- [x] `extract()` - Universal archive extraction
- [x] `compress()` - Folder compression to tar.gz
- [x] `gclone()` - Clone and cd into repo
- [x] `aztemplate()` - Azure template scaffolding
- [x] `kpod()` - kubectl port-forward helper
- [x] `dps()` - Docker ps with grep
- [x] `web2app()` - Create web app desktop launcher
- [x] Zoxide integration with bash/zsh
- [x] FZF with Tokyo Night colors
- [x] FZF keybindings for ctrl-r, ctrl-t, alt-c

### #40 Ghostty Terminal Improvements 🔴 P0 ✅
- [x] Split pane resize keybinds (Super+Ctrl+Shift+Arrow)
- [x] Mouse scroll multiplier (0.95)
- [x] async-backend = epoll for performance
- [x] Unbind conflicting keybinds for tmux

---

## 🖥️ Tmux Integration

### #41 Tmux Configuration 🔴 P0 ✅
- [x] Create themed `tmux.conf`
- [x] Status bar top position with theme colors
- [x] Vi mode for copy/paste
- [x] Mouse support enabled
- [x] Prefix key: Ctrl+Space
- [x] Split keybinds: | for vertical, - for horizontal

### #42 Tmux Dev Layouts 🟡 P1 ✅
- [x] `tml` function - Create tmux layout (web/api/k8s)
- [x] `nic` function - New session named after current directory
- [x] `nicx` function - nic with web layout applied
- [x] Auto-attach or create session

---

## 🎨 Theme System Expansion

### Existing Themes ✅ (Already Implemented)
Located in `themes/` directory:
- [x] **Tokyo Night** - Purple-blue dark theme (default)
  - [x] Ghostty colors (`ghostty.conf`)
  - [x] Starship prompt (`starship.toml`)
  - [x] VS Code settings (`vscode-settings.json`)
- [x] **Ghostty Blue** - Blue-focused dark theme
  - [x] Ghostty colors
  - [x] Starship prompt
  - [x] VS Code settings

### #43 Gruvbox Theme 🔴 P0 ✅
- [x] Ghostty colors
- [x] Starship colors
- [x] VS Code settings (Gruvbox extension)
- [x] btop theme
- [x] tmux theme
- [ ] Wallpapers (3+)
- [ ] GNOME accent color

### #44 Catppuccin Theme 🔴 P0 ✅
- [x] Ghostty colors (Mocha variant)
- [x] Starship colors
- [x] VS Code settings (Catppuccin extension)
- [x] btop theme
- [x] tmux theme
- [ ] Wallpapers (3+)
- [ ] GNOME accent color

### #45 Nord Theme 🔴 P0 ✅
- [x] Ghostty colors
- [x] Starship colors
- [x] VS Code settings (Nord extension)
- [x] btop theme
- [x] tmux theme
- [ ] Wallpapers (3+)
- [ ] GNOME accent color

### #46 Rose Pine Theme 🟡 P1 ✅
- [x] Ghostty colors
- [x] Starship colors
- [x] VS Code settings (Rose Pine extension)
- [x] btop theme
- [x] tmux theme
- [ ] Wallpapers (3+)
- [ ] GNOME accent color

### #47 Additional Themes 🟢 P2
- [ ] Everforest - Nature-inspired greens
- [ ] Kanagawa - Japanese-inspired
- [ ] Miasma - Dark earthy tones
- [ ] Vantablack - Pure black OLED
- [ ] Flexoki - Warm neutral
- [ ] Flexoki Light - Light variant
- [ ] Catppuccin Latte - Light variant
- [ ] Osaka Jade - Jade/green focused
- [ ] Ristretto - Coffee browns
- [ ] Matte Black - Subtle blacks
- [ ] Ethereal - Dreamy pastels

### #48 Theme Hot-Swap 🟡 P1 ✅
- [x] Refresh components without logout
- [x] `kodra-refresh-terminal` post theme switch
- [x] `kodra-refresh-starship` post theme switch
- [x] Script to reload VS Code theme
- [x] Reload btop with new theme

### #49 Multiple Wallpapers Per Theme 🟡 P1 ✅
- [x] Theme-specific wallpaper directories (wallpapers/<theme>/)
- [x] `kodra wallpaper next` - Cycle wallpapers
- [x] `kodra wallpaper prev` - Previous wallpaper
- [x] `kodra wallpaper list` - Show available
- [x] `kodra wallpaper set <name>` - Set specific
- [x] `kodra wallpaper theme` - List theme-specific wallpapers

### #50 Visual Wallpaper Picker 🟢 P2
- [ ] Interactive wallpaper selection dialog
- [ ] Thumbnail previews (zenity/yad)
- [ ] Works with current theme wallpapers

### #51 btop Theme Sync 🔴 P0 ✅
- [x] btop config exists with Tokyo Night theme
- [x] Create btop theme for each Kodra theme
- [x] Auto-apply btop theme on theme switch
- [x] Match terminal color palette

### #52 nvim Colorscheme Sync 🟡 P1 ✅
- [x] Auto-install nvim colorscheme plugins
- [x] Set colorscheme on theme switch
- [x] LazyVim integration

### #53 Theme Template System 🟢 P2
- [ ] Template files with color placeholders
- [ ] `colors.toml` per theme with palette
- [ ] Generator script from template + colors
- [ ] Documentation for creating themes

---

## 🛠️ Kodra Commands

### Existing Kodra Commands ✅ (Already Implemented)
The following commands exist in `bin/kodra` and `bin/kodra-sub/`:
- [x] `kodra theme [name]` - Switch themes (interactive if no name)
- [x] `kodra wallpaper [name]` - Change wallpaper
- [x] `kodra desktop [cmd]` - Configure desktop (setup, refresh, dock, extensions)
- [x] `kodra motd [style]` - Set terminal banner (banner, minimal, none)
- [x] `kodra setup` - Run first-time setup (GitHub, Azure, Git)
- [x] `kodra fetch` - Show beautiful system info (fastfetch)
- [x] `kodra update` - Update Kodra and installed packages
- [x] `kodra install <app>` - Install additional applications
- [x] `kodra uninstall <app>` - Remove applications
- [x] `kodra repair` - Re-apply all configs without reinstalling
- [x] `kodra restore` - Restore backed up dotfiles
- [x] `kodra resume` - Resume incomplete installation
- [x] `kodra doctor` - Check system health
- [x] `kodra welcome` - Show first-run welcome screen
- [x] `kodra version` - Show version and current theme
- [x] `kodra help` - Show help message

### #54 `kodra menu` 🔴 P0 ✅
- [x] Interactive gum-based main menu
- [x] Nested submenus for categories
- [x] Options: Theme, Wallpaper, Install, Update, System
- [x] Keyboard navigation
- [x] Color-coded by category

### #55 `kodra shortcuts` 🔴 P0 ✅
- [x] Display all GNOME keybindings
- [x] Parse gsettings for custom shortcuts
- [x] Format as readable table
- [x] Group by category
- [x] Search/filter option

### #56 `kodra font` 🟡 P1 ✅
- [x] `kodra font list` - Show available Nerd Fonts
- [x] `kodra font set <name>` - Change all fonts
- [x] Update Ghostty font
- [x] Update GNOME monospace font
- [x] Verify font exists before applying

### #57 `kodra screenshot` 🟡 P1 ✅
- [x] `kodra screenshot` - Full screen
- [x] `kodra screenshot region` - Area selection
- [x] `kodra screenshot window` - Active window
- [x] `kodra screenshot delay` - Delayed capture
- [x] Use gnome-screenshot or scrot
- [x] Copy to clipboard + save to file

### #58 `kodra screenrecord` 🟢 P2
- [ ] `kodra screenrecord start` - Begin recording
- [ ] `kodra screenrecord stop` - End recording
- [ ] Options: with/without audio
- [ ] Integration with OBS or simplescreenrecorder

### #59 `kodra colorpicker` 🟢 P2
- [ ] Pick color from screen
- [ ] Copy HEX to clipboard
- [ ] Use gpick or gcolor3

### #60 `kodra power` 🔴 P0 ✅
- [x] `kodra power` - Show current profile
- [x] `kodra power performance` - Set performance
- [x] `kodra power balanced` - Set balanced
- [x] `kodra power saver` - Set power saver
- [x] Use powerprofilesctl

### #61 `kodra nightlight` 🔴 P0 ✅
- [x] `kodra nightlight` - Toggle on/off
- [x] `kodra nightlight on` - Enable
- [x] `kodra nightlight off` - Disable
- [x] `kodra nightlight temp <K>` - Set temperature
- [x] Use gsettings for GNOME Night Light

### #62 System Power Commands 🟡 P1 ✅
- [x] `kodra lock` - Lock screen
- [x] `kodra suspend` - Suspend system
- [ ] `kodra hibernate` - Hibernate (if enabled)
- [x] `kodra restart` - Restart system
- [x] `kodra shutdown` - Shutdown system

### #63 `kodra wifi` 🟢 P2
- [ ] `kodra wifi list` - Show networks
- [ ] `kodra wifi connect <ssid>` - Connect
- [ ] `kodra wifi disconnect` - Disconnect
- [ ] `kodra wifi status` - Show current
- [ ] Use nmcli

### #64 `kodra bluetooth` 🟢 P2
- [ ] `kodra bluetooth list` - Show devices
- [ ] `kodra bluetooth connect <device>` - Connect
- [ ] `kodra bluetooth disconnect` - Disconnect
- [ ] `kodra bluetooth status` - Show status
- [ ] Use bluetoothctl

### #65 `kodra brightness` 🟢 P2
- [ ] `kodra brightness` - Show current
- [ ] `kodra brightness <0-100>` - Set level
- [ ] `kodra brightness up` - Increase
- [ ] `kodra brightness down` - Decrease
- [ ] Use brightnessctl or xrandr

### #66 `kodra volume` 🟢 P2
- [ ] `kodra volume` - Show current
- [ ] `kodra volume <0-100>` - Set level
- [ ] `kodra volume up` - Increase
- [ ] `kodra volume down` - Decrease
- [ ] `kodra volume mute` - Toggle mute
- [ ] Use pactl/pamixer

### #67 `kodra battery` 🟢 P2
- [ ] Show battery percentage
- [ ] Show charging status
- [ ] Show time remaining
- [ ] Use upower

### #68 `kodra cleanup` 🟡 P1 ✅
- [x] Clean apt cache
- [x] Clean snap cache
- [x] Clean flatpak unused runtimes
- [x] Remove orphaned packages
- [x] Clean journal logs
- [x] Clean temp files
- [x] Clean Docker unused data
- [x] Clean Homebrew cache
- [x] Show space reclaimed

### #69 `kodra backup` 🟡 P1 ✅
- [x] Backup system exists (`lib/backup.sh`)
- [x] `kodra restore` command exists
- [x] Backup dotfiles to tarball
- [x] Include: shell, ghostty, starship, vscode settings
- [ ] Exclude secrets
- [x] Timestamp filename

### #70 `kodra status` 🟢 P2
- [ ] System overview
- [ ] Show: CPU, RAM, Disk, Network
- [ ] Show: Kodra version, theme
- [ ] Show: OS version, uptime

### #71 `kodra version` 🔴 P0 ✅
- [x] Show Kodra version
- [x] Show current theme
- [ ] Show Git commit (if dev)
- [ ] Check for updates available

---

## 💻 Development Tools

### #72 Dev Environment Installers 🟡 P1 ✅
- [x] `kodra dev setup ruby` - mise + bundler
- [x] `kodra dev setup node` - mise + npm
- [x] `kodra dev setup python` - mise + pip
- [x] `kodra dev setup go` - mise + go tools
- [x] `kodra dev setup rust` - mise + cargo
- [x] `kodra dev setup java` - mise + java
- [x] `kodra dev setup dotnet` - .NET SDK via mise
- [x] `kodra dev setup deno` - Deno via mise
- [x] `kodra dev setup bun` - Bun via mise
- [x] `kodra dev list` - Show installed runtimes
- [x] Interactive mode with gum

### #73 Docker Database Commands 🟡 P1 ✅
- [x] `kodra db postgres` - Start PostgreSQL container
- [x] `kodra db mysql` - Start MySQL container
- [x] `kodra db redis` - Start Redis container
- [x] `kodra db mongo` - Start MongoDB container
- [x] `kodra db stop <name>` - Stop container
- [x] `kodra db list` - List running DBs
- [x] `kodra db stop-all` - Stop all DBs
- [x] `kodra db clean` - Remove containers and volumes
- [x] Persist data in Docker volumes

### #74 Project Scaffolding 🟢 P2
- [ ] `kodra new rails <name>` - Rails project
- [ ] `kodra new next <name>` - Next.js project
- [ ] `kodra new django <name>` - Django project
- [ ] `kodra new go <name>` - Go project
- [ ] `kodra new rust <name>` - Rust project
- [ ] Auto-initialize git repo
- [ ] Open in VS Code

---

## ℹ️ Fastfetch Enhancement

### #75 Enhanced Fastfetch 🔴 P0 ✅
- [x] Custom Kodra branding/logo
- [x] Sectioned layout (Hardware/Software/Cloud)
- [x] Show current Kodra theme name
- [ ] Show system age (days since install)
- [ ] Show last apt update timestamp
- [x] Show Kodra version

### #76 Fastfetch Customization 🟡 P1
- [x] Custom JSONC config exists
- [ ] Color swatches for current theme
- [ ] User-customizable logo/branding file
- [ ] Better GPU detection
- [ ] Better display/monitor info
- [x] Package count (apt + snap + flatpak)
- [ ] Terminal detection improvement

---

## ⭐ Starship Prompt Enhancement

### #77 Starship Improvements 🟡 P1
- [x] Themed starship configs per theme
- [x] OS icons (Ubuntu, Linux, Windows, macOS)
- [x] Directory truncation
- [x] Docker context display
- [x] Kubernetes context display
- [x] Azure subscription display
- [ ] Minimal mode option (directory + git only)
- [x] Better git status symbols (ahead/behind/diverged)
- [x] Command timeout = 200ms
- [x] AWS profile display
- [x] Terraform workspace display

---

## 📖 Documentation

### #78 AGENTS.md 🔴 P0 ✅
- [x] AI coding agent style guide
- [x] Code style conventions
- [x] Command naming patterns
- [x] File organization
- [x] Testing requirements

### #79 Keybindings Cheatsheet 🟡 P1 ✅
- [x] All GNOME shortcuts documented
- [x] Kodra command reference
- [x] Ghostty keybindings
- [x] tmux keybindings
- [x] Shell aliases and functions
- [ ] Printable PDF version

### #80 Theme Creation Guide 🟡 P1 ✅
- [x] How to create a new theme
- [x] Required files
- [x] Color palette format
- [x] Testing themes
- [x] Contributing themes

---

## 🐧 GNOME Integration

### #81 Extension Management 🟡 P1 ✅
- [ ] Better extension auto-install
- [ ] Extension settings backup/restore
- [x] `kodra extensions list`
- [x] `kodra extensions enable <name>`
- [x] `kodra extensions disable <name>`

### #82 GTK Theme Sync 🟢 P2
- [ ] Match GTK theme to Kodra theme
- [ ] Adwaita-based themes per color scheme
- [ ] Auto-apply on theme switch

### #83 Icon Theme Sync 🟢 P2
- [ ] Match icon theme to Kodra theme
- [ ] Install compatible icon packs
- [ ] Auto-apply on theme switch

### #84 GDM Login Theme 🟢 P2
- [ ] Match login screen to Kodra theme
- [ ] Set login wallpaper
- [ ] Custom GDM styling

### #85 Panel Customization 🟢 P2
- [ ] Dynamic transparency
- [ ] Match panel to theme
- [ ] Custom panel layout

### #86 Touchpad Gestures 🟢 P2
- [ ] Configure 3/4 finger gestures
- [ ] Workspace switching gestures
- [ ] App switching gestures
- [ ] Use libinput-gestures or touchegg

### #87 Keyboard Shortcuts Sync 🟡 P1 ✅
- [x] `kodra shortcuts export` - Export to file
- [x] `kodra shortcuts import` - Import from file
- [ ] Share shortcuts across installs

### #88 dconf Backup 🟡 P1 ✅
- [x] `kodra dconf backup` - Backup all settings
- [x] `kodra dconf restore` - Restore settings
- [ ] Include in full backup

---

## 📦 Installer Enhancements

### #89 Offline Install Support 🟢 P2
- [ ] Bundle dependencies option
- [ ] Downloadable offline package
- [ ] Install from local cache

### #90 Selective Install 🟡 P1 ✅
- [x] Choose components interactively
- [x] Skip categories (--skip-azure, --skip-docker)
- [x] Minimal install profile

### #91 Progress Indicators 🟡 P1
- [ ] Real-time progress bar
- [ ] Current step / total steps
- [ ] Estimated time remaining
- [ ] Component status (installing/done/failed)

### #92 Import from Other Dotfiles 🟢 P2
- [ ] Migration tool from other dotfile managers
- [ ] Import Oh My Zsh config
- [ ] Import Prezto config
- [ ] Preserve user customizations

---

## ✨ Nice-to-Have Features

### #93 `kodra weather` 🟢 P2
- [ ] Show weather in terminal
- [ ] Use wttr.in or openweathermap
- [ ] Cache results

### #94 `kodra todo` 🟢 P2
- [ ] Simple task management
- [ ] `kodra todo add <task>`
- [ ] `kodra todo list`
- [ ] `kodra todo done <n>`
- [ ] Store in ~/.kodra/todo.txt

### #95 `kodra notes` 🟢 P2
- [ ] Quick notes
- [ ] `kodra notes add <note>`
- [ ] `kodra notes list`
- [ ] `kodra notes search <query>`
- [ ] Store in ~/.kodra/notes/

### #96 `kodra time` 🟢 P2
- [ ] World clock / timezones
- [ ] `kodra time <city>`
- [ ] `kodra time list` - Configured cities

### #97 `kodra qr` 🟢 P2
- [ ] QR code generation
- [ ] `kodra qr <text>` - Generate QR
- [ ] `kodra qr scan` - Scan QR from screen

### #98 `kodra ai` 🟢 P2
- [ ] AI assistant integration
- [ ] `kodra ai ask <question>`
- [ ] Use GitHub Copilot CLI or opencode
- [ ] Shell command suggestions

### #99 Auto Power Profile on AC/Battery 🟢 P2
- [ ] Performance when plugged in
- [ ] Balanced/saver on battery
- [ ] udev rule integration

### #100 Battery Low Notification 🟢 P2
- [ ] Desktop notification at low battery
- [ ] Configurable threshold (20%, 10%)
- [ ] Optional auto-hibernate at critical

### #101 Hibernation Setup 🟢 P2
- [ ] `kodra setup hibernate`
- [ ] Create swap file if needed
- [ ] Configure resume hook
- [ ] GRUB configuration

---

## Release Targets

### v0.2.0 (Launch Ready)
- #1 Backup system
- #4 Error handling + resume
- #10 Video demo
- #11 Screenshots
- #23 Enhanced README

### v0.3.0 (Quality)
- #5 Per-component uninstall
- #7 Enhanced doctor command
- #12 Documentation site
- #25 Troubleshooting guide
- #29 Code quality

### v0.3.1 (Stability)
- GNOME 46 compatibility (screenshot shortcuts schema fallback)
- Unified Copilot extension (`github.copilot-chat` replaces deprecated `github.copilot`)
- Resilient installer (component failures tracked, never kill install)
- Fixed needrestart non-interactive configuration
- Fixed progress bar rendering (ASCII-compatible)

### v0.3.2 (Desktop Polish)
- Auto-enable all installed GNOME extensions via gsettings
- 6 extensions enabled by default: Dash to Dock, Blur my Shell, Tactile, TopHat, Alphabetical Grid, Space Bar
- Disabled night light (user can re-enable)
- Disabled extension version validation (no update prompts)
- Improved dock favorites with dconf fallback
- VS Code Tokyo Night theme auto-applied with extensions

### v0.4.0 (Shell Enhancement)
- #34 Tab-cycle completion
- #35 Dynamic theme loading  
- #36 Enhanced shell aliases
- #40 Ghostty improvements
- #51 btop theme sync

### v0.5.0 (Themes)
- #43 Gruvbox theme
- #44 Catppuccin theme
- #45 Nord theme
- #46 Rose Pine theme
- #49 Multiple wallpapers per theme

### v0.6.0 (Commands)
- #54 kodra menu
- #55 kodra shortcuts
- #60 kodra power
- #61 kodra nightlight
- #71 kodra version

### v0.7.0 (Tmux & Dev)
- #41 Tmux configuration
- #42 Tmux dev layouts
- #72 Dev environment installers
- #73 Docker database commands

### v0.8.0 (Features)
- #8 ARM support
- #18 Configuration profiles
- #19 Shell completions
- #20 Update notifications
- #75 Enhanced fastfetch

### v0.9.0 (Polish)
- #47 Additional themes (5+)
- #56 kodra font
- #57 kodra screenshot
- #77 Starship improvements
- #78 AGENTS.md

### v1.0.0 (Stable)
- All P0/P1 complete
- Comprehensive docs
- Production-ready stability
- 10+ themes available
- Full command suite
