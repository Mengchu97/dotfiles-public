# Agent Skills

Reusable instruction sets for AI coding agents (OpenCode, Claude Code, OpenAI Codex).

## Skills Overview

| Skill | Description |
|---|---|
| `deep-learning` | PyTorch training loops, model definitions, data pipelines, GPU management, distributed training |
| `signal-processing` | Statistical signal processing, spectral analysis, filter design, array processing, detection/estimation theory |
| `latex-paper` | Academic LaTeX writing, mathematical typesetting, figures/tables, venue-specific formatting (IEEE/ACM/Springer) |

## Directory Structure

```
agent-skills/
├── deep-learning/
│   └── SKILL.md
├── signal-processing/
│   └── SKILL.md
├── latex-paper/
│   └── SKILL.md
├── install_agent_skills.sh
└── README.md
```

## How Skills Work

Skills are **lazy-loaded**. The agent only sees the skill name + description (a few tokens) at all times. The full SKILL.md content is injected into context **only when the agent calls the `skill` tool**.

---

## Configuration

### OpenCode

OpenCode searches these paths for skills (in order):

1. `.opencode/skills/<name>/SKILL.md` (project-local)
2. `~/.config/opencode/skills/<name>/SKILL.md` (global)
3. `.claude/skills/<name>/SKILL.md` (Claude Code compat, project-local)
4. `~/.claude/skills/<name>/SKILL.md` (Claude Code compat, global)
5. `.agents/skills/<name>/SKILL.md` (agent-compatible, project-local)
6. `~/.agents/skills/<name>/SKILL.md` (agent-compatible, global)

**Setup (symlink to global config):**

```bash
mkdir -p ~/.config/opencode/skills

for skill in deep-learning signal-processing latex-paper; do
    ln -sf ~/.dotfiles/agent-skills/$skill ~/.config/opencode/skills/$skill
done
```

Or use the Claude-compatible path (shared with Claude Code):

```bash
mkdir -p ~/.claude/skills

for skill in deep-learning signal-processing latex-paper; do
    ln -sf ~/.dotfiles/agent-skills/$skill ~/.claude/skills/$skill
done
```

**Verify:**
```bash
ls -la ~/.config/opencode/skills/
```

### Claude Code

Claude Code reads from `~/.claude/skills/<name>/SKILL.md`.

**Setup:**
```bash
mkdir -p ~/.claude/skills

for skill in deep-learning signal-processing latex-paper; do
    ln -sf ~/.dotfiles/agent-skills/$skill ~/.claude/skills/$skill
done
```

### OpenAI Codex

Codex reads skills from `~/.agents/skills/` (user-level) or `.agents/skills/` (repo-level).

**Setup (user-level, global):** Covered by the install script.

**Setup (per-repo):**
```bash
mkdir -p .agents/skills

for skill in deep-learning signal-processing latex-paper; do
    ln -s ~/.dotfiles/agent-skills/$skill .agents/skills/$skill
done
```

---

## Adding a New Skill

1. Create directory: `mkdir -p ~/.dotfiles/agent-skills/my-new-skill`
2. Write `SKILL.md` with YAML frontmatter (`name` and `description` required)
3. Re-run `install_agent_skills.sh`

## One-Time Install

```bash
~/.dotfiles/agent-skills/install_agent_skills.sh
```
