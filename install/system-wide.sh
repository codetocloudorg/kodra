#!/usr/bin/env bash
#
# Kodra System-Wide Installation
# Installs Kodra for all users on the system
#
# This script:
# 1. Copies Kodra to /opt/kodra (root-owned, world-readable)
# 2. Creates /usr/local/bin/kodra symlink
# 3. Creates /etc/profile.d/kodra.sh for login shells
# 4. Each user runs 'kodra setup' for personal config
#

set -e

KODRA_SOURCE="${KODRA_DIR:-$HOME/.kodra}"
KODRA_SYSTEM_DIR="/opt/kodra"
KODRA_BIN="/usr/local/bin/kodra"
KODRA_PROFILE="/etc/profile.d/kodra.sh"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Must be root
if [ "$(id -u)" -ne 0 ]; then
    log_error "System-wide installation requires root. Run with sudo."
    echo "  Usage: sudo bash install/system-wide.sh"
    exit 1
fi

echo ""
log_info "Installing Kodra system-wide..."
echo ""

# Step 1: Copy to /opt/kodra
log_info "Copying Kodra to $KODRA_SYSTEM_DIR..."
if [ -d "$KODRA_SYSTEM_DIR" ]; then
    # Backup existing
    mv "$KODRA_SYSTEM_DIR" "${KODRA_SYSTEM_DIR}.bak.$(date +%s)"
fi

cp -a "$KODRA_SOURCE" "$KODRA_SYSTEM_DIR"

# Set ownership: root-owned, world-readable
chown -R root:root "$KODRA_SYSTEM_DIR"
chmod -R a+rX "$KODRA_SYSTEM_DIR"
# Ensure scripts are executable
find "$KODRA_SYSTEM_DIR/bin" -type f -exec chmod a+rx {} \;
find "$KODRA_SYSTEM_DIR/install" -name "*.sh" -exec chmod a+rx {} \;
find "$KODRA_SYSTEM_DIR/migrations" -name "*.sh" -exec chmod a+rx {} \;

log_success "Kodra installed to $KODRA_SYSTEM_DIR"

# Step 2: Create CLI symlink
log_info "Creating CLI symlink..."
ln -sf "$KODRA_SYSTEM_DIR/bin/kodra" "$KODRA_BIN"
chmod a+rx "$KODRA_BIN"
log_success "CLI available at $KODRA_BIN"

# Step 3: Create system-wide profile script
log_info "Creating login profile..."
cat > "$KODRA_PROFILE" << 'EOF'
# Kodra Developer Environment
# This file is sourced by login shells for all users
# Per-user setup: run 'kodra setup' to initialize your personal config

export KODRA_DIR="/opt/kodra"
export PATH="$KODRA_DIR/bin:$PATH"

# Only run shell integration if user has initialized Kodra
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/kodra/initialized" ]; then
    if [ -f "$KODRA_DIR/configs/shell/kodra.sh" ]; then
        . "$KODRA_DIR/configs/shell/kodra.sh"
    fi
fi
EOF

chmod 644 "$KODRA_PROFILE"
log_success "Profile installed at $KODRA_PROFILE"

# Step 4: Create per-user init script
log_info "Setting up per-user initialization..."
cat > "$KODRA_SYSTEM_DIR/bin/kodra-user-init" << 'INITEOF'
#!/usr/bin/env bash
#
# Kodra Per-User Initialization
# Run by each user to set up their personal configuration
#

KODRA_DIR="${KODRA_DIR:-/opt/kodra}"
KODRA_USER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "$KODRA_DIR/lib/utils.sh"

echo ""
log_info "Initializing Kodra for user: $USER"
echo ""

# Create user config directory
mkdir -p "$KODRA_USER_CONFIG"
mkdir -p "$KODRA_USER_CONFIG/shell"

# Set default theme if not set
if [ ! -f "$KODRA_USER_CONFIG/theme" ]; then
    echo "tokyo-night" > "$KODRA_USER_CONFIG/theme"
    log_info "Default theme: tokyo-night"
fi

# Apply config layering for this user
if [ -f "$KODRA_DIR/lib/config.sh" ]; then
    source "$KODRA_DIR/lib/config.sh"
    apply_all_configs
    log_success "Configs applied"
fi

# Add shell integration
source "$KODRA_DIR/lib/utils.sh"
add_shell_integration

# Mark as initialized
touch "$KODRA_USER_CONFIG/initialized"

log_success "Kodra initialized for $USER!"
echo ""
echo "  Theme:    $(cat "$KODRA_USER_CONFIG/theme")"
echo "  Config:   $KODRA_USER_CONFIG"
echo ""
echo "  Restart your shell or run: source ~/.bashrc"
echo "  Change theme: kodra theme"
echo ""
INITEOF

chmod a+rx "$KODRA_SYSTEM_DIR/bin/kodra-user-init"

echo ""
log_success "System-wide installation complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Kodra is now available to ALL users on this system."
echo ""
echo "  Each user should run:"
echo "    kodra setup"
echo ""
echo "  This initializes their personal theme, shell integration,"
echo "  and configuration overrides."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
