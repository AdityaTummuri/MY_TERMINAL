#!/usr/bin/env bash
# tests/test-idempotency.sh - Test running install.sh multiple times produces no duplicates or broken links

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"

TEST_HOME=$(mktemp -d -t test-idempotency-XXXXXX)
trap 'rm -rf "$TEST_HOME"' EXIT

echo "Running idempotency tests in isolated HOME: $TEST_HOME"

# 1. First run with minimal profile
echo "--- Run 1: Minimal Profile ---"
bash "$INSTALL_SCRIPT" --profile minimal --home "$TEST_HOME"

manifest="$TEST_HOME/.local/share/omen-terminal/manifest.txt"
if [[ ! -f "$manifest" ]]; then
    echo "  [FAIL] Manifest was not created" >&2
    exit 1
fi
count_run1=$(grep -vc '^#' "$manifest")

# 2. Second run with minimal profile (should be idempotent)
echo "--- Run 2: Minimal Profile (Idempotent Check) ---"
bash "$INSTALL_SCRIPT" --profile minimal --home "$TEST_HOME"

count_run2=$(grep -vc '^#' "$manifest")
if [[ "$count_run1" -ne "$count_run2" ]]; then
    echo "  [FAIL] Manifest entry count changed between runs: $count_run1 vs $count_run2" >&2
    exit 1
fi
echo "  [PASS] Manifest entry count is stable ($count_run1 items)"

# 3. Third run with full profile
echo "--- Run 3: Upgrade to Full Profile ---"
bash "$INSTALL_SCRIPT" --profile full --home "$TEST_HOME"
count_full1=$(grep -vc '^#' "$manifest")

# 4. Fourth run with full profile (should remain stable)
echo "--- Run 4: Repeat Full Profile ---"
bash "$INSTALL_SCRIPT" --profile full --home "$TEST_HOME"
count_full2=$(grep -vc '^#' "$manifest")

if [[ "$count_full1" -ne "$count_full2" ]]; then
    echo "  [FAIL] Full profile count changed between runs: $count_full1 vs $count_full2" >&2
    exit 1
fi
echo "  [PASS] Full profile idempotent check passed ($count_full1 items)"

# Verify no links are broken
while IFS= read -r item || [[ -n "$item" ]]; do
    [[ -z "$item" || "$item" =~ ^# ]] && continue
    if [[ ! -L "$item" ]]; then
        echo "  [FAIL] Manifest item $item is not a symlink" >&2
        exit 1
    fi
    if [[ ! -e "$item" ]]; then
        echo "  [FAIL] Broken symlink: $item -> $(readlink "$item")" >&2
        exit 1
    fi
done < "$manifest"

echo "  [PASS] All created symlinks are valid and unbroken"
echo "Idempotency test completed successfully."

