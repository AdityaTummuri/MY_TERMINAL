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

The dry run reports the planned actions without creating configuration links or changing files in your home directory. It does not install packages.

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

## Package Installation by Distribution

OMEN Terminal separates package installation from configuration linking. Install the packages for your distribution, then return to the Quickstart section to preview and apply the configuration.

- **Ubuntu / Debian:** Follow the APT instructions in [Installation Guide](docs/INSTALL.md#ubuntu-2404-lts-noble-numbat).
- **Fedora:** Follow the DNF instructions in [Installation Guide](docs/INSTALL.md#fedora).
- **Arch Linux:** Follow the pacman instructions in [Installation Guide](docs/INSTALL.md#arch-linux).

The installer does not run privileged package commands automatically.

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