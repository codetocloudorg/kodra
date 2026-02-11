#!/usr/bin/env bash
#
# Kodra Azure VM Test
# Spins up a real Ubuntu 24.04 VM, installs Kodra, captures results
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - SSH key at ~/.ssh/id_rsa.pub
#
# Usage:
#   ./tests/test-azure-vm.sh              # Full test cycle
#   ./tests/test-azure-vm.sh --keep       # Keep VM for debugging
#   ./tests/test-azure-vm.sh --cleanup    # Just delete resources
#

set -e

# Configuration
RESOURCE_GROUP="kodra-test-rg"
VM_NAME="kodra-test-vm"
LOCATION="eastus"
VM_SIZE="Standard_B2s"  # 2 vCPU, 4GB RAM - ~$0.04/hour
IMAGE="Canonical:ubuntu-24_04-lts:server:latest"
ADMIN_USER="kodratester"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse args
KEEP_VM=false
CLEANUP_ONLY=false
for arg in "$@"; do
    case $arg in
        --keep) KEEP_VM=true ;;
        --cleanup) CLEANUP_ONLY=true ;;
    esac
done

log() { echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

cleanup() {
    log "Cleaning up Azure resources..."
    az group delete --name "$RESOURCE_GROUP" --yes --no-wait 2>/dev/null || true
    success "Cleanup initiated (runs in background)"
}

# Cleanup only mode
if [ "$CLEANUP_ONLY" = true ]; then
    cleanup
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Kodra Azure VM Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check prerequisites
log "Checking prerequisites..."
if ! command -v az &> /dev/null; then
    error "Azure CLI not installed. Run: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    exit 1
fi

if ! az account show &> /dev/null; then
    error "Not logged in to Azure. Run: az login"
    exit 1
fi

if [ ! -f ~/.ssh/id_rsa.pub ]; then
    error "No SSH key found. Run: ssh-keygen -t rsa -b 4096"
    exit 1
fi
success "Prerequisites OK"

# Create resource group
log "Creating resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
success "Resource group: $RESOURCE_GROUP"

# Create VM
log "Creating Ubuntu 24.04 VM (this takes ~2 minutes)..."
VM_IP=$(az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --image "$IMAGE" \
    --size "$VM_SIZE" \
    --admin-username "$ADMIN_USER" \
    --ssh-key-values ~/.ssh/id_rsa.pub \
    --public-ip-sku Standard \
    --output tsv \
    --query publicIpAddress)

success "VM created: $VM_IP"

# Wait for SSH
log "Waiting for SSH to be ready..."
for i in {1..30}; do
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$ADMIN_USER@$VM_IP" "echo ready" 2>/dev/null; then
        break
    fi
    sleep 5
done
success "SSH connected"

# SSH options for reliability
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=30 -o ServerAliveInterval=30"

# Install desktop environment (needed for GNOME tests)
log "Installing Ubuntu Desktop (this takes ~5 minutes)..."
ssh $SSH_OPTS "$ADMIN_USER@$VM_IP" << 'INSTALL_DESKTOP'
    set -e
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -qq
    sudo apt-get install -y -qq ubuntu-desktop-minimal gnome-shell gdm3 > /dev/null 2>&1
    echo "Desktop installed"
INSTALL_DESKTOP
success "Ubuntu Desktop installed"

# Run Kodra installation
log "Installing Kodra..."
INSTALL_LOG=$(ssh $SSH_OPTS "$ADMIN_USER@$VM_IP" << 'RUN_KODRA'
    set -e
    export KODRA_THEME="tokyo-night"
    export KODRA_MINIMAL=1
    
    # Clone and install
    git clone https://github.com/codetocloudorg/kodra.git ~/.kodra 2>/dev/null
    cd ~/.kodra
    
    # Run install in non-interactive mode
    ./install.sh --debug 2>&1 || true
    
    # Check results
    echo "=== VERIFICATION ==="
    echo "Theme file: $(cat ~/.config/kodra/theme 2>/dev/null || echo 'NOT SET')"
    echo "Kodra version: $(~/.kodra/bin/kodra version 2>/dev/null || echo 'NOT FOUND')"
    echo "Ghostty: $(command -v ghostty && echo 'OK' || echo 'NOT FOUND')"
    echo "VS Code: $(command -v code && echo 'OK' || echo 'NOT FOUND')"
    echo "Azure CLI: $(command -v az && echo 'OK' || echo 'NOT FOUND')"
    echo "Docker: $(command -v docker && echo 'OK' || echo 'NOT FOUND')"
    echo "Starship: $(command -v starship && echo 'OK' || echo 'NOT FOUND')"
    
    # Run doctor
    echo "=== KODRA DOCTOR ==="
    ~/.kodra/bin/kodra doctor 2>&1 || true
RUN_KODRA
)

echo "$INSTALL_LOG"

# Save results
RESULTS_DIR="tests/results/$(date +%Y-%m-%d-%H%M%S)"
mkdir -p "$RESULTS_DIR"
echo "$INSTALL_LOG" > "$RESULTS_DIR/install.log"

# Copy logs from VM
log "Collecting logs..."
scp $SSH_OPTS "$ADMIN_USER@$VM_IP:~/.config/kodra/install.log" "$RESULTS_DIR/" 2>/dev/null || true
scp $SSH_OPTS "$ADMIN_USER@$VM_IP:~/.config/kodra/state.json" "$RESULTS_DIR/" 2>/dev/null || true
success "Logs saved to $RESULTS_DIR/"

# Parse results
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Test Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check for failures
if echo "$INSTALL_LOG" | grep -q "NOT FOUND"; then
    warn "Some tools failed to install"
    echo "$INSTALL_LOG" | grep "NOT FOUND"
else
    success "All tools installed successfully"
fi

# Check doctor output
DOCTOR_PASSED=$(echo "$INSTALL_LOG" | grep -oP '\d+(?=/\d+ checks passed)' | tail -1)
DOCTOR_TOTAL=$(echo "$INSTALL_LOG" | grep -oP '\d+(?= checks passed)' | tail -1)
if [ -n "$DOCTOR_PASSED" ] && [ -n "$DOCTOR_TOTAL" ]; then
    if [ "$DOCTOR_PASSED" -eq "$DOCTOR_TOTAL" ]; then
        success "Doctor: $DOCTOR_PASSED/$DOCTOR_TOTAL checks passed"
    else
        warn "Doctor: $DOCTOR_PASSED/$DOCTOR_TOTAL checks passed"
    fi
fi

# Cleanup or keep
if [ "$KEEP_VM" = true ]; then
    echo ""
    warn "VM kept for debugging"
    echo "  SSH: ssh $ADMIN_USER@$VM_IP"
    echo "  Cleanup: ./tests/test-azure-vm.sh --cleanup"
else
    cleanup
fi

echo ""
echo "Results saved to: $RESULTS_DIR/"
echo ""
