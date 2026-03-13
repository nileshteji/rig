#!/bin/bash

# Dotfiles removal script - interactive module uninstaller
# Usage: ./removal.sh        (interactive menu)
#        ./removal.sh --all  (remove everything, non-interactive)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Utility functions ---

remove_symlink() {
    local target_path="$1"
    local label="$2"

    if [[ -L "$target_path" ]]; then
        rm -f "$target_path"
        echo "✓ Removed symlink $label ($target_path)"
    elif [[ -e "$target_path" ]]; then
        echo "  Skipped $label ($target_path is not a symlink)"
    else
        echo "  Skipped $label ($target_path does not exist)"
    fi
}

# --- Module removal functions ---

remove_shell() {
    echo "Removing Oh My Zsh..."
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        rm -rf "$HOME/.oh-my-zsh"
        echo "✓ Oh My Zsh removed"
    else
        echo "  Oh My Zsh not installed"
    fi

    remove_symlink "$HOME/.zshrc" "zshrc"
}

remove_neovim() {
    if command -v nvim &> /dev/null; then
        echo "Uninstalling Neovim..."
        brew uninstall neovim 2>/dev/null || true
        echo "✓ Neovim uninstalled"
    else
        echo "  Neovim not installed"
    fi

    remove_symlink "$HOME/.config/nvim" "nvim config"
}

remove_tmux() {
    if command -v tmux &> /dev/null; then
        echo "Uninstalling tmux..."
        brew uninstall tmux 2>/dev/null || true
        echo "✓ tmux uninstalled"
    else
        echo "  tmux not installed"
    fi

    remove_symlink "$HOME/.tmux.conf" "tmux config"
}

remove_git_tools() {
    if command -v lazygit &> /dev/null; then
        echo "Uninstalling Lazygit..."
        brew uninstall lazygit 2>/dev/null || true
        echo "✓ Lazygit uninstalled"
    else
        echo "  Lazygit not installed"
    fi
}

remove_amp() {
    if command -v amp &> /dev/null; then
        echo "Uninstalling Amp..."
        rm -f "$(command -v amp)" 2>/dev/null || true
        echo "✓ Amp uninstalled"
    else
        echo "  Amp not installed"
    fi

    remove_symlink "$HOME/.config/amp/settings.json" "Amp config"
}

remove_codex() {
    if command -v codex &> /dev/null; then
        echo "Uninstalling Codex..."
        brew uninstall --cask codex 2>/dev/null || true
        echo "✓ Codex uninstalled"
    else
        echo "  Codex not installed"
    fi

    remove_symlink "$HOME/.codex/config.toml" "Codex config.toml"
    remove_symlink "$HOME/.codex/skills" "Codex skills"
    remove_symlink "$HOME/.codex/agents" "Codex agents"
}

remove_opencode() {
    if command -v opencode &> /dev/null; then
        echo "Uninstalling OpenCode..."
        brew uninstall anomalyco/tap/opencode 2>/dev/null || true
        echo "✓ OpenCode uninstalled"
    else
        echo "  OpenCode not installed"
    fi

    remove_symlink "$HOME/.config/opencode/opencode.json" "OpenCode config"
    remove_symlink "$HOME/.config/.opencode" "OpenCode hidden config"
}

remove_claude() {
    if command -v claude &> /dev/null; then
        echo "Uninstalling Claude Code..."
        npm uninstall -g @anthropic-ai/claude-code 2>/dev/null || true
        echo "✓ Claude Code uninstalled"
    else
        echo "  Claude Code not installed"
    fi

    # Claude Code config symlinks
    remove_symlink "$HOME/.claude/settings.json" "Claude Code settings"
    remove_symlink "$HOME/.claude/statusline-command.sh" "Claude Code statusline script"
    remove_symlink "$HOME/.claude/agents" "Claude Code agents"

    # Claude Desktop config
    CLAUDE_DESKTOP_CONFIG_DIR="$HOME/Library/Application Support/Claude"
    remove_symlink "$CLAUDE_DESKTOP_CONFIG_DIR/claude_desktop_config.json" "Claude Desktop config"
}

remove_cursor() {
    if command -v cursor &> /dev/null; then
        echo "Uninstalling Cursor..."
        rm -f "$(command -v cursor)" 2>/dev/null || true
        echo "✓ Cursor uninstalled"
    else
        echo "  Cursor not installed"
    fi
}

remove_terminal() {
    if command -v ghostty &> /dev/null || [[ -d "/Applications/Ghostty.app" ]] || [[ -d "$HOME/Applications/Ghostty.app" ]]; then
        echo "Uninstalling Ghostty..."
        brew uninstall --cask ghostty 2>/dev/null || true
        echo "✓ Ghostty uninstalled"
    else
        echo "  Ghostty not installed"
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
        GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
    else
        GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
    fi

    remove_symlink "$GHOSTTY_CONFIG_DIR/config" "Ghostty config"
}

remove_google_cloud() {
    # Google Workspace CLI
    if command -v gws &> /dev/null; then
        echo "Uninstalling Google Workspace CLI..."
        brew uninstall googleworkspace-cli 2>/dev/null || true
        echo "✓ Google Workspace CLI uninstalled"
    else
        echo "  Google Workspace CLI not installed"
    fi

    # Google Cloud CLI
    if command -v gcloud &> /dev/null; then
        echo "Uninstalling Google Cloud CLI..."
        brew uninstall --cask gcloud-cli 2>/dev/null || true
        echo "✓ Google Cloud CLI uninstalled"
    else
        echo "  Google Cloud CLI not installed"
    fi

    # GWS credentials
    GWS_CREDENTIALS_TARGET="$HOME/.config/gws/credentials.json"
    if [[ -f "$GWS_CREDENTIALS_TARGET" ]]; then
        rm -f "$GWS_CREDENTIALS_TARGET"
        echo "✓ Removed GWS credentials ($GWS_CREDENTIALS_TARGET)"
    else
        echo "  GWS credentials not found"
    fi
}

remove_ssh() {
    remove_symlink "$HOME/.ssh/config" "SSH config"

    if [[ -L "$HOME/.1password/agent.sock" ]]; then
        rm -f "$HOME/.1password/agent.sock"
        echo "✓ Removed 1Password agent socket symlink"
    else
        echo "  1Password agent socket not found"
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
    "Cursor"
    "Terminal"
    "Google Cloud"
    "SSH & Security"
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
    "Cursor IDE"
    "Ghostty + config"
    "GWS CLI, gcloud + credentials"
    "SSH config, 1Password socket"
)

# --- Run a module by index (0-based) ---

run_module() {
    local idx="$1"
    echo ""
    echo "--- ${MODULE_NAMES[$idx]} ---"
    case "$idx" in
        0) remove_shell ;;
        1) remove_neovim ;;
        2) remove_tmux ;;
        3) remove_git_tools ;;
        4) remove_amp ;;
        5) remove_codex ;;
        6) remove_opencode ;;
        7) remove_claude ;;
        8) remove_cursor ;;
        9) remove_terminal ;;
        10) remove_google_cloud ;;
        11) remove_ssh ;;
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
    echo "Dotfiles Removal"
    echo "================"
    echo ""
    echo "Use arrow keys to navigate, spacebar to toggle, enter to confirm:"
    echo ""

    local chosen
    chosen=$(printf '%s\n' "${options[@]}" | gum choose --no-limit --cursor-prefix="[ ] " --selected-prefix="[x] " --unselected-prefix="[ ] " --header="") || { echo "Aborted."; return 1; }

    [[ -z "$chosen" ]] && { echo "No modules selected. Aborted."; return 1; }

    echo ""
    echo "The following will be removed:"
    echo "$chosen"
    echo ""

    if ! gum confirm "Proceed with removal?"; then
        echo "Aborted."
        return 1
    fi

    echo ""
    echo "Removing dotfiles..."
    echo ""

    for i in $(seq 0 $((num_modules - 1))); do
        if echo "$chosen" | grep -qF "${MODULE_NAMES[$i]}"; then
            run_module "$i"
        fi
    done

    echo ""
    echo "✓ All selected modules removed!"
}

# --- Interactive menu (fallback — number input) ---

show_menu() {
    local selected=("$@")
    echo ""
    echo "Dotfiles Removal"
    echo "================"
    echo ""
    echo "Toggle modules (e.g. 1  1,3,5  1-4  1,3-5,8), then press 'r' to remove:"
    echo ""
    for i in "${!MODULE_NAMES[@]}"; do
        if [[ "${selected[$i]}" -eq 1 ]]; then
            printf "  [x] %2d. %-18s (%s)\n" "$((i + 1))" "${MODULE_NAMES[$i]}" "${MODULE_DESCRIPTIONS[$i]}"
        else
            printf "  [ ] %2d. %-18s (%s)\n" "$((i + 1))" "${MODULE_NAMES[$i]}" "${MODULE_DESCRIPTIONS[$i]}"
        fi
    done
    echo ""
    echo "  a) Select All   n) Select None   r) Remove   q) Quit"
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
                if [[ "$num" -ge 1 && "$num" -le 12 ]]; then
                    local idx=$((num - 1))
                    if [[ "${sel_ref[$idx]}" -eq 1 ]]; then
                        sel_ref[$idx]=0
                    else
                        sel_ref[$idx]=1
                    fi
                fi
            done
        elif [[ "$part" =~ ^[0-9]+$ ]]; then
            if [[ "$part" -ge 1 && "$part" -le 12 ]]; then
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
    local selected=(0 0 0 0 0 0 0 0 0 0 0 0)
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
            r|R)
                local any_selected=0
                for i in $(seq 0 $((num_modules - 1))); do
                    if [[ "${selected[$i]}" -eq 1 ]]; then
                        any_selected=1
                        break
                    fi
                done

                if [[ "$any_selected" -eq 0 ]]; then
                    echo "No modules selected."
                    sleep 1
                    continue
                fi

                echo ""
                echo "The following will be removed:"
                for i in $(seq 0 $((num_modules - 1))); do
                    if [[ "${selected[$i]}" -eq 1 ]]; then
                        echo "  - ${MODULE_NAMES[$i]} (${MODULE_DESCRIPTIONS[$i]})"
                    fi
                done
                echo ""
                read -rp "Proceed with removal? (y/N): " confirm
                if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
                    echo "Aborted."
                    return 1
                fi

                echo ""
                echo "Removing dotfiles..."
                echo ""

                for i in $(seq 0 $((num_modules - 1))); do
                    if [[ "${selected[$i]}" -eq 1 ]]; then
                        run_module "$i"
                    fi
                done

                echo ""
                echo "✓ All selected modules removed!"
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
        fallback_menu
    fi
}

# --- Main ---

if [[ "$1" == "--all" ]]; then
    echo "Removing all dotfiles..."
    echo ""

    read -rp "This will remove ALL modules. Proceed? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        exit 1
    fi

    for i in $(seq 0 $((${#MODULE_NAMES[@]} - 1))); do
        run_module "$i"
    done

    echo ""
    echo "✓ All dotfiles removed!"
else
    interactive_menu
fi
