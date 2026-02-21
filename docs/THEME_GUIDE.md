# Creating Themes for Kodra

This guide explains how to create a new theme for Kodra.

## Theme Structure

Each theme lives in `themes/<theme-name>/` and contains these files:

```
themes/my-theme/
├── ghostty.conf      # Terminal colors (required)
├── starship.toml     # Prompt theme (required)
├── vscode-settings.json  # VS Code theme (required)
├── tmux.conf         # Tmux status bar (optional)
└── README.md         # Theme description (optional)
```

Additionally, you may add:
- `configs/btop/themes/<theme-name>.theme` - btop system monitor
- `wallpapers/<theme-name>/` - Theme-specific wallpapers

## Color Palette

Before creating theme files, define your color palette:

| Role | Description | Example (Tokyo Night) |
|------|-------------|----------------------|
| Background | Main terminal/editor BG | `#1a1b26` |
| Foreground | Primary text | `#c0caf5` |
| Accent | Primary highlights | `#7aa2f7` |
| Secondary | Secondary accent | `#bb9af7` |
| Border | UI borders | `#414868` |
| Red | Errors, deletions | `#f7768e` |
| Green | Success, additions | `#9ece6a` |
| Yellow | Warnings | `#e0af68` |
| Blue | Info, links | `#7aa2f7` |
| Purple | Keywords, special | `#bb9af7` |
| Cyan | Constants, strings | `#7dcfff` |

## Step 1: Create Theme Directory

```bash
mkdir -p ~/.kodra/themes/my-theme
cd ~/.kodra/themes/my-theme
```

## Step 2: Create ghostty.conf

This file defines terminal colors. Ghostty uses a simple key=value format.

```conf
# Kodra Theme: My Theme
# Terminal color scheme

# Main colors
background = #1a1b26
foreground = #c0caf5
cursor-color = #c0caf5
selection-background = #33467c
selection-foreground = #c0caf5

# Normal colors (0-7)
palette = 0=#15161e
palette = 1=#f7768e
palette = 2=#9ece6a
palette = 3=#e0af68
palette = 4=#7aa2f7
palette = 5=#bb9af7
palette = 6=#7dcfff
palette = 7=#a9b1d6

# Bright colors (8-15)
palette = 8=#414868
palette = 9=#f7768e
palette = 10=#9ece6a
palette = 11=#e0af68
palette = 12=#7aa2f7
palette = 13=#bb9af7
palette = 14=#7dcfff
palette = 15=#c0caf5
```

### Color Reference

- Palette 0-7: Normal colors (black, red, green, yellow, blue, purple, cyan, white)
- Palette 8-15: Bright variants of the same colors

## Step 3: Create starship.toml

The Starship prompt uses TOML format. Base your config on an existing theme.

```toml
# Kodra Theme: My Theme
# Starship prompt configuration

command_timeout = 200

format = """
[░▒▓](#7aa2f7)\
$os\
$username\
[](bg:#bb9af7 fg:#7aa2f7)\
$directory\
[](fg:#bb9af7 bg:#414868)\
$git_branch\
$git_status\
[](fg:#414868 bg:#1a1b26)\
$nodejs\
$rust\
$golang\
$python\
$azure\
$kubernetes\
$docker_context\
[](fg:#1a1b26)\
$line_break$character"""

[os]
disabled = false
style = "bg:#7aa2f7 fg:#1a1b26"
format = "[ $symbol ]($style)"

[os.symbols]
Ubuntu = ""
Linux = "󰌽"
Windows = "󰍲"
Macos = "󰀵"

[username]
show_always = true
style_user = "bg:#7aa2f7 fg:#1a1b26"
style_root = "bg:#f7768e fg:#1a1b26"
format = '[ $user ]($style)'

[directory]
style = "bg:#bb9af7 fg:#1a1b26"
format = "[ $path ]($style)"
truncation_length = 3

[git_branch]
symbol = ""
style = "bg:#414868 fg:#c0caf5"
format = '[ $symbol $branch ]($style)'

[git_status]
style = "bg:#414868 fg:#c0caf5"
format = '[$all_status$ahead_behind ]($style)'

[character]
success_symbol = "[❯](bold #9ece6a)"
error_symbol = "[❯](bold #f7768e)"

# Add more modules as needed...
```

### Key Sections

- **format**: The prompt layout using Starship modules
- **[os]**: OS icon display
- **[directory]**: Current path styling
- **[git_branch]** / **[git_status]**: Git information
- **[character]**: The final prompt character

## Step 4: Create vscode-settings.json

VS Code settings to apply the theme and colors.

```json
{
    "workbench.colorTheme": "Tokyo Night",
    "editor.fontFamily": "'JetBrainsMono Nerd Font', 'JetBrains Mono', Consolas, monospace",
    "editor.fontSize": 14,
    "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font'",
    "workbench.iconTheme": "material-icon-theme",
    "editor.tokenColorCustomizations": {
        "[Tokyo Night]": {
            "comments": "#565f89"
        }
    }
}
```

### Finding VS Code Theme Names

For `workbench.colorTheme`, use the exact theme name from the extension:

| Theme | Extension | Theme Name |
|-------|-----------|------------|
| Tokyo Night | enkia.tokyo-night | "Tokyo Night" |
| Catppuccin | catppuccin.catppuccin-vsc | "Catppuccin Mocha" |
| Gruvbox | jdinhlife.gruvbox | "Gruvbox Dark Medium" |
| Nord | arcticicestudio.nord-visual-studio-code | "Nord" |
| Rose Pine | mvllow.rose-pine | "Rosé Pine" |

## Step 5: Create tmux.conf (Optional)

Tmux status bar theme.

```conf
# Kodra Theme: My Theme
# Tmux status bar theme

# Status bar colors
set -g status-style "bg=#1a1b26,fg=#c0caf5"

# Window status
set -g window-status-current-style "bg=#7aa2f7,fg=#1a1b26,bold"
set -g window-status-style "bg=#414868,fg=#a9b1d6"

# Pane borders
set -g pane-border-style "fg=#414868"
set -g pane-active-border-style "fg=#7aa2f7"

# Status bar content
set -g status-left "#[bg=#9ece6a,fg=#1a1b26,bold] #S #[bg=#1a1b26] "
set -g status-right "#[bg=#414868,fg=#c0caf5] %H:%M #[bg=#7aa2f7,fg=#1a1b26,bold] %d-%b "
```

## Step 6: Create btop Theme (Optional)

Create `configs/btop/themes/<theme-name>.theme`:

```ini
# Kodra btop theme: My Theme
theme[main_bg]="#1a1b26"
theme[main_fg]="#c0caf5"
theme[title]="#c0caf5"
theme[hi_fg]="#7aa2f7"
theme[selected_bg]="#414868"
theme[selected_fg]="#c0caf5"
theme[inactive_fg]="#565f89"
theme[graph_text]="#c0caf5"
theme[meter_bg]="#414868"
theme[proc_misc]="#7dcfff"
theme[cpu_box]="#7aa2f7"
theme[mem_box]="#9ece6a"
theme[net_box]="#bb9af7"
theme[proc_box]="#e0af68"
theme[div_line]="#414868"
theme[temp_start]="#9ece6a"
theme[temp_mid]="#e0af68"
theme[temp_end]="#f7768e"
theme[cpu_start]="#7aa2f7"
theme[cpu_mid]="#bb9af7"
theme[cpu_end]="#f7768e"
theme[free_start]="#9ece6a"
theme[free_mid]="#e0af68"
theme[free_end]="#f7768e"
theme[cached_start]="#7dcfff"
theme[cached_mid]="#7aa2f7"
theme[cached_end]="#bb9af7"
theme[available_start]="#9ece6a"
theme[available_mid]="#e0af68"
theme[available_end]="#f7768e"
theme[used_start]="#bb9af7"
theme[used_mid]="#e0af68"
theme[used_end]="#f7768e"
theme[download_start]="#9ece6a"
theme[download_mid]="#7dcfff"
theme[download_end]="#7aa2f7"
theme[upload_start]="#bb9af7"
theme[upload_mid]="#f7768e"
theme[upload_end]="#e0af68"
theme[process_start]="#7aa2f7"
theme[process_mid]="#7dcfff"
theme[process_end]="#bb9af7"
```

## Step 7: Add Wallpapers (Optional)

Create theme-specific wallpapers:

```bash
mkdir -p ~/.kodra/wallpapers/my-theme
# Add .jpg, .png, or .webp files
```

Wallpapers should complement the theme colors (e.g., dark wallpapers for dark themes).

## Step 8: Test Your Theme

```bash
# Apply your theme
kodra theme my-theme

# Check each component
# - Terminal colors should change immediately (new windows)
# - Prompt should reflect new Starship config
# - VS Code should show new theme after reload
```

## Step 9: Add GNOME Accent Color

In `bin/kodra-sub/theme.sh`, add your theme to the accent color mapping:

```bash
case "$theme" in
    tokyo-night)  accent_color="purple" ;;
    my-theme)     accent_color="blue" ;;    # Add your theme
    *)            accent_color="blue" ;;
esac
```

Available accent colors: `blue`, `teal`, `green`, `yellow`, `orange`, `red`, `pink`, `purple`, `slate`

## Step 10: Add nvim Colorscheme

In `bin/kodra-sub/theme.sh`, add to the colorscheme mapping:

```bash
get_nvim_colorscheme() {
    local theme="$1"
    case "$theme" in
        tokyo-night)  echo "tokyonight" ;;
        my-theme)     echo "my-colorscheme" ;;  # Add your theme
        *)            echo "default" ;;
    esac
}
```

## Contributing Your Theme

1. Fork the Kodra repository
2. Create your theme in `themes/<name>/`
3. Add btop theme if applicable
4. Update the accent color and nvim colorscheme mappings
5. Test on a fresh install
6. Submit a pull request

### Theme Guidelines

- Use a consistent color palette (8-16 colors)
- Ensure sufficient contrast for readability
- Test in both dark and light terminal backgrounds
- Include at least: ghostty.conf, starship.toml, vscode-settings.json
- Name files exactly as shown above

## Resources

- **Ghostty Colors:** https://ghostty.org/docs/config/reference#palette
- **Starship Docs:** https://starship.rs/config/
- **btop Themes:** https://github.com/aristocratos/btop#themes
- **Popular Color Schemes:** 
  - https://github.com/catppuccin/catppuccin
  - https://github.com/folke/tokyonight.nvim
  - https://github.com/morhetz/gruvbox
  - https://github.com/nordtheme/nord
  - https://github.com/rose-pine/rose-pine-theme
