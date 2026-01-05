#!/bin/bash

# Dotfiles installation script - creates symlinks for nvim, ssh, and zsh configs

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Backup function
backup_file() {
    if [[ -f "$1" ]]; then
        cp "$1" "$1.backup.$(date +%s)"
        echo "  Backed up existing file to $1.backup.*"
    fi
}

echo "Setting up dotfiles from: $DOTFILES_DIR"

# Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "✓ Homebrew installed"
else
    echo "✓ Homebrew already installed"
fi

# Install Neovim
if ! command -v nvim &> /dev/null; then
    echo "Installing Neovim..."
    brew install neovim
    echo "✓ Neovim installed"
else
    echo "✓ Neovim already installed"
fi

# Install Amp
if ! command -v amp &> /dev/null; then
    echo "Installing Amp..."
    curl -fsSL https://ampcode.com/install.sh | bash
    echo "✓ Amp installed"
else
    echo "✓ Amp already installed"
fi

# Install Codex
if ! command -v codex &> /dev/null; then
    echo "Installing Codex..."
    brew install --cask codex
    echo "✓ Codex installed"
else
    echo "✓ Codex already installed"
fi

# Install Claude
if ! command -v claude &> /dev/null; then
    echo "Installing Claude..."
    curl -fsSL https://claude.ai/install.sh | bash
    echo "✓ Claude installed"
else
    echo "✓ Claude already installed"
fi

# Create nvim symlink
echo "Setting up nvim config..."
mkdir -p ~/.config
rm -f ~/.config/nvim
ln -s "$DOTFILES_DIR/nvim" ~/.config/nvim
echo "✓ nvim symlinked to ~/.config/nvim"

# Create zsh symlink
echo "Setting up zsh config..."
rm -f ~/.zshrc
ln -s "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
echo "✓ zshrc symlinked to ~/.zshrc"

# Create ssh symlink
echo "Setting up ssh config..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
rm -f ~/.ssh/config
ln -s "$DOTFILES_DIR/ssh/config" ~/.ssh/config
chmod 600 ~/.ssh/config
echo "✓ ssh config symlinked to ~/.ssh/config"

# Ghostty configuration
echo "Setting up ghostty config..."
GHOSTTY_SRC="$DOTFILES_DIR/ghostty/config"

if [[ "$OSTYPE" == "darwin"* ]]; then
    GHOSTTY_TARGET="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
else
    GHOSTTY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
    GHOSTTY_TARGET="$GHOSTTY_CONFIG_DIR/config"
fi

mkdir -p "$(dirname "$GHOSTTY_TARGET")"
backup_file "$GHOSTTY_TARGET"
cp "$GHOSTTY_SRC" "$GHOSTTY_TARGET"
echo "✓ Ghostty config installed to $GHOSTTY_TARGET"

# iTerm color preset
echo "Setting up iTerm color preset..."
ITERM_THEME_SRC="$DOTFILES_DIR/iterm/nilesh.itermcolors"

if [[ "$OSTYPE" == "darwin"* ]]; then
    ITERM_PRESET_DIR="$HOME/Library/Application Support/iTerm2/Color Presets"
    ITERM_PRESET_TARGET="$ITERM_PRESET_DIR/$(basename "$ITERM_THEME_SRC")"
    mkdir -p "$ITERM_PRESET_DIR"
    backup_file "$ITERM_PRESET_TARGET"
    cp "$ITERM_THEME_SRC" "$ITERM_PRESET_TARGET"
    echo "✓ iTerm color preset installed to $ITERM_PRESET_TARGET"
else
    echo "Skipping iTerm color preset (macOS only)"
fi

# 1Password agent socket
echo "Setting up 1Password agent socket..."
mkdir -p ~/.1password
rm -f ~/.1password/agent.sock
ln -s "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ~/.1password/agent.sock
echo "✓ 1Password agent.sock symlinked to ~/.1password/agent.sock"

echo ""
echo "✓ All dotfiles installed successfully!"
