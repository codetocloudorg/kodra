#!/usr/bin/env bash
#
# GitHub Copilot CLI Installer
# AI-powered command line assistance
# https://docs.github.com/en/copilot/how-tos/copilot-cli/cli-getting-started
#

# Don't use set -e - we handle errors gracefully

# Check if copilot-cli is already installed
if command -v copilot &> /dev/null; then
    echo "GitHub Copilot CLI already installed"
    copilot --version 2>/dev/null || true
    exit 0
fi

# Install via npm (macOS/Linux/Windows)
if command -v npm &> /dev/null; then
    echo "Installing GitHub Copilot CLI via npm..."
    if npm install -g @github/copilot; then
        echo ""
        echo "GitHub Copilot CLI installed successfully!"
        echo ""
        echo "Getting started:"
        echo "  copilot                           Start interactive session"
        echo "  /login                            Login (inside interactive session)"
        echo "  copilot -p 'your prompt'          Non-interactive mode"
        echo ""
        echo "Quick aliases (included in Kodra shell config):"
        echo "  ?? 'your question'                Ask Copilot"
        echo "  explain 'command'                 Explain a command"
        echo ""
    else
        echo ""
        echo "⚠️  Could not install GitHub Copilot CLI."
        echo "   Try: npm install -g @github/copilot"
        echo ""
        exit 1
    fi
else
    echo ""
    echo "⚠️  npm is required to install GitHub Copilot CLI."
    echo "   Install Node.js/npm first, then run: npm install -g @github/copilot"
    echo ""
    exit 1
fi
