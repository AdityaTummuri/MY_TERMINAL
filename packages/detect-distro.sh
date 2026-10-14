#!/usr/bin/env bash
# packages/detect-distro.sh - Detect Linux distribution from /etc/os-release or custom path

set -euo pipefail

detect_distro() {
    local os_release_file="${1:-/etc/os-release}"
    
    if [[ ! -f "$os_release_file" ]]; then
        echo "unknown"
        return 1
    fi

    # Parse key variables safely without executing untrusted arbitrary code
    local distro_id=""
    local id_like=""
    
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
        # Trim leading/trailing whitespace
        key=$(echo "$key" | tr -d '[:space:]')
        # Remove surrounding quotes if present
        value=$(echo "$value" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
        
        case "$key" in
            ID) distro_id="$value" ;;
            ID_LIKE) id_like="$value" ;;
        esac
    done < "$os_release_file"

    # Normalize identifiers
    case "$distro_id" in
        ubuntu|debian|pop|linuxmint|elementary|zorin)
            echo "ubuntu"
            return 0
            ;;
        fedora|rhel|centos|rocky|alma)
            echo "fedora"
            return 0
            ;;
        arch|manjaro|endeavouros|artix|garuda)
            echo "arch"
            return 0
            ;;
    esac

    # Check ID_LIKE fallback
    for like in $id_like; do
        case "$like" in
            ubuntu|debian)
                echo "ubuntu"
                return 0
                ;;
            fedora|rhel)
                echo "fedora"
                return 0
                ;;
            arch)
                echo "arch"
                return 0
                ;;
        esac
    done

    echo "unsupported"
    return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    target_file="${1:-/etc/os-release}"
    if detected=$(detect_distro "$target_file"); then
        echo "$detected"
        exit 0
    else
        echo "$detected"
        exit 1
    fi
fi
