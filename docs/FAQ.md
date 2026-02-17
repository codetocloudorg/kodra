# Frequently Asked Questions

## General

### Is Kodra free?

**Yes, 100% free and open source.** Kodra is released under the MIT License. There are no premium tiers, no subscriptions, and no hidden costs.

### What operating systems does Kodra support?

Kodra supports:
- **Ubuntu 24.04 LTS** and newer (native)
- **WSL (Windows Subsystem for Linux)** on Windows 10/11
- Ubuntu-based distributions (Pop!_OS, Linux Mint, etc.) may work but are not officially supported

### Does Kodra work on WSL?

**Yes!** We have a dedicated WSL edition. All CLI tools, Azure integrations, and GitHub Copilot work right in Windows Terminal.

```bash
# Install on WSL
wget -qO- https://kodra.wsl.codetocloud.io/boot.sh | bash
```

### What's included in Kodra?

40+ tools across these categories:
- **Cloud**: Azure CLI, azd, Terraform, Bicep, OpenTofu, PowerShell 7
- **Kubernetes**: kubectl, Helm, k9s
- **Containers**: Docker CE or Podman, lazydocker
- **Git & GitHub**: GitHub CLI, GitHub Desktop, lazygit, GitLens
- **AI**: GitHub Copilot CLI (`??` for instant AI help)
- **Terminal**: Ghostty, Starship prompt, Nerd Fonts
- **CLI Tools**: bat, eza, fzf, ripgrep, zoxide, btop, jq, yq
- **Editor**: VS Code with 15 cloud-native extensions, Neovim

See the [full cheat sheet](CHEATSHEET.md) for details.

### Do I need Azure to use Kodra?

**No.** While Kodra is optimized for Azure development, all tools work independently. You can use:
- Docker/Kubernetes without Azure
- Terraform for any cloud provider
- GitHub CLI for any GitHub workflow
- All terminal tools work standalone

You can skip Azure login during setup and configure it later.

---

## Installation

### How do I install Kodra?

One command:

```bash
wget -qO- https://kodra.codetocloud.io/boot.sh | bash
```

The installer will guide you through theme selection and optional apps.

### How long does installation take?

- **Fast connection**: 10-15 minutes
- **Slower connection**: 20-30 minutes

The installer shows real-time progress and can resume if interrupted.

### Can I review the script before running it?

**Absolutely!** We recommend reviewing any script before running it:

```bash
wget https://kodra.codetocloud.io/boot.sh
cat boot.sh
bash boot.sh
```

### What if the installation fails?

1. Run with debug mode for detailed logging:
   ```bash
   ./install.sh --debug
   ```

2. The installer saves logs to `~/.config/kodra/install.log`

3. Try resuming a failed installation:
   ```bash
   kodra resume
   ```

4. [Join Discord](https://discord.gg/vwfwq2EpXJ) for help

---

## Uninstallation

### How do I uninstall Kodra?

```bash
# Interactive uninstall
wget -qO- https://kodra.codetocloud.io/boot.sh | bash
# Select "Uninstall" option

# Or directly
bash ~/.kodra/uninstall.sh
```

### Does uninstall remove all installed tools?

The uninstaller asks what to remove:
- **Kodra configuration only**: Keeps all tools, removes Kodra settings
- **Full uninstall**: Removes Kodra-installed tools (keeps system packages)

Third-party tools like Docker, VS Code may need manual removal if you want a complete clean slate.

---

## Usage

### How do I change themes?

```bash
kodra theme           # Interactive picker
kodra theme tokyo-night  # Switch directly
```

Available themes:
- **Tokyo Night** - Purple-blue Tokyo city lights
- **Ghostty Blue** - Deep navy with electric cyan

### How do I update Kodra?

```bash
kodra update
```

This updates:
- Kodra scripts
- System packages (apt)
- Homebrew packages
- npm global packages
- Flatpak apps
- VS Code extensions
- Desktop configuration

### What's the `??` command?

It's GitHub Copilot CLI—your AI assistant in the terminal:

```bash
?? how do I list all Azure resource groups
```

Copilot will suggest the exact command and explain it.

### How do I configure the dock?

```bash
kodra desktop dock    # Set dock favorites
kodra desktop refresh # Re-apply all desktop settings
```

---

## Troubleshooting

### Extensions aren't showing up after install

Log out and log back in. Kodra configures a first-login script that enables extensions after GNOME Shell restarts.

If still not working:
```bash
kodra desktop refresh
```

### Flatpak apps not in launcher

Run:
```bash
kodra repair
```

This re-applies all configurations including:
- XDG_DATA_DIRS for Flatpak desktop file discovery
- Desktop database refresh
- Shell integration

Then **log out and back in** for changes to take effect.

### Docker permission denied error

Log out and back in for group membership to take effect, or run:
```bash
newgrp docker
```

### Terminal looks wrong (no Nerd Fonts)

Make sure you're using Ghostty as your terminal. It has Nerd Fonts built-in.

For other terminals, manually install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/).

---

## Contributing

### How can I contribute?

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on:
- Reporting bugs
- Suggesting features
- Submitting pull requests

### Can I create my own theme?

Yes! Add a theme folder to `~/.kodra/themes/your-theme/` with:
- `ghostty.conf`
- `starship.toml`
- `vscode-settings.json`

---

## Other

### Is Kodra affiliated with Microsoft/Azure?

**No.** Kodra is an independent project by [Code To Cloud](https://www.codetocloud.io). We're not affiliated with Microsoft, GitHub, or any other company. We just love their tools!

### How do I report a security issue?

Email **security@codetocloud.io**. Do NOT open a public issue for security vulnerabilities. See [SECURITY.md](../SECURITY.md) for details.

### Where can I get help?

1. Check this FAQ
2. Search [GitHub Issues](https://github.com/codetocloudorg/kodra/issues)
3. Join [Discord](https://discord.gg/vwfwq2EpXJ)
4. Open a new issue with the bug report template
