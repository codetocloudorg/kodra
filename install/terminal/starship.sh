#!/usr/bin/env bash
#
# Starship Prompt Installer
# Minimal, fast, customizable cross-shell prompt
# https://starship.rs/
#

set -e

# Install Starship if not present
if ! command -v starship &> /dev/null; then
    # Prefer Homebrew (always latest)
    if command -v brew &> /dev/null; then
        echo "Installing Starship via Homebrew..."
        brew install starship
    else
        # Fallback: Official install script
        echo "Installing Starship via official installer..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
fi

# Always configure (even if already installed)
if command -v starship &> /dev/null; then
    # Create config directory
    mkdir -p "$HOME/.config"

    # Copy Kodra's Starship configuration
    KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
    CURRENT_THEME="${KODRA_THEME:-tokyo-night}"
    
    # Try theme-specific config first, then fall back to default
    if [ -f "$KODRA_DIR/themes/$CURRENT_THEME/starship.toml" ]; then
        cp "$KODRA_DIR/themes/$CURRENT_THEME/starship.toml" "$HOME/.config/starship.toml"
    elif [ -f "$KODRA_DIR/configs/starship/starship.toml" ]; then
        cp "$KODRA_DIR/configs/starship/starship.toml" "$HOME/.config/starship.toml"
    fi

    # Add to bashrc
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "starship init" "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo '# Starship prompt' >> "$HOME/.bashrc"
            echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
        fi
    fi

    # Add to zshrc
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "starship init" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo '# Starship prompt' >> "$HOME/.zshrc"
            echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
        fi
    fi

    # Verify installation
    starship --version

    echo "Starship prompt configured!"
fi
