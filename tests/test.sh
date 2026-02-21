#!/usr/bin/env bash
#
# Kodra User Experience Test
# Simulates exactly what a real user would do: wget from the website
#
# Usage:
#   ./tests/test.sh              # Run in Docker (safe, isolated)
#   ./tests/test.sh --local      # Run local syntax checks only
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KODRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

header() { echo -e "\n${CYAN}════════════════════════════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}\n"; }

# Local syntax check only
if [[ "$1" == "--local" ]]; then
    header "LOCAL SYNTAX CHECK"
    echo "Checking all shell scripts for syntax errors..."
    ERRORS=0
    for f in $(find "$KODRA_DIR" -name "*.sh" -type f ! -path "*/.git/*"); do
        if ! bash -n "$f" 2>/dev/null; then
            echo -e "${RED}✗${NC} $f"
            ERRORS=$((ERRORS + 1))
        fi
    done
    
    if [ $ERRORS -eq 0 ]; then
        echo -e "${GREEN}✓${NC} All scripts pass syntax check"
        exit 0
    else
        echo -e "${RED}$ERRORS scripts have errors${NC}"
        exit 1
    fi
fi

# Docker test - simulates real user
header "KODRA USER EXPERIENCE TEST"
echo "This runs in an isolated Ubuntu 24.04 container."
echo "Simulates: wget -qO- https://kodra.codetocloud.io/boot.sh | bash"
echo ""

if ! command -v docker &>/dev/null; then
    echo -e "${RED}Docker not installed. Install Docker or use --local for syntax checks only.${NC}"
    exit 1
fi

# Run the real user simulation in Docker
docker run --rm -it ubuntu:24.04 bash -c '
set -e

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"

header() { echo -e "\n${CYAN}════════════════════════════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}\n"; }

header "SYSTEM INFO"
cat /etc/os-release | grep -E "^(NAME|VERSION)="
uname -a

header "PHASE 1: INSTALL PREREQUISITES"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq wget curl git sudo 2>&1 | tail -3
echo -e "${GREEN}✓${NC} Prerequisites installed"

header "PHASE 2: WGET INSTALL (Like Real User)"
echo "Running: wget -qO- https://kodra.codetocloud.io/boot.sh | bash"
echo ""

# Set non-interactive install options
export KODRA_THEME="tokyo-night"
export KODRA_MINIMAL=1
export TERM=xterm-256color

# This is exactly what a user would run
wget -qO- https://kodra.codetocloud.io/boot.sh | bash --debug 2>&1 || echo "Install exited with code: $?"

header "PHASE 3: VERIFY INSTALLATION"
export KODRA_DIR="$HOME/.kodra"
export PATH="$KODRA_DIR/bin:$PATH"

echo "=== Kodra Directory ==="
ls -la ~/.kodra/ 2>/dev/null | head -20 || echo "NOT FOUND"

echo ""
echo "=== Theme ==="
cat ~/.config/kodra/theme 2>/dev/null || echo "NOT SET"

echo ""
echo "=== Kodra Version ==="
~/.kodra/bin/kodra version 2>&1 || echo "kodra command not working"

echo ""
echo "=== Kodra Help ==="
~/.kodra/bin/kodra help 2>&1 || echo "help failed"

header "PHASE 4: TEST ALL COMMANDS"
for cmd in "theme list" "theme current" "wallpaper list" "doctor" "shortcuts"; do
    echo ">> kodra $cmd"
    ~/.kodra/bin/kodra $cmd 2>&1 || echo "(failed)"
    echo ""
done

header "PHASE 5: TEST THEME SWITCHING"
for theme in tokyo-night ghostty-blue catppuccin gruvbox nord rose-pine; do
    echo ">> kodra theme $theme"
    ~/.kodra/bin/kodra theme "$theme" 2>&1 || echo "(failed)"
    echo "Current: $(cat ~/.config/kodra/theme 2>/dev/null)"
    echo ""
done

header "PHASE 6: TOOL VERIFICATION"
echo "Checking installed tools..."
for cmd in starship bat eza fzf rg fd zoxide jq git gh az docker brew; do
    if command -v "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC} $cmd"
    else
        echo -e "${YELLOW}○${NC} $cmd (not installed or not in PATH)"
    fi
done

header "TEST COMPLETE"
echo -e "${GREEN}All tests finished!${NC}"
'

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Docker test complete - your local system is unchanged${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
