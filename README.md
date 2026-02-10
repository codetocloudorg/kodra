<div align="center">

```
    ██╗  ██╗ ██████╗ ██████╗ ██████╗  █████╗ 
    ██║ ██╔╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗
    █████╔╝ ██║   ██║██║  ██║██████╔╝███████║
    ██╔═██╗ ██║   ██║██║  ██║██╔══██╗██╔══██║
    ██║  ██╗╚██████╔╝██████╔╝██║  ██║██║  ██║
    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
```

**Agentic Azure engineering using cloud-native tools—one command to ship.**

[![Version](https://img.shields.io/badge/version-0.2.7-blue?style=flat-square)](VERSION)
[![CI](https://img.shields.io/github/actions/workflow/status/codetocloudorg/kodra/ci.yml?branch=main&style=flat-square&label=CI)](https://github.com/codetocloudorg/kodra/actions)
[![Ubuntu 24.04+](https://img.shields.io/badge/Ubuntu-24.04+-E95420?style=flat-square&logo=ubuntu&logoColor=white)](https://releases.ubuntu.com/noble/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-Join-5865F2?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/vwfwq2EpXJ)

*Developed by [Code To Cloud](https://www.codetocloud.io)*

</div>

---

**That's the pitch.** No more hunting for tools, configuring extensions, or figuring out which CLI utilities matter. Kodra is an opinionated Ubuntu setup for engineers who build and deploy on **Azure**—with AI assistance baked in.

Whether you're deploying to AKS, authoring Bicep templates, or shipping containers with GitHub Copilot suggesting your next command—Kodra gets you from fresh install to `azd up` in minutes.

## Why Ubuntu?

We chose Ubuntu as our foundation for good reasons:

| Reason | Why It Matters |
|--------|----------------|
| 🌍 **Massive Community** | 40M+ users, endless tutorials, instant answers on Stack Overflow |
| 📚 **Lower Learning Curve** | Most beginner-friendly Linux distro with polished desktop experience |
| ☁️ **Azure Native Support** | First-class support in Azure VMs, WSL, and all major cloud tools |
| 🔒 **LTS Stability** | 5 years of security updates—no surprise breakages mid-project |

> **🚀 Coming Soon:** Fedora (for bleeding-edge users) and Arch (for the customization-obsessed) editions are in active development. [Join our Discord](https://discord.gg/vwfwq2EpXJ) to get notified!

## Quick Start

```bash
curl -fsSL https://kodra.codetocloud.io/boot.sh | bash
```

> **Alternative:** If curl isn't available, use wget:
> ```bash
> wget -qO- https://kodra.codetocloud.io/boot.sh | bash
> ```

That's it. The installer will:
1. Show a beautiful menu (install, update, or uninstall)
2. Let you pick a theme and optional apps
3. Install everything you need for Azure and cloud-native development
4. Configure your desktop with window tiling, keyboard shortcuts, and a macOS-style dock

## What You Get

| Category | Tools |
|----------|-------|
| **Terminal** | [Ghostty](https://ghostty.org) + [Starship](https://starship.rs) prompt + Nerd Fonts |
| **Editor** | VS Code with 12 essential extensions |
| **Cloud** | Azure CLI, azd, Bicep, Terraform, OpenTofu, PowerShell 7 |
| **Kubernetes** | kubectl, Helm, k9s |
| **Containers** | Docker CE, lazydocker, Dev Containers support |
| **Git** | GitHub CLI, GitHub Desktop, lazygit, GitLens |
| **AI** | GitHub Copilot + Copilot CLI (`gh copilot suggest`) |
| **CLI** | bat, eza, fzf, ripgrep, zoxide, btop, jq, yq |
| **Desktop** | Window tiling (Tactile), macOS-style dock, dark theme |

## Commands

```bash
kodra theme       # Switch themes (tokyo-night, ghostty-blue)
kodra wallpaper   # Browse and set wallpapers
kodra desktop     # Configure dock, tiling, login screen
kodra setup       # Re-run first-time setup (GitHub, Azure login)
kodra fetch       # Show system info
kodra doctor      # Check system health
kodra update      # Update everything
```

## Themes

Two beautiful themes that sync across terminal, editor, and desktop:

| Theme | Vibe |
|-------|------|
| 🌃 **Tokyo Night** | Purple-blue Tokyo city lights |
| 💙 **Ghostty Blue** | Deep navy with electric cyan |

## Window Tiling

Rectangle/Magnet-style tiling via Tactile extension:

| Shortcut | Action |
|----------|--------|
| `Super + T` | Show tiling grid |
| `Super + ←/→` | Tile left/right half |
| `Ctrl + Super + ←/→/↑/↓` | Tile to edges |
| `Ctrl + Alt + U/I/J/K` | Tile to corners |

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
