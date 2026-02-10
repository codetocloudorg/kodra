#!/usr/bin/env bash
#
# Kodra Full System Test
# Run in Ubuntu 24.04 container
#

set -e

echo "=================================================================="
echo "  KODRA FULL SYSTEM TEST - Ubuntu 24.04 LTS"
echo "=================================================================="
echo ""

cat /etc/os-release | grep -E "^(NAME|VERSION)="
echo ""

# PHASE 1: Prerequisites
echo "[PHASE 1] Installing prerequisites..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq curl wget git sudo lsb-release gnupg ca-certificates \
    software-properties-common build-essential procps file zsh > /dev/null 2>&1

useradd -m -s /bin/bash testuser 2>/dev/null || true
echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "OK Prerequisites installed"
echo ""

# PHASE 2: Copy Kodra
echo "[PHASE 2] Setting up Kodra..."
su - testuser -c '
    export KODRA_DIR=$HOME/.kodra
    cp -r /kodra $KODRA_DIR
    chmod +x $KODRA_DIR/*.sh $KODRA_DIR/bin/* $KODRA_DIR/bin/kodra-sub/*.sh 2>/dev/null || true
    mkdir -p $HOME/.bashrc_dir
    touch $HOME/.bashrc
    touch $HOME/.zshrc
    echo "OK Kodra copied to ~/.kodra"
'
echo ""

# PHASE 3: Syntax Check
echo "[PHASE 3] Syntax validation..."
ERRORS=0
for script in $(find /home/testuser/.kodra -name "*.sh" -type f 2>/dev/null); do
    if ! bash -n "$script" 2>&1; then
        echo "FAIL SYNTAX: $script"
        ERRORS=$((ERRORS + 1))
    fi
done
SCRIPT_COUNT=$(find /home/testuser/.kodra -name "*.sh" -type f | wc -l)
if [ $ERRORS -eq 0 ]; then
    echo "OK All $SCRIPT_COUNT shell scripts pass syntax check"
else
    echo "FAIL $ERRORS scripts have syntax errors"
fi
echo ""

# PHASE 4: Library Functions
echo "[PHASE 4] Testing library functions..."
su - testuser -c '
    export KODRA_DIR=$HOME/.kodra
    source $KODRA_DIR/lib/utils.sh
    
    [ -n "$RED" ] && echo "OK Colors exported" || echo "FAIL Colors not exported"
    type log_info &>/dev/null && echo "OK log_info exists" || echo "FAIL log_info missing"
    type log_success &>/dev/null && echo "OK log_success exists" || echo "FAIL log_success missing"
    type add_to_path &>/dev/null && echo "OK add_to_path exists" || echo "FAIL add_to_path missing"
    type add_shell_integration &>/dev/null && echo "OK add_shell_integration exists" || echo "FAIL add_shell_integration missing"
    check_ubuntu_version && echo "OK Ubuntu version check passed" || echo "FAIL Ubuntu version check"
'
echo ""

# PHASE 5: CLI Commands
echo "[PHASE 5] Testing CLI commands..."
su - testuser -c '
    export KODRA_DIR=$HOME/.kodra
    export PATH="$KODRA_DIR/bin:$PATH"
    
    kodra --help > /dev/null 2>&1 && echo "OK kodra --help" || echo "FAIL kodra --help"
    kodra version > /dev/null 2>&1 && echo "OK kodra version" || echo "FAIL kodra version"
    kodra theme list > /dev/null 2>&1 && echo "OK kodra theme list" || echo "FAIL kodra theme list"
    kodra theme current > /dev/null 2>&1 && echo "OK kodra theme current" || echo "FAIL kodra theme current"
    kodra wallpaper list > /dev/null 2>&1 && echo "OK kodra wallpaper list" || echo "FAIL kodra wallpaper list"
    kodra fetch > /dev/null 2>&1 && echo "OK kodra fetch" || echo "FAIL kodra fetch"
    kodra doctor > /dev/null 2>&1 && echo "OK kodra doctor" || echo "FAIL kodra doctor"
    kodra desktop --help > /dev/null 2>&1 && echo "OK kodra desktop --help" || echo "FAIL kodra desktop --help"
'
echo ""

# PHASE 6: Theme Files
echo "[PHASE 6] Validating theme files..."
THEME_ERRORS=0
for theme in tokyo-night ghostty-blue; do
    THEME_DIR="/home/testuser/.kodra/themes/$theme"
    [ -f "$THEME_DIR/ghostty.conf" ] || { echo "FAIL Missing: $theme/ghostty.conf"; THEME_ERRORS=$((THEME_ERRORS+1)); }
    [ -f "$THEME_DIR/starship.toml" ] || { echo "FAIL Missing: $theme/starship.toml"; THEME_ERRORS=$((THEME_ERRORS+1)); }
done
[ $THEME_ERRORS -eq 0 ] && echo "OK All 2 themes complete (4 config files)"
echo ""

# PHASE 7: Config Files
echo "[PHASE 7] Validating config files..."
[ -f "/home/testuser/.kodra/configs/ghostty/config" ] && echo "OK Ghostty config" || echo "FAIL Ghostty config"
[ -f "/home/testuser/.kodra/configs/nvim/init.lua" ] && echo "OK Neovim config" || echo "FAIL Neovim config"
[ -f "/home/testuser/.kodra/configs/shell/kodra.sh" ] && echo "OK Shell integration" || echo "FAIL Shell integration"
[ -f "/home/testuser/.kodra/configs/shell/aliases.sh" ] && echo "OK Aliases file" || echo "FAIL Aliases file"
echo ""

# PHASE 8: Wallpapers
echo "[PHASE 8] Checking wallpapers..."
WP_COUNT=$(ls /home/testuser/.kodra/wallpapers/*.svg /home/testuser/.kodra/wallpapers/*.png /home/testuser/.kodra/wallpapers/*.jpg 2>/dev/null | wc -l)
echo "OK Found $WP_COUNT wallpapers"
echo ""

# PHASE 9: Shell Integration
echo "[PHASE 9] Testing shell integration..."
su - testuser -c '
    export KODRA_DIR=$HOME/.kodra
    source $KODRA_DIR/lib/utils.sh
    
    # Test add_to_path
    add_to_path "$KODRA_DIR/bin"
    grep -q "kodra" $HOME/.bashrc && echo "OK PATH added to .bashrc" || echo "FAIL PATH not in .bashrc"
    grep -q "kodra" $HOME/.zshrc && echo "OK PATH added to .zshrc" || echo "FAIL PATH not in .zshrc"
    
    # Test add_shell_integration
    add_shell_integration
    grep -q "kodra.sh" $HOME/.bashrc && echo "OK Shell integration in .bashrc" || echo "FAIL Shell integration not in .bashrc"
    grep -q "kodra.sh" $HOME/.zshrc && echo "OK Shell integration in .zshrc" || echo "FAIL Shell integration not in .zshrc"
'
echo ""

# PHASE 10: Installer Tests
echo "[PHASE 10] Testing installers..."
echo ""

# Test kubectl
echo "Testing kubectl installer..."
su - testuser -c 'bash /home/testuser/.kodra/install/required/azure/kubectl.sh' 2>&1 | tail -5
su - testuser -c 'which kubectl && kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -1' && echo "OK kubectl installed" || echo "FAIL kubectl"
echo ""

# Test Helm
echo "Testing Helm installer..."
su - testuser -c 'bash /home/testuser/.kodra/install/required/azure/helm.sh' 2>&1 | tail -5
su - testuser -c 'which helm && helm version --short' && echo "OK Helm installed" || echo "FAIL Helm"
echo ""

# Test Azure CLI
echo "Testing Azure CLI installer..."
su - testuser -c 'bash /home/testuser/.kodra/install/required/azure/azure-cli.sh' 2>&1 | tail -5
su - testuser -c 'which az && az version --query \"azure-cli\" -o tsv' && echo "OK Azure CLI installed" || echo "FAIL Azure CLI"
echo ""

# Test Terraform
echo "Testing Terraform installer..."
su - testuser -c 'bash /home/testuser/.kodra/install/required/azure/terraform.sh' 2>&1 | tail -5
su - testuser -c 'which terraform && terraform version | head -1' && echo "OK Terraform installed" || echo "FAIL Terraform"
echo ""

# Test mise
echo "Testing mise installer..."
su - testuser -c 'bash /home/testuser/.kodra/install/required/package-managers/mise.sh' 2>&1 | tail -5
su - testuser -c 'which mise || [ -f $HOME/.local/bin/mise ]' && echo "OK mise installed" || echo "FAIL mise"
echo ""

# Test Starship
echo "Testing Starship installer..."
su - testuser -c 'bash /home/testuser/.kodra/install/terminal/starship.sh' 2>&1 | tail -5
su - testuser -c 'which starship && starship --version' && echo "OK Starship installed" || echo "FAIL Starship"
echo ""

# Test modern CLI tools
echo "Testing modern CLI tools installer..."
su - testuser -c 'bash /home/testuser/.kodra/install/terminal/modern-cli-tools.sh' 2>&1 | tail -10
su - testuser -c 'which bat && which eza && which fd && which rg' && echo "OK Modern CLI tools installed" || echo "FAIL Some CLI tools"
echo ""

# PHASE 11: Theme Switching
echo "[PHASE 11] Testing theme switching..."
su - testuser -c '
    export KODRA_DIR="$HOME/.kodra"
    export PATH="$KODRA_DIR/bin:$PATH"
    mkdir -p "$HOME/.config/kodra"
    
    for theme in tokyo-night ghostty-blue; do
        OUTPUT=$(kodra theme "$theme" 2>&1)
        RESULT=$?
        if [ $RESULT -ne 0 ]; then
            echo "FAIL Theme $theme command failed (exit $RESULT): $OUTPUT"
        elif [ -f "$HOME/.config/kodra/theme" ]; then
            CURRENT=$(cat "$HOME/.config/kodra/theme")
            [ "$CURRENT" = "$theme" ] && echo "OK Theme switched to $theme" || echo "FAIL Theme: expected $theme, got $CURRENT"
        else
            echo "FAIL Theme file not created for $theme"
            echo "  Debug: KODRA_DIR=$KODRA_DIR"
            echo "  Debug: which kodra=$(which kodra 2>/dev/null)"
        fi
    done
'
echo ""

# PHASE 12: Summary
echo "=================================================================="
echo "  TEST COMPLETE"
echo "=================================================================="
echo ""
echo "Installed tools:"
su - testuser -c '
    echo -n "  kubectl: "; which kubectl 2>/dev/null || echo "not found"
    echo -n "  helm: "; which helm 2>/dev/null || echo "not found"
    echo -n "  az: "; which az 2>/dev/null || echo "not found"
    echo -n "  terraform: "; which terraform 2>/dev/null || echo "not found"
    echo -n "  starship: "; which starship 2>/dev/null || echo "not found"
    echo -n "  bat: "; which bat 2>/dev/null || echo "not found"
    echo -n "  eza: "; which eza 2>/dev/null || echo "not found"
    echo -n "  fd: "; which fd 2>/dev/null || echo "not found"
    echo -n "  rg: "; which rg 2>/dev/null || echo "not found"
'
