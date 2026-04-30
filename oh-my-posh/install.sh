#!/usr/bin/env bash
# ================================================================= #
#           Oh My Posh Installer (Unix)                              #
# ================================================================= #
# Installs Oh My Posh prompt engine and optionally a Nerd Font.
#
# Usage: bash ~/.dotfiles/oh-my-posh/install.sh [--with-font] [--restore]

set -e

DOTFILES_DIR="$HOME/.dotfiles"
OMP_DIR="$DOTFILES_DIR/oh-my-posh"
RESTORE_MODE=false
WITH_FONT=false

for arg in "$@"; do
    case "$arg" in
        --restore) RESTORE_MODE=true ;;
        --with-font) WITH_FONT=true ;;
    esac
done

if [ "$RESTORE_MODE" = true ]; then
    echo "Oh My Posh: Restore not needed (no user config files modified by installer)."
    exit 0
fi

echo ""
echo "Oh My Posh Setup"
echo "================"

# --- Install Oh My Posh ---
if command -v oh-my-posh &>/dev/null; then
    echo "  Already installed: $(oh-my-posh --version)"
else
    echo "  Installing Oh My Posh..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &>/dev/null; then
            brew install jandedobbeleer/oh-my-posh/oh-my-posh
            echo "  Installed via Homebrew"
        else
            echo "  Homebrew not found. Install it first: https://brew.sh"
            echo "  Then run: brew install jandedobbeleer/oh-my-posh/oh-my-posh"
            exit 1
        fi
    else
        echo "  Please install Oh My Posh manually for your Linux distro."
        echo "  See: https://ohmyposh.dev/docs/installation/linux"
        exit 1
    fi
fi

# --- Install Nerd Font ---
if [ "$WITH_FONT" = true ]; then
    echo ""
    echo "  Installing MesloLGM Nerd Font..."
    if command -v oh-my-posh &>/dev/null; then
        oh-my-posh font install meslo
        echo "  Font installed."
        echo ""
        echo "  IMPORTANT: Configure your terminal to use 'MesloLGM Nerd Font':"
        echo "    - iTerm2: Profiles > Text > Font"
        echo "    - VS Code: terminal.integrated.fontFamily = 'MesloLGM Nerd Font'"
    else
        echo "  Cannot install font: oh-my-posh not found."
    fi
else
    echo ""
    echo "  Tip: Install the recommended font with:"
    echo "    oh-my-posh font install meslo"
fi

echo ""
echo "Done! Theme file: $OMP_DIR/theme.omp.json"
