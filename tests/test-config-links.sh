#!/usr/bin/env bash
# tests/test-config-links.sh - Verify config links, dry-run safety, and conflict handling

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"

TEST_HOME=$(mktemp -d -t test-links-XXXXXX)
trap 'rm -rf "$TEST_HOME"' EXIT

echo "Running config link & conflict safety tests in: $TEST_HOME"

# 1. Test Dry Run Safety (Must perform zero disk writes in TEST_HOME)
echo "--- Test 1: Dry Run Safety ---"
bash "$INSTALL_SCRIPT" --dry-run --home "$TEST_HOME"

if [[ -n "$(ls -A "$TEST_HOME")" ]]; then
    echo "  [FAIL] Dry-run created files in $TEST_HOME!" >&2
    exit 1
fi
echo "  [PASS] Dry run performed zero writes."

# 2. Test Conflict Preservation (Pre-existing file must not be overwritten)
echo "--- Test 2: Existing Config Conflict Detection ---"
mkdir -p "$TEST_HOME/.config/kitty"
echo "custom user content" > "$TEST_HOME/.config/kitty/kitty.conf"

set +e
bash "$INSTALL_SCRIPT" --home "$TEST_HOME" 2>/dev/null
exit_code=$?
set -e

if [[ $exit_code -ne 2 ]]; then
    echo "  [FAIL] Installer did not exit with conflict error code (exit code: $exit_code)" >&2
    exit 1
fi

user_content=$(cat "$TEST_HOME/.config/kitty/kitty.conf")
if [[ "$user_content" != "custom user content" ]]; then
    echo "  [FAIL] User's existing kitty.conf was modified or overwritten!" >&2
    exit 1
fi
echo "  [PASS] Existing non-symlink file was safely preserved."

# 3. Test Normal Installation after removing conflicting file
rm "$TEST_HOME/.config/kitty/kitty.conf"
bash "$INSTALL_SCRIPT" --profile full --home "$TEST_HOME"

# Check expected full symlinks
expected_links=(
    "$TEST_HOME/.config/kitty/kitty.conf"
    "$TEST_HOME/.zshrc"
    "$TEST_HOME/.config/starship.toml"
    "$TEST_HOME/.config/fastfetch/config.jsonc"
    "$TEST_HOME/.tmux.conf"
)

for target in "${expected_links[@]}"; do
    if [[ ! -L "$target" ]]; then
        echo "  [FAIL] Expected symlink does not exist: $target" >&2
        exit 1
    fi
    echo "  [PASS] Verified symlink: $target"
done

echo "All config link tests passed."

