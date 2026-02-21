#!/usr/bin/env bash
#
# GitHub Copilot CLI Installer
# AI-powered command line assistance
# https://docs.github.com/en/copilot/how-tos/copilot-cli/cli-getting-started
#

# Don't use set -e - we handle errors gracefully

# Check if copilot-cli is already installed (either version)
if command -v copilot &> /dev/null; then
    echo "GitHub Copilot CLI already installed (npm version)"
    copilot --version 2>/dev/null || true
    exit 0
fi

# Check if gh copilot extension is installed
if command -v gh &> /dev/null && gh extension list 2>/dev/null | grep -q "copilot"; then
    echo "GitHub Copilot CLI already installed (gh extension)"
    exit 0
fi

# Method 1: Try gh extension (requires gh auth)
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        echo "Installing GitHub Copilot CLI via gh extension..."
        if gh extension install github/gh-copilot 2>/dev/null; then
            echo ""
            echo "GitHub Copilot CLI installed successfully!"
            echo "Usage: gh copilot suggest 'your prompt'"
            exit 0
        fi
    else
        echo "Note: gh not authenticated, skipping gh-copilot extension"
    fi
fi

# Method 2: Install via npm (macOS/Linux/Windows)
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
        exit 0
    else
        echo "⚠️  npm install failed for GitHub Copilot CLI"
    fi
fi

# Neither method worked - provide helpful message and exit gracefully
echo ""
echo "ℹ️  GitHub Copilot CLI could not be installed automatically."
echo ""
echo "To install later, either:"
echo "  1. Run 'gh auth login' then 'gh extension install github/gh-copilot'"
echo "  2. Install Node.js via 'kodra dev setup node' then 'npm install -g @github/copilot'"
echo ""
# Exit 0 since this is optional - don't fail the overall install
exit 0
