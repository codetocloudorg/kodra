#!/usr/bin/env bash
#
# Kodra First-Run Welcome
# Animated post-install welcome screen showing what was installed,
# quick-start commands, and keyboard shortcuts. Uses ANSI escape codes
# for color and a typewriter effect for key messages.
#

clear

# Print text one character at a time for a typewriter effect
# Arguments:
#   $1 - Text to display
#   $2 - Delay between characters in seconds (default: 0.03)
type_text() {
    local text="$1"
    local delay="${2:-0.03}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

# ANSI color codes (short names to keep banner lines readable)
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
B='\033[0;34m'
M='\033[0;35m'
C='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Rainbow ASCII banner — each line uses 256-color escapes for a gradient effect
echo ""
sleep 0.1
echo -e "\033[38;5;196m    ██╗  ██╗\033[38;5;208m ██████╗ \033[38;5;226m██████╗ \033[38;5;46m██████╗ \033[38;5;51m █████╗ \033[0m"
sleep 0.05
echo -e "\033[38;5;196m    ██║ ██╔╝\033[38;5;208m██╔═══██╗\033[38;5;226m██╔══██╗\033[38;5;46m██╔══██╗\033[38;5;51m██╔══██╗\033[0m"
sleep 0.05
echo -e "\033[38;5;196m    █████╔╝ \033[38;5;208m██║   ██║\033[38;5;226m██║  ██║\033[38;5;46m██████╔╝\033[38;5;51m███████║\033[0m"
sleep 0.05
echo -e "\033[38;5;196m    ██╔═██╗ \033[38;5;208m██║   ██║\033[38;5;226m██║  ██║\033[38;5;46m██╔══██╗\033[38;5;51m██╔══██║\033[0m"
sleep 0.05
echo -e "\033[38;5;196m    ██║  ██╗\033[38;5;208m╚██████╔╝\033[38;5;226m██████╔╝\033[38;5;46m██║  ██║\033[38;5;51m██║  ██║\033[0m"
sleep 0.05
echo -e "\033[38;5;196m    ╚═╝  ╚═╝\033[38;5;208m ╚═════╝ \033[38;5;226m╚═════╝ \033[38;5;46m╚═╝  ╚═╝\033[38;5;51m╚═╝  ╚═╝\033[0m"
echo ""
sleep 0.2

echo -e "    ${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
sleep 0.3

type_text "    ✨ Welcome to your new developer environment!" 0.02
echo ""
sleep 0.5

# Show what's installed
echo -e "    ${BOLD}${G}What's ready for you:${NC}"
echo ""

items=(
    "☁️  Azure CLI, azd, Bicep, Terraform, OpenTofu"
    "🤖 GitHub Copilot CLI - AI pair programming"  
    "🐳 Docker CE with Dev Containers"
    "👻 Ghostty terminal with Nerd Fonts"
    "⭐ Starship prompt - beautiful & fast"
    "📝 Neovim + VS Code with extensions"
    "🎨 Tokyo Night & Ghostty Blue themes"
    "🖼️  Curated wallpapers"
    "🖥️  Beautiful dock & polished desktop"
)

for item in "${items[@]}"; do
    sleep 0.15
    echo -e "    ${item}"
done

echo ""
sleep 0.3

echo -e "    ${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "    ${BOLD}${Y}Quick commands:${NC}"
echo ""
echo -e "    ${M}kodra theme${NC}       Switch between themes"
echo -e "    ${M}kodra wallpaper${NC}   Change wallpaper"
echo -e "    ${M}kodra desktop${NC}     Configure dock & desktop"
echo -e "    ${M}kodra fetch${NC}       Show system info"
echo -e "    ${M}kodra doctor${NC}      Check system health"
echo ""

echo -e "    ${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "    ${BOLD}${B}Keyboard shortcuts:${NC}"
echo ""
echo -e "    ${W}Super+Return${NC}      Open terminal"
echo -e "    ${W}Shift+Super+3${NC}     Screenshot (full)"
echo -e "    ${W}Shift+Super+4${NC}     Screenshot (area)"
echo -e "    ${W}Super+Space${NC}       Show all windows"
echo -e "    ${W}Super+Q${NC}           Close window"
echo ""

echo -e "    ${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

type_text "    🚀 You're all set. Build something amazing!" 0.02
echo ""
echo -e "    ${W}Documentation:${NC} ${C}https://kodra.codetocloud.io${NC}"
echo -e "    ${W}Discord:${NC}       ${C}https://discord.gg/vwfwq2EpXJ${NC}"
echo ""
