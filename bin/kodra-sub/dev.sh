#!/usr/bin/env bash
#
# Kodra Dev Environment Setup
# Quickly install language runtimes via mise
#

set -e

KODRA_DIR="${KODRA_DIR:-$HOME/.kodra}"
source "$KODRA_DIR/lib/utils.sh"

# Check dependencies
check_mise() {
    if ! command -v mise &>/dev/null; then
        log_error "mise is required. Run: kodra repair"
        exit 1
    fi
}

# Install a language runtime
install_language() {
    local lang="$1"
    local version="${2:-latest}"
    
    check_mise
    
    log_info "Installing $lang@$version..."
    
    case "$lang" in
        node|nodejs)
            mise use --global node@"$version"
            log_success "Node.js installed: $(node --version)"
            ;;
        python|py)
            mise use --global python@"$version"
            log_success "Python installed: $(python3 --version)"
            ;;
        ruby|rb)
            mise use --global ruby@"$version"
            log_success "Ruby installed: $(ruby --version)"
            ;;
        go|golang)
            mise use --global go@"$version"
            log_success "Go installed: $(go version)"
            ;;
        rust|rs)
            mise use --global rust@"$version"
            log_success "Rust installed: $(rustc --version)"
            ;;
        java|jdk)
            mise use --global java@"$version"
            log_success "Java installed: $(java --version | head -1)"
            ;;
        deno)
            mise use --global deno@"$version"
            log_success "Deno installed: $(deno --version | head -1)"
            ;;
        bun)
            mise use --global bun@"$version"
            log_success "Bun installed: $(bun --version)"
            ;;
        dotnet)
            mise use --global dotnet@"$version"
            log_success ".NET installed: $(dotnet --version)"
            ;;
        *)
            # Generic mise plugin
            mise use --global "$lang@$version"
            log_success "$lang installed"
            ;;
    esac
}

# List available runtimes
list_available() {
    echo "Popular runtimes supported by mise:"
    echo ""
    echo "  Language      Command"
    echo "  ─────────────────────────────────────"
    echo "  Node.js       kodra dev setup node [version]"
    echo "  Python        kodra dev setup python [version]"
    echo "  Ruby          kodra dev setup ruby [version]"
    echo "  Go            kodra dev setup go [version]"
    echo "  Rust          kodra dev setup rust [version]"
    echo "  Java          kodra dev setup java [version]"
    echo "  Deno          kodra dev setup deno [version]"
    echo "  Bun           kodra dev setup bun [version]"
    echo "  .NET          kodra dev setup dotnet [version]"
    echo ""
    echo "Install any mise plugin:"
    echo "  kodra dev setup <plugin> [version]"
    echo ""
    echo "See all plugins: mise plugins --all"
}

# Show installed runtimes
show_installed() {
    check_mise
    
    echo "Installed runtimes:"
    echo ""
    mise current 2>/dev/null || echo "  No runtimes configured globally"
    echo ""
    echo "Local (project) runtimes:"
    mise ls 2>/dev/null || true
}

# Interactive setup
interactive_setup() {
    if ! command -v gum &>/dev/null; then
        log_error "gum required for interactive mode"
        list_available
        exit 1
    fi
    
    check_mise
    
    echo "Select runtimes to install:"
    echo ""
    
    local choices=$(gum choose --no-limit --height 12 \
        "node (JavaScript/TypeScript)" \
        "python (Python 3)" \
        "ruby (Ruby)" \
        "go (Golang)" \
        "rust (Rust)" \
        "java (OpenJDK)" \
        "deno (Deno)" \
        "bun (Bun)")
    
    if [ -z "$choices" ]; then
        log_info "No runtimes selected"
        exit 0
    fi
    
    echo ""
    
    while IFS= read -r choice; do
        local lang=$(echo "$choice" | cut -d' ' -f1)
        install_language "$lang"
    done <<< "$choices"
}

# Show help
show_help() {
    echo "Usage: kodra dev <command>"
    echo ""
    echo "Commands:"
    echo "  setup [lang] [version]   Install a language runtime"
    echo "  list                     Show installed runtimes"
    echo "  available                List available runtimes"
    echo ""
    echo "Examples:"
    echo "  kodra dev setup              Interactive runtime selection"
    echo "  kodra dev setup node         Install latest Node.js"
    echo "  kodra dev setup python 3.11  Install Python 3.11"
    echo "  kodra dev setup go 1.22      Install Go 1.22"
    echo "  kodra dev list               Show what's installed"
    echo ""
    echo "Runtimes are managed by mise and installed globally."
    echo "Use mise local in projects for per-project versions."
}

# Main
case "${1:-}" in
    setup)
        if [ -z "${2:-}" ]; then
            interactive_setup
        else
            install_language "$2" "${3:-latest}"
        fi
        ;;
    list|ls)
        show_installed
        ;;
    available|avail)
        list_available
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        ;;
esac
