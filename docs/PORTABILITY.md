# Portability & Migration Guide

OMEN Terminal is designed to be easily moved between workstations, home labs, and remote Linux servers without lock-in or state pollution.

## Principles of Portability

1. **No Absolute Paths**: All configurations use relative paths or portable standard environment variables (`$HOME`, `$XDG_CONFIG_HOME`).
2. **Framework Independence**: No Oh My Zsh or bulky plugin managers. The shell boots in milliseconds and tolerates missing tools.
3. **Graceful Degradation**: If an optional utility (such as `eza`, `bat`, `fzf`, `zoxide`, or `fastfetch`) is not installed on a remote host, standard fallback aliases are used automatically.

---

## Moving Configurations Between Machines

### Method A: Git-Based Dotfiles (Recommended)

1. Clone this repository on your target host:
   ```bash
   git clone <your-repo-url> ~/dotfiles/omen-terminal
   cd ~/dotfiles/omen-terminal
   ```
2. Run dry-run to preview:
   ```bash
   ./install.sh --dry-run
   ```
3. Apply links:
   ```bash
   ./install.sh --profile full
   ```
4. To pull future updates:
   ```bash
   ./scripts/update.sh
   ```

### Method B: Offline Archive Export & Import

When target servers lack direct Git access:

1. **Export on source machine**:
   ```bash
   ./export-config.sh omen-config.tar.gz
   ```
2. **Copy the archive to destination host**:
   ```bash
   scp omen-config.tar.gz user@remote-server:~/
   ```
3. **Import on destination host**:
   ```bash
   ./import-config.sh omen-config.tar.gz
   ./install.sh --profile full
   ```

---

## Machine-Specific Customizations

To add machine-specific environment variables, aliases, or overrides without modifying git-tracked files:

Create `~/.zshrc.local` in your home directory:
```bash
# ~/.zshrc.local
export WORK_PROJECT_DIR="$HOME/work"
alias deploy="ssh prod-cluster"

# Disable fastfetch on this particular machine
export ENABLE_FASTFETCH=false
```
OMEN Terminal sources `~/.zshrc.local` at the end of `.zshrc` if present, leaving it untouched by updates or uninstalls.

