# Dotfiles

A cross-platform, modular dotfiles framework for **macOS / Linux (Bash)** and **Windows (PowerShell)**.

One command sets up a new machine with your shell, Git, Vim, Tmux, prompt theme, and more.

## What You Get

- **Bash / PowerShell** — aliases, functions, proxy management, project scaffolding
- **Git** — shared config with useful aliases (`git bn`, `git wn`, `git pushall`, etc.)
- **Vim** — vim-plug, sensible keymaps, UI settings
- **Tmux** — [Oh My Tmux!](https://github.com/gpakosz/.tmux) integration with custom config
- **Oh My Posh** — themed prompt with Git status, language versions, execution time (shared across all platforms)
- **OpenCode** — AI coding assistant config with multi-model agent setup
- **IEEE LaTeX template** — ready-to-use IEEE Transactions paper scaffold

**Design principle:** No symlinks (except one for tmux). All configs are loaded via `source` / `include` directives — your local files stay in place.

## Quick Start

### 1. Clone & Replace Placeholders

```bash
git clone https://github.com/Mengchu97/dotfiles-public.git ~/.dotfiles
cd ~/.dotfiles
```

Several files contain `INPUT_` placeholders that **must be replaced** before use:

| Placeholder | File | What to put |
|---|---|---|
| `INPUT_YOUR_NAME` | `git/gitconfig` | Your display name for Git commits |
| `INPUT_YOUR_EMAIL` | `git/gitconfig` | Your email for Git commits |
| `INPUT_YOUR_BIB_REPO_URL` | `git/gitconfig`, `bash/bash_aliases` | Your bibliography repo URL (e.g. `https://github.com/user/bibs.git`) |
| `INPUT_YOUR_HPC_SERVER` | `bash/bash_aliases` | Your HPC cluster hostname (for `pydebug`) — remove if not applicable |

One-liner to replace all:
```bash
cd ~/.dotfiles
sed -i 's/INPUT_YOUR_NAME/Your Name/g' git/gitconfig
sed -i 's/INPUT_YOUR_EMAIL/your@email.com/g' git/gitconfig
sed -i 's|INPUT_YOUR_BIB_REPO_URL|https://github.com/user/bibs.git|g' git/gitconfig bash/bash_aliases
sed -i 's/INPUT_YOUR_HPC_SERVER/login.example.com/g' bash/bash_aliases
```

### 2. Run the Installer

**macOS / Linux:**
```bash
bash ~/.dotfiles/install.sh

# Optional: install Nerd Font for Oh My Posh icons
bash ~/.dotfiles/install.sh --with-font

# Optional: install OpenCode config
bash ~/.dotfiles/opencode/install-opencode.sh

# Optional: install AI agent skills
bash ~/.dotfiles/agent-skills/install_agent_skills.sh
```

**Windows (PowerShell):**
```powershell
. "$HOME\.dotfiles\install.ps1"

# Optional: install Nerd Font
. "$HOME\.dotfiles\install.ps1" -WithFont

# Optional: install OpenCode config
. "$HOME\.dotfiles\opencode\install-opencode.ps1"
```

### 3. Restart Your Terminal

That's it. All configs are live.

## How It Works

Each component lives in its own folder with its own install scripts. The top-level `install.sh` / `install.ps1` orchestrates them all.

All configs use the same loading pattern — your local files get a marker-delimited block that pulls in the dotfiles version:

```
# >>> dotfiles >>>
source / path / include directive pointing to ~/.dotfiles/...
# <<< dotfiles <<<
```

This is idempotent (safe to re-run) and reversible (`--restore` removes the block and restores your originals).

## What's Inside

| Directory | Purpose |
|---|---|
| `bash/` | Bash config: bashrc, bash_profile, bash_aliases |
| `powershell/` | PowerShell profile for Windows |
| `git/` | Git config, gitignore templates (blacklist & whitelist) |
| `vim/` | Vim config: vim-plug, keymaps, UI settings |
| `tmux/` | Tmux config via Oh My Tmux! |
| `oh-my-posh/` | Oh My Posh prompt theme (shared across platforms) |
| `opencode/` | OpenCode + Oh-My-OpenAgent config |
| `agent-skills/` | AI agent skills (deep-learning, signal-processing, latex-paper) |
| `IEEE_Trans_Temp/` | LaTeX template for IEEE Transactions papers |

## Daily Commands

| Command | Where | Description |
|---|---|---|
| `dotpush [msg]` | Bash/PS | Commit & push dotfiles |
| `dotpull` | Bash/PS | Pull dotfiles & reload |
| `proxy_on` / `proxy_off` | Bash/PS | Toggle proxy |
| `uvnew` | Bash | Scaffold new Python project with uv |
| `upy [args]` | Bash | Run Python via uv (auto-detects module vs script) |
| `activate [name]` | Bash | Activate virtual env (auto-finds .venv/venv/envs) |
| `newieee <dir>` | Bash | Scaffold IEEE paper from template |
| `reload` | Bash/PS | Reload shell config |
| `extract <file>` | Bash | Universal archive extractor |
| `git bn` / `git wn` | Git | Init repo with blacklist/whitelist gitignore |
| `git addbib` | Git | Add bibliography submodule |
| `git pushall` / `git pullall` | Git | Batch operations across sub-repos |

## Restore Previous Config

If the installer modified existing files, backups are stored at `~/.dotfiles_backup_YYYYMMDD_HHMMSS/`.

```bash
# macOS/Linux
bash ~/.dotfiles/install.sh --restore

# Windows
. "$HOME\.dotfiles\install.ps1" -Restore
```

## Notes

- **Bash only.** No zsh setup.
- **No symlinks.** Everything uses `source` / `include` / copy-on-diff. (Exception: tmux uses one symlink for `~/.tmux.conf` as required by oh-my-tmux.)
- **HPC aliases** (`bsub`, `module load`, etc.) in `bash_aliases` are institution-specific. They are silently ignored on machines without these commands.
- **`credential.helper = store`** in gitconfig. On Windows, you may want to override with `[credential] helper = manager`.
