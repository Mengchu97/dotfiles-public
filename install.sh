#!/usr/bin/env bash
# ================================================================= #
#                 Dotfiles Installation Orchestrator                  #
# ================================================================= #
# Run this script on a new macOS/Linux machine to initialize your
# environment. Calls component-specific installers in each subfolder.
#
# Usage: ./install.sh [--restore] [--with-font]
#
# Options:
#   --restore     Restore backed up configurations instead of installing
#   --with-font   Install MesloLGM Nerd Font (for Oh My Posh icons)

set -euo pipefail

FAILED_STEPS=()

run_step() {
    local name="$1"
    shift
    echo ""
    echo "➡️ Installing ${name}..."
    if "$@"; then
        echo "   ✅ ${name} done"
    else
        echo "   ⚠️  ${name} failed (continuing...)"
        FAILED_STEPS+=("$name")
    fi
}

DOTFILES_DIR="$HOME/.dotfiles"
RESTORE_MODE=false
WITH_FONT=false

for arg in "$@"; do
    case "$arg" in
        --restore) RESTORE_MODE=true ;;
        --with-font) WITH_FONT=true ;;
    esac
done

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: Directory $DOTFILES_DIR does not exist."
    echo "Please clone the repo to ~/.dotfiles first."
    exit 1
fi

# --- Restore mode ---
if [ "$RESTORE_MODE" = true ]; then
    latest_backup=$(ls -dt "$HOME"/.dotfiles_backup_* 2>/dev/null | head -1)
    if [ -z "$latest_backup" ] || [ ! -d "$latest_backup" ]; then
        echo "Error: No backup found to restore from."
        exit 1
    fi

    echo "Restoring from: $latest_backup"
    # Let each component restore from the same backup
    run_step "Bash (restore)" bash "$DOTFILES_DIR/bash/install.sh" --restore
    run_step "Git (restore)" bash "$DOTFILES_DIR/git/install.sh" --restore
    run_step "Vim (restore)" bash "$DOTFILES_DIR/vim/install.sh" --restore
    run_step "Tmux (restore)" bash "$DOTFILES_DIR/tmux/install.sh" --restore
    echo "Restore Complete!"
    exit 0
fi

echo ""
echo "Dotfiles Setup (macOS/Linux)"
echo "============================"

# 1. Oh My Posh
if [ "$WITH_FONT" = true ]; then
    run_step "Oh My Posh (with font)" bash "$DOTFILES_DIR/oh-my-posh/install.sh" --with-font
else
    run_step "Oh My Posh" bash "$DOTFILES_DIR/oh-my-posh/install.sh"
fi

# 2. Bash
run_step "Bash" bash "$DOTFILES_DIR/bash/install.sh"

# 3. Git
run_step "Git" bash "$DOTFILES_DIR/git/install.sh"

# 4. Vim
run_step "Vim" bash "$DOTFILES_DIR/vim/install.sh"

# 5. Tmux (oh-my-tmux)
run_step "Tmux" bash "$DOTFILES_DIR/tmux/install.sh"

# 6. OpenCode + Oh-My-OpenAgent / Oh-My-OpenCode-Slim
run_step "OpenCode" bash "$DOTFILES_DIR/opencode/install-opencode.sh"

echo ""
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
    echo "⚠️  Setup completed with ${#FAILED_STEPS[@]} failure(s):"
    for step in "${FAILED_STEPS[@]}"; do
        echo "   ❌ $step"
    done
    echo ""
else
    echo "Setup Complete!"
fi
echo "Please restart your terminal or run 'source ~/.bash_profile' to take effect."
echo ""
echo "To restore previous configurations, run: ./install.sh --restore"
