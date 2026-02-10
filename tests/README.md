# Kodra Tests

Test scripts to validate Kodra before deploying.

## Quick Reference

```bash
# Local syntax/structure tests (works on macOS/Linux)
./tests/test.sh

# Full system tests (requires Docker)
docker run --rm -v $(pwd):/kodra ubuntu:24.04 bash /kodra/tests/test-full.sh
```

## Test Scripts

### test.sh — Local Validation

Fast tests that run on any system (macOS, Linux):

- **Syntax check** — All shell scripts pass `bash -n`
- **Source check** — All libraries can be sourced
- **Theme validation** — Theme files have required properties
- **Structure check** — Required directories and files exist
- **VERSION check** — Version file is valid semver

Run before every commit:

```bash
./tests/test.sh
```

### test-full.sh — Container Simulation

Full installation test in Ubuntu 24.04 container:

- Installs prerequisites (curl, git, sudo, etc.)
- Creates test user with sudo access
- Sources all libraries
- Tests utility functions
- Validates theme application
- Tests shell integration

Run for major changes:

```bash
docker run --rm -v $(pwd):/kodra ubuntu:24.04 bash /kodra/tests/test-full.sh
```

## CI Integration

GitHub Actions runs these tests on every push. See `.github/workflows/ci.yml`.

## Writing Tests

When adding new functionality:

1. Add syntax tests to `test.sh` if adding new scripts
2. Add functional tests to `test-full.sh` if adding new features
3. Ensure tests are idempotent (can run multiple times)

## Debugging

```bash
# Run with verbose output
bash -x ./tests/test.sh

# Interactive container for debugging
docker run -it --rm -v $(pwd):/kodra ubuntu:24.04 bash
cd /kodra
# ... manual testing ...
```
