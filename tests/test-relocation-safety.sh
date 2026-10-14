#!/usr/bin/env bash
# tests/test-relocation-safety.sh - Test uninstall and links when repository is cloned to another path

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

TEST_HOME=$(mktemp -d -t test-reloc-home-XXXXXX)
TEST_REPO=$(mktemp -d -t test-reloc-repo-XXXXXX)
trap 'rm -rf "$TEST_HOME" "$TEST_REPO"' EXIT

echo "========================================="
echo "   OMEN Terminal - Relocation Test       "
echo "========================================="

# 1. Copy repo to a different directory to simulate moving/cloning to another path
cp -r "$SCRIPT_DIR"/* "$TEST_REPO"/

# 2. Install from the relocated path
bash "$TEST_REPO/install.sh" --profile full --home "$TEST_HOME"

# Check that links point into TEST_REPO
target_link=$(readlink "$TEST_HOME/.zshrc")
if [[ "$target_link" != "$TEST_REPO/config/zsh/.zshrc" ]]; then
    echo "  [FAIL] Expected symlink to point to $TEST_REPO/config/zsh/.zshrc, got $target_link" >&2
    exit 1
fi
echo "  [PASS] Links correctly established from relocated repository."

# 3. Simulate moving the repo directory (broken symlinks scenario)
MOVED_REPO="${TEST_REPO}_moved"
mv "$TEST_REPO" "$MOVED_REPO"

# At this point, the symlink in $TEST_HOME is broken because the repo path changed
if [[ -e "$TEST_HOME/.zshrc" ]]; then
    echo "  [FAIL] Symlink should be broken after repo move" >&2
    exit 1
fi
echo "  [PASS] Simulated broken symlink condition verified."

# 4. Uninstall should safely clean broken symlinks without crashing
bash "$MOVED_REPO/uninstall.sh" --home "$TEST_HOME"

if [[ -L "$TEST_HOME/.zshrc" ]]; then
    echo "  [FAIL] Broken symlink was not cleaned by uninstall.sh" >&2
    exit 1
fi
echo "  [PASS] Broken symlinks safely removed during uninstallation."

# Clean up moved repo
rm -rf "$MOVED_REPO"

echo "Relocation safety tests passed."

