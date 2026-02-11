# Kodra Cheat Sheet

Quick reference for all aliases, keyboard shortcuts, and keybindings included with Kodra.

---

## 🖥️ Desktop Shortcuts

### Window Tiling (via Tactile)

| Shortcut | Action |
|----------|--------|
| `Super + T` | Show tiling grid overlay |
| `Super + ←` | Tile window to left half |
| `Super + →` | Tile window to right half |
| `Super + ↑` | Maximize window |
| `Super + ↓` | Restore/minimize window |
| `Ctrl + Super + ←` | Tile to left edge |
| `Ctrl + Super + →` | Tile to right edge |
| `Ctrl + Super + ↑` | Tile to top edge |
| `Ctrl + Super + ↓` | Tile to bottom edge |
| `Ctrl + Alt + U` | Tile to top-left corner |
| `Ctrl + Alt + I` | Tile to top-right corner |
| `Ctrl + Alt + J` | Tile to bottom-left corner |
| `Ctrl + Alt + K` | Tile to bottom-right corner |

### App Launcher & System

| Shortcut | Action |
|----------|--------|
| `Super + Space` | Open Ulauncher (app search) |
| `Super + Return` | Open terminal (Ghostty) |
| `Ctrl + Alt + T` | Open terminal (alternative) |
| `Shift + Super + 3` | Screenshot (full screen) |
| `Shift + Super + 4` | Screenshot (area selection) |
| `Shift + Super + 5` | Screenshot (window) |

---

## ⌨️ Terminal Keybindings (Ghostty)

| Shortcut | Action |
|----------|--------|
| `Ctrl + Shift + C` | Copy to clipboard |
| `Ctrl + Shift + V` | Paste from clipboard |
| `Ctrl + Shift + N` | New window |
| `Ctrl + Shift + T` | New tab |
| `Ctrl + Shift + W` | Close tab/window |
| `Ctrl + +` | Increase font size |
| `Ctrl + -` | Decrease font size |
| `Ctrl + 0` | Reset font size |

---

## 🐚 Shell Aliases

### Modern CLI Replacements

These aliases upgrade classic commands with modern alternatives:

| Alias | Command | Description |
|-------|---------|-------------|
| `cat` | `bat --paging=never` | Syntax-highlighted file viewer |
| `catp` | `bat` | Same with pager enabled |
| `ls` | `eza --icons` | Modern ls with icons |
| `ll` | `eza -l --icons` | Long listing with icons |
| `la` | `eza -la --icons` | Long listing including hidden |
| `lt` | `eza --tree --icons` | Tree view with icons |
| `l` | `eza -l --icons` | Quick long listing |
| `find` | `fd` | Fast, user-friendly find |

### Git Shortcuts

| Alias | Command | Description |
|-------|---------|-------------|
| `g` | `git` | Short git |
| `gs` | `git status` | Check repo status |
| `ga` | `git add` | Stage files |
| `gc` | `git commit` | Commit changes |
| `gp` | `git push` | Push to remote |
| `gl` | `git pull` | Pull from remote |
| `gd` | `git diff` | Show diff |
| `gco` | `git checkout` | Checkout branch/file |
| `gb` | `git branch` | List/manage branches |
| `glog` | `git log --oneline --graph --decorate` | Pretty git log |
| `lg` | `lazygit` | TUI git client |

### Docker Shortcuts

| Alias | Command | Description |
|-------|---------|-------------|
| `d` | `docker` | Short docker |
| `dc` | `docker compose` | Docker Compose |
| `dps` | `docker ps` | List containers |
| `di` | `docker images` | List images |
| `dex` | `docker exec -it` | Exec into container |
| `dlogs` | `docker logs -f` | Follow container logs |
| `lzd` | `lazydocker` | TUI docker manager |

### Azure Shortcuts

| Alias | Command | Description |
|-------|---------|-------------|
| `az-login` | `az login` | Login to Azure |
| `az-sub` | `az account show --query name -o tsv` | Show current subscription |
| `az-subs` | `az account list ...` | List all subscriptions |
| `az-switch` | `az account set --subscription` | Switch subscription |
| `azd-init` | `azd init` | Initialize azd project |
| `azd-up` | `azd up` | Deploy infrastructure + app |
| `azd-down` | `azd down` | Tear down deployment |
| `azd-deploy` | `azd deploy` | Deploy app only |

### GitHub Copilot CLI ✨

| Alias | Command | Description |
|-------|---------|-------------|
| `??` | `gh copilot suggest -t shell` | Ask Copilot for shell commands |
| `git?` | `gh copilot suggest -t git` | Ask Copilot for git commands |
| `gh?` | `gh copilot suggest -t gh` | Ask Copilot for gh CLI commands |
| `explain` | `gh copilot explain` | Explain a command |

**Examples:**
```bash
?? "find all .ts files modified in the last week"
git? "undo last commit but keep changes"
explain "tar -xzvf archive.tar.gz"
```

### Terraform / OpenTofu

| Alias | Command | Description |
|-------|---------|-------------|
| `tf` | `terraform` | Short terraform |
| `tfi` | `terraform init` | Initialize workspace |
| `tfp` | `terraform plan` | Plan changes |
| `tfa` | `terraform apply` | Apply changes |
| `tfd` | `terraform destroy` | Destroy resources |
| `tofu-init` | `tofu init` | OpenTofu init |
| `tofu-plan` | `tofu plan` | OpenTofu plan |
| `tofu-apply` | `tofu apply` | OpenTofu apply |

### Utility Shortcuts

| Alias | Command | Description |
|-------|---------|-------------|
| `c` | `clear` | Clear terminal |
| `h` | `history` | Show command history |
| `ports` | `netstat -tulanp` | Show open ports |
| `path` | `echo $PATH` | Show PATH (one per line) |
| `now` | `date +"%Y-%m-%d %H:%M:%S"` | Current timestamp |
| `vim`, `vi`, `v` | `nvim` | Open Neovim |
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `....` | `cd ../../..` | Go up three directories |

### Functions

| Function | Usage | Description |
|----------|-------|-------------|
| `mkcd` | `mkcd my-project` | Create directory and cd into it |

### Kodra Management

| Alias | Command | Description |
|-------|---------|-------------|
| `kodra-theme` | `kodra theme` | Change theme |
| `kodra-update` | `kodra update` | Update Kodra |
| `kodra-doctor` | `kodra doctor` | Diagnose issues |

---

## 🎨 Theme Sync

Both themes (Tokyo Night / Ghostty Blue) are synchronized across:

- **Terminal** — Ghostty color scheme
- **Editor** — VS Code theme + settings
- **Prompt** — Starship prompt colors
- **Desktop** — GNOME accent colors

Switch themes anytime:
```bash
kodra theme
```

---

## 📁 Configuration Locations

| What | Location |
|------|----------|
| Shell aliases | `~/.kodra/configs/shell/aliases.sh` |
| Shell integration | `~/.kodra/configs/shell/kodra.sh` |
| Ghostty config | `~/.config/ghostty/config` |
| Neovim config | `~/.config/nvim/init.lua` |
| Starship prompt | `~/.config/starship.toml` |
| VS Code settings | `~/.config/Code/User/settings.json` |
| btop config | `~/.config/btop/btop.conf` |
| fastfetch config | `~/.config/fastfetch/config.jsonc` |

---

## 💡 Pro Tips

1. **Use `??` for anything** — GitHub Copilot CLI understands natural language
   ```bash
   ?? "compress this folder and upload to Azure blob storage"
   ```

2. **lazygit is your friend** — Type `lg` in any repo for a powerful TUI
   
3. **Quick Azure context** — Use `az-sub` to quickly see your current subscription

4. **Tile windows fast** — `Super + T` then click grid positions

5. **Search anything** — `Super + Space` opens Ulauncher for instant app/file search

---

*Made with ☁️ by [Code To Cloud](https://www.codetocloud.io)*
