#!/usr/bin/env bash
# ================================================================= #
#           Oh My Tmux Installer (Unix)                              #
# ================================================================= #
# Installs oh-my-tmux (gpakosz/.tmux) and symlinks/copies the
# dotfiles tmux configuration. Works on Linux and macOS.
#
# How it works:
#   1. Clones gpakosz/.tmux to ~/.tmux (the oh-my-tmux repo)
#   2. Symlinks ~/.tmux.conf → ~/.tmux/.tmux.conf (required by oh-my-tmux)
#   3. Copies ~/.dotfiles/tmux/tmux.conf.local to ~/.tmux.conf.local
#      (the user-customizable file that oh-my-tmux reads)
#
# Usage: bash ~/.dotfiles/tmux/install.sh [--restore]
#
# Requirements:
#   - tmux >= 2.6
#   - git
#   - awk, perl, grep, sed

set -e

DOTFILES_DIR="$HOME/.dotfiles"
TMUX_DIR="$DOTFILES_DIR/tmux"
OH_MY_TMUX_DIR="$HOME/.tmux"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
RESTORE_MODE=false

for arg in "$@"; do
    case "$arg" in
        --restore) RESTORE_MODE=true ;;
    esac
done

# --- Restore mode ---
if [ "$RESTORE_MODE" = true ]; then
    latest_backup=$(ls -dt "$HOME"/.dotfiles_backup_* 2>/dev/null | head -1)
    if [ -z "$latest_backup" ] || [ ! -d "$latest_backup" ]; then
        echo "Error: No backup found."
        exit 1
    fi

    echo "Restoring tmux configs from: $latest_backup"
    # Restore .tmux.conf.local
    if [ -f "$latest_backup/.tmux.conf.local" ]; then
        cp "$latest_backup/.tmux.conf.local" "$HOME/.tmux.conf.local"
        echo "  Restored .tmux.conf.local"
    fi
    # Restore .tmux.conf symlink
    if [ -L "$HOME/.tmux.conf" ] || [ -f "$latest_backup/.tmux.conf" ]; then
        if [ -f "$latest_backup/.tmux.conf" ]; then
            cp "$latest_backup/.tmux.conf" "$HOME/.tmux.conf"
            echo "  Restored .tmux.conf"
        fi
    fi
    echo "Done."
    exit 0
fi

echo ""
echo "Oh My Tmux Setup"
echo "================"

# --- Check prerequisites ---
if ! command -v tmux &>/dev/null; then
    echo "  tmux not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &>/dev/null; then
            brew install tmux
        else
            echo "  Homebrew not found. Install tmux manually or install brew first."
            exit 1
        fi
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y -qq tmux
    elif command -v yum &>/dev/null; then
        sudo yum install -y tmux
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y tmux
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm tmux
    else
        echo "  Cannot auto-install tmux. Please install it manually (>= 2.6)."
        exit 1
    fi
fi

TMUX_VERSION=$(tmux -V 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
echo "  tmux version: ${TMUX_VERSION:-unknown}"

if ! command -v git &>/dev/null; then
    echo "  Error: git is required but not found."
    exit 1
fi

# --- Clone oh-my-tmux ---
if [ -d "$OH_MY_TMUX_DIR" ]; then
    echo "  Oh my tmux! already cloned at $OH_MY_TMUX_DIR"
    # Pull latest updates
    echo "  Updating oh-my-tmux..."
    (cd "$OH_MY_TMUX_DIR" && git pull --ff-only 2>/dev/null) || {
        echo "  Warning: Could not update oh-my-tmux (may have local changes). Continuing..."
    }
else
    echo "  Cloning oh-my-tmux to $OH_MY_TMUX_DIR..."
    git clone --single-branch https://github.com/gpakosz/.tmux.git "$OH_MY_TMUX_DIR"
fi

# --- Symlink .tmux.conf ---
if [ -L "$HOME/.tmux.conf" ]; then
    CURRENT_TARGET=$(readlink -f "$HOME/.tmux.conf" 2>/dev/null || readlink "$HOME/.tmux.conf")
    if [ "$CURRENT_TARGET" = "$OH_MY_TMUX_DIR/.tmux.conf" ]; then
        echo "  ~/.tmux.conf symlink already correct"
    else
        echo "  Updating ~/.tmux.conf symlink..."
        ln -sf "$OH_MY_TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
    fi
elif [ -f "$HOME/.tmux.conf" ]; then
    # Existing file (not our symlink) - back it up
    mkdir -p "$BACKUP_DIR"
    cp "$HOME/.tmux.conf" "$BACKUP_DIR/"
    echo "  Backed up existing ~/.tmux.conf to $BACKUP_DIR"
    ln -sf "$OH_MY_TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
    echo "  Created symlink: ~/.tmux.conf → ~/.tmux/.tmux.conf"
else
    ln -sf "$OH_MY_TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
    echo "  Created symlink: ~/.tmux.conf → ~/.tmux/.tmux.conf"
fi

# --- Symlink .tmux.conf.local ---
# Symlink to dotfiles so editing ~/.dotfiles/tmux/tmux.conf.local takes effect
# immediately. This matches the ~/.tmux.conf symlink pattern used by oh-my-tmux.
if [ -L "$HOME/.tmux.conf.local" ]; then
    CURRENT_TARGET=$(readlink -f "$HOME/.tmux.conf.local" 2>/dev/null || readlink "$HOME/.tmux.conf.local")
    if [ "$CURRENT_TARGET" = "$TMUX_DIR/tmux.conf.local" ]; then
        echo "  ~/.tmux.conf.local symlink already correct"
    else
        echo "  Updating ~/.tmux.conf.local symlink..."
        ln -sf "$TMUX_DIR/tmux.conf.local" "$HOME/.tmux.conf.local"
    fi
elif [ -f "$HOME/.tmux.conf.local" ]; then
    # Existing file (not our symlink) - back it up, then symlink
    mkdir -p "$BACKUP_DIR"
    cp "$HOME/.tmux.conf.local" "$BACKUP_DIR/"
    echo "  Backed up existing ~/.tmux.conf.local to $BACKUP_DIR"
    ln -sf "$TMUX_DIR/tmux.conf.local" "$HOME/.tmux.conf.local"
    echo "  Created symlink: ~/.tmux.conf.local → $TMUX_DIR/tmux.conf.local"
else
    ln -sf "$TMUX_DIR/tmux.conf.local" "$HOME/.tmux.conf.local"
    echo "  Created symlink: ~/.tmux.conf.local → $TMUX_DIR/tmux.conf.local"
fi

echo ""
echo "Done! Oh my tmux! is installed."
echo ""
echo "  Config file:     ~/.tmux.conf.local"
echo "  Edit in tmux:    <prefix> e"
echo "  Reload config:   <prefix> r"
echo "  Toggle mouse:    <prefix> m"
echo ""
echo "  Start tmux:      tmux"
echo "  Start named:     tmux new -s myname"
echo "  Attach:          tmux attach -t myname"
