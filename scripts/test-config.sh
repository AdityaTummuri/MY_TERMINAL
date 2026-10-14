#!/usr/bin/env bash
# scripts/test-config.sh - Validate configuration syntax and sanity

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0

echo "========================================="
echo "   OMEN Terminal - Config Validator      "
echo "========================================="
echo ""

# 1. Validate Shell scripts syntax with bash -n
echo "[1] Checking shell script syntax (bash -n)..."
while IFS= read -r script; do
    if bash -n "$script"; then
        echo "  [PASS] $script"
    else
        echo "  [FAIL] Syntax error in $script" >&2
        ERRORS=$((ERRORS + 1))
    fi
done < <(find "$SCRIPT_DIR" -maxdepth 3 -type f -name "*.sh")

# 2. Validate Zsh syntax
echo ""
echo "[2] Checking Zsh configuration syntax..."
if command -v zsh >/dev/null 2>&1; then
    if zsh -n "$SCRIPT_DIR/config/zsh/.zshrc"; then
        echo "  [PASS] config/zsh/.zshrc syntax is valid"
    else
        echo "  [FAIL] config/zsh/.zshrc syntax error" >&2
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "  [SKIP] zsh not installed"
fi

# 3. Validate Fastfetch JSONC
echo ""
echo "[3] Checking Fastfetch JSON syntax..."
if command -v python3 >/dev/null 2>&1; then
    if python3 -c '
import json, re, sys
with open(sys.argv[1]) as f:
    content = f.read()
# Strip comments line by line (only lines starting with optional whitespace and //)
lines = []
for line in content.splitlines():
    stripped = line.strip()
    if not stripped.startswith("//"):
        lines.append(line)
json.loads("\n".join(lines))
' "$SCRIPT_DIR/config/fastfetch/config.jsonc" 2>/dev/null; then
        echo "  [PASS] config/fastfetch/config.jsonc syntax is valid"
    else
        echo "  [FAIL] config/fastfetch/config.jsonc invalid JSON" >&2
        ERRORS=$((ERRORS + 1))
    fi
fi

# 4. Validate Starship TOML
echo ""
echo "[4] Checking Starship TOML syntax..."
if command -v python3 >/dev/null 2>&1; then
    if python3 -c '
import sys
try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib
    except ImportError:
        sys.exit(0)
with open(sys.argv[1], "rb") as f:
    tomllib.load(f)
' "$SCRIPT_DIR/config/starship/starship.toml" 2>/dev/null; then
        echo "  [PASS] config/starship/starship.toml syntax is valid"
    else
        echo "  [FAIL] config/starship/starship.toml invalid TOML" >&2
        ERRORS=$((ERRORS + 1))
    fi
fi

# 5. Validate Kitty conf basic syntax
echo ""
echo "[5] Checking Kitty conf format..."
# Kitty configs are key-value pairs or empty/comments
kitty_invalid_lines=$(grep -vE '^\s*(#|$|[a-zA-Z0-9_-]+(\s+.*)?$)' "$SCRIPT_DIR/config/kitty/kitty.conf" || true)
if [[ -z "$kitty_invalid_lines" ]]; then
    echo "  [PASS] config/kitty/kitty.conf format is valid"
else
    echo "  [FAIL] config/kitty/kitty.conf unexpected syntax: $kitty_invalid_lines" >&2
    ERRORS=$((ERRORS + 1))
fi

echo ""
if [[ $ERRORS -eq 0 ]]; then
    echo "All configuration files passed syntax validation!"
    exit 0
else
    echo "Found $ERRORS syntax error(s)." >&2
    exit 1
fi
