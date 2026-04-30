#!/usr/bin/env bash
# ================================================================= #
#           Agent Skills Installation Script                         #
# ================================================================= #
# Creates symlinks from ~/.dotfiles/agent-skills/ to the appropriate
# locations for OpenCode, Claude Code, and other agents.
#
# Usage: ./install_agent_skills.sh

set -e

DOTFILES_DIR="$HOME/.dotfiles"
SKILLS_DIR="$DOTFILES_DIR/agent-skills"
SKILLS=("deep-learning" "signal-processing" "latex-paper")

echo "🔧 Installing Agent Skills..."

# --- OpenCode (global) ---
OC_SKILLS="$HOME/.config/opencode/skills"
mkdir -p "$OC_SKILLS"
echo ""
echo "📦 OpenCode (~/.config/opencode/skills/):"
for skill in "${SKILLS[@]}"; do
    target="$OC_SKILLS/$skill"
    if [ -L "$target" ]; then
        current=$(readlink "$target")
        if [ "$current" = "$SKILLS_DIR/$skill" ]; then
            echo "   ⏭️  $skill already symlinked"
            continue
        fi
    fi
    ln -sf "$SKILLS_DIR/$skill" "$target"
    echo "   ✅ $skill -> $SKILLS_DIR/$skill"
done

# --- Claude Code (global) ---
CC_SKILLS="$HOME/.claude/skills"
mkdir -p "$CC_SKILLS"
echo ""
echo "📦 Claude Code (~/.claude/skills/):"
for skill in "${SKILLS[@]}"; do
    target="$CC_SKILLS/$skill"
    if [ -L "$target" ]; then
        current=$(readlink "$target")
        if [ "$current" = "$SKILLS_DIR/$skill" ]; then
            echo "   ⏭️  $skill already symlinked"
            continue
        fi
    fi
    ln -sf "$SKILLS_DIR/$skill" "$target"
    echo "   ✅ $skill -> $SKILLS_DIR/$skill"
done

# --- .agents (universal: OpenAI Codex + OpenCode agent-compatible) ---
AG_SKILLS="$HOME/.agents/skills"
mkdir -p "$AG_SKILLS"
echo ""
echo "📦 Codex + Agent-compatible (~/.agents/skills/):"
for skill in "${SKILLS[@]}"; do
    target="$AG_SKILLS/$skill"
    if [ -L "$target" ]; then
        current=$(readlink "$target")
        if [ "$current" = "$SKILLS_DIR/$skill" ]; then
            echo "   ⏭️  $skill already symlinked"
            continue
        fi
    fi
    ln -sf "$SKILLS_DIR/$skill" "$target"
    echo "   ✅ $skill -> $SKILLS_DIR/$skill"
done

echo ""
echo "🎉 Agent Skills installed!"
