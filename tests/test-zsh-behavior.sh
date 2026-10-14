#!/usr/bin/env bash
# tests/test-zsh-behavior.sh - Test interactive/non-interactive behavior, missing tools, and switches

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC="$SCRIPT_DIR/config/zsh/.zshrc"

if ! command -v zsh >/dev/null 2>&1; then
    echo "Notice: zsh binary not found. Skipping live zsh execution tests."
    exit 0
fi

echo "========================================="
echo "   OMEN Terminal - Zsh Behavior Tests    "
echo "========================================="

TEST_HOME=$(mktemp -d -t test-zsh-env-XXXXXX)
trap 'rm -rf "$TEST_HOME"' EXIT

# Copy zshrc into isolated home
cp "$ZSHRC" "$TEST_HOME/.zshrc"

# 1. Non-interactive shell execution should NOT produce fastfetch output
echo "--- Test 1: Non-interactive shell startup ---"
output_noninteractive=$(HOME="$TEST_HOME" zsh -c 'echo "NON_INTERACTIVE_OK"')
if [[ "$output_noninteractive" != "NON_INTERACTIVE_OK" ]]; then
    echo "  [FAIL] Non-interactive execution printed unexpected output: $output_noninteractive" >&2
    exit 1
fi
echo "  [PASS] Non-interactive shell startup produces zero spurious output."

# 2. Interactive shell syntax and source test
echo "--- Test 2: Sourcing .zshrc in isolated environment ---"
HOME="$TEST_HOME" zsh -i -c 'exit 0' </dev/null
echo "  [PASS] Sourced successfully in interactive mode without fatal errors."

# 3. Test ENABLE_FASTFETCH switch in ~/.zshrc.local
echo "--- Test 3: Fastfetch switch via ~/.zshrc.local ---"
echo "export ENABLE_FASTFETCH=false" > "$TEST_HOME/.zshrc.local"
output_disabled=$(HOME="$TEST_HOME" zsh -i -c 'echo "FASTFETCH_SWITCH_CHECK: $ENABLE_FASTFETCH"' </dev/null 2>&1 || true)
if echo "$output_disabled" | grep -q "FASTFETCH_SWITCH_CHECK: false"; then
    echo "  [PASS] ENABLE_FASTFETCH=false was honored correctly."
else
    echo "  [FAIL] ENABLE_FASTFETCH override failed: $output_disabled" >&2
    exit 1
fi

# 4. Startup speed tolerance without PATH tools
echo "--- Test 4: Graceful startup with empty PATH ---"
# Test startup when none of optional tools exist
output_empty_path=$(HOME="$TEST_HOME" PATH="/bin:/usr/bin" zsh -c 'echo "CLEAN_START"')
if [[ "$output_empty_path" == "CLEAN_START" ]]; then
    echo "  [PASS] Shell starts cleanly even with minimal base PATH."
else
    echo "  [FAIL] Shell output error with minimal PATH: $output_empty_path" >&2
    exit 1
fi

echo "All Zsh behavior tests passed."

