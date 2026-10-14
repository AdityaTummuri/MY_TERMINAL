#!/usr/bin/env bash
# tests/test-distro-detection.sh - Test distro detection logic using mock fixtures

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DETECT_SCRIPT="$SCRIPT_DIR/packages/detect-distro.sh"

TEST_TEMP_DIR=$(mktemp -d -t test-distro-XXXXXX)
trap 'rm -rf "$TEST_TEMP_DIR"' EXIT

passed=0
failed=0

run_test() {
    local name="$1"
    local content="$2"
    local expected="$3"

    local fixture="$TEST_TEMP_DIR/os-release"
    printf "%s\n" "$content" > "$fixture"

    local result
    result=$(bash "$DETECT_SCRIPT" "$fixture" 2>/dev/null || true)

    if [[ "$result" == "$expected" ]]; then
        echo "  [PASS] $name (expected '$expected', got '$result')"
        passed=$((passed + 1))
    else
        echo "  [FAIL] $name (expected '$expected', got '$result')" >&2
        failed=$((failed + 1))
    fi
}

echo "Running distro detection tests..."

# 1. Ubuntu
run_test "Ubuntu Standard" $'NAME="Ubuntu"\nID=ubuntu\nID_LIKE=debian' "ubuntu"
# 2. Debian
run_test "Debian Standard" $'NAME="Debian GNU/Linux"\nID=debian' "ubuntu"
# 3. Pop!_OS
run_test "Pop!_OS (ID match)" $'NAME="Pop!_OS"\nID=pop\nID_LIKE="ubuntu debian"' "ubuntu"
# 4. Fedora
run_test "Fedora Standard" $'NAME="Fedora Linux"\nID=fedora' "fedora"
# 5. RHEL / Rocky (ID_LIKE match)
run_test "Rocky Linux (ID_LIKE)" $'NAME="Rocky Linux"\nID=rocky\nID_LIKE="rhel centos fedora"' "fedora"
# 6. Arch Linux
run_test "Arch Linux Standard" $'NAME="Arch Linux"\nID=arch' "arch"
# 7. Manjaro (ID_LIKE match)
run_test "Manjaro Linux (ID_LIKE)" $'NAME="Manjaro Linux"\nID=manjaro\nID_LIKE=arch' "arch"
# 8. Unsupported distro (Alpine / Void / Gentoo)
run_test "Alpine Linux (Unsupported)" $'NAME="Alpine Linux"\nID=alpine' "unsupported"

echo ""
echo "Distro detection test summary: $passed passed, $failed failed."
if [[ $failed -gt 0 ]]; then
    exit 1
fi

