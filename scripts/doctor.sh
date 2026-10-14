#!/usr/bin/env bash
# scripts/doctor.sh - Diagnostic tool for OMEN Terminal environment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_HOME="${HOME}"

echo "========================================="
echo "   OMEN Terminal - System Doctor         "
echo "========================================="
echo ""

# 1. Distro Detection
echo "--- [1] Distribution Support ---"
DISTRO_SCRIPT="$SCRIPT_DIR/packages/detect-distro.sh"
DISTRO=$(bash "$DISTRO_SCRIPT" 2>/dev/null || echo "unsupported")
echo "Detected distribution: $DISTRO"
if [[ "$DISTRO" == "unsupported" ]]; then
    echo "  [WARN] Native package manager recipes not available for this distro."
else
    echo "  [PASS] Supported distro adapter available."
fi
echo ""

# 2. Installed Binary Checks
echo "--- [2] Tool Availability ---"
check_cmd() {
    local cmd="$1"
    local required="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        local version_info
        version_info=$("$cmd" --version 2>&1 | head -n 1 || echo "installed")
        echo "  [OK] $cmd: $version_info"
    else
        if [[ "$required" == "true" ]]; then
            echo "  [FAIL] $cmd: Not found (Required for core terminal setup)"
        else
            echo "  [OPTIONAL] $cmd: Not found (Optional integration disabled)"
        fi
    fi
}

echo "Core Stack:"
check_cmd "kitty" false
check_cmd "zsh" true
check_cmd "starship" false

echo ""
echo "Full Tools:"
check_cmd "fastfetch" false
check_cmd "tmux" false
check_cmd "fzf" false
check_cmd "zoxide" false
check_cmd "eza" false
if command -v batcat >/dev/null 2>&1; then
    check_cmd "batcat" false
else
    check_cmd "bat" false
fi
echo ""

# 3. Font Checks
echo "--- [3] Font Checks ---"
if command -v fc-list >/dev/null 2>&1; then
    if fc-list : family | grep -qi "JetBrainsMono Nerd Font"; then
        echo "  [PASS] JetBrainsMono Nerd Font found in fontconfig cache."
    elif fc-list : family | grep -qi "JetBrains Mono"; then
        echo "  [WARN] JetBrains Mono detected, but Nerd Font glyphs may need fallback."
    else
        echo "  [WARN] JetBrainsMono Nerd Font not detected in system font list."
    fi
else
    echo "  [INFO] fc-list not installed; skipping font query."
fi
echo ""

# 4. Config Symlinks & Ownership
echo "--- [4] Managed Config Links ---"
MANIFEST_FILE="$TARGET_HOME/.local/share/omen-terminal/manifest.txt"
if [[ -f "$MANIFEST_FILE" ]]; then
    echo "  Manifest found at: $MANIFEST_FILE"
    while IFS= read -r item || [[ -n "$item" ]]; do
        [[ -z "$item" || "$item" =~ ^# ]] && continue
        if [[ -L "$item" ]]; then
            target=$(readlink "$item")
            echo "  [PASS] $item -> $target"
        elif [[ -e "$item" ]]; then
            echo "  [WARN] $item exists but is NOT a symlink!"
        else
            echo "  [FAIL] $item is tracked but missing."
        fi
    done < "$MANIFEST_FILE"
else
    echo "  [INFO] No active installation manifest found at $MANIFEST_FILE"
fi

echo ""
echo "Doctor check complete."

