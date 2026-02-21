# Kodra Tests

## Quick Start

```bash
# Full user experience test (runs in Docker - safe, isolated)
./tests/test.sh

# Local syntax check only (fast, no Docker needed)
./tests/test.sh --local
```

## What It Tests

The test simulates exactly what a real user would do:

```bash
wget -qO- https://kodra.codetocloud.io/boot.sh | bash
```

It runs in an isolated Ubuntu 24.04 Docker container so your local system is never touched.

### Test Phases

1. **Prerequisites** - Install wget, curl, git
2. **wget Install** - Run the real installer from the website
3. **Verify Installation** - Check kodra directory and theme
4. **Test Commands** - Run `kodra theme`, `kodra doctor`, etc.
5. **Theme Switching** - Test all 6 themes
6. **Tool Verification** - Check which tools installed

## Requirements

- Docker (for full test)
- Bash (for syntax check)
