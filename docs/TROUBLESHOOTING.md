# Troubleshooting & FAQ

## 1. Fastfetch on Startup

### How do I disable Fastfetch on shell launch?
Fastfetch is enabled by default for interactive shells. To disable it without modifying git tracked files:
```bash
echo "export ENABLE_FASTFETCH=false" >> ~/.zshrc.local
```

### Fastfetch is not displaying?
Fastfetch only runs if:
1. The shell is interactive (`[[ -o interactive ]]`).
2. The `fastfetch` binary is installed on your `PATH`.
3. `ENABLE_FASTFETCH` is not set to `false`.

---

## 2. Tmux Usage

### Does Tmux start automatically?
**No.** OMEN Terminal strictly does not auto-start tmux to prevent nested sessions, SSH agent breakage, or unwanted overhead.

### Basic Tmux Workflow:
- Start a new session:
  ```bash
  tmux new -s work
  ```
- Detach from session: Press `Ctrl-a`, then `d`.
- List active sessions:
  ```bash
  tmux ls
  ```
- Reattach to session:
  ```bash
  tmux attach -t work
  ```
- Split panes:
  - Vertical split: `Ctrl-a` then `|`
  - Horizontal split: `Ctrl-a` then `-`
  - Navigate panes: `Ctrl-a` followed by `h`, `j`, `k`, or `l`.

---

## 3. Font and Icons Issues

### Symbols or icons appear as missing boxes or question marks
1. Ensure a Nerd Font is installed, preferably `JetBrainsMono Nerd Font`.
2. On Ubuntu / Debian:
   ```bash
   sudo apt install fonts-jetbrains-mono
   ```
   Or download the latest archive from [Nerd Fonts releases](https://www.nerdfonts.com/).
3. On Arch Linux:
   ```bash
   sudo pacman -S ttf-jetbrains-mono-nerd
   ```
4. Verify Kitty config fallback:
   Kitty's configuration in `~/.config/kitty/kitty.conf` maps symbol ranges (`U+E0A0-U+E0A3`, etc.) to `PowerlineSymbols` and `Symbols Nerd Font`.

---

## 4. Resolving Conflicts During Installation

If `./install.sh` reports a conflict:
```
[CONFLICT] Regular file/directory already exists: /home/user/.zshrc
```
This is a safety feature to prevent overwriting your existing work.
- To resolve:
  ```bash
  mv ~/.zshrc ~/.zshrc.backup
  ./install.sh
  ```
- If the conflict is an outdated symlink, use `--force`:
  ```bash
  ./install.sh --force
  ```

---

## 5. Doctor Diagnostics

Run the doctor script any time to check tool status:
```bash
./scripts/doctor.sh
```

