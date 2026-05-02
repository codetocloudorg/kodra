# Kodra Cheat Sheet

Quick reference for all aliases, keyboard shortcuts, and keybindings included with Kodra.

---

## 🖥️ Desktop Shortcuts (GNOME)

### Window Management

| Shortcut | Action |
|----------|--------|
| `Super + T` | Show tiling grid overlay (Tactile) |
| `Super + ←` | Tile window to left half |
| `Super + →` | Tile window to right half |
| `Super + ↑` | Maximize window |
| `Super + ↓` | Restore/minimize window |
| `Ctrl + Super + ←/→/↑/↓` | Tile to edges |
| `Ctrl + Alt + U/I/J/K` | Tile to corners |

### Workspaces

| Shortcut | Action |
|----------|--------|
| `Super + Page Up/Down` | Switch workspace |
| `Shift + Super + Page Up/Down` | Move window to workspace |
| `Super + 1-9` | Switch to workspace 1-9 |

### System

| Shortcut | Action |
|----------|--------|
| `Super + Space` | Open Ulauncher |
| `Super + Return` | Open Ghostty terminal |
| `Ctrl + Alt + T` | Open terminal (alt) |
| `Super + L` | Lock screen |
| `Shift + Super + 3/4/5` | Screenshot (full/area/window) |

---

## ⌨️ Terminal (Ghostty)

| Shortcut | Action |
|----------|--------|
| `Ctrl + Shift + C/V` | Copy / Paste |
| `Ctrl + Shift + N/T` | New window / tab |
| `Ctrl + +/-/0` | Font size up/down/reset |
| `Ctrl + Shift + O/E` | Split horizontal/vertical |

---

## 📟 Tmux (Prefix: `Ctrl + Space`)

### Windows & Sessions

| Shortcut | Action |
|----------|--------|
| `Prefix + c` | New window |
| `Prefix + n/p` | Next/previous window |
| `Prefix + 0-9` | Switch to window |
| `Prefix + d` | Detach session |
| `Shift + ←/→` | Switch windows (no prefix) |

### Panes

| Shortcut | Action |
|----------|--------|
| `Prefix + \|` | Split vertical |
| `Prefix + -` | Split horizontal |
| `Prefix + h/j/k/l` | Navigate panes |
| `Alt + Arrow` | Navigate (no prefix) |
| `Prefix + x` | Close pane |
| `Prefix + z` | Zoom pane |

### Copy Mode

| Shortcut | Action |
|----------|--------|
| `Prefix + Enter` | Enter copy mode |
| `v` | Start selection |
| `y` | Copy selection |

---

## 🐚 Shell Aliases

### Modern CLI

| Alias | Replaces | Description |
|-------|----------|-------------|
| `ls/ll/la/lt` | `eza` | Modern ls with icons |
| `cat` | `bat` | Syntax highlighting |
| `grep` | `rg` | Ripgrep |
| `find` | `fd` | Fast find |
| `du` | `dust` | Disk usage |
| `top` | `btop` | System monitor |
| `vim/vi` | `nvim` | Neovim |

### Git

| Alias | Command |
|-------|---------|
| `g/gs/ga/gc/gp` | git status/add/commit/push |
| `gpl/gd/gco/gl` | pull/diff/checkout/log |
| `lg` | lazygit |

### Kubernetes

| Alias | Command |
|-------|---------|
| `k/kx/kn` | kubectl/kubectx/kubens |
| `kgp/kgs/kgd/kga` | get pods/svc/deploy/all |
| `kaf/kdf` | apply -f / delete -f |
| `kl/klf/ke/kpf` | logs/logs -f/exec/port-forward |

### Helm

| Alias | Command |
|-------|---------|
| `h/hl/hi/hu/hs` | helm list/install/upgrade/search |

### Azure

| Alias | Command |
|-------|---------|
| `azl/azup` | az login/upgrade |
| `azdeploy/azinit` | azd up/init |
| `tf` | terraform |
| `dc` | docker compose |
| `posh` | pwsh |

### Copilot CLI

| Alias | Usage |
|-------|-------|
| `??` | Ask for shell commands |
| `git?` | Ask for git commands |
| `explain` | Explain a command |

### Utilities

| Alias | Description |
|-------|-------------|
| `serve` | Python HTTP server |
| `ports` | Show listening ports |
| `myip` | Public IP |
| `t` | tmux attach/new |

---

## 🔧 Shell Functions

### Navigation

| Function | Description |
|----------|-------------|
| `open <file>` | Open in background |
| `n [path]` | Smart nvim |
| `zd` | Fuzzy cd + preview |
| `fe` | Fuzzy edit file |
| `extract <archive>` | Extract any archive |

### Git

| Function | Description |
|----------|-------------|
| `fco` | Fuzzy branch checkout |
| `fgl` | Fuzzy git log |
| `gclone <url>` | Clone and cd |

### Docker

| Function | Description |
|----------|-------------|
| `dsh` | Fuzzy container shell |
| `dps [filter]` | Docker ps |
| `fkill` | Fuzzy process kill |

### SSH Tunnels

| Function | Description |
|----------|-------------|
| `fip local remote port host` | Port forward |
| `dip [port] host` | SOCKS proxy |
| `lip` | List tunnels |

### Media

| Function | Description |
|----------|-------------|
| `img2jpg/png/webp` | Convert images |
| `transcode-video-1080p/720p` | Video transcode |

### Tmux Layouts

| Function | Description |
|----------|-------------|
| `tml web/api/k8s` | Dev layouts |
| `nic` | Session from dir name |
| `nicx` | nic + web layout |

---

## 🎛️ Kodra Commands

### Core
`kodra theme/wallpaper/fetch/menu/help/version`

### System
`kodra power/nightlight/lock/suspend/restart/shutdown`

### Desktop
`kodra desktop/shortcuts/screenshot/font`

### Development
`kodra dev setup [lang]` | `kodra db postgres/mysql/redis/mongo`

### Maintenance
`kodra update/repair/cleanup/doctor/install/uninstall`

### CI/CD & Quality

```bash
kodra ci-report              # Latest CI run remediation report
kodra ci-report --run 123    # Specific run ID
kodra ci-report --watch      # Watch for failures and report
kodra ci-report --history 5  # Last 5 runs summary
kodra ci-report --json       # JSON output for automation
kodra migrate                # Run pending version migrations
kodra migrate --init         # Mark all migrations complete (fresh install)
kodra migrate list           # Show pending migrations
kodra migrate status         # Show migration status
```

### Testing

```bash
# Run all BATS tests locally
bats tests/unit/ tests/integration/ tests/security/

# Run specific suite
bats tests/unit/           # 22 unit tests
bats tests/integration/    # 9 integration tests
bats tests/security/       # 12 security tests

# CI runs automatically: ShellCheck → Hadolint → BATS → Docker build
```

---

## 🎨 Themes

`tokyo-night` | `ghostty-blue` | `gruvbox` | `catppuccin` | `nord` | `rose-pine`

```bash
kodra theme           # Interactive
kodra theme gruvbox   # Direct
```

---

## 📁 Config Locations

| Config | Location |
|--------|----------|
| Shell | `~/.kodra/configs/shell/kodra.sh` |
| Ghostty | `~/.config/ghostty/config` |
| Tmux | `~/.config/tmux/tmux.conf` |
| Neovim | `~/.config/nvim/init.lua` |
| Starship | `~/.config/starship.toml` |
| Themes | `~/.kodra/themes/<name>/` |

---

## 💡 Pro Tips

1. `??` - Ask Copilot anything: `?? "compress and upload to Azure"`
2. `lg` - LazyGit for powerful TUI git
3. `nic` - Quick tmux session from folder name
4. `kodra db postgres` - Instant database
5. `Tab` - Cycle completions, `Shift+Tab` - reverse
6. `Ctrl+R` - Fuzzy history search
7. `Super+T` - Window tiling grid

---

*Made with ☁️ by [Code To Cloud](https://www.codetocloud.io)*
