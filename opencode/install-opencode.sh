#!/usr/bin/env bash
# ================================================================= #
#       OpenCode + Oh-My-OpenAgent / Oh-My-OpenCode-Slim Setup      #
# ================================================================= #
# Run this on a new machine to install OpenCode and restore your
# opencode/omo/oms config tracked in your dotfiles repo.
#
# Usage: ./install-opencode.sh
#
# Uses copy (not symlinks) for Windows compatibility.

set -e

DOTFILES_DIR="$HOME/.dotfiles"
OPENCODE_DIR="$DOTFILES_DIR/opencode"
CONFIG_DIR="$HOME/.config/opencode"

echo "🚀 OpenCode + Oh-My-OpenAgent / Oh-My-OpenCode-Slim Setup"
echo "=========================================================="

if command -v opencode &>/dev/null; then
    echo "✅ OpenCode $(opencode --version) already installed"
else
    echo "➡️ OpenCode not found. Please install it first:"
    echo "   https://opencode.ai/docs"
    echo ""
    read -p "Press Enter after installing OpenCode, or Ctrl+C to abort..."
    if ! command -v opencode &>/dev/null; then
        echo "❌ OpenCode still not found. Exiting."
        exit 1
    fi
fi

mkdir -p "$CONFIG_DIR"

sync_config() {
    local source="$1"
    local target="$2"
    local name="$3"

    if [ -f "$source" ]; then
        cmp -s "$source" "$target" 2>/dev/null || cp "$source" "$target"
        echo "   ✅ $name synced"
    else
        echo "   ⚠️  $name not found at $source"
    fi
}

echo ""
echo "➡️ Syncing config files..."
sync_config "$OPENCODE_DIR/opencode.json" "$CONFIG_DIR/opencode.json" "opencode.json"
sync_config "$OPENCODE_DIR/oh-my-openagent.json" "$CONFIG_DIR/oh-my-openagent.json" "oh-my-openagent.json"
sync_config "$OPENCODE_DIR/oh-my-opencode-slim.json" "$CONFIG_DIR/oh-my-opencode-slim.json" "oh-my-opencode-slim.json"

echo ""
echo "➡️ Installing oh-my-opencode-slim plugin..."
if command -v bunx &>/dev/null || command -v bun &>/dev/null; then
    bunx oh-my-opencode-slim@latest install --no-config || echo "   ⚠️  Plugin install failed (you may need to run manually)"
else
    echo "   ⚠️  bun not found. Install bun first: curl -fsSL https://bun.sh/install | bash"
    echo "   Then run: bunx oh-my-opencode-slim@latest install"
fi

echo ""
echo "🎉 Done! Run 'opencode' to start."
echo "   Profile switchers:"
echo "     omo-glm / omo-gpt / omo-manual  — switch oh-my-openagent profile"
echo "     oms-glm / oms-gpt / oms-manual  — switch oh-my-opencode-slim profile"
echo "     omo-status / oms-status          — show active profile"
