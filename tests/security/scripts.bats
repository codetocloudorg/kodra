#!/usr/bin/env bats
#
# Security tests — script hygiene and supply chain
#

load '../helpers/setup'

# ── Entrypoint scripts must have set -e ──────────────────────────

@test "security/scripts: entrypoint scripts have set -e" {
    local entrypoints=(
        "$KODRA_DIR/install.sh"
        "$KODRA_DIR/boot.sh"
        "$KODRA_DIR/uninstall.sh"
        "$KODRA_DIR/install/system-wide.sh"
        "$KODRA_DIR/bin/kodra"
    )
    local missing=()
    for script in "${entrypoints[@]}"; do
        [ -f "$script" ] || continue
        if ! grep -q 'set -e' "$script"; then
            missing+=("$script")
        fi
    done
    [ ${#missing[@]} -eq 0 ] || fail "Entrypoints missing set -e:\n$(printf '%s\n' "${missing[@]}")"
}

# ── No hardcoded secrets ─────────────────────────────────────────

@test "security/scripts: no hardcoded secrets or tokens" {
    # Match PASSWORD="literal" but not PASSWORD="$variable"
    local pattern='(API_KEY|SECRET_KEY|ACCESS_TOKEN|PRIVATE_KEY|PASSWORD)\s*=\s*"[^$"][^"]{8,}'
    local violations
    violations=$(grep -rEn "$pattern" "$KODRA_DIR" \
        --include="*.sh" --include="*.bash" \
        --exclude-dir=".git" --exclude-dir="tests" \
        --exclude-dir="node_modules" 2>/dev/null || true)
    [ -z "$violations" ] || fail "Possible hardcoded secrets:\n$violations"
}

# ── All download URLs use HTTPS ──────────────────────────────────

@test "security/scripts: all URLs use HTTPS (no plain HTTP)" {
    local violations
    violations=$(grep -rEn 'http://' "$KODRA_DIR" \
        --include="*.sh" --include="*.bash" --include="Dockerfile" \
        --exclude-dir=".git" --exclude-dir="tests" \
        --exclude-dir="docs" --exclude-dir=".github" \
        --exclude-dir="node_modules" \
        2>/dev/null | grep -v '#' | grep -v 'localhost' | grep -v '127\.0\.0\.1' \
        | grep -v 'http://deb\.' || true)
    [ -z "$violations" ] || fail "Non-HTTPS URLs found:\n$violations"
}

# ── Supply chain: download domains are from known sources ────────

@test "security/scripts: downloads only from trusted domains" {
    local allowed_domains=(
        # GitHub
        "github.com" "githubusercontent.com" "raw.githubusercontent.com"
        "objects.githubusercontent.com"
        # Microsoft / Azure
        "packages.microsoft.com" "aka.ms" "code.visualstudio.com"
        "learn.microsoft.com" "docs.microsoft.com" "azure.microsoft.com"
        # Package repos
        "apt.releases.hashicorp.com" "download.docker.com" "cli.github.com"
        "dl.google.com" "deb.nodesource.com" "repo.charm.sh"
        "brave-browser-apt-release.s3.brave.com" "deb.gierens.de"
        "get.opentofu.org"
        # Tools
        "starship.rs" "mise.jdx.dev" "mise.run" "brew.sh" "helm.sh"
        "ghostty.org" "neovim.io" "www.nerdfonts.com"
        # Flatpak
        "apt.fury.io" "flathub.org" "dl.flathub.org" "flatpak.org"
        # Launchpad
        "launchpad.net" "ppa.launchpadcontent.net"
        # Kubernetes
        "dl.k8s.io" "kubernetes.io" "kubernetes.github.io"
        "charts.bitnami.com" "charts.jetstack.io" "k9scli.io"
        # Applications
        "discord.com" "discord.gg" "bitwarden.com" "www.postman.com"
        "podman.io" "extensions.gnome.org"
        # Docs / non-download references
        "developer.hashicorp.com" "docs.docker.com" "opentofu.org"
        # Kodra
        "kodra.codetocloud.io"
        # Local / examples
        "localhost" "0x0.st" "termbin.com"
        "grafana.mycompany.io"
    )

    # Build grep pattern from allowed domains
    local allowed_pattern
    allowed_pattern=$(printf '|%s' "${allowed_domains[@]}")
    allowed_pattern="${allowed_pattern:1}"  # strip leading |

    local violations
    violations=$(grep -rEohn 'https?://[a-zA-Z0-9._-]+' "$KODRA_DIR" \
        --include="*.sh" --include="*.bash" --include="Dockerfile" \
        --exclude-dir=".git" --exclude-dir="tests" --exclude-dir="docs" \
        --exclude-dir=".github" --exclude-dir="wallpapers" \
        2>/dev/null \
        | sed 's|.*https\?://||' \
        | sort -u \
        | grep -Ev "$allowed_pattern" \
        || true)

    [ -z "$violations" ] || fail "Downloads from untrusted domains:\n$violations\nAdd to allowed list in tests/security/scripts.bats if legitimate."
}

# ── No unsafe eval with variables ────────────────────────────────

@test "security/scripts: no eval with user-controlled variables" {
    # Only flag eval that uses $1, $@, $*, $input, $arg, etc.
    # Safe patterns like eval "$(brew shellenv)" are allowed
    local pattern='eval\s+["'"'"']?\$[1-9@*]|eval\s+\$\{?(input|arg|user|param|query)'
    local violations
    violations=$(grep -rEn "$pattern" "$KODRA_DIR" \
        --include="*.sh" --include="*.bash" \
        --exclude-dir=".git" --exclude-dir="tests" \
        --exclude-dir="node_modules" 2>/dev/null || true)
    [ -z "$violations" ] || fail "Unsafe eval patterns:\n$violations"
}

# ── GPG keys for apt repos ───────────────────────────────────────

@test "security/scripts: apt repo additions include GPG key setup" {
    # Only check files that ADD new repos (not remove old ones)
    local violations
    violations=$(grep -rln 'add-apt-repository\|apt-key add\|echo.*sources\.list' "$KODRA_DIR" \
        --include="*.sh" --exclude-dir=".git" --exclude-dir="tests" \
        --exclude-dir="node_modules" \
        2>/dev/null || true)

    for file in $violations; do
        # PPAs handle GPG automatically via add-apt-repository
        if grep -q 'add-apt-repository.*ppa:' "$file"; then
            continue
        fi
        # Files that add repos should also reference gpg or signed-by
        if grep -q 'echo.*sources.list\|add-apt-repository' "$file"; then
            if ! grep -q 'gpg\|signed-by\|apt-key' "$file"; then
                fail "$file adds apt repo without GPG verification"
            fi
        fi
    done
}
