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

backup_dir() {
    if [[ -d "$1" && ! -L "$1" ]]; then
        local backup_dir="$1.backup.$(date +%s)"
        mv "$1" "$backup_dir"
        echo "  Backed up existing directory to $backup_dir"
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

# Install tmux
if ! command -v tmux &> /dev/null; then
    echo "Installing tmux..."
    brew install tmux
    echo "✓ tmux installed"
else
    echo "✓ tmux already installed"
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

# Install Kitty
if command -v kitty &> /dev/null; then
    echo "✓ Kitty already installed"
elif [[ -d "/Applications/Kitty.app" || -d "/Applications/kitty.app" || -d "$HOME/Applications/Kitty.app" || -d "$HOME/Applications/kitty.app" ]]; then
    echo "✓ Kitty already installed (Applications)"
else
    echo "Installing Kitty..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    echo "✓ Kitty installed"
fi

# Install Claude
if ! command -v claude &> /dev/null; then
    echo "Installing Claude..."
    curl -fsSL https://claude.ai/install.sh | bash
    echo "✓ Claude installed"
else
    echo "✓ Claude already installed"
fi

# Install Cursor
if ! command -v cursor &> /dev/null; then
    echo "Installing Cursor..."
    curl -fsSL https://cursor.com/install | bash
    echo "✓ Cursor installed"
else
    echo "✓ Cursor already installed"
fi

# Create nvim symlink
echo "Setting up nvim config..."
mkdir -p ~/.config
backup_dir "$HOME/.config/nvim"
rm -f ~/.config/nvim
ln -s "$DOTFILES_DIR/nvim" ~/.config/nvim
echo "✓ nvim symlinked to ~/.config/nvim"

# Create zsh symlink
echo "Setting up zsh config..."
rm -f ~/.zshrc
ln -s "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
echo "✓ zshrc symlinked to ~/.zshrc"

# Create tmux symlink
echo "Setting up tmux config..."
backup_file "$HOME/.tmux.conf"
rm -f ~/.tmux.conf
ln -s "$DOTFILES_DIR/tmux/.tmux.conf" ~/.tmux.conf
echo "✓ tmux config symlinked to ~/.tmux.conf"

# Create ssh symlink
echo "Setting up ssh config..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
rm -f ~/.ssh/config
ln -s "$DOTFILES_DIR/ssh/config" ~/.ssh/config
chmod 600 ~/.ssh/config
echo "✓ ssh config symlinked to ~/.ssh/config"

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
