#!/usr/bin/env bash
# uninstall.sh - Safe uninstaller for OMEN Terminal
# Removes only files tracked in the project manifest and verifies ownership.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"
DRY_RUN=false
FORCE=false

print_usage() {
    cat <<EOF
Usage: ./uninstall.sh [OPTIONS]

Options:
    --dry-run                  Simulate actions without removing files
    --force                    Remove even if symlinks point elsewhere or targets were altered
    --home <dir>               Specify custom target HOME directory (useful for testing)
    -h, --help                 Display this help message
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --home)
            TARGET_HOME="$2"
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            print_usage
            exit 1
            ;;
    esac
done

MANIFEST_DIR="$TARGET_HOME/.local/share/omen-terminal"
MANIFEST_FILE="$MANIFEST_DIR/manifest.txt"

echo "========================================="
echo "   OMEN Terminal - Dotfiles Uninstaller  "
echo "========================================="
echo "Target HOME : $TARGET_HOME"
echo "Dry Run     : $DRY_RUN"
echo ""

if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo "Notice: No installation manifest found at $MANIFEST_FILE."
    echo "Nothing to safely remove."
    exit 0
fi

echo "[1/2] Reading ownership manifest..."

REMOVAL_LIST=()
SKIPPED_LIST=()

while IFS= read -r file_path || [[ -n "$file_path" ]]; do
    [[ -z "$file_path" || "$file_path" =~ ^# ]] && continue

    if [[ ! -e "$file_path" && ! -L "$file_path" ]]; then
        # File no longer exists, already gone
        continue
    fi

    # Safety verification: ensure it is a symlink pointing into this repository
    if [[ -L "$file_path" ]]; then
        link_target=$(readlink "$file_path" || true)
        # Check if link points into the repo directory or targets matching config/
        if [[ "$link_target" == "${SCRIPT_DIR}"* ]] || [[ "$link_target" == *"/config/"* ]] || [[ "$FORCE" == "true" ]]; then
            REMOVAL_LIST+=("$file_path")
        else
            echo "  [WARNING] Symlink points outside repo ($link_target): $file_path"
            SKIPPED_LIST+=("$file_path (points outside repository)")
        fi
    else
        # Regular file or directory exists where symlink was expected
        echo "  [WARNING] Tracked target is no longer a symlink: $file_path"
        if [[ "$FORCE" == "true" ]]; then
            REMOVAL_LIST+=("$file_path")
        else
            SKIPPED_LIST+=("$file_path (not a project symlink; preserve user data)")
        fi
    fi
done < "$MANIFEST_FILE"

echo ""
echo "[2/2] Processing removal..."

for item in "${REMOVAL_LIST[@]}"; do
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "  [DRY-RUN] Would remove: $item"
    else
        rm "$item"
        echo "  [REMOVED] $item"
    fi
done

for skipped in "${SKIPPED_LIST[@]}"; do
    echo "  [PRESERVED] $skipped"
done

# Clean up manifest directory if empty or dry run completed
if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [DRY-RUN] Would remove manifest: $MANIFEST_FILE"
    echo ""
    echo "Dry run completed successfully. No files were removed."
else
    rm -f "$MANIFEST_FILE"
    rmdir "$MANIFEST_DIR" 2>/dev/null || true
    echo ""
    echo "Uninstall complete! User packages and unmanaged files were untouched."
fi

