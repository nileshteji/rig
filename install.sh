#!/bin/bash

# Dotfiles installation script - interactive module installer
# Usage: ./install.sh        (interactive menu)
#        ./install.sh --all  (install everything, non-interactive)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    mkdir -p ~/.config/amp
    backup_file "$HOME/.config/amp/settings.json"
    rm -f ~/.config/amp/settings.json
    ln -s "$DOTFILES_DIR/amp/settings.json" ~/.config/amp/settings.json
    echo "✓ Amp config symlinked to ~/.config/amp/settings.json"
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
        mkdir -p "$HOME/.codex"
        ensure_symlink "$DOTFILES_DIR/codex/config.toml" "$HOME/.codex/config.toml" "Codex config.toml"
        ensure_symlink "$DOTFILES_DIR/codex/skills" "$HOME/.codex/skills" "Codex skills"
        ensure_symlink "$DOTFILES_DIR/codex/agents" "$HOME/.codex/agents" "Codex agents"
    fi

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
    mkdir -p ~/.config/opencode
    backup_file "$HOME/.config/opencode/opencode.json"
    rm -f ~/.config/opencode/opencode.json
    ln -s "$DOTFILES_DIR/opencode/opencode.json" ~/.config/opencode/opencode.json
    echo "✓ OpenCode config symlinked to ~/.config/opencode/opencode.json"

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

    if [[ -d "$DOTFILES_DIR/pi/skills" ]]; then
        ensure_symlink "$DOTFILES_DIR/pi/skills" "$HOME/.pi/agent/skills" "Pi skills"
    fi

    # Symlink pi skills into ~/.agents/skills so pi discovers them globally
    if [[ -d "$DOTFILES_DIR/pi/skills" ]]; then
        mkdir -p "$HOME/.agents/skills"
        for skill_dir in "$DOTFILES_DIR/pi/skills"/*/; do
            if [[ -d "$skill_dir" ]]; then
                skill_name="$(basename "$skill_dir")"
                ensure_symlink "$skill_dir" "$HOME/.agents/skills/$skill_name" "Pi global skill: $skill_name"
            fi
        done
    fi
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

    # Claude Code skills (symlink repo-local and installed user skills)
    mkdir -p "$HOME/.claude/skills"

    if [[ -d "$DOTFILES_DIR/claude/skills" ]]; then
        for skill_dir in "$DOTFILES_DIR/claude/skills"/*/; do
            if [[ -d "$skill_dir" ]]; then
                local skill_name
                skill_name="$(basename "$skill_dir")"
                ensure_symlink "$skill_dir" "$HOME/.claude/skills/$skill_name" "Claude Code skill: $skill_name"
            fi
        done
    fi

    if [[ -d "$HOME/.agents/skills" ]]; then
        for skill_dir in "$HOME/.agents/skills"/*/; do
            if [[ -d "$skill_dir" ]]; then
                local skill_name
                skill_name="$(basename "$skill_dir")"
                ensure_symlink "$skill_dir" "$HOME/.claude/skills/$skill_name" "Claude Code user skill: $skill_name"
            fi
        done
    fi

    # gstack skills (cloned and built separately)
    if [[ -d "$HOME/.claude/skills/gstack" ]]; then
        echo "✓ gstack already cloned, updating..."
        (cd "$HOME/.claude/skills/gstack" && git pull --ff-only 2>/dev/null || true)
    else
        echo "Installing gstack skills..."
        mkdir -p "$HOME/.claude/skills"
        git clone https://github.com/garrytan/gstack.git "$HOME/.claude/skills/gstack"
    fi
    echo "Running gstack setup..."
    (cd "$HOME/.claude/skills/gstack" && ./setup)
    echo "✓ gstack skills installed"

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

    # Forge skills (symlink each skill from dotfiles into ~/forge/skills/)
    if [[ -d "$DOTFILES_DIR/forge/skills" ]]; then
        mkdir -p "$HOME/forge/skills"
        for skill_dir in "$DOTFILES_DIR/forge/skills"/*/; do
            if [[ -d "$skill_dir" ]]; then
                local skill_name
                skill_name="$(basename "$skill_dir")"
                ensure_symlink "$skill_dir" "$HOME/forge/skills/$skill_name" "Forge skill: $skill_name"
            fi
        done
    fi

    # gstack skills (cloned, browse binary built, skills linked with path rewriting)
    local GSTACK_SRC="$HOME/.gstack/repo"
    if [[ -d "$GSTACK_SRC" ]]; then
        echo "✓ gstack already cloned, updating..."
        (cd "$GSTACK_SRC" && git pull --ff-only 2>/dev/null || true)
    else
        echo "Cloning gstack..."
        mkdir -p "$HOME/.gstack"
        git clone https://github.com/garrytan/gstack.git "$GSTACK_SRC"
    fi

    # Build browse binary if bun is available
    if command -v bun &> /dev/null; then
        echo "Building gstack browse binary..."
        (cd "$GSTACK_SRC" && bun install --frozen-lockfile 2>/dev/null && bun run build 2>/dev/null || true)
    fi

    # Link gstack skills into ~/forge/skills/ with path rewriting
    local FORGE_GSTACK="$HOME/forge/skills/gstack"
    rm -rf "$FORGE_GSTACK"
    mkdir -p "$FORGE_GSTACK" "$FORGE_GSTACK/browse" "$FORGE_GSTACK/gstack-upgrade" "$FORGE_GSTACK/review"

    # Symlink runtime assets
    ln -snf "$GSTACK_SRC/bin" "$FORGE_GSTACK/bin"
    ln -snf "$GSTACK_SRC/browse/dist" "$FORGE_GSTACK/browse/dist"
    ln -snf "$GSTACK_SRC/browse/bin" "$FORGE_GSTACK/browse/bin"
    [[ -f "$GSTACK_SRC/ETHOS.md" ]] && ln -snf "$GSTACK_SRC/ETHOS.md" "$FORGE_GSTACK/ETHOS.md"

    # Rewrite root SKILL.md paths for Forge
    if [[ -f "$GSTACK_SRC/SKILL.md" ]]; then
        sed -e "s|~/.claude/skills/gstack|~/forge/skills/gstack|g" \
            -e "s|\.claude/skills/gstack|forge/skills/gstack|g" \
            -e "s|\.claude/skills|forge/skills|g" \
            "$GSTACK_SRC/SKILL.md" > "$FORGE_GSTACK/SKILL.md"
    fi

    # Link individual gstack sub-skills
    for skill_dir in "$GSTACK_SRC"/*/; do
        if [[ -f "$skill_dir/SKILL.md" ]]; then
            local gstack_skill_name
            gstack_skill_name="$(basename "$skill_dir")"
            [[ "$gstack_skill_name" == "node_modules" ]] && continue
            [[ "$gstack_skill_name" == "test" ]] && continue
            local target="$HOME/forge/skills/$gstack_skill_name"
            if [[ -L "$target" ]] || [[ ! -e "$target" ]]; then
                ln -snf "gstack/$gstack_skill_name" "$target"
            fi
        fi
    done
    echo "✓ gstack skills installed for Forge"

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

    if [[ ! -f "$env_file" ]]; then
        echo ""
        echo "No .env file found at $env_file"
        echo "  To set API keys, create .env with:"
        echo "    CONTEXT7_API_KEY=your-key-here"
        echo "  Then re-run the installer."
        return
    fi

    echo ""
    echo "Loading API keys from .env..."

    # Read CONTEXT7_API_KEY
    local ctx7_key
    ctx7_key=$(grep -E "^CONTEXT7_API_KEY=" "$env_file" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
    if [[ -n "$ctx7_key" ]]; then
        sed -i '' "s|\"CONTEXT7_API_KEY\": \"\"|\"CONTEXT7_API_KEY\": \"$ctx7_key\"|g" "$DOTFILES_DIR/amp/settings.json"
        # Claude Code MCPs are registered via `claude mcp add`, not settings.json
        sed -i '' "s|\"CONTEXT7_API_KEY\": \"\"|\"CONTEXT7_API_KEY\": \"$ctx7_key\"|g" "$DOTFILES_DIR/opencode/opencode.json"
        sed -i '' "s|CONTEXT7_API_KEY = \"\"|CONTEXT7_API_KEY = \"$ctx7_key\"|g" "$DOTFILES_DIR/codex/config.toml"
        echo "✓ Context7 API key set in config files"
    fi
}

# --- Module definitions ---

MODULE_NAMES=(
    "Shell"
    "Neovim"
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
    "SSH & Security"
    "Forge"
)

MODULE_DESCRIPTIONS=(
    "Oh My Zsh + .zshrc"
    "neovim + config"
    "tmux + config"
    "lazygit"
    "Amp + config"
    "Codex + config, skills, agents"
    "OpenCode + config"
    "Claude Code, Claude Desktop + configs"
    "Pi + specialist skills"
    "Cursor IDE"
    "Ghostty + config"
    "GWS CLI, gcloud + credentials"
    "Agentation MCP + skills for AI tools"
    "SSH config, 1Password socket"
    "Forge CLI + skills, gstack, zsh integration"
)

# --- Run a module by index (0-based) ---

run_module() {
    local idx="$1"
    echo ""
    echo "--- ${MODULE_NAMES[$idx]} ---"
    case "$idx" in
        0) install_shell; config_shell ;;
        1) install_neovim; config_neovim ;;
        2) install_tmux; config_tmux ;;
        3) install_git_tools ;;
        4) install_amp; config_amp ;;
        5) install_codex; config_codex ;;
        6) install_opencode; config_opencode ;;
        7) install_bun; install_claude; config_claude ;;
        8) install_pi; config_pi ;;
        9) install_cursor ;;
        10) install_terminal; config_terminal ;;
        11) install_google_cloud; config_google_cloud ;;
        12) install_agentation ;;
        13) config_ssh ;;
        14) install_forge; config_forge ;;
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
    chosen=$(printf '%s\n' "${options[@]}" | gum choose --no-limit --selected="${options[0]}","${options[1]}","${options[2]}","${options[3]}","${options[4]}","${options[5]}","${options[6]}","${options[7]}","${options[8]}","${options[9]}","${options[10]}","${options[11]}","${options[12]}","${options[13]}","${options[14]}" --cursor-prefix="[ ] " --selected-prefix="[x] " --unselected-prefix="[ ] " --header="") || { echo "Aborted."; return 1; }

    [[ -z "$chosen" ]] && { echo "No modules selected. Aborted."; return 1; }

    echo ""
    echo "Setting up dotfiles from: $DOTFILES_DIR"
    echo ""

    local any_ai=0
    local has_gcloud=0
    for i in $(seq 0 $((num_modules - 1))); do
        if echo "$chosen" | grep -qF "${MODULE_NAMES[$i]}"; then
            run_module "$i"
            if [[ "$i" -ge 4 && "$i" -le 8 ]] || [[ "$i" -eq 12 ]]; then
                any_ai=1
            fi
            if [[ "$i" -eq 11 ]]; then
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

    IFS=',' read -ra parts <<< "$input"
    for part in "${parts[@]}"; do
        part="$(echo "$part" | tr -d ' ')"
        if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            local start="${BASH_REMATCH[1]}"
            local end="${BASH_REMATCH[2]}"
            for num in $(seq "$start" "$end"); do
                if [[ "$num" -ge 1 && "$num" -le 15 ]]; then
                    local idx=$((num - 1))
                    if [[ "${sel_ref[$idx]}" -eq 1 ]]; then
                        sel_ref[$idx]=0
                    else
                        sel_ref[$idx]=1
                    fi
                fi
            done
        elif [[ "$part" =~ ^[0-9]+$ ]]; then
            if [[ "$part" -ge 1 && "$part" -le 15 ]]; then
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
    local selected=(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
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

                if [[ "${selected[4]}" -eq 1 || "${selected[5]}" -eq 1 || "${selected[6]}" -eq 1 || "${selected[7]}" -eq 1 || "${selected[8]}" -eq 1 || "${selected[12]}" -eq 1 ]]; then
                    apply_env_keys
                fi

                echo ""
                echo "Next steps:"
                echo "  1. Run 'source ~/.zshrc'"
                if [[ "${selected[11]}" -eq 1 ]]; then
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
