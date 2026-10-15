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

# 4. Validate Starship TOML & Structure
echo ""
echo "[4] Checking Starship TOML syntax and structure..."
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
    data = tomllib.load(f)

# Semantic checks for Starship config
palette = data.get("palette")
if not isinstance(palette, str):
    print("Error: root palette must be a string", file=sys.stderr)
    sys.exit(1)

palettes = data.get("palettes")
if not isinstance(palettes, dict) or palette not in palettes:
    print(f"Error: defined palette \"{palette}\" not found under [palettes.<name>]", file=sys.stderr)
    sys.exit(1)
' "$SCRIPT_DIR/config/starship/starship.toml" 2>/dev/null; then
        echo "  [PASS] config/starship/starship.toml syntax & palette structure are valid"
    else
        echo "  [FAIL] config/starship/starship.toml invalid TOML or palette structure" >&2
        ERRORS=$((ERRORS + 1))
    fi
fi

# 5. Validate Starship executable evaluation if starship is installed
if command -v starship >/dev/null 2>&1; then
    starship_err=$(TERM=xterm-256color STARSHIP_CONFIG="$SCRIPT_DIR/config/starship/starship.toml" starship prompt 2>&1 >/dev/null || true)
    if [[ -z "$starship_err" ]]; then
        echo "  [PASS] starship prompt evaluates without warnings or errors"
    else
        echo "  [FAIL] starship prompt produced warning/error: $starship_err" >&2
        ERRORS=$((ERRORS + 1))
    fi
fi

# 6. Validate Kitty conf format and symbol_map safety
echo ""
echo "[6] Checking Kitty conf format and symbol_map safety..."
kitty_invalid_lines=$(grep -vE '^\s*(#|$|[a-zA-Z0-9_-]+(\s+.*)?$)' "$SCRIPT_DIR/config/kitty/kitty.conf" || true)
if [[ -z "$kitty_invalid_lines" ]]; then
    echo "  [PASS] config/kitty/kitty.conf format is valid"
else
    echo "  [FAIL] config/kitty/kitty.conf unexpected syntax: $kitty_invalid_lines" >&2
    ERRORS=$((ERRORS + 1))
fi

# Verify active symbol_map entries do not trigger Kitty render crash
if command -v python3 >/dev/null 2>&1 && [[ -d "/usr/lib/kitty" ]]; then
    if PYTHONPATH=/usr/lib/kitty python3 -c '
import sys
from kitty.fonts.render import coalesce_symbol_maps
from kitty.options.utils import symbol_map

active_maps = {}
with open(sys.argv[1]) as f:
    for line in f:
        line = line.strip()
        if line.startswith("symbol_map ") and not line.startswith("#"):
            val = line[len("symbol_map "):].strip()
            for k, v in symbol_map(val):
                active_maps[k] = v

if active_maps:
    coalesce_symbol_maps(active_maps)
' "$SCRIPT_DIR/config/kitty/kitty.conf" 2>/dev/null; then
        echo "  [PASS] Kitty symbol_map entries are non-conflicting and crash-free"
    else
        echo "  [FAIL] Kitty symbol_map entries cause KeyError or crash in renderer" >&2
        ERRORS=$((ERRORS + 1))
    fi
fi

echo ""
if [[ $ERRORS -eq 0 ]]; then
    echo "All configuration files passed syntax validation!"
    exit 0
else
    echo "Found $ERRORS syntax error(s)." >&2
    exit 1
fi
