#!/usr/bin/env bash
#
# mise Installer
# Polyglot version manager (replacement for asdf, nvm, pyenv, etc.)
# https://mise.jdx.dev/
#

set -e

if command -v mise &> /dev/null; then
    echo "mise already installed: $(mise --version)"
    exit 0
fi

# Prefer Homebrew (always latest, proper package management)
if command -v brew &> /dev/null; then
    echo "Installing mise via Homebrew..."
    brew install mise
    MISE_BIN="$(brew --prefix)/bin"
else
    # Fallback: Official installer
    echo "Installing mise via official installer..."
    curl https://mise.run | sh
    MISE_BIN="$HOME/.local/bin"
fi

# Add to bashrc
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "mise activate" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo '# mise (polyglot version manager)' >> "$HOME/.bashrc"
        echo 'eval "$(mise activate bash)"' >> "$HOME/.bashrc"
    fi
fi

# Add to zshrc
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "mise activate" "$HOME/.zshrc"; then
        echo "" >> "$HOME/.zshrc"
        echo '# mise (polyglot version manager)' >> "$HOME/.zshrc"
        echo 'eval "$(mise activate zsh)"' >> "$HOME/.zshrc"
    fi
fi

# Activate for current session
export PATH="$MISE_BIN:$PATH"
eval "$(mise activate bash)"

# Install default runtimes for Azure/agentic development
echo "Installing Python and Node.js via mise..."
mise use --global python@latest
mise use --global node@lts

# Verify installation
mise --version

echo ""
echo "mise installed successfully!"
echo ""
echo "Installed runtimes:"
mise list
echo ""
echo "Usage:"
echo "  mise use python@3.12       Set Python version"
echo "  mise use node@20           Set Node.js version"
echo "  mise install               Install all versions from .mise.toml"
