SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
export PATH := /opt/homebrew/bin:/usr/local/bin:$(PATH)

DOTFILES_DIR := $(CURDIR)
CONFIG_DIR := $(HOME)/.config
SKILLS_DIR := $(DOTFILES_DIR)/skills
AGENT_SKILLS_DIR := $(HOME)/.agents/skills

define link_path
	@source_path="$(1)"; \
	target_path="$(2)"; \
	label="$(3)"; \
	mkdir -p "$$(dirname "$$target_path")"; \
	if [[ -L "$$target_path" || -f "$$target_path" ]]; then \
		rm -f "$$target_path"; \
	elif [[ -d "$$target_path" ]]; then \
		mv "$$target_path" "$$target_path.backup.$$(date +%s)"; \
	fi; \
	ln -s "$$source_path" "$$target_path"; \
	echo "✓ $$label linked"
endef

.PHONY: all install homebrew git python zsh nvim ghostty vscode amp pi claude codex skills configs \
	config-zsh config-nvim config-ghostty config-amp config-codex config-claude config-pi \
	default-shell check
.NOTPARALLEL:

all: install

install:
	@bash ./install.sh --default

homebrew:
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	else \
		echo "✓ Homebrew already installed"; \
	fi

git: homebrew
	@if ! brew list git >/dev/null 2>&1; then \
		echo "Installing Git..."; \
		brew install git; \
	else \
		echo "✓ Git already installed"; \
	fi

python: homebrew
	@if ! brew list python >/dev/null 2>&1; then \
		echo "Installing Python..."; \
		brew install python; \
	else \
		echo "✓ Python already installed"; \
	fi

zsh: homebrew config-zsh
	@if ! brew list zsh >/dev/null 2>&1; then \
		echo "Installing Zsh..."; \
		brew install zsh; \
	else \
		echo "✓ Zsh already installed"; \
	fi
	@if [[ ! -d "$(HOME)/.oh-my-zsh" ]]; then \
		echo "Installing Oh My Zsh..."; \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
	else \
		echo "✓ Oh My Zsh already installed"; \
	fi

nvim: homebrew config-nvim
	@if ! command -v nvim >/dev/null 2>&1; then \
		echo "Installing Neovim..."; \
		brew install neovim; \
	else \
		echo "✓ Neovim already installed"; \
	fi

ghostty: homebrew config-ghostty
	@if command -v ghostty >/dev/null 2>&1 || [[ -d "/Applications/Ghostty.app" ]] || [[ -d "$(HOME)/Applications/Ghostty.app" ]]; then \
		echo "✓ Ghostty already installed"; \
	else \
		echo "Installing Ghostty..."; \
		brew install --cask ghostty; \
	fi

vscode: homebrew
	@if command -v code >/dev/null 2>&1 || [[ -d "/Applications/Visual Studio Code.app" ]] || brew list --cask visual-studio-code >/dev/null 2>&1; then \
		echo "✓ Visual Studio Code already installed"; \
	else \
		echo "Installing Visual Studio Code..."; \
		brew install --cask visual-studio-code; \
	fi

amp: config-amp
	@if ! command -v amp >/dev/null 2>&1; then \
		echo "Installing Amp..."; \
		curl -fsSL https://ampcode.com/install.sh | bash; \
	else \
		echo "✓ Amp already installed"; \
	fi

pi: homebrew config-pi
	@if ! command -v node >/dev/null 2>&1; then \
		echo "Installing Node.js for Pi..."; \
		brew install node; \
	fi
	@if ! command -v pi >/dev/null 2>&1; then \
		echo "Installing Pi..."; \
		npm install -g @mariozechner/pi-coding-agent; \
	else \
		echo "✓ Pi already installed"; \
	fi

claude: homebrew config-claude
	@if ! command -v node >/dev/null 2>&1; then \
		echo "Installing Node.js for Claude..."; \
		brew install node; \
	fi
	@if ! command -v claude >/dev/null 2>&1; then \
		echo "Installing Claude Code..."; \
		curl -fsSL https://claude.ai/install.sh | bash; \
	else \
		echo "✓ Claude Code already installed"; \
	fi

codex: homebrew config-codex
	@if ! command -v codex >/dev/null 2>&1; then \
		echo "Installing Codex..."; \
		brew install --cask codex; \
	else \
		echo "✓ Codex already installed"; \
	fi

skills:
	@echo "Setting up shared skills in $(AGENT_SKILLS_DIR)..."
	@mkdir -p "$(AGENT_SKILLS_DIR)"
	@for skill_path in "$(SKILLS_DIR)"/* "$(SKILLS_DIR)"/.[!.]*; do \
		[[ -e "$$skill_path" ]] || continue; \
		skill_name="$$(basename "$$skill_path")"; \
		[[ "$$skill_name" == ".git" || "$$skill_name" == ".DS_Store" ]] && continue; \
		if [[ ! -d "$$skill_path" && "$$skill_name" != *.zip ]]; then \
			continue; \
		fi; \
		target_path="$(AGENT_SKILLS_DIR)/$$skill_name"; \
		if [[ -L "$$target_path" ]]; then \
			rm -f "$$target_path"; \
		elif [[ -e "$$target_path" ]]; then \
			echo "  Skipping existing non-symlink: $$target_path"; \
			continue; \
		fi; \
		ln -s "$$skill_path" "$$target_path"; \
		echo "✓ Skill linked: $$skill_name"; \
	done

configs: config-zsh config-nvim config-ghostty config-amp config-codex config-claude config-pi

config-zsh:
	$(call link_path,$(DOTFILES_DIR)/zsh/.zshrc,$(HOME)/.zshrc,zsh config)

config-nvim:
	$(call link_path,$(DOTFILES_DIR)/nvim,$(CONFIG_DIR)/nvim,Neovim config)

config-ghostty:
	@if [[ "$${OSTYPE:-}" == darwin* ]]; then \
		ghostty_dir="$(HOME)/Library/Application Support/com.mitchellh.ghostty"; \
	else \
		ghostty_dir="$(CONFIG_DIR)/ghostty"; \
	fi; \
	mkdir -p "$$ghostty_dir"; \
	if [[ -L "$$ghostty_dir/config" || -f "$$ghostty_dir/config" ]]; then \
		rm -f "$$ghostty_dir/config"; \
	fi; \
	ln -s "$(DOTFILES_DIR)/ghostty/config" "$$ghostty_dir/config"; \
	echo "✓ Ghostty config linked"

config-amp:
	$(call link_path,$(DOTFILES_DIR)/amp/settings.json,$(CONFIG_DIR)/amp/settings.json,Amp config)

config-codex: skills
	@mkdir -p "$(HOME)/.codex"
	$(call link_path,$(DOTFILES_DIR)/codex/config.toml,$(HOME)/.codex/config.toml,Codex config.toml)
	$(call link_path,$(DOTFILES_DIR)/codex/agents,$(HOME)/.codex/agents,Codex agents)
	$(call link_path,$(AGENT_SKILLS_DIR),$(HOME)/.codex/skills,Codex skills)
	@echo "✓ Codex config linked"

config-claude: skills
	@mkdir -p "$(HOME)/.claude"
	$(call link_path,$(DOTFILES_DIR)/claude/settings.json,$(HOME)/.claude/settings.json,Claude settings.json)
	$(call link_path,$(DOTFILES_DIR)/claude/statusline-command.sh,$(HOME)/.claude/statusline-command.sh,Claude statusline script)
	$(call link_path,$(DOTFILES_DIR)/claude/agents,$(HOME)/.claude/agents,Claude agents)
	$(call link_path,$(AGENT_SKILLS_DIR),$(HOME)/.claude/skills,Claude skills)
	@echo "✓ Claude config linked"

config-pi: skills
	@mkdir -p "$(HOME)/.pi/agent"
	$(call link_path,$(DOTFILES_DIR)/pi/AGENTS.md,$(HOME)/.pi/agent/AGENTS.md,Pi AGENTS.md)
	$(call link_path,$(AGENT_SKILLS_DIR),$(HOME)/.pi/agent/skills,Pi skills)
	@echo "✓ Pi config linked"

default-shell:
	@zsh_path="$$(command -v zsh)"; \
	if [[ "$${SHELL:-}" == "$$zsh_path" ]]; then \
		echo "✓ Zsh is already the default shell"; \
	elif grep -qx "$$zsh_path" /etc/shells; then \
		chsh -s "$$zsh_path"; \
		echo "✓ Default shell changed to $$zsh_path"; \
	else \
		echo "Add $$zsh_path to /etc/shells, then run make default-shell again"; \
	fi

check:
	@command -v git >/dev/null && git --version
	@command -v python3 >/dev/null && python3 --version
	@command -v zsh >/dev/null && zsh --version
	@command -v nvim >/dev/null && nvim --version | head -n 1
	@command -v amp >/dev/null && amp --version || true
	@command -v pi >/dev/null && pi --version || true
	@command -v claude >/dev/null && claude --version || true
	@command -v codex >/dev/null && codex --version || true
	@echo "✓ Tool check complete"
