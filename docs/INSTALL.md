# Installation Guide for OMEN Terminal

OMEN Terminal provides a lightweight, modular terminal setup with zero lock-in and non-destructive installation.

## Prerequisites

Check your Linux distribution:
```bash
bash packages/detect-distro.sh
```

OMEN supports native package managers on:
- **Ubuntu / Debian** (`apt`)
- **Fedora** (`dnf`)
- **Arch Linux** (`pacman`)

---

## Step 1: Install Native Packages (Manual Step)

OMEN Terminal never runs `sudo` or privileged package commands automatically. You choose whether to install minimal or full packages.

### Ubuntu 24.04 LTS (Noble Numbat)

#### 1. Minimal Profile
Includes: Kitty terminal emulator, Zsh shell, JetBrains Mono font, and curl.
```bash
sudo apt update && sudo apt install -y kitty zsh fonts-jetbrains-mono curl
```
*Prompt (Starship)*:
Starship is not in standard Ubuntu apt repositories. Install the official standalone binary into `/usr/local/bin` (or `~/.local/bin`):
```bash
curl -sS https://starship.rs/install.sh | sh
```

#### 2. Full Profile
Adds modern CLI tools: `fzf`, `zoxide`, `eza`, `bat`, `tmux`, and native `zsh-autosuggestions`.
```bash
sudo apt update && sudo apt install -y kitty zsh fonts-jetbrains-mono curl fzf zoxide eza bat tmux zsh-autosuggestions
```
*Fastfetch*:
Fastfetch is not included in the standard Ubuntu 24.04 repos. You can install it via official PPA or direct release deb:
```bash
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
sudo apt update && sudo apt install -y fastfetch
```

#### 3. JetBrainsMono Nerd Font (Full Glyph Support)
While `fonts-jetbrains-mono` provides the base font family, installing the patched **JetBrainsMono Nerd Font** ensures icons and status glyphs render properly:
```bash
mkdir -p ~/.local/share/fonts
curl -fLo /tmp/JetBrainsMono.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar -xf /tmp/JetBrainsMono.tar.xz -C ~/.local/share/fonts/
fc-cache -f ~/.local/share/fonts/
rm -f /tmp/JetBrainsMono.tar.xz
```

---

### Fedora

#### Minimal Profile
```bash
sudo dnf install -y kitty zsh starship jetbrains-mono-fonts-all curl
```

#### Full Profile
```bash
sudo dnf install -y kitty zsh starship jetbrains-mono-fonts-all curl fzf zoxide eza bat fastfetch tmux
```

---

### Arch Linux

#### Minimal Profile
```bash
sudo pacman -S --needed kitty zsh starship ttf-jetbrains-mono-nerd curl
```

#### Full Profile
```bash
sudo pacman -S --needed kitty zsh starship ttf-jetbrains-mono-nerd curl fzf zoxide eza bat fastfetch tmux
```

---

## Step 2: Install Configurations

### 1. Dry Run (Preview Only)
Preview the actions without writing any files or links:
```bash
./install.sh --dry-run
# or for full profile:
./install.sh --profile full --dry-run
```

### 2. Apply Symlinks
Link configuration files into your `$HOME`:
```bash
# Minimal profile (default)
./install.sh

# Full profile
./install.sh --profile full
```

The installer:
- Never overwrites existing user files without warning.
- Preserves your existing shell configuration and files.
- Records all created links in `~/.local/share/omen-terminal/manifest.txt`.

---

## Step 3: Run Doctor / Diagnostics

Verify your environment and check for missing optional tools:
```bash
./scripts/doctor.sh
```

---

## Setting Default Shell (Optional)

OMEN Terminal does **NOT** automatically change your login shell. If you wish to make Zsh your default shell:
```bash
chsh -s $(which zsh)
```
Or simply start Kitty, which launches your preferred shell.

---

## Uninstallation

To safely remove OMEN Terminal configurations:
```bash
./uninstall.sh --dry-run   # Preview removals
./uninstall.sh             # Safely remove tracked links
```
Uninstallation only deletes symlinks recorded in the manifest. It never deletes user data or uninstalls your packages.
