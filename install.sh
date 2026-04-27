#!/bin/bash

# Dotfiles installation script - interactive module installer
# Usage: ./install.sh        (interactive menu)
#        ./install.sh --all  (install everything, non-interactive)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Initialize git submodules (skills repo + gstack) ---

echo "Initializing submodules..."
(cd "$DOTFILES_DIR" && git submodule update --init --recursive)
echo "✓ Submodules initialized"

GSTACK_SRC="$DOTFILES_DIR/skills/gstack"
SKILLS_SRC="$DOTFILES_DIR/skills"

# --- Utility functions ---

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

ensure_symlink() {
    local source_path="$1"
    local target_path="$2"
    local label="$3"

    if [[ -L "$target_path" ]]; then
        local current_target
        current_target="$(readlink "$target_path")"
        if [[ "$current_target" == "$source_path" ]]; then
            echo "✓ $label already symlinked to $target_path"
            return
        fi
        rm -f "$target_path"
    elif [[ -d "$target_path" ]]; then
        backup_dir "$target_path"
        rm -rf "$target_path"
    elif [[ -f "$target_path" ]]; then
        backup_file "$target_path"
        rm -f "$target_path"
    fi

    ln -s "$source_path" "$target_path"
    echo "✓ $label symlinked to $target_path"
}

prepare_skill_dir() {
    local target_dir="$1"

    if [[ -L "$target_dir" ]]; then
        rm -f "$target_dir"
    elif [[ -f "$target_dir" ]]; then
        backup_file "$target_dir"
        rm -f "$target_dir"
    fi

    mkdir -p "$target_dir"
}

get_context7_api_key() {
    local env_file="$DOTFILES_DIR/.env"

    if [[ ! -f "$env_file" ]]; then
        return 1
    fi

    grep -E "^CONTEXT7_API_KEY=" "$env_file" | head -n 1 | cut -d'=' -f2- | tr -d '"' | tr -d "'"
}

render_context7_config() {
    local source_path="$1"
    local target_path="$2"
    local label="$3"
    local ctx7_key="${4:-}"

    mkdir -p "$(dirname "$target_path")"
    backup_file "$target_path"
    rm -f "$target_path"

    if [[ -n "$ctx7_key" ]]; then
        python3 - "$source_path" "$target_path" "$ctx7_key" <<'PY'
import sys
source_path, target_path, ctx7_key = sys.argv[1:4]
text = open(source_path, encoding="utf-8").read()
text = text.replace('"CONTEXT7_API_KEY": ""', f'"CONTEXT7_API_KEY": "{ctx7_key}"')
text = text.replace('CONTEXT7_API_KEY = ""', f'CONTEXT7_API_KEY = "{ctx7_key}"')
with open(target_path, 'w', encoding='utf-8') as f:
    f.write(text)
PY
        echo "✓ $label written to $target_path with Context7 API key from .env"
    else
        cp "$source_path" "$target_path"
        echo "✓ $label written to $target_path"
        echo "  No CONTEXT7_API_KEY found in .env; leaving placeholder in local config"
    fi
}

link_all_skills() {
    local target_dir="$1"
    local label="$2"

    prepare_skill_dir "$target_dir"

    # Link every skill directory from shared/skills into the target
    for skill_dir in "$SKILLS_SRC"/*/; do
        if [[ -d "$skill_dir" ]]; then
            local skill_name
            skill_name="$(basename "$skill_dir")"
            ensure_symlink "$skill_dir" "$target_dir/$skill_name" "$label skill: $skill_name"
        fi
    done

    # Also link hidden directories (e.g. .system for Codex)
    for skill_dir in "$SKILLS_SRC"/.[!.]*/; do
        if [[ -d "$skill_dir" ]]; then
            local skill_name
            skill_name="$(basename "$skill_dir")"
            ensure_symlink "$skill_dir" "$target_dir/$skill_name" "$label skill: $skill_name"
        fi
    done

    # Link non-directory skill assets (e.g. implement-plan.zip)
    for skill_file in "$SKILLS_SRC"/*.zip; do
        if [[ -f "$skill_file" ]]; then
            local file_name
            file_name="$(basename "$skill_file")"
            ensure_symlink "$skill_file" "$target_dir/$file_name" "$label asset: $file_name"
        fi
    done
}

link_gstack_host_skills() {
    local source_dir="$1"
    local target_dir="$2"
    local label="$3"

    mkdir -p "$target_dir"

    for skill_dir in "$source_dir"/gstack*/; do
        if [[ -d "$skill_dir" ]]; then
            local skill_name
            skill_name="$(basename "$skill_dir")"
            ensure_symlink "$skill_dir" "$target_dir/$skill_name" "$label skill: $skill_name"
        fi
    done
}

# --- Module install functions ---

install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "✓ Homebrew installed"
    else
        echo "✓ Homebrew already installed"
    fi

    # Install Node.js (required for Claude Code CLI and npx-based MCPs)
    if ! command -v node &> /dev/null; then
        echo "Installing Node.js..."
        brew install node
        echo "✓ Node.js installed"
    else
        echo "✓ Node.js already installed"
    fi

    # Install gum for interactive menu
    if ! command -v gum &> /dev/null; then
        echo "Installing gum (interactive menu)..."
        brew install gum
        echo "✓ gum installed"
    fi
}

install_shell() {
    if ! command -v zsh &> /dev/null; then
        echo "Installing zsh..."
        brew install zsh
        echo "✓ zsh installed"
    else
        echo "✓ zsh already installed"
    fi

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo "✓ Oh My Zsh installed"
    else
        echo "✓ Oh My Zsh already installed"
    fi

    local zsh_path
    if [[ -x "/bin/zsh" ]]; then
        zsh_path="/bin/zsh"
    else
        zsh_path="$(command -v zsh)"
    fi

    if [[ "$SHELL" == "$zsh_path" ]]; then
        echo "✓ zsh already set as default shell"
    elif grep -qx "$zsh_path" /etc/shells; then
        echo "Setting zsh as default shell..."
        chsh -s "$zsh_path"
        echo "✓ zsh set as default shell"
    else
        echo "  zsh is installed at $zsh_path but is not listed in /etc/shells"
        echo "  Run: sudo sh -c 'echo $zsh_path >> /etc/shells'"
        echo "  Then re-run the installer to set it as your default shell."
    fi
}

config_shell() {
    echo "Setting up zsh config..."
    ensure_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc" "zshrc"
}

install_neovim() {
    if ! command -v nvim &> /dev/null; then
        echo "Installing Neovim..."
        brew install neovim
        echo "✓ Neovim installed"
    else
        echo "✓ Neovim already installed"
    fi
}

config_neovim() {
    echo "Setting up nvim config..."
    mkdir -p ~/.config
    backup_dir "$HOME/.config/nvim"
    rm -f ~/.config/nvim
    ln -s "$DOTFILES_DIR/nvim" ~/.config/nvim
    echo "✓ nvim symlinked to ~/.config/nvim"
}

install_tmux() {
    if ! command -v tmux &> /dev/null; then
        echo "Installing tmux..."
        brew install tmux
        echo "✓ tmux installed"
    else
        echo "✓ tmux already installed"
    fi
}

config_tmux() {
    echo "Setting up tmux config..."
    backup_file "$HOME/.tmux.conf"
    rm -f ~/.tmux.conf
    ln -s "$DOTFILES_DIR/tmux/.tmux.conf" ~/.tmux.conf
    echo "✓ tmux config symlinked to ~/.tmux.conf"
}

install_git_tools() {
    if ! command -v lazygit &> /dev/null; then
        echo "Installing Lazygit..."
        brew install lazygit
        echo "✓ Lazygit installed"
    else
        echo "✓ Lazygit already installed"
    fi
}

install_amp() {
    if ! command -v amp &> /dev/null; then
        echo "Installing Amp..."
        curl -fsSL https://ampcode.com/install.sh | bash
        echo "✓ Amp installed"
    else
        echo "✓ Amp already installed"
    fi
}

config_amp() {
    echo "Setting up Amp config..."
    local ctx7_key
    ctx7_key="$(get_context7_api_key || true)"
    render_context7_config "$DOTFILES_DIR/amp/settings.json" "$HOME/.config/amp/settings.json" "Amp config" "$ctx7_key"
}

install_codex() {
    if ! command -v codex &> /dev/null; then
        echo "Installing Codex..."
        brew install --cask codex
        echo "✓ Codex installed"
    else
        echo "✓ Codex already installed"
    fi
}

config_codex() {
    echo "Setting up Codex config..."
    if [[ -f "$DOTFILES_DIR/codex/config.toml" ]]; then
        local ctx7_key
        ctx7_key="$(get_context7_api_key || true)"
        render_context7_config "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml" "Codex config.toml" "$ctx7_key"
        ensure_symlink "$DOTFILES_DIR/codex/agents" "$HOME/.codex/agents" "Codex agents"
    fi

    # Link all skills from shared/skills
    link_all_skills "$HOME/.codex/skills" "Codex"

    if [[ -d "$HOME/.agents/skills/gstack" ]]; then
        ensure_symlink "$HOME/.agents/skills/gstack" "$HOME/.codex/skills/gstack" "Codex skill: gstack"
        link_gstack_host_skills "$HOME/.agents/skills" "$HOME/.codex/skills" "Codex"
    fi

    # Link codex-specific .system skills
    ensure_symlink "$DOTFILES_DIR/codex/.system" "$HOME/.codex/skills/.system" "Codex .system skills"

    # Link codex-specific assets
    ensure_symlink "$DOTFILES_DIR/codex/implement-plan.zip" "$HOME/.codex/skills/implement-plan.zip" "Codex implement-plan.zip"
}

install_opencode() {
    if ! command -v opencode &> /dev/null; then
        echo "Installing OpenCode..."
        brew install anomalyco/tap/opencode
        echo "✓ OpenCode installed"
    else
        echo "✓ OpenCode already installed"
    fi
}

config_opencode() {
    echo "Setting up OpenCode config..."
    local ctx7_key
    ctx7_key="$(get_context7_api_key || true)"
    render_context7_config "$DOTFILES_DIR/opencode/opencode.json" "$HOME/.config/opencode/opencode.json" "OpenCode config" "$ctx7_key"

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
}

install_bun() {
    if ! command -v bun &> /dev/null; then
        echo "Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
        # Source zshrc to pick up bun PATH (in case shell module wasn't selected)
        if [[ -f "$HOME/.zshrc" ]]; then
            source "$HOME/.zshrc"
        elif [[ -f "$HOME/.bun/bin/bun" ]]; then
            export BUN_INSTALL="$HOME/.bun"
            export PATH="$BUN_INSTALL/bin:$PATH"
        fi
        echo "✓ Bun installed"
    else
        echo "✓ Bun already installed"
    fi
}

install_claude() {
    if ! command -v claude &> /dev/null; then
        echo "Installing Claude Code..."
        curl -fsSL https://claude.ai/install.sh | bash
        echo "✓ Claude Code installed"
    else
        echo "✓ Claude Code already installed"
    fi
}

install_pi() {
    if ! command -v pi &> /dev/null; then
        echo "Installing Pi..."
        npm install -g @mariozechner/pi-coding-agent
        echo "✓ Pi installed"
    else
        echo "✓ Pi already installed"
    fi
}

config_pi() {
    echo "Setting up Pi config..."
    mkdir -p "$HOME/.pi/agent"

    if [[ -f "$DOTFILES_DIR/pi/AGENTS.md" ]]; then
        ensure_symlink "$DOTFILES_DIR/pi/AGENTS.md" "$HOME/.pi/agent/AGENTS.md" "Pi AGENTS.md"
    fi

    local pi_skills_dir="$HOME/.pi/agent/skills"

    # Repair stale installs where ~/.pi/agent/skills was a file or symlink.
    prepare_skill_dir "$pi_skills_dir"

    # Pi already discovers ~/.agents/skills. Skip overlapping skills there to avoid name-collision warnings.
    for skill_dir in "$SKILLS_SRC"/*/; do
        if [[ -d "$skill_dir" ]]; then
            local skill_name
            skill_name="$(basename "$skill_dir")"

            case "$skill_name" in
                gstack|remotion-best-practices)
                    echo "✓ Pi skill already provided elsewhere, skipping duplicate: $skill_name"
                    continue
                    ;;
            esac

            ensure_symlink "$skill_dir" "$pi_skills_dir/$skill_name" "Pi skill: $skill_name"
        fi
    done
}

install_cursor() {
    if ! command -v cursor &> /dev/null; then
        echo "Installing Cursor..."
        curl -fsSL https://cursor.com/install | bash
        echo "✓ Cursor installed"
    else
        echo "✓ Cursor already installed"
    fi
}

config_claude() {
    # Claude Code config
    echo "Setting up Claude Code config..."
    mkdir -p ~/.claude
    ensure_symlink "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json" "Claude Code settings.json"
    ensure_symlink "$DOTFILES_DIR/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh" "Claude Code statusline script"

    # Link all shared skills, then overlay Claude-specific extras from ~/.agents/skills.
    link_all_skills "$HOME/.claude/skills" "Claude Code"

    local claude_user_skills=(
        "agentation"
        "agentation-self-driving"
        "brainstorming"
        "find-skills"
        "gstack"
        "remotion-best-practices"
    )
    local skill_name
    for skill_name in "${claude_user_skills[@]}"; do
        if [[ -d "$HOME/.agents/skills/$skill_name" ]]; then
            ensure_symlink "$HOME/.agents/skills/$skill_name" "$HOME/.claude/skills/$skill_name" "Claude Code skill: $skill_name"
        fi
    done

    if [[ -d "$HOME/.agents/skills/gstack" ]]; then
        link_gstack_host_skills "$HOME/.agents/skills" "$HOME/.claude/skills" "Claude Code"
    fi

    # Claude Code agents
    if [[ -d "$DOTFILES_DIR/claude/agents" ]]; then
        ensure_symlink "$DOTFILES_DIR/claude/agents" "$HOME/.claude/agents" "Claude Code agents"
    fi

    # Claude Code MCP servers
    echo "Setting up Claude Code MCP servers..."
    if command -v claude &> /dev/null; then
        claude mcp add --transport http context7 https://mcp.context7.com/mcp 2>/dev/null || true
        echo "✓ MCP: context7"
        claude mcp add --transport http openaiDeveloperDocs https://developers.openai.com/mcp 2>/dev/null || true
        echo "✓ MCP: openaiDeveloperDocs"
        claude mcp add --transport http figma https://mcp.figma.com/mcp 2>/dev/null || true
        echo "✓ MCP: figma"
        claude mcp add --transport http notion https://mcp.notion.com/mcp 2>/dev/null || true
        echo "✓ MCP: notion"
        claude mcp add playwright -- npx -y @playwright/mcp@latest 2>/dev/null || true
        echo "✓ MCP: playwright"
        claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest 2>/dev/null || true
        echo "✓ MCP: chrome-devtools"
        claude mcp add -e TASK_MASTER_TOOLS=all -e CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 task-master-ai -- npx -y task-master-ai 2>/dev/null || true
        echo "✓ MCP: task-master-ai"
    else
        echo "  Claude Code CLI not found, skipping MCP setup"
    fi

    # Claude Desktop config
    echo "Setting up Claude Desktop config..."
    CLAUDE_DESKTOP_CONFIG_DIR="$HOME/Library/Application Support/Claude"
    mkdir -p "$CLAUDE_DESKTOP_CONFIG_DIR"
    backup_file "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json"
    rm -f "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json"
    ln -s "$DOTFILES_DIR/claude-desktop/claude_desktop_config.json" "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json"
    echo "✓ Claude Desktop config symlinked to $CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json"
}

install_terminal() {
    if command -v ghostty &> /dev/null; then
        echo "✓ Ghostty already installed"
    elif [[ -d "/Applications/Ghostty.app" || -d "$HOME/Applications/Ghostty.app" ]]; then
        echo "✓ Ghostty already installed (Applications)"
    else
        echo "Installing Ghostty..."
        brew install --cask ghostty
        echo "✓ Ghostty installed"
    fi
}

config_terminal() {
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
}

install_google_cloud() {
    # Google Workspace CLI
    if command -v gws &> /dev/null && gws --help 2>&1 | grep -q "Google Workspace CLI"; then
        echo "✓ Google Workspace CLI already installed"
    elif brew list --formula gws &> /dev/null; then
        echo "✗ Found conflicting Homebrew formula 'gws' (not Google Workspace CLI)"
        echo "  Run 'brew uninstall gws' and re-run this installer."
        return 1
    else
        echo "Installing Google Workspace CLI..."
        brew install googleworkspace-cli
        echo "✓ Google Workspace CLI installed"
    fi

    # Google Cloud CLI
    if command -v gcloud &> /dev/null; then
        echo "✓ Google Cloud CLI already installed"
    else
        echo "Installing Google Cloud CLI..."
        brew install --cask gcloud-cli
        echo "✓ Google Cloud CLI installed"
    fi
}

config_google_cloud() {
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
}

install_agentation() {
    echo "Setting up Agentation..."
    if [[ -f "$DOTFILES_DIR/agentation/install.sh" ]]; then
        bash "$DOTFILES_DIR/agentation/install.sh" all
    else
        echo "✗ agentation/install.sh not found"
    fi
}

config_copilot_skills() {
    echo "Setting up Copilot skills..."
    link_all_skills "$HOME/.copilot/skills" "Copilot"
}

install_gstack() {
    if [[ ! -d "$GSTACK_SRC" ]]; then
        echo "✗ gstack source not found at $GSTACK_SRC"
        return 1
    fi

    install_bun
}

config_gstack() {
    if [[ ! -d "$GSTACK_SRC" ]]; then
        echo "✗ gstack source not found at $GSTACK_SRC"
        return 1
    fi

    echo "Setting up gstack in ~/.agents/skills..."
    mkdir -p "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.codex/skills"

    ensure_symlink "$GSTACK_SRC" "$HOME/.agents/skills/gstack" "gstack source-of-truth skill"
    ensure_symlink "$HOME/.agents/skills/gstack" "$HOME/.claude/skills/gstack" "Claude Code skill: gstack"
    ensure_symlink "$HOME/.agents/skills/gstack" "$HOME/.codex/skills/gstack" "Codex skill: gstack"

    echo "Running gstack setup for Claude Code..."
    (cd "$HOME/.claude/skills/gstack" && ./setup)

    echo "Running gstack setup for Codex-compatible hosts..."
    (cd "$HOME/.agents/skills/gstack" && ./setup --host codex)

    link_gstack_host_skills "$HOME/.agents/skills" "$HOME/.claude/skills" "Claude Code"
    link_gstack_host_skills "$HOME/.agents/skills" "$HOME/.codex/skills" "Codex"

    echo "✓ gstack installed with ~/.agents/skills as the source and Claude/Codex linked to it"
}

config_ssh() {
    echo "Setting up ssh config..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    rm -f ~/.ssh/config
    ln -s "$DOTFILES_DIR/ssh/config" ~/.ssh/config
    chmod 600 ~/.ssh/config
    echo "✓ ssh config symlinked to ~/.ssh/config"

    echo "Setting up 1Password agent socket..."
    mkdir -p ~/.1password
    rm -f ~/.1password/agent.sock
    ln -s "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ~/.1password/agent.sock
    echo "✓ 1Password agent.sock symlinked to ~/.1password/agent.sock"
}

install_vim() {
    if ! command -v vim &> /dev/null; then
        echo "Installing Vim..."
        brew install vim
        echo "✓ Vim installed"
    else
        echo "✓ Vim already installed"
    fi
}

config_vim() {
    echo "Setting up Vim config..."
    mkdir -p ~/.vim/undodir
    ensure_symlink "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc" "vimrc"

    # Symlink theme and runtime files into ~/.vim
    ensure_symlink "$DOTFILES_DIR/vim/colors" "$HOME/.vim/colors" "vim colors"
    ensure_symlink "$DOTFILES_DIR/vim/after" "$HOME/.vim/after" "vim after"

    # Merge autoload: vim-plug lives in autoload/, so we symlink subdirs only
    mkdir -p "$HOME/.vim/autoload/lightline/colorscheme"
    mkdir -p "$HOME/.vim/autoload/airline/themes"
    ensure_symlink "$DOTFILES_DIR/vim/autoload/lightline/colorscheme/onehalfdark.vim" \
        "$HOME/.vim/autoload/lightline/colorscheme/onehalfdark.vim" "lightline onehalfdark theme"
    ensure_symlink "$DOTFILES_DIR/vim/autoload/airline/themes/onehalfdark.vim" \
        "$HOME/.vim/autoload/airline/themes/onehalfdark.vim" "airline onehalfdark theme"
    ensure_symlink "$DOTFILES_DIR/vim/autoload/airline/themes/onehalflight.vim" \
        "$HOME/.vim/autoload/airline/themes/onehalflight.vim" "airline onehalflight theme"

    # Auto-install vim-plug and plugins on first run
    if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
        echo "Installing vim-plug..."
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        echo "✓ vim-plug installed"
        echo "Installing Vim plugins (this may take a moment)..."
        vim -es -u "$HOME/.vimrc" -i NONE -c "PlugInstall" -c "qa" 2>/dev/null || true
        echo "✓ Vim plugins installed"
    else
        echo "✓ vim-plug already installed"
    fi
}

install_forge() {
    if ! command -v forge &> /dev/null; then
        echo "Installing Forge..."
        brew install forge
        echo "✓ Forge installed"
    else
        echo "✓ Forge already installed"
    fi
}

config_forge() {
    echo "Setting up Forge config..."

    # Link all skills from shared/skills
    link_all_skills "$HOME/forge/skills" "Forge"

    # Forge zsh integration
    echo "Setting up Forge zsh integration..."
    if command -v forge &> /dev/null; then
        forge zsh setup
        echo "✓ Forge zsh integration configured"
    else
        echo "  Forge CLI not found, skipping zsh setup"
    fi
}

# --- API keys from .env file ---

apply_env_keys() {
    local env_file="$DOTFILES_DIR/.env"

    echo ""
    if [[ ! -f "$env_file" ]]; then
        echo "No .env file found at $env_file"
        echo "  To set API keys, create .env with:"
        echo "    CONTEXT7_API_KEY=your-key-here"
        echo "  Then re-run the installer."
        return
    fi

    echo "Loading API keys from .env..."

    local ctx7_key
    ctx7_key="$(get_context7_api_key || true)"
    if [[ -z "$ctx7_key" ]]; then
        echo "  CONTEXT7_API_KEY is empty; managed configs will keep placeholders."
        return
    fi

    [[ -f "$DOTFILES_DIR/amp/settings.json" ]] && render_context7_config "$DOTFILES_DIR/amp/settings.json" "$HOME/.config/amp/settings.json" "Amp config" "$ctx7_key"
    [[ -f "$DOTFILES_DIR/opencode/opencode.json" ]] && render_context7_config "$DOTFILES_DIR/opencode/opencode.json" "$HOME/.config/opencode/opencode.json" "OpenCode config" "$ctx7_key"
    [[ -f "$DOTFILES_DIR/codex/config.toml" ]] && render_context7_config "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml" "Codex config.toml" "$ctx7_key"
}

# --- Module definitions ---

MODULE_NAMES=(
    "Shell"
    "Neovim"
    "Vim"
    "Tmux"
    "Git Tools"
    "Amp"
    "Codex"
    "OpenCode"
    "Claude"
    "Pi"
    "Cursor"
    "Terminal"
    "Google Cloud"
    "Agentation"
    "Copilot"
    "SSH & Security"
    "Forge"
    "Gstack"
)

MODULE_DESCRIPTIONS=(
    "Oh My Zsh + .zshrc"
    "neovim + config"
    "vim + config (merged keybindings)"
    "tmux + config"
    "lazygit"
    "Amp + config"
    "Codex + config, agents, shared skills"
    "OpenCode + config"
    "Claude Code, Claude Desktop + configs, shared skills"
    "Pi + shared skills"
    "Cursor IDE"
    "Ghostty + config"
    "GWS CLI, gcloud + credentials"
    "Agentation MCP for AI tools"
    "Copilot shared skills"
    "SSH config, 1Password socket"
    "Forge CLI + shared skills, zsh integration"
    "Optional gstack install via ~/.agents/skills, linked to Claude Code and Codex"
)

# --- Run a module by index (0-based) ---

module_requires_env_keys() {
    local idx="$1"

    case "$idx" in
        5|6|7|8|9|13|14|16|17) return 0 ;;
        *) return 1 ;;
    esac
}

run_module() {
    local idx="$1"
    echo ""
    echo "--- ${MODULE_NAMES[$idx]} ---"
    case "$idx" in
        0) install_shell; config_shell ;;
        1) install_neovim; config_neovim ;;
        2) install_vim; config_vim ;;
        3) install_tmux; config_tmux ;;
        4) install_git_tools ;;
        5) install_amp; config_amp ;;
        6) install_codex; config_codex ;;
        7) install_opencode; config_opencode ;;
        8) install_bun; install_claude; config_claude ;;
        9) install_pi; config_pi ;;
        10) install_cursor ;;
        11) install_terminal; config_terminal ;;
        12) install_google_cloud; config_google_cloud ;;
        13) install_agentation ;;
        14) config_copilot_skills ;;
        15) config_ssh ;;
        16) install_forge; config_forge ;;
        17)
            if [[ -d "$GSTACK_SRC" ]]; then
                install_gstack
                config_gstack
            else
                echo "Skipping Gstack: optional source not found at $GSTACK_SRC"
            fi
            ;;
    esac
}

# --- Interactive menu (gum — spacebar + arrow keys) ---

gum_menu() {
    local num_modules=${#MODULE_NAMES[@]}
    local options=()
    for i in $(seq 0 $((num_modules - 1))); do
        options+=("${MODULE_NAMES[$i]}  (${MODULE_DESCRIPTIONS[$i]})")
    done

    echo ""
    echo "Dotfiles Installer"
    echo "=================="
    echo "Homebrew will be installed automatically."
    echo ""
    echo "Use arrow keys to navigate, spacebar to toggle, enter to confirm:"
    echo ""

    local chosen
    chosen=$(printf '%s\n' "${options[@]}" | gum choose --no-limit --selected="${options[0]}","${options[1]}","${options[2]}","${options[3]}","${options[4]}","${options[5]}","${options[6]}","${options[7]}","${options[8]}","${options[9]}","${options[10]}","${options[11]}","${options[12]}","${options[13]}","${options[14]}","${options[15]}","${options[16]}" --cursor-prefix="[ ] " --selected-prefix="[x] " --unselected-prefix="[ ] " --header="") || { echo "Aborted."; return 1; }

    [[ -z "$chosen" ]] && { echo "No modules selected. Aborted."; return 1; }

    echo ""
    echo "Setting up dotfiles from: $DOTFILES_DIR"
    echo ""

    local any_ai=0
    local has_gcloud=0
    for i in $(seq 0 $((num_modules - 1))); do
        if echo "$chosen" | grep -qF "${MODULE_NAMES[$i]}"; then
            run_module "$i"
            if module_requires_env_keys "$i"; then
                any_ai=1
            fi
            if [[ "$i" -eq 12 ]]; then
                has_gcloud=1
            fi
        fi
    done

    if [[ "$any_ai" -eq 1 ]]; then
        apply_env_keys
    fi

    echo ""
    echo "Next steps:"
    echo "  1. Run 'source ~/.zshrc'"
    if [[ "$has_gcloud" -eq 1 ]]; then
        echo "  2. If credentials were not copied, run 'gcloud auth login'"
        echo "  3. Then run 'gws auth setup' and 'gws auth login'"
    fi
    echo ""
    echo "✓ All selected dotfiles installed successfully!"
}

# --- Interactive menu (fallback — number input) ---

show_menu() {
    local selected=("$@")
    echo ""
    echo "Dotfiles Installer"
    echo "=================="
    echo "Homebrew will be installed automatically."
    echo ""
    echo "Toggle modules (e.g. 1  1,3,5  1-4  1,3-5,8), then press 'i' to install:"
    echo ""
    for i in "${!MODULE_NAMES[@]}"; do
        if [[ "${selected[$i]}" -eq 1 ]]; then
            printf "  [x] %2d. %-18s (%s)\n" "$((i + 1))" "${MODULE_NAMES[$i]}" "${MODULE_DESCRIPTIONS[$i]}"
        else
            printf "  [ ] %2d. %-18s (%s)\n" "$((i + 1))" "${MODULE_NAMES[$i]}" "${MODULE_DESCRIPTIONS[$i]}"
        fi
    done
    echo ""
    echo "  a) Select All   n) Select None   i) Install   q) Quit"
    echo ""
}

toggle_selection() {
    local input="$1"
    shift
    local -n sel_ref=$1
    local num_modules=${#MODULE_NAMES[@]}

    IFS=',' read -ra parts <<< "$input"
    for part in "${parts[@]}"; do
        part="$(echo "$part" | tr -d ' ')"
        if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            local start="${BASH_REMATCH[1]}"
            local end="${BASH_REMATCH[2]}"
            for num in $(seq "$start" "$end"); do
                if [[ "$num" -ge 1 && "$num" -le "$num_modules" ]]; then
                    local idx=$((num - 1))
                    if [[ "${sel_ref[$idx]}" -eq 1 ]]; then
                        sel_ref[$idx]=0
                    else
                        sel_ref[$idx]=1
                    fi
                fi
            done
        elif [[ "$part" =~ ^[0-9]+$ ]]; then
            if [[ "$part" -ge 1 && "$part" -le "$num_modules" ]]; then
                local idx=$((part - 1))
                if [[ "${sel_ref[$idx]}" -eq 1 ]]; then
                    sel_ref[$idx]=0
                else
                    sel_ref[$idx]=1
                fi
            fi
        fi
    done
}

fallback_menu() {
    local selected=(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0)
    local num_modules=${#MODULE_NAMES[@]}

    while true; do
        clear
        show_menu "${selected[@]}"
        read -rp "Choice: " choice

        case "$choice" in
            a|A)
                for i in $(seq 0 $((num_modules - 1))); do
                    selected[$i]=1
                done
                ;;
            n|N)
                for i in $(seq 0 $((num_modules - 1))); do
                    selected[$i]=0
                done
                ;;
            i|I)
                echo ""
                echo "Setting up dotfiles from: $DOTFILES_DIR"
                echo ""

                for i in $(seq 0 $((num_modules - 1))); do
                    if [[ "${selected[$i]}" -eq 1 ]]; then
                        run_module "$i"
                    fi
                done

                local any_ai=0
                for i in $(seq 0 $((num_modules - 1))); do
                    if [[ "${selected[$i]}" -eq 1 ]] && module_requires_env_keys "$i"; then
                        any_ai=1
                        break
                    fi
                done
                if [[ "$any_ai" -eq 1 ]]; then
                    apply_env_keys
                fi

                echo ""
                echo "Next steps:"
                echo "  1. Run 'source ~/.zshrc'"
                if [[ "${selected[12]}" -eq 1 ]]; then
                    echo "  2. If credentials were not copied, run 'gcloud auth login'"
                    echo "  3. Then run 'gws auth setup' and 'gws auth login'"
                fi
                echo ""
                echo "✓ All selected dotfiles installed successfully!"
                return 0
                ;;
            q|Q)
                echo "Aborted."
                return 1
                ;;
            *)
                if [[ "$choice" =~ ^[0-9,\ -]+$ ]]; then
                    toggle_selection "$choice" selected
                else
                    echo "Invalid choice: $choice"
                    sleep 1
                fi
                ;;
        esac
    done
}

interactive_menu() {
    if command -v gum &> /dev/null; then
        gum_menu
    else
        echo "Warning: 'gum' is unavailable after Homebrew bootstrap."
        echo "Falling back to the basic menu."
        echo ""
        fallback_menu
    fi
}

# --- Main ---

if [[ "$1" == "--all" ]]; then
    echo "Setting up dotfiles from: $DOTFILES_DIR"
    echo ""

    install_homebrew

    for i in $(seq 0 $((${#MODULE_NAMES[@]} - 1))); do
        run_module "$i"
    done

    apply_env_keys

    echo ""
    echo "Next steps:"
    echo "  1. Run 'source ~/.zshrc'"
    echo "  2. If credentials were not copied, run 'gcloud auth login'"
    echo "  3. Then run 'gws auth setup' and 'gws auth login'"
    echo ""
    echo "✓ All dotfiles installed successfully!"
else
    install_homebrew
    interactive_menu
fi
