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

### #5 Uninstall Scripts per Component 🟡 P1
- [ ] Create `uninstall/` mirroring `install/`
- [ ] Each install has matching uninstall
- [ ] Interactive uninstall menu
- [ ] Options: uninstall all, by category, specific tool
- [ ] Option to keep or remove configs
- [ ] Restore backed up dotfiles
- [ ] Add `--dry-run` flag

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

---

## 🎨 Website

### #10 Video Demonstration 🔴 P0
- [ ] Record 2-3 min demo video
- [ ] Show fresh Ubuntu → themed desktop
- [ ] Demo Azure CLI, Docker, k9s
- [ ] Host on YouTube
- [ ] Add "Watch Demo" button to site
- [ ] Create GIF preview for README

### #11 Screenshot Gallery 🔴 P0
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
- [ ] Add meta tags (title, description, OG)
- [ ] Add structured data (JSON-LD)
- [ ] Submit to Google Search Console
- [ ] Add analytics (Plausible)

### #15 Social Proof & Testimonials 🟢 P2
- [ ] Add testimonials section
- [ ] GitHub star count widget
- [ ] Discord member count
- [ ] "As used by" section

### #16 Landing Page Improvements 🟡 P1
- [ ] Add hero section with video/screenshot
- [ ] "How It Works" 3-step section
- [ ] "Why Kodra?" benefits section
- [ ] FAQ section
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

### #19 Shell Completions 🟢 P2
- [ ] Bash completion for `kodra`
- [ ] Zsh completion for `kodra`
- [ ] Tab complete themes, commands
- [ ] Install completions during setup

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
- [ ] How to report bugs
- [ ] How to add new tools
- [ ] How to create themes
- [ ] Code style guide
- [ ] Development setup

### #25 Troubleshooting Guide 🟡 P1
- [ ] Installation failures
- [ ] Azure CLI login issues
- [ ] Docker permission issues
- [ ] Theme not applying
- [ ] GNOME extension issues
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

### #33 Security Audit 🟡 P1
- [ ] Review all download URLs (HTTPS only)
- [ ] Verify GPG signatures on packages
- [ ] Don't run scripts with eval
- [ ] Sanitize user input
- [ ] Don't store credentials
- [ ] Add SECURITY.md
- [ ] Set up Dependabot

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

### v0.4.0 (Features)
- #8 ARM support
- #18 Configuration profiles
- #19 Shell completions
- #20 Update notifications

### v1.0.0 (Stable)
- All P0/P1 complete
- Comprehensive docs
- Production-ready stability
