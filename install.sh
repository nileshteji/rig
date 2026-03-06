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

# Install Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh My Zsh installed"
else
    echo "✓ Oh My Zsh already installed"
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

# Install Lazygit
if ! command -v lazygit &> /dev/null; then
    echo "Installing Lazygit..."
    brew install lazygit
    echo "✓ Lazygit installed"
else
    echo "✓ Lazygit already installed"
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

# Install OpenCode
if ! command -v opencode &> /dev/null; then
    echo "Installing OpenCode..."
    brew install anomalyco/tap/opencode
    echo "✓ OpenCode installed"
else
    echo "✓ OpenCode already installed"
fi

# Install Google Workspace CLI
if command -v gws &> /dev/null && gws --help 2>&1 | grep -q "Google Workspace CLI"; then
    echo "✓ Google Workspace CLI already installed"
elif brew list --formula gws &> /dev/null; then
    echo "✗ Found conflicting Homebrew formula 'gws' (not Google Workspace CLI)"
    echo "  Run 'brew uninstall gws' and re-run this installer."
    exit 1
else
    echo "Installing Google Workspace CLI..."
    brew install googleworkspace-cli
    echo "✓ Google Workspace CLI installed"
fi

# Install Google Cloud CLI
if command -v gcloud &> /dev/null; then
    echo "✓ Google Cloud CLI already installed"
else
    echo "Installing Google Cloud CLI..."
    brew install --cask gcloud-cli
    echo "✓ Google Cloud CLI installed"
fi

# Install Ghostty
if command -v ghostty &> /dev/null; then
    echo "✓ Ghostty already installed"
elif [[ -d "/Applications/Ghostty.app" || -d "$HOME/Applications/Ghostty.app" ]]; then
    echo "✓ Ghostty already installed (Applications)"
else
    echo "Installing Ghostty..."
    brew install --cask ghostty
    echo "✓ Ghostty installed"
fi

# Install Kitty (disabled for now)
# if command -v kitty &> /dev/null; then
#     echo "✓ Kitty already installed"
# elif [[ -d "/Applications/Kitty.app" || -d "/Applications/kitty.app" || -d "$HOME/Applications/Kitty.app" || -d "$HOME/Applications/kitty.app" ]]; then
#     echo "✓ Kitty already installed (Applications)"
# else
#     echo "Installing Kitty..."
#     curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
#     echo "✓ Kitty installed"
# fi

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

# Create Ghostty config
echo "Setting up Ghostty config..."
GHOSTTY_CONFIG_SRC="$DOTFILES_DIR/ghostty/config"

if [[ "$OSTYPE" == "darwin"* ]]; then
    GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
else
    GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
fi

mkdir -p "$GHOSTTY_CONFIG_DIR"
backup_file "$GHOSTTY_CONFIG_DIR/config"
rm -f "$GHOSTTY_CONFIG_DIR/config"
ln -s "$GHOSTTY_CONFIG_SRC" "$GHOSTTY_CONFIG_DIR/config"
echo "✓ Ghostty config installed to $GHOSTTY_CONFIG_DIR/config"

# Create Google Workspace CLI credentials file
echo "Setting up Google Workspace CLI credentials..."
GWS_CREDENTIALS_SRC="$DOTFILES_DIR/gws/credentials.json"
GWS_CONFIG_DIR="$HOME/.config/gws"
GWS_CREDENTIALS_TARGET="$GWS_CONFIG_DIR/credentials.json"

mkdir -p "$GWS_CONFIG_DIR"
if [[ -f "$GWS_CREDENTIALS_SRC" ]]; then
    backup_file "$GWS_CREDENTIALS_TARGET"
    cp "$GWS_CREDENTIALS_SRC" "$GWS_CREDENTIALS_TARGET"
    chmod 600 "$GWS_CREDENTIALS_TARGET"
    echo "✓ Google Workspace credentials copied to $GWS_CREDENTIALS_TARGET"
else
    echo "  No repo credentials file found at $GWS_CREDENTIALS_SRC"
    echo "  Add one there or run 'gws auth setup' and 'gws auth login' manually."
fi

# iTerm color preset (disabled for now)
# echo "Setting up iTerm color preset..."
# ITERM_THEME_SRC="$DOTFILES_DIR/iterm/nilesh.itermcolors"
#
# if [[ "$OSTYPE" == "darwin"* ]]; then
#     ITERM_PRESET_DIR="$HOME/Library/Application Support/iTerm2/Color Presets"
#     ITERM_PRESET_TARGET="$ITERM_PRESET_DIR/$(basename "$ITERM_THEME_SRC")"
#     mkdir -p "$ITERM_PRESET_DIR"
#     backup_file "$ITERM_PRESET_TARGET"
#     cp "$ITERM_THEME_SRC" "$ITERM_PRESET_TARGET"
#     echo "✓ iTerm color preset installed to $ITERM_PRESET_TARGET"
# else
#     echo "Skipping iTerm color preset (macOS only)"
# fi

# 1Password agent socket
echo "Setting up 1Password agent socket..."
mkdir -p ~/.1password
rm -f ~/.1password/agent.sock
ln -s "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ~/.1password/agent.sock
echo "✓ 1Password agent.sock symlinked to ~/.1password/agent.sock"

# Create Amp config symlink
echo "Setting up Amp config..."
mkdir -p ~/.config/amp
backup_file "$HOME/.config/amp/settings.json"
rm -f ~/.config/amp/settings.json
ln -s "$DOTFILES_DIR/amp/settings.json" ~/.config/amp/settings.json
echo "✓ Amp config symlinked to ~/.config/amp/settings.json"

# Create Codex config symlinks
echo "Setting up Codex config..."
if [[ -f "$DOTFILES_DIR/codex/config.toml" ]]; then
    mkdir -p "$HOME/.codex"
    if [[ -f "$HOME/.codex/config.toml" ]]; then
        backup_file "$HOME/.codex/config.toml"
    fi
    if [[ -d "$HOME/.codex/skills" ]]; then
        backup_dir "$HOME/.codex/skills"
    fi
    rm -f "$HOME/.codex/config.toml"
    ln -s "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml"
    rm -rf "$HOME/.codex/skills"
    ln -s "$DOTFILES_DIR/codex/skills" "$HOME/.codex/skills"
    echo "✓ Codex config.toml and skills symlinked to ~/.codex"
fi

# Create OpenCode config symlink
echo "Setting up OpenCode config..."
mkdir -p ~/.config/opencode
backup_file "$HOME/.config/opencode/opencode.json"
rm -f ~/.config/opencode/opencode.json
ln -s "$DOTFILES_DIR/opencode/opencode.json" ~/.config/opencode/opencode.json
echo "✓ OpenCode config symlinked to ~/.config/opencode/opencode.json"

# Create OpenCode hidden config symlink
echo "Setting up OpenCode hidden config..."
mkdir -p ~/.config
if [[ -d "$HOME/.config/.opencode" && ! -L "$HOME/.config/.opencode" ]]; then
    backup_dir "$HOME/.config/.opencode"
elif [[ -f "$HOME/.config/.opencode" && ! -L "$HOME/.config/.opencode" ]]; then
    backup_file "$HOME/.config/.opencode"
fi
rm -f ~/.config/.opencode
ln -s "$DOTFILES_DIR/opencode" ~/.config/.opencode
echo "✓ OpenCode config symlinked to ~/.config/.opencode"

# Create Claude Code config symlink
echo "Setting up Claude Code config..."
mkdir -p ~/.claude
backup_file "$HOME/.claude/settings.json"
rm -f ~/.claude/settings.json
ln -s "$DOTFILES_DIR/claude/settings.json" ~/.claude/settings.json
echo "✓ Claude Code config symlinked to ~/.claude/settings.json"

# Create Claude Desktop config symlink
echo "Setting up Claude Desktop config..."
CLAUDE_DESKTOP_CONFIG_DIR="$HOME/Library/Application Support/Claude"
mkdir -p "$CLAUDE_DESKTOP_CONFIG_DIR"
backup_file "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json"
rm -f "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json"
ln -s "$DOTFILES_DIR/claude-desktop/claude_desktop_config.json" "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json"
echo "✓ Claude Desktop config symlinked to $CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json"

echo ""
echo "Next steps for Google Workspace tooling:"
echo "  1. Run 'source ~/.zshrc'"
echo "  2. If credentials were not copied, run 'gcloud auth login'"
echo "  3. Then run 'gws auth setup' and 'gws auth login'"
echo ""
echo "✓ All dotfiles installed successfully!"
