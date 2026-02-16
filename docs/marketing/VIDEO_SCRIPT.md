# YouTube Video Script: Kodra Demo

## Video Metadata

**Title (SEO Optimized)**:
```
Setup Azure Developer Environment in 10 Minutes | Kodra One-Command Install
```

**Alternative Titles**:
- "One Command to Install 40+ Developer Tools on Ubuntu"
- "Azure + Docker + Kubernetes Setup Made Easy | Kodra"
- "My Ubuntu Developer Setup in One Command (Kodra Tutorial)"

**Description**:
```
Learn how to set up a complete Azure cloud-native developer environment on Ubuntu with a single command using Kodra.

🔗 Website: https://kodra.codetocloud.io
📦 GitHub: https://github.com/codetocloudorg/kodra
💬 Discord: https://discord.gg/vwfwq2EpXJ

⏱️ TIMESTAMPS:
0:00 - Why I Built Kodra
0:45 - Installation Demo
2:30 - What's Included
4:00 - Terminal Features
5:30 - GitHub Copilot CLI Demo
6:30 - Customization Options
7:30 - WSL Support
8:00 - Getting Started

📋 TOOLS INCLUDED:
- Azure CLI, azd, Bicep, Terraform
- Docker CE, kubectl, Helm, k9s
- GitHub CLI with Copilot CLI
- VS Code with 15 extensions
- Ghostty terminal + Starship prompt
- 40+ CLI tools (bat, eza, fzf, etc.)

#Azure #Ubuntu #DevOps #CloudNative #DeveloperTools #GitHubCopilot
```

**Tags**:
```
azure cli, ubuntu setup, developer environment, devops tools, kubernetes, docker, terraform, github copilot, one command install, cloud native, azd, bicep, developer productivity, linux setup, wsl
```

---

## Script

### [0:00 - 0:45] HOOK & INTRO

**[Show frustrated typing on terminal]**

"Every time I spin up a new Ubuntu VM, I spend the next two hours doing this..."

**[Quick montage of apt install commands, downloading configs, fixing errors]**

"Installing Azure CLI... Docker... Terraform... kubectl... fixing terminal fonts... configuring VS Code extensions..."

**[Cut to clean shot]**

"I got tired of it. So I built Kodra - a single command that does all of this:"

**[Terminal, type slowly]**
```bash
wget -qO- https://kodra.codetocloud.io/boot.sh | bash
```

"Let me show you what happens."

---

### [0:45 - 2:30] INSTALLATION DEMO

**[Fresh Ubuntu VM screen]**

"Here's a completely fresh Ubuntu 24.04 installation. Nothing installed. Let's run the command."

**[Run the command, show progress]**

"You'll pick a theme... select any optional apps like Spotify or Discord..."

**[Speed up footage, show progress bar]**

"And it starts installing. This takes about 10-15 minutes depending on your connection, but watch what happens."

**[Montage with captions showing what's installing]**
- "Installing Azure CLI..."
- "Setting up Docker CE..."
- "Configuring kubectl & Helm..."
- "Adding 40+ CLI tools..."

**[Show completion screen]**

"And we're done. Let me log out and back in to activate everything."

---

### [2:30 - 4:00] WHAT'S INCLUDED

**[Clean desktop shot with dock visible]**

"So what do we actually get? Let me break it down."

**[Show terminal, run: kodra fetch]**

"First, the terminal. This is Ghostty - a GPU-accelerated terminal that's incredibly fast. The prompt is Starship, showing my git branch, Azure subscription, and more."

**[Open VS Code]**

"VS Code comes pre-configured with 15 extensions for cloud development - Azure tools, Docker, GitLens, and more."

**[Terminal commands]**

"For CLI tools, we've got the essentials:
- `az` for Azure CLI, `azd` for Azure Developer CLI
- `terraform` and `bicep` for infrastructure
- `kubectl`, `helm`, and `k9s` for Kubernetes
- `docker` with lazydocker for a TUI"

**[Show: bat file.txt, eza -la, fzf demo]**

"And 30+ modern CLI replacements - bat instead of cat, eza instead of ls, fzf for fuzzy finding everything."

---

### [4:00 - 5:30] TERMINAL FEATURES

**[Terminal focused]**

"Let me show you some productivity boosts."

**[Run: lg]**

"lg opens lazygit - a terminal UI for git. Stage changes, write commits, push, all with keyboard."

**[Run: lzd]**

"lzd is lazydocker - see all your containers, logs, stats in a TUI."

**[Show zoxide]**

"z lets you jump to any directory you've visited before:"

```bash
z kodra    # jumps to ~/.kodra even from anywhere
```

**[Show fzf integration]**

"And fuzzy search is everywhere. Ctrl+R for command history, Ctrl+T for files."

---

### [5:30 - 6:30] GITHUB COPILOT CLI DEMO

**[New terminal, excited tone]**

"But here's my favorite feature. GitHub Copilot CLI."

**[Type slowly]**

```bash
?? how do I find all files larger than 100mb
```

**[Show Copilot suggestion]**

"Just type two question marks and ask anything. Copilot gives you the exact command."

**[More examples]**

```bash
?? list all docker containers sorted by memory usage
?? kubectl get pods that are crashlooping
```

"It's like having an expert next to you, all the time."

---

### [6:30 - 7:30] CUSTOMIZATION

**[Show kodra commands]**

"Kodra is customizable. Let me show you."

```bash
kodra theme           # Pick a theme
kodra wallpaper       # Browse wallpapers
kodra desktop dock    # Customize the dock
```

**[Switch theme]**

"Two themes included - Tokyo Night with purple vibes, and Ghostty Blue with cyan accents. It syncs across terminal, VS Code, and desktop."

**[Show keyboard shortcuts]**

"And macOS-style keyboard shortcuts work out of the box. Super+Space for launcher, Super+T for window tiling."

---

### [7:30 - 8:00] WSL SUPPORT

**[Switch to Windows screen if possible, or just mention]**

"Windows user? There's a WSL edition too."

```bash
wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash
```

"All the same CLI tools, right in Windows Terminal."

---

### [8:00 - END] CALL TO ACTION

**[Back to main shot]**

"That's Kodra. One command, 40+ tools, zero headaches."

**[Show on screen: kodra.codetocloud.io]**

"It's free, open source, MIT licensed. Link in the description."

"If you found this useful, hit like and subscribe. And let me know in the comments - what tools would YOU add?"

**[End card with links]**

---

## Production Notes

**Duration**: Target 8-10 minutes

**B-Roll needed**:
- Fresh Ubuntu VM boot
- Terminal commands executing
- VS Code with extensions
- Desktop with dock visible
- Keyboard typing close-up

**Screen recording tips**:
- Use a 1080p or 4K resolution
- Increase terminal font size for visibility
- Zoom in on important commands
- Add text overlays for key points

**Thumbnail idea**:
- Split screen: "Before" (messy terminal) vs "After" (beautiful setup)
- Big text: "ONE COMMAND"
- Ubuntu + Azure logos
