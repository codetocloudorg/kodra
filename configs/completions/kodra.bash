# Bash completion for Kodra
# Install: copy to /etc/bash_completion.d/kodra or source from ~/.bashrc

_kodra_completions() {
    local cur prev words cword
    _init_completion || return

    local commands="theme wallpaper desktop motd setup fetch dev db update install uninstall repair restore resume doctor menu shortcuts power nightlight font screenshot cleanup lock suspend restart shutdown welcome version help"
    
    # Theme names
    local themes="tokyo-night ghostty-blue gruvbox catppuccin nord rose-pine"
    
    # Power profiles
    local power_profiles="performance balanced power-saver status"
    
    # Database types
    local databases="postgres mysql redis mongo list stop-all clean"
    
    # Dev commands
    local dev_commands="setup list available"
    local dev_languages="node python ruby go rust java deno bun dotnet"
    
    # Desktop commands
    local desktop_commands="setup refresh dock extensions"
    
    # MOTD styles
    local motd_styles="banner minimal none"
    
    # Nightlight commands
    local nightlight_commands="on off toggle temp status schedule"
    
    # Font commands
    local font_commands="list set"
    
    # Screenshot commands
    local screenshot_commands="full region window"
    
    # Cleanup commands
    local cleanup_commands="all apt snap journal temp"

    case "${prev}" in
        kodra)
            COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
            return 0
            ;;
        theme)
            COMPREPLY=($(compgen -W "${themes}" -- "${cur}"))
            return 0
            ;;
        power)
            COMPREPLY=($(compgen -W "${power_profiles}" -- "${cur}"))
            return 0
            ;;
        db|database)
            COMPREPLY=($(compgen -W "${databases}" -- "${cur}"))
            return 0
            ;;
        dev)
            COMPREPLY=($(compgen -W "${dev_commands}" -- "${cur}"))
            return 0
            ;;
        setup)
            # After 'dev setup'
            if [[ "${words[1]}" == "dev" ]]; then
                COMPREPLY=($(compgen -W "${dev_languages}" -- "${cur}"))
            fi
            return 0
            ;;
        desktop)
            COMPREPLY=($(compgen -W "${desktop_commands}" -- "${cur}"))
            return 0
            ;;
        motd|banner)
            COMPREPLY=($(compgen -W "${motd_styles}" -- "${cur}"))
            return 0
            ;;
        nightlight|night-light|nl)
            COMPREPLY=($(compgen -W "${nightlight_commands}" -- "${cur}"))
            return 0
            ;;
        font)
            COMPREPLY=($(compgen -W "${font_commands}" -- "${cur}"))
            return 0
            ;;
        screenshot)
            COMPREPLY=($(compgen -W "${screenshot_commands}" -- "${cur}"))
            return 0
            ;;
        cleanup)
            COMPREPLY=($(compgen -W "${cleanup_commands}" -- "${cur}"))
            return 0
            ;;
        wallpaper|wp)
            local wp_commands="list set next prev random current theme"
            COMPREPLY=($(compgen -W "${wp_commands}" -- "${cur}"))
            return 0
            ;;
        install)
            # List available applications
            local apps="discord spotify docker-ce lazydocker podman postman bitwarden"
            COMPREPLY=($(compgen -W "${apps}" -- "${cur}"))
            return 0
            ;;
        uninstall)
            local apps="discord spotify docker-ce lazydocker podman postman bitwarden"
            COMPREPLY=($(compgen -W "${apps}" -- "${cur}"))
            return 0
            ;;
        *)
            COMPREPLY=()
            return 0
            ;;
    esac
}

complete -F _kodra_completions kodra
