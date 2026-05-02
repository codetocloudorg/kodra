# Kodra Tests

Enterprise-grade test suite using **BATS** (Bash Automated Testing System) with JUnit XML reporting.

## Quick Start

```bash
# Install BATS + helpers (one-time setup)
sudo apt-get install -y bats
git clone --depth 1 https://github.com/bats-core/bats-support.git tests/lib/bats-support
git clone --depth 1 https://github.com/bats-core/bats-assert.git tests/lib/bats-assert

# Run all tests
bats tests/unit/ tests/integration/ tests/security/

# Run specific suite
bats tests/unit/           # Library unit tests
bats tests/integration/    # CLI & theme integration tests
bats tests/security/       # Security & supply chain tests

# JUnit XML output (for CI)
bats --formatter junit tests/unit/ > test-results/unit.xml

# Full user experience test (runs in Docker — safe, isolated)
./tests/test.sh

# Local syntax check only (fast, no Docker needed)
./tests/test.sh --local
```

## Test Structure

```
tests/
├── unit/                  # Library unit tests (one file per lib)
│   ├── utils.bats         # Color vars, log functions
│   ├── checks.bats        # command_exists, is_ubuntu, disk space
│   ├── state.bats         # State init, mark_installed, is_installed
│   ├── package.bats       # apt package detection
│   ├── logging.bats       # Install logging lifecycle
│   └── config.bats        # Config layering
├── integration/           # Integration tests
│   ├── cli.bats           # CLI dispatcher, help, version, subcommands
│   └── theme.bats         # Theme system, manifests
├── security/              # Security & supply chain tests
│   ├── permissions.bats   # File permissions, no world-writable, no setuid
│   ├── scripts.bats       # set -e enforcement, no secrets, HTTPS-only,
│   │                      # trusted download domains, safe eval, GPG keys
│   └── container.bats     # Dockerfile hardening (no root, pinned base)
├── helpers/
│   └── setup.bash         # Shared BATS helpers (isolated $HOME, teardown)
├── lib/                   # BATS libraries (gitignored, installed at runtime)
│   ├── bats-support/
│   └── bats-assert/
├── test.sh                # Docker-based full user experience test
└── README.md              # This file
```

## CI Integration

Tests run automatically on every PR via GitHub Actions:

| Workflow | What it does | Output |
|----------|-------------|--------|
| **CI** (`ci.yml`) | BATS unit/integration/security + ShellCheck + Hadolint + container matrix | JUnit XML → PR annotations via dorny/test-reporter |
| **E2E** (`e2e.yml`) | Full/minimal/system-wide install in Docker containers | Install logs + diagnostics as artifacts |

All test results appear as **check annotations** directly on PRs. JUnit XML artifacts are uploaded with 14-day retention.

## Writing New Tests

```bash
#!/usr/bin/env bats
# tests/unit/my-feature.bats

load '../helpers/setup'

@test "my feature: does something" {
    source "$KODRA_DIR/lib/my-lib.sh"
    run my_function "input"
    assert_success
    assert_output --partial "expected"
}
```

The `setup.bash` helper provides:
- **Isolated `$HOME`** — tests never touch your real home directory
- **`$KODRA_DIR`** — points to the repo root
- **Auto-cleanup** — temp dirs removed after each test
- **bats-assert** — `assert_success`, `assert_failure`, `assert_output`

## Requirements

- **BATS** 1.10+ (`sudo apt-get install bats` or `npm install bats`)
- **Docker** (for `test.sh` full user experience test only)
