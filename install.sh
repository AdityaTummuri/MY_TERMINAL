#!/usr/bin/env bash
# install.sh - OMEN Terminal Installer
# Safe, idempotent dotfiles linker and manifest tracker.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"
PROFILE="minimal"
DRY_RUN=false
FORCE=false

print_usage() {
    cat <<EOF
Usage: ./install.sh [OPTIONS]

Options:
    --profile <minimal|full>   Installation profile (default: minimal)
    --dry-run                  Simulate actions without making changes
    --force                    Overwrite conflicting symlinks (preserves regular files)
    --home <dir>               Specify custom target HOME directory (useful for testing)
    -h, --help                 Display this help message
EOF
}

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            PROFILE="$2"
            shift 2
            ;;
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

if [[ "$PROFILE" != "minimal" && "$PROFILE" != "full" ]]; then
    echo "Error: Invalid profile '$PROFILE'. Must be 'minimal' or 'full'." >&2
    exit 1
fi

echo "========================================="
echo "   OMEN Terminal - Dotfiles Installer    "
echo "========================================="
echo "Target HOME : $TARGET_HOME"
echo "Profile     : $PROFILE"
echo "Dry Run     : $DRY_RUN"
echo ""

# 1. Distro Detection and Package recommendations
DISTRO_SCRIPT="$SCRIPT_DIR/packages/detect-distro.sh"
DISTRO="unknown"
if [[ -x "$DISTRO_SCRIPT" || -f "$DISTRO_SCRIPT" ]]; then
    DISTRO=$(bash "$DISTRO_SCRIPT" || echo "unsupported")
fi

echo "[1/4] Checking Distribution..."
if [[ "$DISTRO" == "unsupported" || "$DISTRO" == "unknown" ]]; then
    echo "  Notice: Target OS not directly supported by automatic package recipes."
    echo "  Dotfiles linking will proceed safely, but packages must be installed manually."
else
    echo "  Detected distribution: $DISTRO"
    echo "  To install recommended system packages, run the following command manually:"
    source "$SCRIPT_DIR/packages/common.sh"
    case "$DISTRO" in
        ubuntu)
            source "$SCRIPT_DIR/packages/ubuntu.sh"
            echo "    -> $(get_ubuntu_install_cmd "$PROFILE")"
            if type get_ubuntu_extra_notes &>/dev/null; then
                get_ubuntu_extra_notes "$PROFILE"
            fi
            ;;
        fedora)
            source "$SCRIPT_DIR/packages/fedora.sh"
            echo "    -> $(get_fedora_install_cmd "$PROFILE")"
            ;;
        arch)
            source "$SCRIPT_DIR/packages/arch.sh"
            echo "    -> $(get_arch_install_cmd "$PROFILE")"
            ;;
    esac
fi
echo ""

# 2. Define configurations to link based on profile
# Mapping format: repo_relative_path:target_relative_path
CONFIG_MAP=(
    "config/kitty/kitty.conf:.config/kitty/kitty.conf"
    "config/zsh/.zshrc:.zshrc"
    "config/starship/starship.toml:.config/starship.toml"
)

if [[ "$PROFILE" == "full" ]]; then
    CONFIG_MAP+=(
        "config/fastfetch/config.jsonc:.config/fastfetch/config.jsonc"
        "config/tmux/tmux.conf:.tmux.conf"
    )
fi

MANIFEST_DIR="$TARGET_HOME/.local/share/omen-terminal"
MANIFEST_FILE="$MANIFEST_DIR/manifest.txt"

echo "[2/4] Verifying targets and detecting conflicts..."
CONFLICTS_FOUND=false

for entry in "${CONFIG_MAP[@]}"; do
    src="${SCRIPT_DIR}/${entry%%:*}"
    rel_dst="${entry##*:}"
    dst="${TARGET_HOME}/${rel_dst}"

    if [[ -e "$dst" || -L "$dst" ]]; then
        if [[ -L "$dst" ]]; then
            link_target=$(readlink "$dst" || true)
            if [[ "$link_target" == "$src" ]]; then
                echo "  [OK] Already linked: $rel_dst -> $src"
            else
                echo "  [CONFLICT] Symlink exists pointing elsewhere: $rel_dst -> $link_target"
                if [[ "$FORCE" != "true" ]]; then
                    CONFLICTS_FOUND=true
                fi
            fi
        else
            echo "  [CONFLICT] Regular file/directory already exists: $dst"
            CONFLICTS_FOUND=true
        fi
    fi
done

if [[ "$CONFLICTS_FOUND" == "true" ]]; then
    echo ""
    echo "Conflict detected! Existing files will NOT be overwritten silently." >&2
    echo "Options:" >&2
    echo "  1. Back up or rename the conflicting files manually." >&2
    echo "  2. Use --force to replace existing symlinks (regular files are still preserved)." >&2
    exit 2
fi

echo ""
echo "[3/4] Linking configuration files..."

if [[ "$DRY_RUN" == "true" ]]; then
    echo "  [DRY-RUN] Would create directory: $MANIFEST_DIR"
    echo "  [DRY-RUN] Would create manifest file: $MANIFEST_FILE"
    for entry in "${CONFIG_MAP[@]}"; do
        src="${SCRIPT_DIR}/${entry%%:*}"
        rel_dst="${entry##*:}"
        dst="${TARGET_HOME}/${rel_dst}"
        echo "  [DRY-RUN] Would link: $dst -> $src"
    done
    echo ""
    echo "[4/4] Dry run completed successfully. No changes were made."
    exit 0
fi

mkdir -p "$MANIFEST_DIR"
# Manifest tracking: read existing to preserve history if idempotent
declare -A TRACKED_ITEMS
if [[ -f "$MANIFEST_FILE" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        TRACKED_ITEMS["$line"]=1
    done < "$MANIFEST_FILE"
fi

for entry in "${CONFIG_MAP[@]}"; do
    src="${SCRIPT_DIR}/${entry%%:*}"
    rel_dst="${entry##*:}"
    dst="${TARGET_HOME}/${rel_dst}"
    dst_dir="$(dirname "$dst")"

    mkdir -p "$dst_dir"

    if [[ -L "$dst" ]]; then
        link_target=$(readlink "$dst" || true)
        if [[ "$link_target" == "$src" ]]; then
            echo "  [OK] Unchanged: $rel_dst"
            TRACKED_ITEMS["$dst"]=1
            continue
        elif [[ "$FORCE" == "true" ]]; then
            rm "$dst"
        fi
    fi

    ln -s "$src" "$dst"
    echo "  [LINKED] $rel_dst -> $src"
    TRACKED_ITEMS["$dst"]=1
done

# Write out updated manifest atomically
tmp_manifest="${MANIFEST_FILE}.tmp"
{
    echo "# OMEN Terminal Manifest - Generated $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo "# Profile: $PROFILE"
    for item in "${!TRACKED_ITEMS[@]}"; do
        echo "$item"
    done
} > "$tmp_manifest"
mv "$tmp_manifest" "$MANIFEST_FILE"

echo ""
echo "[4/4] Installation manifest updated at: $MANIFEST_FILE"
echo "Installation complete!"

