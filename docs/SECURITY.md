# Security Guide & Best Practices

OMEN Terminal follows strict security boundaries to protect your system and private credentials.

## Core Security Rules

1. **No Automatic Privileges**:
   The installer and scripts never invoke `sudo` or execute privileged package manager operations automatically. All package installation commands are output for human review and execution.

2. **No Secret Storage**:
   This repository **never** commits, generates, or exports:
   - Private SSH keys (`id_rsa`, `id_ed25519`, `*.key`, `*.pem`)
   - API tokens or secrets
   - Shell history files (`.zsh_history`)
   - Passwords or credential vaults

3. **Non-Destructive Symlink Management**:
   The installer validates file types before linking:
   - Existing regular user files are **never** deleted or silently replaced.
   - Any conflict halts the installer with exit code 2 and prompts the user for action.

4. **Safe Uninstallation**:
   - The uninstaller inspects `~/.local/share/omen-terminal/manifest.txt`.
   - Before removing any entry, it validates that the target is a symlink pointing into the OMEN Terminal repository.
   - If a tracked file has been replaced with a real file, it is preserved.

---

## SSH Host Configuration Template

OMEN Terminal does not manage your private SSH keys. Instead, use the following template to structure `~/.ssh/config` safely using host aliases.

```ssh-config
# ~/.ssh/config - Example Alias Template
# Ensure permissions: chmod 600 ~/.ssh/config

# Global defaults
Host *
    AddKeysToAgent yes
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Work / Production Jump Host (Placeholder)
Host jumphost
    HostName jump.example.com
    User your_username
    Port 22
    IdentityFile ~/.ssh/id_ed25519

# Target Server routed through Jump Host
Host target-server
    HostName 10.0.1.50
    User your_username
    ProxyJump jumphost
    IdentityFile ~/.ssh/id_ed25519

# Personal GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
```

> **Warning**: Never commit your actual `~/.ssh/config` or SSH private keys to public Git repositories!

