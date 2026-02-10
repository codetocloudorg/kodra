#!/usr/bin/env bash
#
# Kodra Doctor Script
# Check system health, diagnose issues, and optionally fix them
#
# Usage:
#   kodra doctor           # Run all health checks
#   kodra doctor --fix     # Run checks and attempt auto-fixes
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

# Parse arguments
FIX_MODE=false
for arg in "$@"; do
    case $arg in
        --fix|-f)
            FIX_MODE=true
            ;;
    esac
done

echo ""
echo -e "${BLUE}Kodra System Health Check${NC}"
[ "$FIX_MODE" = true ] && echo -e "${YELLOW}(Fix mode enabled)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check count
CHECKS=0
PASSED=0
FIXES=()

check() {
    local name="$1"
    local cmd="$2"
    local fix_cmd="${3:-}"
    local fix_hint="${4:-}"
    
    CHECKS=$((CHECKS + 1))
    
    if eval "$cmd" &> /dev/null; then
        echo -e "  ${GREEN}✔${NC} $name"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✖${NC} $name"
        
        if [ -n "$fix_hint" ]; then
            echo -e "      ${GRAY}Fix: $fix_hint${NC}"
        fi
        
        # Attempt auto-fix if in fix mode
        if [ "$FIX_MODE" = true ] && [ -n "$fix_cmd" ]; then
            echo -e "      ${CYAN}Attempting fix...${NC}"
            if eval "$fix_cmd" &> /dev/null; then
                echo -e "      ${GREEN}Fixed!${NC}"
                PASSED=$((PASSED + 1))
            else
                echo -e "      ${RED}Auto-fix failed${NC}"
                FIXES+=("$name: $fix_hint")
            fi
        elif [ -n "$fix_cmd" ]; then
            FIXES+=("$name: $fix_hint")
        fi
        
        return 1
    fi
}

# System
echo -e "${CYAN}System${NC}"
check "Ubuntu 24.04+" \
    "[ -f /etc/os-release ] && . /etc/os-release && [ \${VERSION_ID%.*} -ge 24 ]" \
    "" \
    "Kodra requires Ubuntu 24.04 or newer"
check "Internet connectivity" \
    "ping -c 1 -W 2 github.com || curl -s --max-time 2 https://github.com" \
    "" \
    "Check network connection"
check "Disk space (>5GB)" \
    "[ \$(df -BG ~ | tail -1 | awk '{print \$4}' | tr -d 'G') -gt 5 ]" \
    "" \
    "Free up disk space"
check "sudo access" \
    "sudo -v" \
    "" \
    "Ensure user has sudo privileges"
echo ""

# Package Managers
echo -e "${CYAN}Package Managers${NC}"
check "apt" "command -v apt"
check "Flatpak" \
    "command -v flatpak" \
    "sudo apt install -y flatpak" \
    "sudo apt install flatpak"
check "Homebrew" \
    "command -v brew" \
    "" \
    "Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
check "mise" \
    "command -v mise" \
    "curl https://mise.run | sh" \
    "curl https://mise.run | sh"
echo ""

# Azure Tools
echo -e "${CYAN}Azure & Cloud Tools${NC}"
check "Azure CLI" \
    "command -v az" \
    "" \
    "bash $KODRA_DIR/install/required/azure/azure-cli.sh"
check "Azure CLI logged in" \
    "az account show" \
    "" \
    "Run: az login"
check "Azure Developer CLI (azd)" \
    "command -v azd" \
    "" \
    "bash $KODRA_DIR/install/required/azure/azure-developer-cli.sh"
check "Bicep" "command -v bicep"
check "Terraform" "command -v terraform"
check "kubectl" \
    "command -v kubectl" \
    "" \
    "bash $KODRA_DIR/install/required/azure/kubectl.sh"
check "Helm" "command -v helm"
check "k9s" "command -v k9s"
echo ""

# Container Runtime
echo -e "${CYAN}Containers${NC}"
check "Docker installed" \
    "command -v docker" \
    "" \
    "bash $KODRA_DIR/applications/docker-ce.sh"
check "Docker daemon running" \
    "docker info" \
    "sudo systemctl start docker" \
    "sudo systemctl start docker"
check "User in docker group" \
    "groups | grep -q docker" \
    "sudo usermod -aG docker \$USER" \
    "sudo usermod -aG docker \$USER && newgrp docker"
check "lazydocker" "command -v lazydocker"
echo ""

# Kubernetes (only if kubectl exists)
if command -v kubectl &>/dev/null; then
    echo -e "${CYAN}Kubernetes${NC}"
    check "kubectl configured" \
        "kubectl config current-context" \
        "" \
        "Set up a kubeconfig or run: az aks get-credentials"
    check "kubectl can connect" \
        "kubectl cluster-info --request-timeout=2s" \
        "" \
        "Check cluster connectivity or VPN"
    echo ""
fi

# Development
echo -e "${CYAN}Development Tools${NC}"
check "VS Code" \
    "command -v code" \
    "" \
    "bash $KODRA_DIR/install/required/applications/vscode.sh"
check "Git" "command -v git"
check "Git configured (name)" \
    "git config --global user.name" \
    "" \
    "Run: kodra setup"
check "Git configured (email)" \
    "git config --global user.email" \
    "" \
    "Run: kodra setup"
check "GitHub CLI" \
    "command -v gh" \
    "" \
    "bash $KODRA_DIR/install/required/applications/github-cli.sh"
check "GitHub CLI logged in" \
    "gh auth status" \
    "" \
    "Run: gh auth login"
check "GitHub Copilot CLI" \
    "gh extension list 2>/dev/null | grep -q copilot" \
    "gh extension install github/gh-copilot" \
    "gh extension install github/gh-copilot"
echo ""

# Terminal
echo -e "${CYAN}Terminal${NC}"
check "Ghostty" \
    "command -v ghostty" \
    "" \
    "bash $KODRA_DIR/install/terminal/ghostty.sh"
check "Starship" \
    "command -v starship" \
    "" \
    "bash $KODRA_DIR/install/terminal/starship.sh"
check "Nerd Fonts installed" \
    "fc-list 2>/dev/null | grep -qi 'nerd'" \
    "" \
    "bash $KODRA_DIR/install/terminal/nerd-fonts.sh"
echo ""

# Shell Integration
echo -e "${CYAN}Shell Integration${NC}"
check "Kodra in PATH" \
    "echo \$PATH | grep -q '.kodra/bin'" \
    "" \
    "Add to ~/.bashrc: export PATH=\"\$HOME/.kodra/bin:\$PATH\""
check "Starship in bashrc" \
    "grep -q 'starship init' ~/.bashrc 2>/dev/null" \
    "" \
    "Add to ~/.bashrc: eval \"\$(starship init bash)\""
check "Kodra theme set" \
    "[ -f ~/.config/kodra/theme ]" \
    "" \
    "Run: kodra theme tokyo-night"
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "  ${WHITE}Results: ${PASSED}/${CHECKS} checks passed${NC}"
echo ""

if [ $PASSED -eq $CHECKS ]; then
    echo -e "  ${GREEN}✅ All systems go! Kodra is healthy.${NC}"
elif [ $PASSED -ge $((CHECKS * 3 / 4)) ]; then
    echo -e "  ${YELLOW}⚠️  Mostly healthy, some optional tools missing.${NC}"
else
    echo -e "  ${RED}❌ Several issues detected.${NC}"
fi

# Show fix suggestions
if [ ${#FIXES[@]} -gt 0 ]; then
    echo ""
    echo -e "  ${CYAN}To fix issues:${NC}"
    if [ "$FIX_MODE" = false ]; then
        echo -e "  ${GRAY}Run: kodra doctor --fix${NC}"
        echo ""
        echo -e "  ${GRAY}Or manually:${NC}"
    fi
    for fix in "${FIXES[@]}"; do
        echo -e "  ${GRAY}• $fix${NC}"
    done
fi

echo ""
