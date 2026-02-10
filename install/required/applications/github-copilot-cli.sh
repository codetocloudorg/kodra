#!/usr/bin/env bash
#
# GitHub Copilot CLI Installer
# AI-powered command line assistance
# https://docs.github.com/copilot/github-copilot-in-the-cli
#

# Don't use set -e - we handle errors gracefully

# Requires GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI is required. Installing first..."
    source "$KODRA_DIR/install/required/applications/github-cli.sh"
fi

# Check if Copilot extension is already installed
if gh extension list 2>/dev/null | grep -q "gh-copilot"; then
    echo "GitHub Copilot CLI already installed"
    gh copilot --version 2>/dev/null || true
    exit 0
fi

# Check if user is authenticated with GitHub CLI
if ! gh auth status &>/dev/null; then
    echo ""
    echo "⚠️  GitHub Copilot CLI requires authentication."
    echo "   Run 'gh auth login' after installation completes,"
    echo "   then run 'gh extension install github/gh-copilot'"
    echo ""
    echo "   Skipping Copilot CLI installation for now..."
    exit 0
fi

# Install Copilot CLI extension
if gh extension install github/gh-copilot; then
    echo ""
    echo "GitHub Copilot CLI installed successfully!"
    echo ""
    echo "Usage:"
    echo "  gh copilot suggest 'create a new git branch'    Get command suggestions"
    echo "  gh copilot explain 'git rebase -i HEAD~3'       Explain a command"
    echo ""
    echo "Quick aliases (add to shell config):"
    echo "  alias '??'='gh copilot suggest -t shell'"
    echo "  alias 'git?'='gh copilot suggest -t git'"
    echo "  alias 'gh?'='gh copilot suggest -t gh'"
else
    echo ""
    echo "⚠️  Could not install GitHub Copilot CLI."
    echo "   This may require a GitHub Copilot subscription."
    echo "   After 'gh auth login', try: gh extension install github/gh-copilot"
    echo ""
fi
