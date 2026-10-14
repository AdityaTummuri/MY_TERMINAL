#!/usr/bin/env bash
# packages/ubuntu.sh - Ubuntu/Debian package lists and commands

get_ubuntu_packages() {
    local profile="${1:-minimal}"

    # Ubuntu 24.04 native apt packages:
    # kitty, zsh, fonts-jetbrains-mono, curl
    # Note: starship is not packaged in official Ubuntu 24.04 apt repos (installed via official installer)
    local minimal_pkgs=(
        "kitty"
        "zsh"
        "fonts-jetbrains-mono"
        "curl"
    )

    # Full adds: fzf, zoxide, eza, bat, tmux, zsh-autosuggestions
    # Note: fastfetch is not in standard Ubuntu 24.04 main/universe repos (ppa:zhangsongcui3371/fastfetch or github deb/binary)
    local full_pkgs=(
        "fzf"
        "zoxide"
        "eza"
        "bat"
        "tmux"
        "zsh-autosuggestions"
    )

    if [[ "$profile" == "minimal" ]]; then
        printf "%s\n" "${minimal_pkgs[@]}"
    else
        printf "%s\n" "${minimal_pkgs[@]}" "${full_pkgs[@]}"
    fi
}

get_ubuntu_install_cmd() {
    local profile="${1:-minimal}"
    local pkgs
    pkgs=$(get_ubuntu_packages "$profile" | tr '\n' ' ')
    echo "sudo apt update && sudo apt install -y $pkgs"
}

get_ubuntu_extra_notes() {
    local profile="${1:-minimal}"
    echo "  [INFO] Ubuntu Notes:"
    echo "    - Starship: install via official script: curl -sS https://starship.rs/install.sh | sh"
    echo "    - JetBrainsMono Nerd Font (for full glyphs): download and place in ~/.local/share/fonts"
    if [[ "$profile" == "full" ]]; then
        echo "    - Fastfetch: available via PPA (sudo add-apt-repository ppa:zhangsongcui3371/fastfetch) or GitHub release"
    fi
}

