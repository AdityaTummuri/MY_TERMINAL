#!/usr/bin/env bash
# scripts/update.sh - Pull latest repository updates and refresh symlinks safely

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "========================================="
echo "   OMEN Terminal - Updater               "
echo "========================================="

if [[ -d "$SCRIPT_DIR/.git" ]]; then
    echo "Updating repository from git..."
    git -C "$SCRIPT_DIR" pull --ff-only || {
        echo "Git pull failed or branch has diverged. Please review git status." >&2
        exit 1
    }
else
    echo "Notice: Repository is not a git clone. Skipping git pull."
fi

echo "Refreshing configuration links..."
bash "$SCRIPT_DIR/install.sh" --profile full --force

echo "Update finished successfully."

