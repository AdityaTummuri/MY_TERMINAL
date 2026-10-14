#!/usr/bin/env bash
# packages/arch.sh - Arch Linux package lists and commands

get_arch_packages() {
    local profile="${1:-minimal}"

    local minimal_pkgs=(
        "kitty"
        "zsh"
        "starship"
        "ttf-jetbrains-mono-nerd"
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

get_arch_install_cmd() {
    local profile="${1:-minimal}"
    local pkgs
    pkgs=$(get_arch_packages "$profile" | tr '\n' ' ')
    echo "sudo pacman -S --needed $pkgs"
}

