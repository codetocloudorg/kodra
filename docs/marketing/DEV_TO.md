---
title: I Built a One-Command Azure Developer Environment for Ubuntu
published: true
description: How Kodra sets up 40+ cloud-native tools with a single wget command
tags: azure, ubuntu, devops, productivity
cover_image: https://kodra.codetocloud.io/assets/kodra-desktop.png
canonical_url: https://kodra.codetocloud.io
---

# I Built a One-Command Azure Developer Environment for Ubuntu

Every time I spun up a new Ubuntu VM for cloud development, I spent hours:

- Installing Azure CLI, Terraform, kubectl, Helm...
- Setting up Docker and fixing permissions
- Configuring VS Code extensions
- Making the terminal not look like it's from 1995

Sound familiar?

## The Problem

I have a confession: I've written the same `apt install` commands dozens of times. I've forgotten to add my user to the docker group more times than I can count. And don't get me started on making fonts look good in the terminal.

Every project starts the same way: VM → 2 hours of setup → finally ready to code.

## The Solution: Kodra

I built [Kodra](https://kodra.codetocloud.io)—a single command that transforms a fresh Ubuntu install into a complete cloud-native development environment:

```bash
wget -qO- https://kodra.codetocloud.io/boot.sh | bash
```

That's it. 10-15 minutes later, you have:

### ☁️ Cloud & Infrastructure
- **Azure CLI** + **Azure Developer CLI (azd)**
- **Terraform**, **Bicep**, **OpenTofu**
- **kubectl**, **Helm**, **k9s**
- **Docker CE** with Dev Containers support

### 🤖 AI-Powered Development
- **GitHub CLI** with **Copilot CLI**
- Type `??` in terminal for AI shell assistance
- Ask questions, get commands, understand errors

### 💻 Modern Terminal
- **Ghostty** terminal (GPU-accelerated, beautiful)
- **Starship** prompt with git status, Azure context
- **Nerd Fonts** built-in

### 🛠️ Developer Tools
- **VS Code** with 15 cloud-native extensions
- **lazygit**, **lazydocker** for TUI lovers
- **bat**, **eza**, **fzf**, **ripgrep**, **zoxide**

## Why Ubuntu?

| Reason | Why It Matters |
|--------|----------------|
| 🌍 Massive Community | 40M+ users, endless tutorials |
| ☁️ Azure Native | First-class support in Azure VMs and WSL |
| 🔒 LTS Stability | 5 years of security updates |

## See It In Action

![Kodra Desktop](https://kodra.codetocloud.io/assets/kodra-desktop.png)

## What About WSL?

Yes! There's a dedicated WSL edition:

```bash
# On Windows with WSL
wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash
```

All the CLI tools, right in Windows Terminal.

## It's Opinionated (And That's OK)

Kodra isn't trying to be everything to everyone. It's designed for:
- Azure cloud-native development
- People who use GitHub
- Developers who appreciate good tooling

If that's you, give it a try.

## Getting Started

```bash
# One command to install
wget -qO- https://kodra.codetocloud.io/boot.sh | bash

# Useful commands after install
kodra theme           # Change themes
kodra desktop refresh # Fix dock/extensions
kodra update         # Update everything
kodra fetch          # Show system info
```

## Open Source

Kodra is 100% free and open source under MIT License.

- 🌐 Website: [kodra.codetocloud.io](https://kodra.codetocloud.io)
- 📦 GitHub: [github.com/codetocloudorg/kodra](https://github.com/codetocloudorg/kodra)
- 💬 Discord: [Join the community](https://discord.gg/vwfwq2EpXJ)

---

What tools would you add? What's missing from your ideal dev environment? Let me know in the comments!
