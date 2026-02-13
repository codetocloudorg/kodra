#!/usr/bin/env bash
#
# Kodra Local Test Script
# Test on macOS or any system before deploying to Ubuntu
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export KODRA_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Kodra Local Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PASS=0
FAIL=0

test_result() {
    if [ $1 -eq 0 ]; then
        echo "  ✓ $2"
        PASS=$((PASS + 1))
    else
        echo "  ✗ $2"
        FAIL=$((FAIL + 1))
    fi
}

# Test 1: Syntax check all shell scripts
echo "▸ Syntax checking shell scripts..."
SYNTAX_OK=0
for f in $(find . -name "*.sh" -type f ! -path "./.git/*"); do
    bash -n "$f" 2>/dev/null || { echo "    Failed: $f"; SYNTAX_OK=1; }
done
test_result $SYNTAX_OK "All shell scripts have valid syntax"

# Test 2: CLI help
echo "▸ Testing CLI..."
bash bin/kodra help >/dev/null 2>&1
test_result $? "kodra help"

bash bin/kodra version >/dev/null 2>&1
test_result $? "kodra version"

# Test 3: Theme commands
echo "▸ Testing theme commands..."
bash bin/kodra-sub/theme.sh list >/dev/null 2>&1
test_result $? "kodra theme list"

CURRENT=$(bash bin/kodra-sub/theme.sh current 2>/dev/null)
[ -n "$CURRENT" ]
test_result $? "kodra theme current ($CURRENT)"

# Test 4: Wallpaper commands
echo "▸ Testing wallpaper commands..."
bash bin/kodra-sub/wallpaper.sh list >/dev/null 2>&1
test_result $? "kodra wallpaper list"

# Test 5: Check required files exist
echo "▸ Checking required files..."
[ -f "boot.sh" ]
test_result $? "boot.sh exists"

[ -f "install.sh" ]
test_result $? "install.sh exists"

[ -f "README.md" ]
test_result $? "README.md exists"

[ -f "LICENSE" ]
test_result $? "LICENSE exists"

[ -f "CNAME" ]
test_result $? "CNAME exists"

# Test 6: Check all themes have required files
echo "▸ Checking theme completeness..."
for theme in themes/*/; do
    theme_name=$(basename "$theme")
    THEME_OK=0
    [ -f "$theme/ghostty.conf" ] || { echo "    Missing: $theme_name/ghostty.conf"; THEME_OK=1; }
    [ -f "$theme/starship.toml" ] || { echo "    Missing: $theme_name/starship.toml"; THEME_OK=1; }
    test_result $THEME_OK "Theme: $theme_name complete"
done

# Test 7: Check configs
echo "▸ Checking config files..."
[ -f "configs/ghostty/config" ]
test_result $? "configs/ghostty/config exists"

[ -f "configs/nvim/init.lua" ]
test_result $? "configs/nvim/init.lua exists"

# Test 8: Wallpapers
echo "▸ Checking wallpapers..."
WP_COUNT=$(ls wallpapers/*.{svg,png,jpg,jpeg} 2>/dev/null | wc -l)
[ "$WP_COUNT" -ge 1 ]
test_result $? "At least 1 wallpaper ($WP_COUNT found)"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo "  🎉 All tests passed! Ready to deploy."
    echo ""
    exit 0
else
    echo ""
    echo "  ⚠️  Some tests failed. Please fix before deploying."
    echo ""
    exit 1
fi
