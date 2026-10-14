# OMEN Terminal — Build Plan

## Goal
Build a portable, reproducible Linux terminal environment with low complexity and safe installation. Implement files in this repository only; do not install software or modify the host until explicitly approved.

## Stack
- Emulator: Kitty
- Shell: Zsh (do not change the user's default shell automatically)
- Prompt: Starship
- Theme: Catppuccin Mocha
- Font: JetBrainsMono Nerd Font
- Tools: fzf, zoxide, eza, bat, Fastfetch, tmux
- Extras: Zsh autosuggestions, enhanced completions, Git-aware prompt, SSH host aliases
- Target distros: Ubuntu/Debian, Fedora, Arch Linux

## Required behavior
1. Keep emulator, shell, prompt, tools, package adapters, and portability scripts independent.
2. Use native package managers; detect distro from `/etc/os-release`; report unsupported systems clearly.
3. Provide `minimal` and `full` installation profiles. Minimal = Kitty + Zsh + Starship + theme/font. Full adds all listed tools and integrations.
4. Fastfetch runs on interactive shell startup by default, with a simple config switch to disable it. Never run in noninteractive shells.
5. Do not auto-start tmux. Document manual session use.
6. Keep SSH support limited to documented `~/.ssh/config` aliases/templates. Never copy, generate, export, or commit private keys, tokens, passwords, or real credentials.
7. Store project-owned configs in the repo and link them transparently. Avoid machine-specific absolute paths.
8. Support Git-based dotfiles and configuration archive export/import.
9. Keep shell startup fast and tolerate missing optional tools.
10. Do not use Oh My Zsh or another large shell framework.

## Repository layout
Create:
- `README.md`
- `install.sh`
- `uninstall.sh`
- `export-config.sh`
- `import-config.sh`
- `packages/detect-distro.sh`
- `packages/common.sh`
- `packages/ubuntu.sh`
- `packages/fedora.sh`
- `packages/arch.sh`
- `config/kitty/kitty.conf`
- `config/zsh/.zshrc`
- `config/starship/starship.toml`
- `config/fastfetch/config.jsonc`
- `config/tmux/tmux.conf`
- `scripts/doctor.sh`
- `scripts/update.sh`
- `scripts/test-config.sh`
- `tests/test-distro-detection.sh`
- `tests/test-idempotency.sh`
- `tests/test-config-links.sh`
- `tests/test-uninstall-safety.sh`
- `docs/INSTALL.md`
- `docs/PORTABILITY.md`
- `docs/SECURITY.md`
- `docs/TROUBLESHOOTING.md`

## Safety rules
- Never run privileged commands automatically. Show the planned commands and ask the user to execute/approve them.
- Never change the default shell automatically.
- Never silently overwrite existing configs. Detect conflicts and explain options.
- Do not delete existing files as part of installation.
- Track every created symlink/file in a project-owned manifest.
- Uninstall only resources recorded as owned by this project; preserve user data and unrelated apps/packages.
- If a managed file was changed after installation, warn and ask before removing it.
- Avoid unsafe `rm -rf` patterns; validate paths and symlink targets.
- Installer must be idempotent and include a dry-run mode.
- No system-wide config changes by default.

## Implementation sequence
1. Inspect the workspace and report any conflicting files.
2. Create the repository and all required configs/scripts/docs.
3. Implement distro detection and package adapters.
4. Implement dry-run installer with minimal/full profiles and conflict handling.
5. Implement managed config linking and ownership manifest.
6. Implement safe uninstall and config export/import.
7. Implement doctor/update/test scripts.
8. Add automated tests using a temporary HOME; do not touch the real user's config during tests.
9. Run syntax/static checks and tests; fix failures.
10. Summarize results and list installation commands, but do not run installation.

## Acceptance tests
- Detect Ubuntu/Debian, Fedora, Arch correctly using test fixtures.
- Unsupported distro exits safely without changes.
- Dry-run performs no writes and invokes no package manager or sudo.
- Running installer twice creates no duplicate blocks or broken links.
- Existing conflicting configs are preserved unless explicitly approved.
- Manifest lists only resources owned by this project.
- Uninstall preserves unrelated files, user data, packages and modified configs unless confirmed.
- Zsh startup works if optional tools are absent.
- Fastfetch runs only in interactive shells and can be disabled.
- Starship displays directory, Git branch/status, command duration and exit status.
- Kitty config uses Catppuccin Mocha and a Nerd Font fallback strategy.
- Export/import excludes secrets and machine-specific paths.
- tmux sessions can be created, detached and reattached; shell works without tmux.
- SSH templates contain placeholders only.
- Shell scripts pass `bash -n`; run ShellCheck if installed.
- All tests run in a temporary HOME and do not mutate the host.
- Report each test as PASS, FAIL, or NOT RUN with evidence. Never claim unexecuted tests passed.

## Constraints
- Optimize for simplicity and low maintenance, not feature count.
- Prefer distro packages; document exceptions when a package is unavailable or too old.
- Avoid unnecessary dependencies and complex frameworks.
- Use clear comments, concise docs, and portable shell practices.
- Keep configuration portable across distro changes; package installation itself remains distro-specific.

## Final output from the agent
1. Repository tree.
2. Brief design decisions.
3. Test results with evidence.
4. Known limitations.
5. Exact commands for the user to review and run later.
6. Stop before installing software or modifying the host.
