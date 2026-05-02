#!/usr/bin/env bash
#
# BATS Test Helper — shared setup/teardown for all Kodra tests
#

# Locate bats libraries (CI installs to /usr/lib or tests/lib/)
BATS_LIB_PATHS=(
    "${BATS_TEST_DIRNAME}/../lib/bats-support"
    "${BATS_TEST_DIRNAME}/../lib/bats-assert"
    "/usr/lib/bats-support"
    "/usr/lib/bats-assert"
)

for lib_dir in "${BATS_LIB_PATHS[@]}"; do
    if [ -f "$lib_dir/load.bash" ]; then
        case "$lib_dir" in
            *bats-support*) BATS_SUPPORT_HOME="$lib_dir" ;;
            *bats-assert*)  BATS_ASSERT_HOME="$lib_dir" ;;
        esac
    fi
done

load "${BATS_SUPPORT_HOME}/load.bash"
load "${BATS_ASSERT_HOME}/load.bash"

# Create isolated test environment — never touches real $HOME
setup() {
    export TEST_TMPDIR="$(mktemp -d)"
    export HOME="$TEST_TMPDIR/home"
    export XDG_CONFIG_HOME="$HOME/.config"
    export KODRA_DIR="${BATS_TEST_DIRNAME}/../../"
    export KODRA_DIR="$(cd "$KODRA_DIR" && pwd)"
    export KODRA_STATE_FILE="$XDG_CONFIG_HOME/kodra/state.json"
    export KODRA_INSTALL_LOG_FILE="$TEST_TMPDIR/install.log"
    export PATH="$KODRA_DIR/bin:$PATH"

    mkdir -p "$HOME" "$XDG_CONFIG_HOME/kodra"
}

teardown() {
    rm -rf "$TEST_TMPDIR"
}
