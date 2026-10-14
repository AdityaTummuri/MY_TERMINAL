# Release Checklist & Audit Verification

Status: **READY FOR INSTALLATION**
Target Environment: **Ubuntu 24.04.5 LTS (Noble Numbat)** / Fedora / Arch Linux
Date: 2026-10-14

---

## 1. Summary of Changes Made During Audit & Fix

1. **Ubuntu Package Management Refinement**:
   - Audited true package availability in Ubuntu 24.04 `noble` repositories via `apt-cache`.
   - Identified that `kitty`, `zsh`, `fonts-jetbrains-mono`, `curl`, `fzf`, `zoxide`, `eza`, `bat`, `tmux`, and `zsh-autosuggestions` are official APT packages.
   - Identified that `starship` is not packaged in official Ubuntu apt repos; added instructions for official standalone installer (`curl -sS https://starship.rs/install.sh | sh`).
   - Identified that `fastfetch` is not in universe; added instructions for official PPA (`ppa:zhangsongcui3371/fastfetch`).
   - Documented JetBrainsMono Nerd Font archive installation to guarantee full glyph coverage for Starship.
2. **Safe Relocation and Broken Symlink Handling**:
   - Updated `uninstall.sh` to safely identify and clean broken symlinks pointing to moved repository roots while continuing to guard user-modified files.
   - Added `tests/test-relocation-safety.sh` to verify end-to-end relocation behavior.
3. **Zsh Autosuggestions Search Paths**:
   - Updated `config/zsh/.zshrc` to search system package paths, XDG user data paths (`$XDG_DATA_HOME/zsh/plugins/...`), and `~/.zsh/...`.
4. **Interactive & Tool Tolerance Test Suite**:
   - Added `tests/test-zsh-behavior.sh` to verify non-interactive quiet execution, `ENABLE_FASTFETCH=false` switch handling, and graceful startup under empty/minimal `PATH`.
5. **JSONC and Syntax Validation**:
   - Hardened `scripts/test-config.sh` against inline URLs in JSON schema definitions.
6. **Documentation & User Guides**:
   - Updated `README.md`, `docs/INSTALL.md`, and this checklist.

---

## 2. Test Results & Evidence

All tests were executed against isolated temporary environments (`/tmp/test-...`) without mutating the host.

| Test Case | Status | Evidence / Notes |
| :--- | :---: | :--- |
| **Distro Detection** (`tests/test-distro-detection.sh`) | **PASS** | Evaluated 8 fixtures: Ubuntu, Debian, Pop!_OS, Fedora, Rocky Linux (ID_LIKE), Arch Linux, Manjaro Linux (ID_LIKE), Alpine Linux (unsupported). 8 passed, 0 failed. |
| **Syntax Validation** (`scripts/test-config.sh`) | **PASS** | Validated `bash -n` across all 17 shell scripts; `zsh -n` on `.zshrc`; validated `fastfetch` JSON syntax, `starship` TOML syntax, and `kitty.conf` format. |
| **Dry-Run Zero-Write Guarantee** (`tests/test-config-links.sh`) | **PASS** | `--dry-run` generated 0 disk writes in isolated target home. |
| **Existing File Conflict Detection** (`tests/test-config-links.sh`) | **PASS** | Pre-existing non-symlink file triggered exit code `2` without being altered. |
| **Idempotency & Manifest Tracking** (`tests/test-idempotency.sh`) | **PASS** | Four consecutive installations (minimal x2, full x2) resulted in identical manifest entry counts without duplicate blocks or broken symlinks. |
| **Safe Uninstall with Protected User Files** (`tests/test-uninstall-safety.sh`) | **PASS** | Tracked symlinks were removed; unrelated user files (`notes.txt`, `my_code.py`) and user-modified config replacements were preserved. |
| **Repository Relocation & Broken Links** (`tests/test-relocation-safety.sh`) | **PASS** | Symlinks installed from a cloned path and subsequently broken upon relocation were cleanly uninstalled without errors. |
| **Interactive vs Non-Interactive Zsh** (`tests/test-zsh-behavior.sh`) | **PASS** | Non-interactive execution printed 0 fastfetch banner output; `ENABLE_FASTFETCH=false` switch was honored; started cleanly under stripped `PATH`. |
| **Archive Export & Import** (`export-config.sh` / `import-config.sh`) | **PASS** | Verified archive creation and extraction; verified security scan against private keys (`id_rsa`, `id_ed25519`, `*.key`), tokens, and shell histories. |
| **Host System Mutation** | **VERIFIED CLEAN** | Zero host files modified during testing. No privileged commands executed. |
| **ShellCheck** | **NOT RUN** | `shellcheck` is not installed on the host system. |

---

## 3. Known Limitations

- **Ubuntu Apt Packaging Gaps**: Ubuntu 24.04 repos do not include `starship` or `fastfetch`. Installation requires official standalone scripts or PPAs as documented below.
- **Bat Command Naming**: On Ubuntu/Debian, the `bat` binary is named `batcat`. `config/zsh/.zshrc` automatically aliases `bat='batcat'` and sets `PAGER='batcat'`.
- **Default Shell**: `install.sh` deliberately does not modify `/etc/passwd` or invoke `chsh`; changing the login shell remains an explicit user action.

---

## 4. Ubuntu 24.04 Installation Instructions

To install on Ubuntu 24.04 LTS, run the following steps manually:

### Phase A: Non-Privileged Inspection (Read-Only)
```bash
bash packages/detect-distro.sh
./install.sh --dry-run
./install.sh --profile full --dry-run
```

### Phase B: System Package Installation (Requires sudo)
```bash
# Core minimal packages
sudo apt update && sudo apt install -y kitty zsh fonts-jetbrains-mono curl

# Full profile CLI utilities
sudo apt install -y fzf zoxide eza bat tmux zsh-autosuggestions
```

### Phase C: Additional Tools & Fonts (User-level / Standalone)
```bash
# Install Starship prompt binary
curl -sS https://starship.rs/install.sh | sh

# Install Fastfetch (via official PPA)
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
sudo apt update && sudo apt install -y fastfetch

# Install JetBrainsMono Nerd Font (patched with glyphs)
mkdir -p ~/.local/share/fonts
curl -fLo /tmp/JetBrainsMono.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar -xf /tmp/JetBrainsMono.tar.xz -C ~/.local/share/fonts/ && fc-cache -f ~/.local/share/fonts/ && rm -f /tmp/JetBrainsMono.tar.xz
```

### Phase D: Link OMEN Terminal Dotfiles (Non-Privileged)
```bash
./install.sh --profile full
./scripts/doctor.sh
```

### Phase E: Optional Default Shell Change
```bash
chsh -s $(which zsh)
```

---

## 5. Recovery & Uninstall Instructions

To completely remove all links created by OMEN Terminal:
```bash
# Preview uninstallation
./uninstall.sh --dry-run

# Perform safe uninstallation
./uninstall.sh
```

All managed symlinks recorded in `~/.local/share/omen-terminal/manifest.txt` will be deleted. Any files you modified or replaced with your own custom files will be left intact.

