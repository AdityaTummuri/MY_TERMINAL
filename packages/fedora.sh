#!/usr/bin/env bash
# packages/fedora.sh - Fedora package lists and commands

get_fedora_packages() {
    local profile="${1:-minimal}"

    local minimal_pkgs=(
        "kitty"
        "zsh"
        "starship"
        "jetbrains-mono-fonts-all"
        "curl"
    )

    local full_pkgs=(
        "fzf"
        "zoxide"
        "eza"
        "bat"
        "fastfetch"
        "tmux"
    )

    if [[ "$profile" == "minimal" ]]; then
        printf "%s\n" "${minimal_pkgs[@]}"
    else
        printf "%s\n" "${minimal_pkgs[@]}" "${full_pkgs[@]}"
    fi
}

get_fedora_install_cmd() {
    local profile="${1:-minimal}"
    local pkgs
    pkgs=$(get_fedora_packages "$profile" | tr '\n' ' ')
    echo "sudo dnf install -y $pkgs"
}

