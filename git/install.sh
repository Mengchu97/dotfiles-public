#!/usr/bin/env bash
# ================================================================= #
#           Git Configuration Installer (Unix)                       #
# ================================================================= #
# Sets up [include] directive in ~/.gitconfig to load dotfiles gitconfig.
#
# Usage: bash ~/.dotfiles/git/install.sh [--restore]

set -e

DOTFILES_DIR="$HOME/.dotfiles"
GIT_DIR="$DOTFILES_DIR/git"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
RESTORE_MODE=false

for arg in "$@"; do
    case "$arg" in
        --restore) RESTORE_MODE=true ;;
    esac
done

if [ "$RESTORE_MODE" = true ]; then
    latest_backup=$(ls -dt "$HOME"/.dotfiles_backup_* 2>/dev/null | head -1)
    if [ -z "$latest_backup" ] || [ ! -d "$latest_backup" ]; then
        echo "Error: No backup found."
        exit 1
    fi
    echo "Restoring git config from: $latest_backup"
    [ -f "$latest_backup/.gitconfig" ] && cp "$latest_backup/.gitconfig" "$HOME/.gitconfig" && echo "  Restored .gitconfig"
    echo "Done."
    exit 0
fi

echo ""
echo "Git Configuration Setup"
echo "======================="

GIT_TARGET="$HOME/.gitconfig"
GIT_MARKER="# >>> dotfiles >>>"

if [ -f "$GIT_TARGET" ]; then
    if grep -q "$GIT_MARKER" "$GIT_TARGET"; then
        echo "  Already configured, skipping."
    else
        mkdir -p "$BACKUP_DIR"
        cp "$GIT_TARGET" "$BACKUP_DIR/" 2>/dev/null || true
        echo "  Backed up original .gitconfig to $BACKUP_DIR"
        {
            echo ""
            echo "$GIT_MARKER"
            echo "[include]"
            echo "    path = $GIT_DIR/gitconfig"
            echo "# <<< dotfiles <<<"
        } >> "$GIT_TARGET"
        echo "  Configured git to include $GIT_DIR/gitconfig"
    fi
else
    {
        echo "$GIT_MARKER"
        echo "[include]"
        echo "    path = $GIT_DIR/gitconfig"
        echo "# <<< dotfiles <<<"
    } > "$GIT_TARGET"
    echo "  Created .gitconfig with include for $GIT_DIR/gitconfig"
fi

echo ""
echo "Done!"
