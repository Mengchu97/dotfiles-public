#!/usr/bin/env bash
# ================================================================= #
#           Vim Configuration Installer (Unix)                       #
# ================================================================= #
# Creates ~/.vimrc that sources the dotfiles vimrc.
#
# Usage: bash ~/.dotfiles/vim/install.sh [--restore]

set -e

DOTFILES_DIR="$HOME/.dotfiles"
VIM_DIR="$DOTFILES_DIR/vim"
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
    echo "Restoring vim config from: $latest_backup"
    [ -f "$latest_backup/.vimrc" ] && cp "$latest_backup/.vimrc" "$HOME/.vimrc" && echo "  Restored .vimrc"
    echo "Done."
    exit 0
fi

echo ""
echo "Vim Configuration Setup"
echo "======================="

VIM_TARGET="$HOME/.vimrc"
VIM_MARKER="\" >>> dotfiles >>>"

if [ -f "$VIM_TARGET" ]; then
    if grep -q "$VIM_MARKER" "$VIM_TARGET"; then
        echo "  Already configured, skipping."
    else
        mkdir -p "$BACKUP_DIR"
        cp "$VIM_TARGET" "$BACKUP_DIR/" 2>/dev/null || true
        echo "  Backed up original .vimrc to $BACKUP_DIR"
        {
            echo ""
            echo "$VIM_MARKER"
            echo "source $VIM_DIR/vimrc"
            echo "\" <<< dotfiles <<<"
        } >> "$VIM_TARGET"
        echo "  Configured .vimrc to source $VIM_DIR/vimrc"
    fi
else
    {
        echo "$VIM_MARKER"
        echo "source $VIM_DIR/vimrc"
        echo "\" <<< dotfiles <<<"
    } > "$VIM_TARGET"
    echo "  Created .vimrc sourcing $VIM_DIR/vimrc"
fi

echo ""
echo "Done!"
