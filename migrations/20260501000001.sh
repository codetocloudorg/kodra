#!/usr/bin/env bash
#
# Migration: Clean up duplicate Kodra lines in shell configs
# Date: 2026-05-01
# Description: Remove duplicate Kodra source lines from .bashrc/.zshrc
#

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

clean_duplicates() {
    local file="$1"
    [ -f "$file" ] || return 0
    
    # Create temp file with duplicates removed (keep first occurrence)
    local tmp=$(mktemp)
    awk '!seen[$0]++' "$file" > "$tmp"
    
    # Only replace if different
    if ! cmp -s "$file" "$tmp"; then
        cp "$tmp" "$file"
        echo "Cleaned duplicate lines in $file"
    fi
    
    rm -f "$tmp"
}

clean_duplicates "$HOME/.bashrc"
clean_duplicates "$HOME/.zshrc"
clean_duplicates "$HOME/.profile"

echo "Shell config cleanup complete"
