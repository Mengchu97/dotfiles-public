#!/usr/bin/env bash
# ================================================================= #
#           Bash Configuration Installer                            #
# ================================================================= #
# Sets up source lines in ~/.bashrc, ~/.bash_profile, ~/.bash_aliases
# to load the dotfiles bash configs, and ensures local override files
# exist for environment-only and interactive-only machine settings.
#
# Usage: bash ~/.dotfiles/bash/install.sh [--restore]

set -e

DOTFILES_DIR="$HOME/.dotfiles"
BASH_DIR="$DOTFILES_DIR/bash"
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
    echo "Restoring bash configs from: $latest_backup"
    for file in "$latest_backup"/.bashrc "$latest_backup"/.bash_profile "$latest_backup"/.bash_aliases "$latest_backup"/.bash_env.local "$latest_backup"/.bashrc.local; do
        [ -f "$file" ] || continue
        target="$HOME/$(basename "$file")"
        cp "$file" "$target"
        echo "  Restored $(basename "$file")"
    done
    echo "Done."
    exit 0
fi

# Marker used to detect our block
MARKER="# >>> dotfiles >>>"

setup_source() {
    local target_file="$1"
    local source_file="$2"
    local name="$3"

    echo "  Setting up $name..."

    if [ -f "$target_file" ]; then
        if grep -q "$MARKER" "$target_file"; then
            echo "    Already configured, skipping."
            return
        fi
        mkdir -p "$BACKUP_DIR"
        cp -L "$target_file" "$BACKUP_DIR/" 2>/dev/null || true
        echo "    Backed up to $BACKUP_DIR"
    fi

    echo "" >> "$target_file"
    echo "$MARKER" >> "$target_file"
    echo "source $source_file" >> "$target_file"
    echo "# <<< dotfiles <<<" >> "$target_file"
    echo "    Configured to source $source_file"
}

ensure_local_file() {
    local target_file="$1"
    local name="$2"
    local content="$3"

    echo "  Ensuring $name..."

    if [ -f "$target_file" ]; then
        echo "    Already exists, preserving current contents."
        return
    fi

    printf '%b\n' "$content" > "$target_file"
    echo "    Created $target_file"
}

echo ""
echo "Bash Configuration Setup"
echo "========================="

setup_source "$HOME/.bashrc"        "$BASH_DIR/bashrc"        "Bash (.bashrc)"
setup_source "$HOME/.bash_profile"  "$BASH_DIR/bash_profile"  "Bash Profile (.bash_profile)"
setup_source "$HOME/.bash_aliases"  "$BASH_DIR/bash_aliases"  "Bash Aliases (.bash_aliases)"
ensure_local_file "$HOME/.bash_env.local" "Bash Env Local (.bash_env.local)" "# Machine-specific Bash environment overrides\n# Put PATH additions and export statements here."
ensure_local_file "$HOME/.bashrc.local" "Bash RC Local (.bashrc.local)" "# Machine-specific interactive Bash overrides\n# Put prompt hooks, module loads, aliases, and interactive-only logic here."

echo ""
echo "Done! Restart your terminal or run 'source ~/.bash_profile'."
