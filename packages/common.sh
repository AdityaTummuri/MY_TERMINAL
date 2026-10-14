#!/usr/bin/env bash
# packages/common.sh - Common package abstractions and definitions

get_packages_for_profile() {
    local profile="${1:-minimal}"
    local distro="${2:-ubuntu}"

    case "$distro" in
        ubuntu)
            source "$(dirname "${BASH_SOURCE[0]}")/ubuntu.sh"
            get_ubuntu_packages "$profile"
            ;;
        fedora)
            source "$(dirname "${BASH_SOURCE[0]}")/fedora.sh"
            get_fedora_packages "$profile"
            ;;
        arch)
            source "$(dirname "${BASH_SOURCE[0]}")/arch.sh"
            get_arch_packages "$profile"
            ;;
        *)
            echo "Unsupported distribution: $distro" >&2
            return 1
            ;;
    esac
}

