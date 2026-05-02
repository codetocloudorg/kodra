# Kodra Shell Defaults

These are Kodra-managed shell configurations. They are sourced
automatically and should not be edited directly.

## Layer Order

1. **Defaults** (`defaults/shell/`) — Base functionality (Kodra-managed)
2. **Theme** (`themes/<name>/`) — Theme-specific prompt/colors
3. **User** (`~/.config/kodra/shell/`) — Your personal customizations

## Customization

To add your own aliases, functions, or environment variables:

```bash
mkdir -p ~/.config/kodra/shell
echo 'alias myalias="mycommand"' >> ~/.config/kodra/shell/custom.sh
```

This file is automatically sourced after Kodra's defaults and theme.

## Disabling Features

```bash
# Disable modern tool aliases (cat→bat, ls→eza)
export KODRA_POSIX_ALIASES=false

# Re-enable find→fd (disabled by default)
export KODRA_ALIAS_FIND=true
```
