#!/usr/bin/env bash
#
# Kodra Shortcuts - Display GNOME keybindings
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
DIM='\033[2m'

print_header() {
    echo ""
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                    Kodra Keyboard Shortcuts                    ${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_section() {
    echo -e "${CYAN}━━━ $1 ━━━${NC}"
}

print_shortcut() {
    printf "  ${YELLOW}%-30s${NC} %s\n" "$1" "$2"
}

show_gnome_shortcuts() {
    print_section "GNOME Desktop"
    print_shortcut "Super" "Open Activities / App Launcher"
    print_shortcut "Super + A" "Show Applications"
    print_shortcut "Super + L" "Lock Screen"
    print_shortcut "Super + D" "Show Desktop"
    print_shortcut "Super + Tab" "Switch Applications"
    print_shortcut "Alt + Tab" "Switch Windows"
    print_shortcut "Alt + F2" "Run Command"
    print_shortcut "Ctrl + Alt + T" "Open Terminal"
    print_shortcut "Super + Up" "Maximize Window"
    print_shortcut "Super + Down" "Restore/Minimize Window"
    print_shortcut "Super + Left/Right" "Tile Window Left/Right"
    print_shortcut "Super + H" "Minimize Window"
    print_shortcut "Alt + F4" "Close Window"
    echo ""
}

show_workspace_shortcuts() {
    print_section "Workspaces"
    print_shortcut "Super + Page Up/Down" "Switch Workspace"
    print_shortcut "Ctrl + Alt + Up/Down" "Switch Workspace"
    print_shortcut "Super + Shift + Page Up/Down" "Move Window to Workspace"
    print_shortcut "Super + Home" "First Workspace"
    print_shortcut "Super + End" "Last Workspace"
    echo ""
}

show_screenshot_shortcuts() {
    print_section "Screenshots"
    print_shortcut "Print" "Screenshot (Full Screen)"
    print_shortcut "Shift + Print" "Screenshot (Selection)"
    print_shortcut "Alt + Print" "Screenshot (Window)"
    print_shortcut "Ctrl + Print" "Screenshot to Clipboard"
    print_shortcut "Ctrl + Shift + Print" "Selection to Clipboard"
    echo ""
}

show_terminal_shortcuts() {
    print_section "Ghostty Terminal"
    print_shortcut "Ctrl + Shift + C" "Copy"
    print_shortcut "Ctrl + Shift + V" "Paste"
    print_shortcut "Ctrl + Shift + N" "New Window"
    print_shortcut "Ctrl + Shift + T" "New Tab"
    print_shortcut "Ctrl + Shift + W" "Close Tab"
    print_shortcut "Ctrl + Plus/Minus" "Zoom In/Out"
    print_shortcut "Ctrl + 0" "Reset Zoom"
    print_shortcut "Ctrl + Shift + F" "Find"
    print_shortcut "Shift + Page Up/Down" "Scroll"
    echo ""
}

show_kodra_shortcuts() {
    print_section "Kodra Commands"
    print_shortcut "kodra" "Show help"
    print_shortcut "kodra menu" "Interactive menu"
    print_shortcut "kodra theme" "Change theme"
    print_shortcut "kodra wallpaper" "Change wallpaper"
    print_shortcut "kodra fetch" "System info"
    print_shortcut "kodra update" "Update system"
    print_shortcut "kodra doctor" "Check system health"
    print_shortcut "kodra power" "Power profile"
    print_shortcut "kodra nightlight" "Toggle night light"
    echo ""
}

show_shell_shortcuts() {
    print_section "Shell (FZF + Zoxide)"
    print_shortcut "Ctrl + R" "Search command history"
    print_shortcut "Ctrl + T" "Fuzzy file search"
    print_shortcut "Alt + C" "Fuzzy cd to directory"
    print_shortcut "z <dir>" "Smart directory jump"
    print_shortcut "zz" "Fuzzy cd with preview"
    print_shortcut "fe" "Fuzzy edit file"
    print_shortcut "fkill" "Fuzzy process kill"
    print_shortcut "fco" "Fuzzy git checkout"
    print_shortcut "dsh" "Docker shell picker"
    echo ""
}

show_tmux_shortcuts() {
    print_section "Tmux (prefix: Ctrl+Space)"
    print_shortcut "Ctrl+Space |" "Split vertical"
    print_shortcut "Ctrl+Space -" "Split horizontal"
    print_shortcut "Ctrl+Space h/j/k/l" "Navigate panes"
    print_shortcut "Ctrl+Space c" "New window"
    print_shortcut "Ctrl+Space x" "Kill pane"
    print_shortcut "Ctrl+Space [" "Copy mode (vi)"
    print_shortcut "Shift + Left/Right" "Switch windows"
    print_shortcut "Alt + Arrow" "Switch panes (no prefix)"
    print_shortcut "Ctrl+Space r" "Reload config"
    echo ""
}

# Export shortcuts to file (#87)
export_shortcuts() {
    local output_file="${1:-$HOME/.kodra/backups/shortcuts-$(date +%Y%m%d-%H%M%S).conf}"
    local backup_dir=$(dirname "$output_file")
    
    mkdir -p "$backup_dir"
    
    echo "# Kodra Keyboard Shortcuts Export" > "$output_file"
    echo "# Exported: $(date)" >> "$output_file"
    echo "# System: $(hostname)" >> "$output_file"
    echo "" >> "$output_file"
    
    # Export GNOME custom keybindings
    if command -v gsettings &>/dev/null; then
        echo "[gnome.settings-daemon.plugins.media-keys]" >> "$output_file"
        
        # Get custom keybinding paths
        local custom_list=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || echo "[]")
        echo "custom-keybindings=$custom_list" >> "$output_file"
        echo "" >> "$output_file"
        
        # Export each custom keybinding
        echo "$custom_list" | tr -d "[]'" | tr ',' '\n' | while read -r path; do
            path=$(echo "$path" | xargs)
            if [ -n "$path" ]; then
                local name=$(dconf read "$path/name" 2>/dev/null | tr -d "'")
                local command=$(dconf read "$path/command" 2>/dev/null | tr -d "'")
                local binding=$(dconf read "$path/binding" 2>/dev/null | tr -d "'")
                
                echo "[$path]" >> "$output_file"
                echo "name=$name" >> "$output_file"
                echo "command=$command" >> "$output_file"
                echo "binding=$binding" >> "$output_file"
                echo "" >> "$output_file"
            fi
        done
        
        # Export standard GNOME shortcuts
        echo "[gnome.desktop.wm.keybindings]" >> "$output_file"
        for key in switch-to-workspace-1 switch-to-workspace-2 switch-to-workspace-3 switch-to-workspace-4 \
                   move-to-workspace-1 move-to-workspace-2 move-to-workspace-3 move-to-workspace-4 \
                   maximize minimize close; do
            local value=$(gsettings get org.gnome.desktop.wm.keybindings "$key" 2>/dev/null || echo "")
            [ -n "$value" ] && echo "$key=$value" >> "$output_file"
        done
        echo "" >> "$output_file"
        
        # Export shell shortcuts
        echo "[gnome.shell.keybindings]" >> "$output_file"
        for key in toggle-application-view toggle-overview; do
            local value=$(gsettings get org.gnome.shell.keybindings "$key" 2>/dev/null || echo "")
            [ -n "$value" ] && echo "$key=$value" >> "$output_file"
        done
    fi
    
    echo -e "${GREEN}✓${NC} Exported to: $output_file"
}

# Import shortcuts from file (#87)
import_shortcuts() {
    local input_file="$1"
    
    if [ -z "$input_file" ] || [ ! -f "$input_file" ]; then
        echo -e "${RED}Error:${NC} File not found: $input_file"
        echo "Usage: kodra shortcuts import <file>"
        exit 1
    fi
    
    echo -e "${CYAN}Importing shortcuts from:${NC} $input_file"
    
    if ! command -v gsettings &>/dev/null; then
        echo -e "${RED}Error:${NC} gsettings not available"
        exit 1
    fi
    
    local current_section=""
    local custom_path=""
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue
        
        # Section header
        if [[ "$line" =~ ^\[.*\]$ ]]; then
            current_section="${line:1:-1}"
            if [[ "$current_section" == /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/* ]]; then
                custom_path="$current_section"
            else
                custom_path=""
            fi
            continue
        fi
        
        # Key=value
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            if [ -n "$custom_path" ]; then
                # Custom keybinding
                dconf write "$custom_path/$key" "'$value'" 2>/dev/null || true
            elif [[ "$current_section" == "gnome.desktop.wm.keybindings" ]]; then
                gsettings set org.gnome.desktop.wm.keybindings "$key" "$value" 2>/dev/null || true
            elif [[ "$current_section" == "gnome.shell.keybindings" ]]; then
                gsettings set org.gnome.shell.keybindings "$key" "$value" 2>/dev/null || true
            elif [[ "$current_section" == "gnome.settings-daemon.plugins.media-keys" ]]; then
                if [ "$key" = "custom-keybindings" ]; then
                    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$value" 2>/dev/null || true
                fi
            fi
        fi
    done < "$input_file"
    
    echo -e "${GREEN}✓${NC} Shortcuts imported"
}

filter_shortcuts() {
    local query="$1"
    
    echo ""
    echo -e "${GREEN}Searching for: ${WHITE}$query${NC}"
    echo ""
    
    # Create temp file with all shortcuts
    {
        echo "GNOME_Super_Open Activities / App Launcher"
        echo "GNOME_Super + A_Show Applications"
        echo "GNOME_Super + L_Lock Screen"
        echo "GNOME_Ctrl + Alt + T_Open Terminal"
        echo "Terminal_Ctrl + Shift + C_Copy"
        echo "Terminal_Ctrl + Shift + V_Paste"
        echo "Shell_Ctrl + R_Search command history"
        echo "Shell_z <dir>_Smart directory jump"
        echo "Kodra_kodra theme_Change theme"
        echo "Kodra_kodra fetch_System info"
        echo "Tmux_Ctrl+Space |_Split vertical"
    } | grep -i "$query" | while IFS='_' read -r cat key desc; do
        printf "  ${DIM}[%s]${NC} ${YELLOW}%-25s${NC} %s\n" "$cat" "$key" "$desc"
    done
}

# Parse arguments
case "${1:-}" in
    -s|--search|search)
        if [ -n "${2:-}" ]; then
            filter_shortcuts "$2"
        else
            echo "Usage: kodra shortcuts search <query>"
        fi
        ;;
    export)
        export_shortcuts "${2:-}"
        ;;
    import)
        import_shortcuts "${2:-}"
        ;;
    -h|--help|help)
        echo "Usage: kodra shortcuts [options]"
        echo ""
        echo "Options:"
        echo "  (none)           Show all shortcuts"
        echo "  search <query>   Search shortcuts"
        echo "  export [file]    Export shortcuts to file"
        echo "  import <file>    Import shortcuts from file"
        echo "  gnome            Show GNOME shortcuts only"
        echo "  terminal         Show terminal shortcuts only"
        echo "  shell            Show shell shortcuts only"
        echo "  tmux             Show tmux shortcuts only"
        ;;
    gnome)
        print_header
        show_gnome_shortcuts
        show_workspace_shortcuts
        show_screenshot_shortcuts
        ;;
    terminal)
        print_header
        show_terminal_shortcuts
        ;;
    shell)
        print_header
        show_shell_shortcuts
        ;;
    tmux)
        print_header
        show_tmux_shortcuts
        ;;
    *)
        print_header
        show_gnome_shortcuts
        show_workspace_shortcuts
        show_screenshot_shortcuts
        show_terminal_shortcuts
        show_shell_shortcuts
        show_kodra_shortcuts
        show_tmux_shortcuts
        ;;
esac
