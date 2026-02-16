#!/usr/bin/env bash
#
# Modern CLI Tools Installer
# Replacements for traditional Unix commands
#

set -e

echo "Installing modern CLI tools..."

# Tools to install via apt
APT_TOOLS=(
    "bat"          # cat replacement with syntax highlighting
    "fd-find"      # find replacement
    "ripgrep"      # grep replacement
    "fzf"          # fuzzy finder
    "jq"           # JSON processor
    "htop"         # top replacement
    "tree"         # Directory tree
    "tldr"         # Simplified man pages
    "httpie"       # curl alternative
)

# Note: apt-get update already run by main install.sh
sudo apt-get install -y "${APT_TOOLS[@]}"

# ─────────────────────────────────────────────────────────────────
# Install fastfetch (not in default Ubuntu repos)
# ─────────────────────────────────────────────────────────────────
if ! command -v fastfetch &> /dev/null; then
    echo "Installing fastfetch..."
    # Add fastfetch PPA
    if ! grep -q "fastfetch" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>/dev/null || true
        sudo apt-get update
    fi
    sudo apt-get install -y fastfetch 2>/dev/null || {
        # Fallback: download from GitHub releases
        echo "  Installing fastfetch from GitHub..."
        ARCH=$(uname -m)
        case $ARCH in
            x86_64) FF_ARCH="amd64" ;;
            aarch64|arm64) FF_ARCH="aarch64" ;;
            *) FF_ARCH="" ;;
        esac
        if [ -n "$FF_ARCH" ]; then
            FF_VERSION=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep -Po '"tag_name": "\K[^"]*' || echo "2.8.10")
            curl -sL "https://github.com/fastfetch-cli/fastfetch/releases/download/${FF_VERSION}/fastfetch-linux-${FF_ARCH}.deb" -o /tmp/fastfetch.deb
            sudo dpkg -i /tmp/fastfetch.deb 2>/dev/null || sudo apt-get install -f -y
            rm -f /tmp/fastfetch.deb
        fi
    }
fi

# Create symlinks for tools with different names
# bat is 'batcat' on Ubuntu
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
fi

# fd is 'fdfind' on Ubuntu
if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
fi

# Install tools via Homebrew (more recent versions)
if command -v brew &> /dev/null; then
    BREW_TOOLS=(
        "eza"          # ls replacement
        "zoxide"       # cd replacement
        "lazygit"      # Git TUI
        "btop"         # Resource monitor
        "yq"           # YAML processor
        "glow"         # Markdown renderer
        "dust"         # du replacement
        "duf"          # df replacement
        "procs"        # ps replacement
        "delta"        # git diff pager
    )
    
    for tool in "${BREW_TOOLS[@]}"; do
        echo "Installing $tool via Homebrew..."
        brew install "$tool" || true
    done
else
    # Fallback: Install key tools via cargo or direct download
    echo "Homebrew not found, installing essential tools via alternative methods..."
    
    # Install eza (ls replacement) via cargo or deb
    if ! command -v eza &> /dev/null; then
        echo "Installing eza..."
        # Try apt first (available in Ubuntu 24.04+)
        if sudo apt-get install -y eza 2>/dev/null; then
            echo "eza installed via apt"
        elif command -v cargo &> /dev/null; then
            cargo install eza
        else
            # Direct binary download for eza
            EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -Po '"tag_name": "\K[^"]*' | tr -d 'v')
            if [ -n "$EZA_VERSION" ]; then
                ARCH=$(uname -m)
                case $ARCH in
                    x86_64) ARCH="x86_64" ;;
                    aarch64|arm64) ARCH="aarch64" ;;
                esac
                curl -sL "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_${ARCH}-unknown-linux-gnu.tar.gz" | sudo tar xzf - -C /usr/local/bin eza 2>/dev/null || true
            fi
        fi
    fi
    
    # Install zoxide
    if ! command -v zoxide &> /dev/null; then
        echo "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
    
    # Install lazygit
    if ! command -v lazygit &> /dev/null; then
        echo "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "\K[^"]*' | tr -d 'v')
        if [ -n "$LAZYGIT_VERSION" ]; then
            ARCH=$(uname -m)
            case $ARCH in
                x86_64) ARCH="x86_64" ;;
                aarch64|arm64) ARCH="arm64" ;;
            esac
            curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz" | sudo tar xzf - -C /usr/local/bin lazygit
        fi
    fi
    
    # Install btop
    if ! command -v btop &> /dev/null; then
        echo "Installing btop..."
        sudo apt-get install -y btop 2>/dev/null || true
    fi
fi

# ─────────────────────────────────────────────────────────────
# Configure fastfetch
# ─────────────────────────────────────────────────────────────
if command -v fastfetch &> /dev/null; then
    echo "Configuring fastfetch..."
    mkdir -p "$HOME/.config/fastfetch"
    KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
    if [ -f "$KODRA_DIR/configs/fastfetch/config.jsonc" ]; then
        cp "$KODRA_DIR/configs/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    fi
fi

# ─────────────────────────────────────────────────────────────
# Configure btop with tokyo-night theme
# ─────────────────────────────────────────────────────────────
if command -v btop &> /dev/null; then
    echo "Configuring btop..."
    mkdir -p "$HOME/.config/btop/themes"
    KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
    if [ -f "$KODRA_DIR/configs/btop/btop.conf" ]; then
        cp "$KODRA_DIR/configs/btop/btop.conf" "$HOME/.config/btop/btop.conf"
    fi
    if [ -f "$KODRA_DIR/configs/btop/themes/tokyo-night.theme" ]; then
        cp "$KODRA_DIR/configs/btop/themes/tokyo-night.theme" "$HOME/.config/btop/themes/"
    fi
fi

# ─────────────────────────────────────────────────────────────
# Configure zoxide
# ─────────────────────────────────────────────────────────────
if command -v zoxide &> /dev/null; then
    # Add to bashrc
    if [ -f "$HOME/.bashrc" ] && ! grep -q "zoxide init" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo '# zoxide (smart cd)' >> "$HOME/.bashrc"
        echo 'eval "$(zoxide init bash)"' >> "$HOME/.bashrc"
    fi
    
    # Add to zshrc
    if [ -f "$HOME/.zshrc" ] && ! grep -q "zoxide init" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo '# zoxide (smart cd)' >> "$HOME/.zshrc"
        echo 'eval "$(zoxide init zsh)"' >> "$HOME/.zshrc"
    fi
fi

# ─────────────────────────────────────────────────────────────
# Create desktop files for CLI tools (so they appear in launcher)
# ─────────────────────────────────────────────────────────────
mkdir -p "$HOME/.local/share/applications"

if command -v btop &>/dev/null; then
    cat > "$HOME/.local/share/applications/btop.desktop" << 'EOF'
[Desktop Entry]
Name=btop
GenericName=System Monitor
Comment=Resource monitor that shows usage and stats
Exec=btop
Terminal=true
Type=Application
Keywords=system;monitor;task;
Icon=utilities-system-monitor
Categories=System;Monitor;
EOF
fi

if command -v lazygit &>/dev/null; then
    cat > "$HOME/.local/share/applications/lazygit.desktop" << 'EOF'
[Desktop Entry]
Name=LazyGit
GenericName=Git Client
Comment=Simple terminal UI for git commands
Exec=lazygit
Terminal=true
Type=Application
Keywords=git;vcs;version;
Icon=git
Categories=Development;RevisionControl;
EOF
fi

# Update desktop database
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo ""
echo "Modern CLI tools installed!"
echo ""
echo "Highlights:"
echo "  bat      - cat with syntax highlighting"
echo "  eza      - ls with icons and git integration"
echo "  fd       - faster find"
echo "  rg       - faster grep (ripgrep)"
echo "  fzf      - fuzzy finder"
echo "  zoxide   - smarter cd (use 'z' command)"
echo "  lazygit  - git terminal UI"
echo "  btop     - beautiful resource monitor"
