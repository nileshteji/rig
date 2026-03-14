# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository for macOS development environment. Manages configurations for Neovim, Zsh, Tmux, SSH, Ghostty terminal, and AI coding tools (Amp, Codex, Claude).

## Commands

- **Install everything**: `./install.sh` - Installs dependencies via Homebrew and symlinks all configs
- **Verify Neovim**: `nvim +q` - Quick smoke test that config loads without errors
- **Check plugin status**: Open nvim and run `:Lazy`
- **Verify symlinks**: `ls -l ~/.config/nvim`, `ls -l ~/.zshrc`
- **Test SSH config**: `ssh -G github.com`

## Structure

```
nvim/           → Neovim config (symlinked to ~/.config/nvim)
  lua/nilesh/   → Core Lua modules (init.lua, lazy.lua, remap.lua, set.lua)
  after/        → Filetype-specific settings
  lazy-lock.json → Plugin lockfile
zsh/.zshrc      → Zsh config (symlinked to ~/.zshrc)
tmux/.tmux.conf → Tmux config (symlinked to ~/.tmux.conf)
ssh/config      → SSH config (symlinked to ~/.ssh/config)
ghostty/config  → Terminal config (symlinked to ~/Library/Application Support/ghostty/config)
amp/settings.json → Amp AI config
codex/config.toml → Codex AI config (symlinked to ~/.codex/config.toml)
claude/settings.json → Claude Code config
  statusline-command.sh → Custom statusline script
  agents/              → User-level custom agents (symlinked to ~/.claude/agents)
  skills/              → User-level custom skills (symlinked to ~/.claude/skills)
agentation/install.sh → Standalone Agentation setup (MCP + skills for Claude & Codex)
```

## Coding Style

- **Shell**: Bash with `set -e`, 4-space indentation, double quotes for strings
- **Lua**: 4-space indentation, double quotes, modules loaded via `require("nilesh.*")`
- No formatter/linter configured; match existing style
- Commit messages: short, imperative (e.g., "Add SSH agent support")

## Neovim Architecture

Plugins managed by Lazy.nvim. Key modules in `nvim/lua/nilesh/`:
- `lazy.lua`: Plugin definitions and LSP setup (Mason, Treesitter, Telescope, Harpoon)
- `remap.lua`: Key mappings
- `set.lua`: Editor options

To add LSP servers: update `ensure_installed` in `lazy.lua` and call `vim.lsp.enable()`.

## gstack

Use the `/browse` skill from gstack for all web browsing. Never use `mcp__Claude_in_Chrome__*` tools.

Available skills: `/plan-ceo-review`, `/plan-eng-review`, `/review`, `/ship`, `/browse`, `/retro`

If gstack skills aren't working, run `cd .claude/skills/gstack && ./setup` to build the binary and register skills.
