# OMEN Terminal

A reproducible, portable, and minimal Linux terminal environment powered by **Kitty**, **Zsh**, **Starship**, and the **Catppuccin Mocha** color scheme.

Built with native distribution package adapters, safe manifest-driven symlinking, and zero host pollution. Fully compatible with **Ubuntu 24.04 LTS**, **Fedora**, and **Arch Linux**.

---

## Features

- **Terminal**: [Kitty](https://sw.kovidgoyal.net/kitty/) configured with Catppuccin Mocha and graceful Nerd Font symbol fallbacks.
- **Shell**: Pure, standalone [Zsh](https://www.zsh.org/) (no heavy frameworks like Oh My Zsh). Boots in milliseconds with native completions, emacs-style history search, and plugin fallbacks.
- **Prompt**: [Starship](https://starship.rs/) configured with git branch/status indicators, command duration, and return codes.
- **Fastfetch**: Runs automatically on interactive shell startup; toggled with a single variable (`export ENABLE_FASTFETCH=false` in `~/.zshrc.local`).
- **Tmux**: Catppuccin-styled tmux configuration with intuitive splits and vim-keys. Never auto-started.
- **Safety First**: Idempotent installer, non-destructive conflict handling, dry-run mode, and an ownership manifest for clean uninstallation.

---

## Quickstart

**Before you begin:** Clone this repository and run the commands below from its root directory.

### 1. View Recommended Distro Packages
Check packages for your distro without running any privileged commands:
```bash
bash packages/detect-distro.sh
```

### 2. Preview Installation (Dry Run)
```bash
./install.sh --dry-run
# or for full profile:
./install.sh --profile full --dry-run
```

### 3. Install Configurations
Choose between `minimal` (Kitty + Zsh + Starship) or `full` (+ Fastfetch, Tmux, modern CLI tools):
```bash
# Minimal profile
./install.sh

# Full profile
./install.sh --profile full
```

### 4. Verify Setup
```bash
./scripts/doctor.sh
```

---

## Ubuntu 24.04 LTS Package Installation

OMEN Terminal separates package installation from configuration linking. Run the appropriate command below depending on your desired profile:

### Minimal Profile
```bash
# Official APT packages
sudo apt update && sudo apt install -y kitty zsh fonts-jetbrains-mono curl

# Starship prompt binary (standalone)
curl -sS https://starship.rs/install.sh | sh
```

### Full Profile
```bash
# Core + modern CLI utilities
sudo apt update && sudo apt install -y kitty zsh fonts-jetbrains-mono curl fzf zoxide eza bat tmux zsh-autosuggestions

# Starship prompt binary
curl -sS https://starship.rs/install.sh | sh

# Fastfetch (via official PPA)
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
sudo apt update && sudo apt install -y fastfetch

# JetBrainsMono Nerd Font (for full glyph & icon support)
mkdir -p ~/.local/share/fonts
curl -fLo /tmp/JetBrainsMono.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar -xf /tmp/JetBrainsMono.tar.xz -C ~/.local/share/fonts/ && fc-cache -f ~/.local/share/fonts/ && rm -f /tmp/JetBrainsMono.tar.xz
```

---

## Project Structure

```
.
├── config/
│   ├── fastfetch/config.jsonc
│   ├── kitty/kitty.conf
│   ├── starship/starship.toml
│   ├── tmux/tmux.conf
│   └── zsh/.zshrc
├── docs/
│   ├── INSTALL.md
│   ├── PORTABILITY.md
│   ├── SECURITY.md
│   └── TROUBLESHOOTING.md
├── export-config.sh
├── import-config.sh
├── install.sh
├── packages/
│   ├── arch.sh
│   ├── common.sh
│   ├── detect-distro.sh
│   ├── fedora.sh
│   └── ubuntu.sh
├── scripts/
│   ├── doctor.sh
│   ├── test-config.sh
│   └── update.sh
├── tests/
│   ├── test-config-links.sh
│   ├── test-distro-detection.sh
│   ├── test-idempotency.sh
│   ├── test-relocation-safety.sh
│   ├── test-uninstall-safety.sh
│   └── test-zsh-behavior.sh
├── uninstall.sh
├── README.md
├── RELEASE_CHECKLIST.md
└── LICENSE
```

---

## Documentation

- [Installation Guide](docs/INSTALL.md)
- [Portability & Migration](docs/PORTABILITY.md)
- [Security Guidelines](docs/SECURITY.md)
- [Troubleshooting & FAQ](docs/TROUBLESHOOTING.md)
- [Release Checklist & Verification](RELEASE_CHECKLIST.md)

---

## License

MIT