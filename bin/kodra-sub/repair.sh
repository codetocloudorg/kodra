#!/usr/bin/env bash
#
# Kodra Repair Command
# Re-apply all configurations without reinstalling apps
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
KODRA_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/kodra"

source "$KODRA_DIR/lib/utils.sh"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_help() {
    echo "Usage: kodra repair [option]"
    echo ""
    echo "Re-apply all configurations without reinstalling apps"
    echo ""
    echo "Options:"
    echo "  --all         Repair everything (default)"
    echo "  --shell       Repair shell configs only"
    echo "  --desktop     Repair desktop/GNOME only"
    echo "  --apps        Repair app desktop files only"
    echo "  --vscode      Repair VS Code settings only"
    echo ""
    echo "Examples:"
    echo "  kodra repair           # Fix everything"
    echo "  kodra repair --shell   # Just fix shell configs"
}

repair_shell_integration() {
    echo -e "${CYAN}━━━ Shell Integration ━━━${NC}"
    
    local kodra_dir="${KODRA_DIR:-$HOME/.kodra}"
    local source_line="[ -f \"$kodra_dir/configs/shell/kodra.sh\" ] && source \"$kodra_dir/configs/shell/kodra.sh\""
    
    # Add XDG_DATA_DIRS to ~/.profile for GNOME session
    if [ -f "$HOME/.profile" ]; then
        if ! grep -q "flatpak/exports/share" "$HOME/.profile"; then
            echo "" >> "$HOME/.profile"
            echo "# Kodra: Include Flatpak paths for GNOME app launcher" >> "$HOME/.profile"
            echo 'if [[ ! "$XDG_DATA_DIRS" =~ "flatpak" ]]; then' >> "$HOME/.profile"
            echo '    export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"' >> "$HOME/.profile"
            echo 'fi' >> "$HOME/.profile"
            echo "  ✓ Added XDG_DATA_DIRS to ~/.profile"
        else
            echo "  ✓ XDG_DATA_DIRS already in ~/.profile"
        fi
    fi
    
    # Add to .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "kodra.sh" "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo "# Kodra shell integration (aliases, completions, tips)" >> "$HOME/.bashrc"
            echo "$source_line" >> "$HOME/.bashrc"
            echo "  ✓ Added Kodra integration to ~/.bashrc"
        else
            echo "  ✓ Kodra integration already in ~/.bashrc"
        fi
    fi
    
    # Add to .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "kodra.sh" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# Kodra shell integration (aliases, completions, tips)" >> "$HOME/.zshrc"
            echo "$source_line" >> "$HOME/.zshrc"
            echo "  ✓ Added Kodra integration to ~/.zshrc"
        else
            echo "  ✓ Kodra integration already in ~/.zshrc"
        fi
    fi
    
    # Ensure EDITOR is set
    if ! grep -q "EDITOR=nvim" "$HOME/.bashrc" 2>/dev/null && command -v nvim &>/dev/null; then
        echo 'export EDITOR=nvim' >> "$HOME/.bashrc"
        echo "  ✓ Set EDITOR=nvim in ~/.bashrc"
    fi
    if [ -f "$HOME/.zshrc" ] && ! grep -q "EDITOR=nvim" "$HOME/.zshrc" 2>/dev/null && command -v nvim &>/dev/null; then
        echo 'export EDITOR=nvim' >> "$HOME/.zshrc"
        echo "  ✓ Set EDITOR=nvim in ~/.zshrc"
    fi
    
    echo ""
}

repair_app_desktop_files() {
    echo -e "${CYAN}━━━ Application Desktop Files ━━━${NC}"
    
    mkdir -p "$HOME/.local/share/applications"
    
    # Neovim desktop file
    if command -v nvim &>/dev/null; then
        local nvim_path=$(command -v nvim)
        cat > "$HOME/.local/share/applications/nvim.desktop" << EOF
[Desktop Entry]
Name=Neovim
GenericName=Text Editor
Comment=Edit text files
Exec=$nvim_path %F
Terminal=true
Type=Application
Keywords=Text;editor;vim;nvim;
Icon=nvim
Categories=Utility;TextEditor;
StartupNotify=false
MimeType=text/plain;text/x-c;text/x-c++;text/x-java;text/x-python;text/x-shellscript;
EOF
        echo "  ✓ Created Neovim desktop file"
    fi
    
    # btop desktop file
    if command -v btop &>/dev/null; then
        cat > "$HOME/.local/share/applications/btop.desktop" << EOF
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
        echo "  ✓ Created btop desktop file"
    fi
    
    # lazygit desktop file
    if command -v lazygit &>/dev/null; then
        cat > "$HOME/.local/share/applications/lazygit.desktop" << EOF
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
        echo "  ✓ Created LazyGit desktop file"
    fi
    
    # lazydocker desktop file
    if command -v lazydocker &>/dev/null; then
        cat > "$HOME/.local/share/applications/lazydocker.desktop" << EOF
[Desktop Entry]
Name=LazyDocker
GenericName=Docker Client
Comment=Simple terminal UI for docker commands
Exec=lazydocker
Terminal=true
Type=Application
Keywords=docker;container;
Icon=docker
Categories=Development;
EOF
        echo "  ✓ Created LazyDocker desktop file"
    fi
    
    # k9s desktop file
    if command -v k9s &>/dev/null; then
        cat > "$HOME/.local/share/applications/k9s.desktop" << EOF
[Desktop Entry]
Name=K9s
GenericName=Kubernetes CLI
Comment=Kubernetes cluster manager
Exec=k9s
Terminal=true
Type=Application
Keywords=kubernetes;k8s;cluster;
Icon=utilities-terminal
Categories=Development;
EOF
        echo "  ✓ Created K9s desktop file"
    fi
    
    # Update desktop database
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    echo "  ✓ Updated desktop database"
    echo ""
}

repair_vscode_settings() {
    echo -e "${CYAN}━━━ VS Code Settings ━━━${NC}"
    
    if ! command -v code &>/dev/null; then
        echo "  ⚠ VS Code not installed, skipping"
        echo ""
        return
    fi
    
    # Get current theme
    local current_theme="tokyo-night"
    [ -f "$KODRA_CONFIG/theme" ] && current_theme=$(cat "$KODRA_CONFIG/theme")
    
    local vscode_settings_dir="$HOME/.config/Code/User"
    local vscode_settings_file="$vscode_settings_dir/settings.json"
    local kodra_theme_settings="$KODRA_DIR/themes/$current_theme/vscode-settings.json"
    
    mkdir -p "$vscode_settings_dir"
    
    if [ -f "$kodra_theme_settings" ]; then
        if [ -f "$vscode_settings_file" ]; then
            if command -v jq &>/dev/null; then
                jq -s '.[0] * .[1]' "$vscode_settings_file" "$kodra_theme_settings" > "${vscode_settings_file}.tmp" 2>/dev/null && \
                    mv "${vscode_settings_file}.tmp" "$vscode_settings_file" && \
                    echo "  ✓ Applied $current_theme theme (merged)"
            else
                cp "$kodra_theme_settings" "$vscode_settings_file"
                echo "  ✓ Applied $current_theme theme"
            fi
        else
            cp "$kodra_theme_settings" "$vscode_settings_file"
            echo "  ✓ Applied $current_theme theme"
        fi
    else
        echo "  ⚠ Theme settings not found at $kodra_theme_settings"
    fi
    echo ""
}

repair_terminal_configs() {
    echo -e "${CYAN}━━━ Terminal Configurations ━━━${NC}"
    
    # Get current theme
    local current_theme="tokyo-night"
    [ -f "$KODRA_CONFIG/theme" ] && current_theme=$(cat "$KODRA_CONFIG/theme")
    
    # Starship config
    if command -v starship &>/dev/null; then
        local starship_config="$HOME/.config/starship.toml"
        local kodra_starship="$KODRA_DIR/themes/$current_theme/starship.toml"
        
        if [ -f "$kodra_starship" ]; then
            mkdir -p "$(dirname "$starship_config")"
            cp "$kodra_starship" "$starship_config"
            echo "  ✓ Applied Starship config ($current_theme)"
        fi
    fi
    
    # Ghostty config
    if command -v ghostty &>/dev/null; then
        local ghostty_config="$HOME/.config/ghostty/config"
        local kodra_ghostty="$KODRA_DIR/themes/$current_theme/ghostty.conf"
        
        if [ -f "$kodra_ghostty" ]; then
            mkdir -p "$(dirname "$ghostty_config")"
            cp "$kodra_ghostty" "$ghostty_config"
            echo "  ✓ Applied Ghostty config ($current_theme)"
        fi
    fi
    
    # btop config
    if command -v btop &>/dev/null; then
        local btop_config="$HOME/.config/btop/btop.conf"
        local kodra_btop="$KODRA_DIR/configs/btop/btop.conf"
        
        if [ -f "$kodra_btop" ]; then
            mkdir -p "$(dirname "$btop_config")"
            cp "$kodra_btop" "$btop_config"
            echo "  ✓ Applied btop config"
        fi
        
        # btop theme
        local btop_theme_dir="$HOME/.config/btop/themes"
        local kodra_btop_theme="$KODRA_DIR/configs/btop/themes/tokyo-night.theme"
        if [ -f "$kodra_btop_theme" ]; then
            mkdir -p "$btop_theme_dir"
            cp "$kodra_btop_theme" "$btop_theme_dir/"
            echo "  ✓ Applied btop Tokyo Night theme"
        fi
    fi
    
    # Neovim config
    if command -v nvim &>/dev/null; then
        local nvim_config="$HOME/.config/nvim/init.lua"
        local kodra_nvim="$KODRA_DIR/configs/nvim/init.lua"
        
        if [ -f "$kodra_nvim" ]; then
            mkdir -p "$(dirname "$nvim_config")"
            cp "$kodra_nvim" "$nvim_config"
            echo "  ✓ Applied Neovim config"
        fi
    fi
    
    # fastfetch config
    if command -v fastfetch &>/dev/null; then
        local ff_config="$HOME/.config/fastfetch/config.jsonc"
        local kodra_ff="$KODRA_DIR/configs/fastfetch/config.jsonc"
        
        if [ -f "$kodra_ff" ]; then
            mkdir -p "$(dirname "$ff_config")"
            cp "$kodra_ff" "$ff_config"
            echo "  ✓ Applied fastfetch config"
        fi
    fi
    
    echo ""
}

repair_desktop() {
    echo -e "${CYAN}━━━ Desktop Environment ━━━${NC}"
    
    # Run desktop refresh which handles extensions, dock, etc.
    if [ -f "$KODRA_DIR/bin/kodra-sub/desktop.sh" ]; then
        bash "$KODRA_DIR/bin/kodra-sub/desktop.sh" refresh
    fi
}

repair_all() {
    echo ""
    echo -e "\033[38;5;51m╔════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[38;5;51m║\033[0m  \033[1m🔧 Kodra Repair\033[0m                                           \033[38;5;51m║\033[0m"
    echo -e "\033[38;5;51m║\033[0m  Re-applying all configurations...                        \033[38;5;51m║\033[0m"
    echo -e "\033[38;5;51m╚════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
    
    repair_shell_integration
    repair_app_desktop_files
    repair_terminal_configs
    repair_vscode_settings
    repair_desktop
    
    echo ""
    echo -e "\033[38;5;46m╔════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[38;5;46m║\033[0m  \033[1m✅ Repair Complete!\033[0m                                       \033[38;5;46m║\033[0m"
    echo -e "\033[38;5;46m╠════════════════════════════════════════════════════════════╣\033[0m"
    echo -e "\033[38;5;46m║\033[0m                                                            \033[38;5;46m║\033[0m"
    echo -e "\033[38;5;46m║\033[0m  ${YELLOW}IMPORTANT:${NC} Log out and log back in for Flatpak apps    \033[38;5;46m║\033[0m"
    echo -e "\033[38;5;46m║\033[0m  to appear in the app launcher.                           \033[38;5;46m║\033[0m"
    echo -e "\033[38;5;46m║\033[0m                                                            \033[38;5;46m║\033[0m"
    echo -e "\033[38;5;46m╚════════════════════════════════════════════════════════════╝\033[0m"
    echo ""
}

# Parse arguments
case "${1:-all}" in
    --help|-h|help)
        show_help
        ;;
    --all|all|"")
        repair_all
        ;;
    --shell|shell)
        echo ""
        repair_shell_integration
        echo -e "${GREEN}✓ Shell repair complete${NC}"
        ;;
    --desktop|desktop)
        echo ""
        repair_desktop
        ;;
    --apps|apps)
        echo ""
        repair_app_desktop_files
        echo -e "${GREEN}✓ App desktop files repaired${NC}"
        ;;
    --vscode|vscode)
        echo ""
        repair_vscode_settings
        echo -e "${GREEN}✓ VS Code settings repaired${NC}"
        ;;
    --terminal|terminal)
        echo ""
        repair_terminal_configs
        echo -e "${GREEN}✓ Terminal configs repaired${NC}"
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
