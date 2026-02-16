#!/usr/bin/env bash
#
# Kodra First-Run Setup
# Guides user through initial configuration after installation
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "$KODRA_DIR/lib/utils.sh"

# Colors
C_CYAN='\033[38;5;51m'
C_GREEN='\033[38;5;46m'
C_PURPLE='\033[38;5;141m'
C_YELLOW='\033[38;5;226m'
C_WHITE='\033[38;5;255m'
C_GRAY='\033[38;5;245m'
C_RESET='\033[0m'

# Check if first run is needed
is_first_run() {
    [ ! -f "$KODRA_CONFIG_DIR/first_run_complete" ]
}

# Mark first run as complete
complete_first_run() {
    mkdir -p "$KODRA_CONFIG_DIR"
    date +%s > "$KODRA_CONFIG_DIR/first_run_complete"
}

# Setup GitHub CLI authentication
setup_github() {
    echo ""
    echo -e "${C_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo -e "${C_WHITE}  GitHub Authentication${C_RESET}"
    echo -e "${C_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo ""
    
    if ! command -v gh &> /dev/null; then
        echo -e "${C_GRAY}GitHub CLI not installed. Skipping...${C_RESET}"
        return 0
    fi
    
    if gh auth status &>/dev/null; then
        local user=$(gh api user -q '.login' 2>/dev/null || echo "authenticated user")
        echo -e "${C_GREEN}✓${C_RESET} Already logged in as ${C_WHITE}$user${C_RESET}"
        return 0
    fi
    
    echo -e "${C_GRAY}GitHub CLI enables:${C_RESET}"
    echo -e "  ${C_CYAN}•${C_RESET} Clone private repositories"
    echo -e "  ${C_CYAN}•${C_RESET} Create PRs from command line"
    echo -e "  ${C_CYAN}•${C_RESET} GitHub Copilot CLI (gh copilot)"
    echo ""
    
    if command -v gum &> /dev/null; then
        if gum confirm "Login to GitHub now? (y/N)"; then
            echo ""
            gh auth login
        else
            echo -e "${C_GRAY}Skipped. Run 'gh auth login' anytime.${C_RESET}"
        fi
    else
        read -p "Login to GitHub now? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh auth login
        else
            echo -e "${C_GRAY}Skipped. Run 'gh auth login' anytime.${C_RESET}"
        fi
    fi
}

# Setup Azure CLI authentication
setup_azure() {
    echo ""
    echo -e "${C_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo -e "${C_WHITE}  Azure Authentication${C_RESET}"
    echo -e "${C_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo ""
    
    if ! command -v az &> /dev/null; then
        echo -e "${C_GRAY}Azure CLI not installed. Skipping...${C_RESET}"
        return 0
    fi
    
    if az account show &>/dev/null; then
        local sub=$(az account show --query 'name' -o tsv 2>/dev/null || echo "authenticated")
        echo -e "${C_GREEN}✓${C_RESET} Already logged in to Azure: ${C_WHITE}$sub${C_RESET}"
        return 0
    fi
    
    echo -e "${C_GRAY}Azure CLI enables:${C_RESET}"
    echo -e "  ${C_CYAN}•${C_RESET} Deploy resources with 'az' commands"
    echo -e "  ${C_CYAN}•${C_RESET} Use Azure Developer CLI (azd up)"
    echo -e "  ${C_CYAN}•${C_RESET} Manage Kubernetes (az aks)"
    echo ""
    
    if command -v gum &> /dev/null; then
        if gum confirm "Login to Azure now? (y/N)"; then
            echo ""
            az login
        else
            echo -e "${C_GRAY}Skipped. Run 'az login' anytime.${C_RESET}"
        fi
    else
        read -p "Login to Azure now? (y/N) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            az login
        else
            echo -e "${C_GRAY}Skipped. Run 'az login' anytime.${C_RESET}"
        fi
    fi
}

# Setup Git identity
setup_git_identity() {
    echo ""
    echo -e "${C_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo -e "${C_WHITE}  Git Identity${C_RESET}"
    echo -e "${C_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo ""
    
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [ -n "$current_name" ] && [ -n "$current_email" ]; then
        echo -e "${C_GREEN}✓${C_RESET} Git identity: ${C_WHITE}$current_name${C_RESET} <${C_CYAN}$current_email${C_RESET}>"
        
        if command -v gum &> /dev/null; then
            if ! gum confirm "Keep current settings? (Y/n)"; then
                current_name=""
                current_email=""
            fi
        else
            read -p "Keep current settings? (Y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                current_name=""
                current_email=""
            fi
        fi
    fi
    
    if [ -z "$current_name" ] || [ -z "$current_email" ]; then
        # Try to get defaults from GitHub CLI if authenticated
        local default_name=""
        local default_email=""
        if command -v gh &> /dev/null && gh auth status &>/dev/null; then
            default_name=$(gh api user -q '.name // empty' 2>/dev/null || echo "")
            default_email=$(gh api user -q '.email // empty' 2>/dev/null || echo "")
        fi
        
        # Fallback: system full name (macOS: id -F, Linux: getent)
        if [ -z "$default_name" ]; then
            if [[ "$(uname)" == "Darwin" ]]; then
                default_name=$(id -F 2>/dev/null || echo "")
            else
                default_name=$(getent passwd "$USER" 2>/dev/null | cut -d: -f5 | cut -d, -f1)
            fi
        fi
        
        echo -e "${C_GRAY}Enter your full name and email for Git commits.${C_RESET}"
        echo ""
    fi
    
    if [ -z "$current_name" ]; then
        if command -v gum &> /dev/null; then
            local new_name=$(gum input --placeholder "John Doe" --value "$default_name" --header "Git user name (your full name):")
            [ -n "$new_name" ] && git config --global user.name "$new_name"
        else
            if [ -n "$default_name" ]; then
                read -p "Git user name (your full name) [$default_name]: " new_name
                [ -z "$new_name" ] && new_name="$default_name"
            else
                read -p "Git user name (your full name): " new_name
            fi
            [ -n "$new_name" ] && git config --global user.name "$new_name"
        fi
    fi
    
    if [ -z "$current_email" ]; then
        if command -v gum &> /dev/null; then
            local new_email=$(gum input --placeholder "you@example.com" --value "$default_email" --header "Git email:")
            [ -n "$new_email" ] && git config --global user.email "$new_email"
        else
            if [ -n "$default_email" ]; then
                read -p "Git email [$default_email]: " new_email
                [ -z "$new_email" ] && new_email="$default_email"
            else
                read -p "Git email: " new_email
            fi
            [ -n "$new_email" ] && git config --global user.email "$new_email"
        fi
    fi
    
    local final_name=$(git config --global user.name 2>/dev/null || echo "Not set")
    local final_email=$(git config --global user.email 2>/dev/null || echo "Not set")
    echo -e "${C_GREEN}✓${C_RESET} Git configured: ${C_WHITE}$final_name${C_RESET} <${C_CYAN}$final_email${C_RESET}>"
}

# Install GitHub Copilot CLI after auth
setup_copilot_cli() {
    if ! command -v gh &> /dev/null; then
        return 0
    fi
    
    if ! gh auth status &>/dev/null; then
        return 0
    fi
    
    # Check if copilot extension is already installed
    if gh extension list 2>/dev/null | grep -q "gh-copilot"; then
        echo -e "${C_GREEN}✓${C_RESET} GitHub Copilot CLI already installed"
        return 0
    fi
    
    echo ""
    echo -e "${C_CYAN}Installing GitHub Copilot CLI...${C_RESET}"
    
    if gh extension install github/gh-copilot 2>/dev/null; then
        echo -e "${C_GREEN}✓${C_RESET} GitHub Copilot CLI installed"
        echo -e "  ${C_GRAY}Try: gh copilot suggest 'deploy k8s pod'${C_RESET}"
    else
        echo -e "${C_YELLOW}⚠${C_RESET} Could not install Copilot CLI (requires Copilot subscription)"
    fi
}

# Show helpful tips
show_tips() {
    echo ""
    echo -e "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo -e "${C_WHITE}  Quick Start Tips${C_RESET}"
    echo -e "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo ""
    echo -e "  ${C_CYAN}kodra theme${C_RESET}      - Switch between themes"
    echo -e "  ${C_CYAN}kodra wallpaper${C_RESET}  - Browse and set wallpapers"
    echo -e "  ${C_CYAN}kodra update${C_RESET}     - Update Kodra to latest version"
    echo ""
    echo -e "  ${C_GRAY}Cloud-native workflow:${C_RESET}"
    echo -e "  ${C_WHITE}gh repo clone${C_RESET}    Clone a repository"
    echo -e "  ${C_WHITE}azd init${C_RESET}         Initialize Azure app"
    echo -e "  ${C_WHITE}azd up${C_RESET}           Deploy to Azure"
    echo -e "  ${C_WHITE}k9s${C_RESET}              Kubernetes dashboard"
    echo ""
    echo -e "  ${C_GRAY}Terminal aliases (type to use):${C_RESET}"
    echo -e "  ${C_PURPLE}k${C_RESET}  kubectl    ${C_PURPLE}h${C_RESET}  helm    ${C_PURPLE}g${C_RESET}  git    ${C_PURPLE}ll${C_RESET}  eza -la"
    echo ""
}

# Main first-run flow
run_first_run() {
    echo ""
    echo -e "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo -e "${C_WHITE}  🚀  Kodra First-Run Setup${C_RESET}"
    echo -e "${C_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo ""
    echo -e "${C_GRAY}Let's configure your development environment!${C_RESET}"
    
    setup_git_identity
    setup_github
    setup_copilot_cli
    setup_azure
    show_tips
    
    complete_first_run
    
    echo ""
    echo -e "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo -e "${C_WHITE}  ✨  Setup Complete!${C_RESET}"
    echo -e "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
    echo ""
    echo -e "${C_WHITE}  Log out and back in${C_RESET} to activate all changes."
    echo -e "${C_GRAY}  Extensions and dock will configure automatically.${C_RESET}"
    echo -e "${C_GRAY}  You'll see a notification when it's complete.${C_RESET}"
    echo ""
    echo -e "${C_GRAY}  Then launch ${C_CYAN}Ghostty${C_GRAY} for your new terminal.${C_RESET}"
    echo ""
}

# Parse args
case "${1:-}" in
    --check)
        is_first_run && echo "yes" || echo "no"
        ;;
    --skip)
        complete_first_run
        echo "First run skipped."
        ;;
    *)
        if is_first_run || [ "${1:-}" = "--force" ]; then
            run_first_run
        else
            echo "First-run setup already completed."
            echo "Run with --force to run again."
        fi
        ;;
esac
