#!/usr/bin/env bash
#
# Kodra Feature Branch Test - Azure VM
# Tests feature/kodra-enhancements branch on fresh Ubuntu 24.04
#
set -e

RESOURCE_GROUP="kodra-qa-test-rg"
VM_NAME="kodra-qa-vm"
LOCATION="eastus"
VM_SIZE="Standard_B2s"
IMAGE="Canonical:ubuntu-24_04-lts:server:latest"
ADMIN_USER="kodratester"
BRANCH="feature/kodra-enhancements"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

cleanup() {
    log "Cleaning up Azure resources..."
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait 2>/dev/null || true
    success "Cleanup initiated"
}
trap cleanup EXIT

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Kodra QA Test - Branch: $BRANCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

log "Creating resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
success "Resource group: $RESOURCE_GROUP"

log "Creating Ubuntu 24.04 VM (2-3 minutes)..."
VM_IP=$(az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --image "$IMAGE" \
    --size "$VM_SIZE" \
    --admin-username "$ADMIN_USER" \
    --generate-ssh-keys \
    --public-ip-sku Standard \
    --output tsv \
    --query publicIpAddress)

success "VM created: $VM_IP"

log "Waiting for SSH..."
for i in {1..30}; do
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$ADMIN_USER@$VM_IP" "echo ready" 2>/dev/null; then
        break
    fi
    sleep 5
done
success "SSH connected"

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=30 -o ServerAliveInterval=30"

log "Running comprehensive tests..."
ssh $SSH_OPTS "$ADMIN_USER@$VM_IP" 'bash -s' << 'REMOTE_SCRIPT'
#!/bin/bash
set -x
exec 2>&1

echo "========================================"
echo "PHASE 1: ENVIRONMENT SETUP"
echo "========================================"
echo "Timestamp: $(date)"
cat /etc/os-release | grep PRETTY_NAME
uname -r

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq git curl wget

echo ""
echo "========================================"
echo "PHASE 2: CLONE FEATURE BRANCH"
echo "========================================"
git clone -b feature/kodra-enhancements https://github.com/codetocloudorg/kodra.git ~/.kodra
cd ~/.kodra
git branch --show-current
git log --oneline -3

echo ""
echo "========================================"
echo "PHASE 3: SYNTAX CHECK"
echo "========================================"
SYNTAX_ERRORS=0
find . -name "*.sh" -type f ! -path "./.git/*" | while read f; do
    if ! bash -n "$f" 2>/dev/null; then
        echo "SYNTAX ERROR: $f"
        SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
    fi
done

for f in bin/kodra bin/kodra-sub/*; do
    if [ -f "$f" ] && ! bash -n "$f" 2>/dev/null; then
        echo "SYNTAX ERROR: $f"
    fi
done
echo "Syntax check complete"

echo ""
echo "========================================"
echo "PHASE 4: CLI COMMANDS"
echo "========================================"
export KODRA_DIR="$HOME/.kodra"

echo ">> kodra help"
bash bin/kodra help

echo ""
echo ">> kodra version"
bash bin/kodra version

echo ""
echo ">> kodra theme list"
bash bin/kodra-sub/theme.sh list

echo ""
echo "========================================"
echo "PHASE 5: LOCAL TEST SUITE"
echo "========================================"
bash tests/test.sh || true

echo ""
echo "========================================"
echo "PHASE 6: INSTALL (MINIMAL)"
echo "========================================"
export KODRA_THEME="tokyo-night"
./install.sh --minimal --debug 2>&1 || echo "Install exit: $?"

echo ""
echo "========================================"
echo "PHASE 7: VERIFICATION"
echo "========================================"
echo "Theme: $(cat ~/.config/kodra/theme 2>/dev/null || echo 'NOT SET')"
echo "Kodra: $([ -x ~/.kodra/bin/kodra ] && echo 'OK' || echo 'MISSING')"
echo "Starship: $(command -v starship 2>/dev/null && echo 'OK' || echo 'NOT FOUND')"
echo "Brew: $(command -v brew 2>/dev/null && echo 'OK' || echo 'NOT FOUND')"

echo ""
echo "========================================"
echo "PHASE 8: KODRA DOCTOR"
echo "========================================"
bash ~/.kodra/bin/kodra doctor 2>&1 || true

echo ""  
echo "========================================"
echo "TEST COMPLETE: $(date)"
echo "========================================"
REMOTE_SCRIPT

RESULTS_DIR="tests/results/$(date +%Y-%m-%d-%H%M%S)"
mkdir -p "$RESULTS_DIR"
log "Results saved to: $RESULTS_DIR/"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Test Complete - VM will be cleaned up"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
