#!/usr/bin/env bash
# export-config.sh - Safely bundle OMEN configuration files into a portable tar archive
# Excludes secrets, credentials, history, and machine-specific files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_ARCHIVE="${1:-$SCRIPT_DIR/omen-terminal-config.tar.gz}"

echo "========================================="
echo "   OMEN Terminal - Config Exporter       "
echo "========================================="
echo "Exporting from : $SCRIPT_DIR/config"
echo "Output archive : $OUTPUT_ARCHIVE"
echo ""

# Verify secrets or credentials are not in config directory
echo "Verifying security exclusions..."
forbidden_patterns=("id_rsa" "id_ed25519" "*.pem" "*.key" "*history*" "*token*")
for pat in "${forbidden_patterns[@]}"; do
    found=$(find "$SCRIPT_DIR/config" -name "$pat" -print -quit || true)
    if [[ -n "$found" ]]; then
        echo "Error: Forbidden sensitive file found in config: $found" >&2
        exit 1
    fi
done

# Create clean tar archive of repo config/ directory
# using relative paths to ensure no absolute host paths are baked in
tar --exclude='.git' \
    --exclude='*.swp' \
    --exclude='*~' \
    -czf "$OUTPUT_ARCHIVE" -C "$SCRIPT_DIR" config

echo "Export created successfully at: $OUTPUT_ARCHIVE"
echo "Archive contents:"
tar -ztvf "$OUTPUT_ARCHIVE"

