# Repository Guidelines

## Project Structure & Module Organization
This repository is a small dotfiles bundle. Top-level `install.sh` orchestrates setup. Configs live in:
- `nvim/`: Neovim config; Lua modules in `nvim/lua/nilesh/`, plugin lockfile in `nvim/lazy-lock.json`, and supplemental files under `nvim/after/` and `nvim/plugin/`.
- `zsh/.zshrc`: Zsh configuration.
- `ssh/config`: SSH client configuration.
- `ghostty/config`: Ghostty terminal configuration.

## Build, Test, and Development Commands
- `./install.sh`: Installs Homebrew, Oh My Zsh, Neovim, Amp, and Codex, then symlinks or copies configs into `~/.config`, `~/.zshrc`, and `~/.ssh`. On macOS it writes Ghostty config under `~/Library/Application Support`.
- No build step exists; edit files directly. For a quick smoke check, run `nvim +q` and ensure it opens without errors.

## Coding Style & Naming Conventions
- Shell: bash, 4-space indentation, double quotes for strings, and `set -e` at the top of scripts.
- Lua: 4-space indentation; prefer double quotes. Neovim modules are required via `require("nilesh.*")` from `nvim/init.lua`.
- Keep config filenames consistent (`config`, `.zshrc`) and use lowercase directory names.
- No formatter or linter is configured; match the existing style.

## Testing Guidelines
- No automated tests. Validate by checking symlinks and config parsing:
  - `ls -l ~/.config/nvim`
  - `ls -l ~/.zshrc`
  - `ssh -G github.com` (ensures `ssh/config` parses)
- For Neovim changes, open `nvim` and check `:Lazy` for plugin status.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative summaries (e.g., “Added Agent Sock”) without scopes or prefixes.
- PRs should include a brief summary, list of touched configs, and any manual verification performed.

## Security & Configuration Tips
- Do not commit secrets or tokens. Keep private keys outside the repo and reference them from `~/.ssh/config`.
- The installer sets permissions for `~/.ssh/config` and links the 1Password agent socket; keep those steps intact.
