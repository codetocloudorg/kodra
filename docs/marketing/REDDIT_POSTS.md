# Reddit Posts

Ready-to-post content for various subreddits.

---

## r/Azure

**Title:**
```
I made a one-command Ubuntu setup for Azure development (CLI, azd, Terraform, Bicep, k8s tools)
```

**Body:**
```
Hey r/Azure!

I got tired of manually setting up Ubuntu VMs for Azure work, so I built Kodra - a single command that installs and configures everything:

wget -qO- https://kodra.codetocloud.io/boot.sh | bash

What's included for Azure:
- Azure CLI + Azure Developer CLI (azd)
- Bicep + Terraform + OpenTofu  
- kubectl, Helm, k9s for AKS
- GitHub CLI with Copilot CLI
- Docker CE with Dev Containers

Plus a beautiful terminal with Starship prompt that shows your current Azure subscription context.

It's free, open source (MIT), and works on both native Ubuntu and WSL.

GitHub: https://github.com/codetocloudorg/kodra

Would love to hear what other Azure tools you'd want included!
```

---

## r/Ubuntu

**Title:**
```
Kodra: One-command developer environment setup for Ubuntu 24.04 (40+ tools auto-configured)
```

**Body:**
```
Hey Ubuntu community!

I built Kodra to solve my "new VM setup hell" problem. It's a single command that turns a fresh Ubuntu 24.04 install into a fully-configured development environment:

wget -qO- https://kodra.codetocloud.io/boot.sh | bash

Includes:
- Modern terminal: Ghostty + Starship + Nerd Fonts
- CLI tools: bat, eza, fzf, ripgrep, zoxide, btop, lazygit
- Containers: Docker CE + lazydocker
- Cloud: Azure CLI, Terraform, kubectl, Helm
- Git: GitHub CLI, GitHub Desktop, GitLens
- AI: GitHub Copilot CLI (ask `??` for help)

Plus GNOME customization with a macOS-style dock, window tiling, and keyboard shortcuts.

Two themes included: Tokyo Night and Ghostty Blue.

Free, MIT licensed: https://github.com/codetocloudorg/kodra

What tools would you add?
```

---

## r/devops

**Title:**
```
Built a one-liner to setup complete DevOps toolchain on Ubuntu (Terraform, K8s, Docker, Azure CLI)
```

**Body:**
```
Just released Kodra - a single command to turn fresh Ubuntu into a DevOps workstation:

wget -qO- https://kodra.codetocloud.io/boot.sh | bash

The toolchain:
- IaC: Terraform, OpenTofu, Bicep
- Containers: Docker CE, lazydocker
- Kubernetes: kubectl, Helm, k9s
- Cloud: Azure CLI, azd
- Git: GitHub CLI, lazygit
- Plus 30+ CLI tools (bat, eza, fzf, etc.)

Use case: consistent dev environments across team VMs, quick cloud shell alternatives, WSL setups.

It's opinionated (Azure-focused) but all the tools work for any cloud.

MIT licensed: https://github.com/codetocloudorg/kodra

Curious what your ideal DevOps workstation setup looks like?
```

---

## r/commandline

**Title:**
```
40+ CLI tools, one command: bat, eza, fzf, ripgrep, lazygit, and more for Ubuntu
```

**Body:**
```
Made something for CLI enthusiasts - Kodra sets up a modern terminal environment on Ubuntu:

wget -qO- https://kodra.codetocloud.io/boot.sh | bash

CLI tools included:
- bat (better cat), eza (better ls), fd (better find)
- fzf (fuzzy finder), ripgrep (fast grep)
- zoxide (smarter cd), delta (better diff)
- btop (system monitor), lazygit (git TUI)
- lazydocker (docker TUI), yq/jq (YAML/JSON)
- Starship prompt with Nerd Fonts
- Ghostty terminal (GPU accelerated)

Plus GitHub Copilot CLI - type `??` for AI shell help:
?? how do I find files larger than 100mb

Everything pre-configured with sensible defaults.

MIT licensed: https://github.com/codetocloudorg/kodra

What CLI tools can't you live without?
```

---

## Posting Tips

1. **Best times**: Tuesday-Thursday, 9-11 AM EST
2. **Engage**: Reply to every comment within first 2 hours
3. **Don't spam**: Wait at least 1 week between posts to different subreddits
4. **Be humble**: Ask for feedback, don't just promote
5. **Follow rules**: Check each subreddit's self-promotion rules
