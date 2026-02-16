<div align="center">

```
    ██╗  ██╗ ██████╗ ██████╗ ██████╗  █████╗ 
    ██║ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗
    █████╔╝ ██║   ██║██║  ██║██████╔╝███████║
    ██╔═██╗ ██║   ██║██║  ██║██╔══██╗██╔══██║
    ██║  ██╗╚██████╔╝██████╔╝██║  ██║██║  ██║
    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
```

**One-command Ubuntu setup for Azure cloud-native developers. GitHub CLI, Docker, Kubernetes, AI-powered workflows. From fresh install to production in minutes.**

[![Version](https://img.shields.io/badge/version-0.3.2-blue?style=flat-square)](VERSION)
[![CI](https://img.shields.io/github/actions/workflow/status/codetocloudorg/kodra/ci.yml?branch=main&style=flat-square&label=CI)](https://github.com/codetocloudorg/kodra/actions)
[![Ubuntu 24.04+](https://img.shields.io/badge/Ubuntu-24.04+-E95420?style=flat-square&logo=ubuntu&logoColor=white)](https://releases.ubuntu.com/noble/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/vwfwq2EpXJ)
[![GitHub stars](https://img.shields.io/github/stars/codetocloudorg/kodra?style=flat-square&logo=github)](https://github.com/codetocloudorg/kodra/stargazers)
[![GitHub last commit](https://img.shields.io/github/last-commit/codetocloudorg/kodra?style=flat-square)](https://github.com/codetocloudorg/kodra/commits/main)

*Developed by [Code To Cloud](https://www.codetocloud.io)*

</div>

---

**That's the pitch.** No more hunting for tools, configuring extensions, or figuring out which CLI utilities matter. Kodra is an opinionated Ubuntu setup for engineers who build and deploy on **Azure**—with **GitHub CLI** and **AI agentic workflows** baked in.

GitHub CLI (`gh`) is the backbone of Kodra's agentic development experience. Combined with Copilot CLI, you can ask questions, generate code, create PRs, and manage repos—all from your terminal. Whether you're deploying to AKS, authoring Bicep templates, or letting AI suggest your next command—Kodra gets you from fresh install to `azd up` in minutes.

## Why Ubuntu?

We chose Ubuntu as our foundation for good reasons:

| Reason | Why It Matters |
|--------|----------------|
| 🌍 **Massive Community** | 40M+ users, endless tutorials, instant answers on Stack Overflow |
| 📚 **Lower Learning Curve** | Most beginner-friendly Linux distro with polished desktop experience |
| ☁️ **Azure Native Support** | First-class support in Azure VMs, WSL, and all major cloud tools |
| 🔒 **LTS Stability** | 5 years of security updates—no surprise breakages mid-project |

> **🎉 NEW:** WSL edition is now available for Windows developers! All CLI tools, Azure integrations, and GitHub Copilot—right in Windows Terminal. [Get started →](https://kodra.wsl.codetocloud.io)

## Quick Start

```bash
wget -qO- https://kodra.codetocloud.io/boot.sh | bash
```

That's it. The installer will:
1. Install everything you need for Azure and cloud-native development
2. Let you pick a theme and optional apps
3. Configure your desktop with window tiling, keyboard shortcuts, and a macOS-style dock

---

<div align="center">

### See it in action

| Desktop | Desktop Manager | Terminal |
|:-------:|:---------------:|:--------:|
| <img src="assets/kodra-tools.png" alt="Desktop" width="280"> | <img src="assets/kodra-desktop.png" alt="Desktop Manager" width="280"> | <img src="assets/kodra-terminal.png" alt="Terminal" width="280"> |
| bat • eza • btop • lazygit | GNOME • Blur • Dash to Dock | Ghostty • fastfetch • Starship |

<sub>Tokyo Night theme • Nerd Fonts • 40+ cloud-native tools pre-configured</sub>

</div>

---

## What You Get

| Category | Tools |
|----------|-------|
| **Terminal** | [Ghostty](https://ghostty.org) + [Starship](https://starship.rs) prompt + Nerd Fonts |
| **Editor** | VS Code with [Tokyo Night](https://github.com/tokyo-night/tokyo-night-vscode-theme) theme + 15 essential extensions + Neovim |
| **Cloud** | Azure CLI, azd, Bicep, Terraform, OpenTofu, PowerShell 7 |
| **Kubernetes** | kubectl, Helm, k9s |
| **Containers** | Docker CE, lazydocker, Dev Containers support |
| **Git & GitHub** | **GitHub CLI** (`gh`), GitHub Desktop, lazygit, GitLens |
| **AI Agentic** | GitHub Copilot CLI—ask `??` or run `copilot` for interactive AI |
| **CLI** | bat, eza, fzf, ripgrep, zoxide, btop, fastfetch, jq, yq |
| **Desktop** | ULauncher, window tiling, system monitor, blur effects |

> 📋 **[Full Cheat Sheet](docs/CHEATSHEET.md)** — All aliases, keyboard shortcuts, and keybindings

## Commands

```bash
kodra theme       # Switch themes (tokyo-night, ghostty-blue)
kodra wallpaper   # Browse and set wallpapers
kodra desktop     # Configure dock, tiling, login screen
kodra dock        # Set dock favorites
kodra motd        # Set terminal banner (banner, minimal, none)
kodra setup       # Re-run first-time setup (GitHub, Azure login)
kodra fetch       # Show system info (beautiful fastfetch)
kodra doctor      # Check system health
kodra update      # Update everything
```

## Themes

Two beautiful themes that sync across terminal, editor, and desktop:

| Theme | Vibe |
|-------|------|
| 🌃 **Tokyo Night** | Purple-blue Tokyo city lights |
| 💙 **Ghostty Blue** | Deep navy with electric cyan |

## Keyboard Shortcuts & Aliases

Kodra includes 50+ shell aliases and keyboard shortcuts for productivity. Here are some highlights:

### Desktop Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super + Space` | App launcher (Ulauncher) |
| `Super + Return` | Open terminal |
| `Super + T` | Window tiling grid |
| `Super + ←/→` | Tile left/right half |
| `Shift + Super + 3/4/5` | Screenshots (macOS-style) |

### Shell Aliases

| Alias | What it does |
|-------|--------------|
| `??` | Ask GitHub Copilot for shell commands (agentic AI) |
| `ghpr` | Create a PR via GitHub CLI |
| `lg` | Launch lazygit TUI |
| `lzd` | Launch lazydocker TUI |
| `gs`, `ga`, `gc`, `gp` | Git shortcuts |
| `azd-up` | Deploy to Azure |
| `tf`, `tfi`, `tfp`, `tfa` | Terraform shortcuts |

> 📋 **[Full Cheat Sheet](docs/CHEATSHEET.md)** — Complete reference for all aliases, keybindings, and shortcuts

## Customization

```bash
# Skip specific apps
KODRA_SKIP="spotify,discord" ./install.sh

# Pre-select theme
KODRA_THEME="ghostty-blue" ./install.sh

# Minimal install (no optional apps)
KODRA_MINIMAL=1 ./install.sh

# Debug mode (continue on errors, show summary)
./install.sh --debug
```

## Uninstall

```bash
# Interactive uninstall
wget -qO- https://kodra.codetocloud.io/boot.sh | bash

# Or directly
bash ~/.kodra/uninstall.sh
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on reporting issues, suggesting features, and submitting pull requests.

See [docs/ROADMAP.md](docs/ROADMAP.md) for the development roadmap and planned features.

## License

Kodra is released under the [MIT License](LICENSE).

---

## Extras

While Kodra is purposefully opinionated, the community offers additional customizations you can layer on top:

| Extra | Description |
|-------|-------------|
| **Your theme** | Add themes to `~/.kodra/themes/` following existing structure |
| **Your wallpapers** | Drop images in `~/.kodra/wallpapers/` |
| **Shell aliases** | Edit `~/.kodra/configs/shell/kodra.sh` |
| **VS Code extensions** | `code --install-extension <id>` |

**Community extras** (coming soon):
- Additional themes from the community
- Language-specific tool packs
- Alternative terminal configs

Want to contribute an extra? Open a PR or share in [Discord](https://discord.gg/vwfwq2EpXJ).

---

<div align="center">

[![Discord](https://img.shields.io/badge/Discord-Join_Us-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/vwfwq2EpXJ)
[![GitHub](https://img.shields.io/badge/GitHub-codetocloudorg-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/codetocloudorg)

**[kodra.codetocloud.io](https://kodra.codetocloud.io)**

*Developed by [Code To Cloud](https://www.codetocloud.io)*

</div>
