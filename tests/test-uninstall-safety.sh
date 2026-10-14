#!/usr/bin/env bash
# tests/test-uninstall-safety.sh - Verify uninstall safety rules

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"
UNINSTALL_SCRIPT="$SCRIPT_DIR/uninstall.sh"

TEST_HOME=$(mktemp -d -t test-uninstall-XXXXXX)
trap 'rm -rf "$TEST_HOME"' EXIT

echo "Running uninstall safety tests in: $TEST_HOME"

# 1. Install full configuration
bash "$INSTALL_SCRIPT" --profile full --home "$TEST_HOME"

# 2. Add unrelated user files and modify one tracked file to simulate user replacement
echo "important user notes" > "$TEST_HOME/notes.txt"
echo "custom project" > "$TEST_HOME/my_code.py"

# Simulate user replacing ~/.zshrc symlink with a real custom file
rm "$TEST_HOME/.zshrc"
echo "# Custom user zshrc that replaced symlink" > "$TEST_HOME/.zshrc"

# 3. Run uninstall in dry-run mode first
echo "--- Test 1: Uninstall Dry-Run ---"
bash "$UNINSTALL_SCRIPT" --dry-run --home "$TEST_HOME"
if [[ ! -L "$TEST_HOME/.tmux.conf" ]]; then
    echo "  [FAIL] Dry-run uninstaller deleted .tmux.conf!" >&2
    exit 1
fi
echo "  [PASS] Dry-run uninstall performed zero deletions."

# 4. Run real uninstall
echo "--- Test 2: Standard Uninstall ---"
bash "$UNINSTALL_SCRIPT" --home "$TEST_HOME"

# Tracked symlinks should be removed
if [[ -e "$TEST_HOME/.tmux.conf" || -L "$TEST_HOME/.tmux.conf" ]]; then
    echo "  [FAIL] Tracked symlink ~/.tmux.conf was not removed" >&2
    exit 1
fi
echo "  [PASS] Managed symlink ~/.tmux.conf safely removed."

# Unrelated files must remain untouched
if [[ ! -f "$TEST_HOME/notes.txt" || ! -f "$TEST_HOME/my_code.py" ]]; then
    echo "  [FAIL] Unrelated user files were deleted!" >&2
    exit 1
fi
echo "  [PASS] Unrelated user files preserved."

# Modified tracked file (which became a regular file) must NOT be deleted without --force
if [[ ! -f "$TEST_HOME/.zshrc" ]]; then
    echo "  [FAIL] Modified ~/.zshrc was deleted! User changes were lost." >&2
    exit 1
fi
content=$(cat "$TEST_HOME/.zshrc")
if [[ "$content" != "# Custom user zshrc that replaced symlink" ]]; then
    echo "  [FAIL] ~/.zshrc content was altered." >&2
    exit 1
fi
echo "  [PASS] User-replaced ~/.zshrc was safely preserved."

echo "All uninstall safety tests passed."

