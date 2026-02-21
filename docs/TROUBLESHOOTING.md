# Kodra Troubleshooting Guide

Common issues and solutions for Kodra installation and usage.

## Installation Issues

### "Package has no installation candidate"

**Problem:** apt reports a package can't be installed.

**Solutions:**
1. Update your package lists:
   ```bash
   sudo apt update
   ```
2. The package name may have changed. Check the install log for alternatives.
3. Try running with `--debug` flag:
   ```bash
   ./install.sh --debug
   ```

### "GPG key error" or "Repository signature invalid"

**Problem:** Third-party repository keys are invalid or expired.

**Solutions:**
1. The repository's GPG key may have expired. Kodra will try to re-download.
2. Check your system date is correct:
   ```bash
   date
   ```
3. Manually fix by removing and re-adding the repository:
   ```bash
   sudo rm /etc/apt/sources.list.d/problematic-repo.list
   kodra repair
   ```

### "E: Unable to lock /var/lib/dpkg/lock-frontend"

**Problem:** Another apt process is running.

**Solutions:**
1. Wait for automatic updates to complete
2. Check for running apt processes:
   ```bash
   ps aux | grep apt
   ```
3. If safe to do so:
   ```bash
   sudo killall apt apt-get
   sudo dpkg --configure -a
   ```

### Installation hangs at "Installing..."

**Problem:** A package is prompting for input but stdin isn't connected.

**Solutions:**
1. The installer should run in a terminal, not via SSH without -t flag
2. Run with debug mode to see prompts:
   ```bash
   ./install.sh --debug
   ```
3. Set noninteractive mode:
   ```bash
   export DEBIAN_FRONTEND=noninteractive
   ./install.sh
   ```

### "Sudo password timeout"

**Problem:** Installation takes too long and sudo expires.

**Solutions:**
1. Kodra maintains a sudo keepalive during install, but this may fail in some environments
2. Run installer as root (not recommended):
   ```bash
   sudo -E ./install.sh
   ```
3. Extend sudo timeout temporarily:
   ```bash
   sudo visudo
   # Add: Defaults timestamp_timeout=60
   ```

## Theme Issues

### Theme not applying

**Problem:** After `kodra theme <name>`, nothing changes.

**Solutions:**
1. Close and reopen your terminal
2. Check the theme exists:
   ```bash
   ls ~/.kodra/themes/
   ```
3. Check what's currently set:
   ```bash
   cat ~/.config/kodra/theme
   ```
4. Run repair:
   ```bash
   kodra repair
   ```

### VS Code theme not matching

**Problem:** Terminal has new theme but VS Code doesn't.

**Solutions:**
1. VS Code may need to reload. Press `Ctrl+Shift+P` > "Developer: Reload Window"
2. Check if extension is installed:
   - Tokyo Night: `enkia.tokyo-night`
   - Catppuccin: `catppuccin.catppuccin-vsc`
   - Gruvbox: `jdinhlife.gruvbox`
3. Check VS Code settings:
   ```bash
   cat ~/.config/Code/User/settings.json | grep workbench.colorTheme
   ```

### Wallpaper not changing

**Problem:** `kodra wallpaper` shows success but wallpaper unchanged.

**Solutions:**
1. Check you're in a GNOME session (not SSH/terminal-only)
2. Verify the wallpaper file exists:
   ```bash
   kodra wallpaper list
   ```
3. Apply manually:
   ```bash
   gsettings set org.gnome.desktop.background picture-uri "file:///path/to/wallpaper.jpg"
   ```

## Azure CLI Issues

### "az: command not found"

**Problem:** Azure CLI not in PATH after installation.

**Solutions:**
1. Open a new terminal (path changes require shell restart)
2. Source your profile:
   ```bash
   source ~/.bashrc   # or ~/.zshrc
   ```
3. Check if installed:
   ```bash
   which az
   ```
4. Reinstall:
   ```bash
   kodra install azure-cli
   ```

### Azure CLI login fails

**Problem:** `az login` opens browser but doesn't complete.

**Solutions:**
1. Use device code flow:
   ```bash
   az login --use-device-code
   ```
2. Check WSL2 browser integration if on Windows
3. Clear credentials and retry:
   ```bash
   az logout
   az account clear
   az login
   ```

### "AADSTS700016: Application not found"

**Problem:** Old Azure CLI version with expired app registration.

**Solution:**
```bash
az upgrade
az login
```

## Docker Issues

### "Cannot connect to Docker daemon"

**Problem:** Docker service not running or permission denied.

**Solutions:**
1. Start Docker service:
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```
2. Add yourself to docker group:
   ```bash
   sudo usermod -aG docker $USER
   ```
3. **Log out and log back in** for group changes to apply
4. Verify:
   ```bash
   groups | grep docker
   docker ps
   ```

### "Got permission denied while trying to connect"

**Problem:** User not in docker group.

**Solution:**
```bash
sudo usermod -aG docker $USER
# Then log out and log back in
```

### Docker uses too much disk space

**Solution:**
```bash
kodra cleanup docker
# Or manually:
docker system prune -a --volumes
```

## Kubernetes Issues

### "connection refused" when using kubectl

**Problem:** No Kubernetes cluster configured.

**Solutions:**
1. For local development, install minikube or kind:
   ```bash
   minikube start
   ```
2. For Azure:
   ```bash
   az aks get-credentials --resource-group <rg> --name <cluster>
   ```
3. Check current context:
   ```bash
   kubectl config current-context
   ```

### kubectl very slow / timeouts

**Problem:** Cluster unreachable or DNS issues.

**Solutions:**
1. Check cluster connectivity:
   ```bash
   kubectl cluster-info
   ```
2. Check your VPN if connecting to private cluster
3. Try different context:
   ```bash
   kubectl config get-contexts
   kubectl config use-context <working-context>
   ```

## Shell/Terminal Issues

### Starship prompt not showing

**Problem:** Prompt is boring default bash/zsh prompt.

**Solutions:**
1. Check starship is installed:
   ```bash
   which starship
   ```
2. Check init is in shell config:
   ```bash
   grep starship ~/.bashrc ~/.zshrc
   ```
3. Should see: `eval "$(starship init bash)"` or `eval "$(starship init zsh)"`
4. Reinstall:
   ```bash
   kodra repair
   ```

### Weird characters in terminal (broken icons)

**Problem:** Missing Nerd Fonts.

**Solutions:**
1. Install fonts:
   ```bash
   kodra install nerd-fonts
   ```
2. Set terminal to use JetBrainsMono Nerd Font
3. In Ghostty, should be automatic. Check config:
   ```bash
   grep font-family ~/.config/ghostty/config
   ```

### FZF keybindings not working

**Problem:** Ctrl+R, Ctrl+T, Alt+C don't work.

**Solutions:**
1. Check fzf is installed:
   ```bash
   which fzf
   ```
2. Check shell integration:
   ```bash
   grep fzf ~/.bashrc ~/.zshrc
   ```
3. Refresh shell:
   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```

### zoxide "not found" error

**Problem:** `z` or `zz` commands don't work.

**Solutions:**
1. Check zoxide installed:
   ```bash
   which zoxide
   ```
2. Check shell init:
   ```bash
   grep zoxide ~/.bashrc ~/.zshrc
   ```
3. Should see: `eval "$(zoxide init bash)"` or `eval "$(zoxide init zsh)"`

## GNOME/Desktop Issues

### Extensions not appearing

**Problem:** Installed extensions don't show in GNOME.

**Solutions:**
1. Check extension status:
   ```bash
   kodra extensions list
   ```
2. Enable all installed:
   ```bash
   kodra extensions enable-all
   ```
3. Restart GNOME Shell: Press `Alt+F2`, type `r`, press Enter (Xorg only)
4. For Wayland, log out and back in

### Panel customization not applied

**Problem:** Dock, panel transparency, etc. not working.

**Solutions:**
1. Check Dash to Dock extension:
   ```bash
   gnome-extensions info dash-to-dock@micxgx.gmail.com
   ```
2. Re-apply desktop settings:
   ```bash
   kodra desktop refresh
   ```

### Night Light not toggling

**Problem:** `kodra nightlight` doesn't work.

**Solution:**
```bash
# Check current state
gsettings get org.gnome.settings-daemon.plugins.color night-light-enabled

# Set manually
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
```

## Getting Help

### Collect diagnostic info

Run the doctor command:
```bash
kodra doctor
```

### Check installation logs

```bash
cat ~/.config/kodra/install.log
# Or the temp log:
ls /tmp/kodra-install-*.log
```

### Share logs for support

```bash
cat /tmp/kodra-install-*.log | nc termbin.com 9999
```

### Reset everything

If nothing works, you can uninstall and reinstall:
```bash
kodra uninstall
# Then reinstall fresh:
wget -qO- https://kodra.codetocloud.io/boot.sh | bash
```

### Get support

- **GitHub Issues:** https://github.com/codetocloudorg/kodra/issues
- **Documentation:** https://kodra.codetocloud.io/docs
