#!/usr/bin/env bash
# import-config.sh - Safely import an OMEN terminal configuration archive
# Verifies archive integrity and replaces/updates files in config/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT_ARCHIVE="${1:-}"

if [[ -z "$INPUT_ARCHIVE" || ! -f "$INPUT_ARCHIVE" ]]; then
    echo "Usage: ./import-config.sh <path-to-archive.tar.gz>" >&2
    exit 1
fi

echo "========================================="
echo "   OMEN Terminal - Config Importer       "
echo "========================================="
echo "Import archive : $INPUT_ARCHIVE"
echo "Target dir     : $SCRIPT_DIR/config"
echo ""

# Validate archive contents before extracting
echo "Inspecting archive structure..."
if ! tar -ztf "$INPUT_ARCHIVE" | grep -q '^config/'; then
    echo "Error: Archive does not contain valid config/ root directory." >&2
    exit 1
fi

# Ensure archive does not contain absolute paths or directory traversal attempts
if tar -ztf "$INPUT_ARCHIVE" | grep -E '(^/|\.\./)'; then
    echo "Error: Archive contains unsafe paths (absolute paths or directory traversal)." >&2
    exit 1
fi

# Extract into repository config directory
tar -zxvf "$INPUT_ARCHIVE" -C "$SCRIPT_DIR"

echo ""
echo "Configuration imported successfully into $SCRIPT_DIR/config."
echo "Run ./install.sh to update links in your home directory."

