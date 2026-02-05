# Repository Guidelines

## Project Structure & Module Organization
This repository is a small dotfiles bundle for macOS. Top-level `install.sh` orchestrates setup. Configs live in:
- `nvim/`: Neovim config; Lua modules in `nvim/lua/nilesh/` (init.lua, lazy.lua, remap.lua, set.lua), plugin lockfile in `nvim/lazy-lock.json`, and supplemental files under `nvim/after/` and `nvim/plugin/`.
- `zsh/.zshrc`: Zsh configuration with git aliases and SSH shortcuts.
- `ssh/config`: SSH client configuration with 1Password agent integration.
- `ghostty/config`: Ghostty terminal configuration.
- `tmux/.tmux.conf`: Tmux configuration with `C-a` prefix.
- `amp/`, `codex/`, `claude/`, `opencode/`: AI tool configurations.

## Build, Test, and Development Commands
- `./install.sh`: Installs Homebrew, Oh My Zsh, Neovim, Tmux, Amp, Codex, Claude, Cursor, and Ghostty, then symlinks or copies configs into `~/.config`, `~/.zshrc`, and `~/.ssh`. On macOS it writes Ghostty config under `~/Library/Application Support`.
- `nvim +q`: Quick smoke test to ensure Neovim loads without errors.
- `nvim --headless +'checkhealth' +qa`: Run Neovim health checks to verify plugins and LSP servers.
- Inside Neovim:
  - `:Lazy` to check plugin status and updates.
  - `:TSUpdate` to update Treesitter parsers.
  - `:Mason` to view and manage LSP servers and tools.
  - `:checkhealth` to diagnose configuration issues.
- No automated test suite exists. Validate by:
  - `ls -l ~/.config/nvim` (symlink check)
  - `ls -l ~/.zshrc` (symlink check)
  - `ssh -G github.com` (ensure `ssh/config` parses)
  - Open Neovim and verify plugin loading and LSP servers start correctly.

## Coding Style & Naming Conventions

### Shell Scripts (Bash)
- Use 4-space indentation (not tabs).
- Always start scripts with `set -e` for error handling.
- Use double quotes around variable expansions (`"$VAR"`) to prevent word splitting.
- Prefer `[[` over `[` for conditionals.
- Use `$OSTYPE` checks for macOS-specific paths: `[[ "$OSTYPE" == "darwin"* ]]`.
- Use lowercase snake_case for function names: `backup_file()`, `backup_dir()`.
- Use uppercase with underscores for constants: `DOTFILES_DIR`, `GHOSTTY_CONFIG_DIR`.
- Comment briefly above code blocks; `#` followed by space.

### Lua (Neovim Configuration)
- Use 4-space indentation (not tabs).
- Prefer double quotes for strings (`require("nilesh.set")` over `require('nilesh.set')`).
- Module structure: Core modules in `nvim/lua/nilesh/` loaded via `require("nilesh.*")`.
- Use `vim.opt` for Neovim 0.11+ options: `vim.opt.nu = true` not `vim.wo.number = true`.
- Use `vim.keymap.set()` for keybindings: `vim.keymap.set("n", "<leader>pf", builtin.find_files)`.
- Keybind opts table: `{ buffer = bufnr, remap = false }` for buffer-local bindings.
- LSP configuration: Use `vim.lsp.config()` and `vim.lsp.enable()` in Neovim 0.11+.
- Plugin setup functions: use table notation `{ key = val, ... }` over positional args.
- Use `build = ':TSUpdate'` for plugins that require compiling (like Treesitter).
- Use `tag = 'v0.2.0'` for stable plugin versions; `branch = "main"` for development branches.
- Autocommands: Use `vim.api.nvim_create_autocmd()` with group and pattern specifications.
- Avoid inline comments; prefer clear function names and grouping.
- LuaSnippet snippets: Place in `~/.config/nvim/snippets/` directory as `.lua` files.

### Zsh Configuration
- Keep `.zshrc` focused: Oh My Zsh theme first, then aliases, then exports.
- Short, intuitive git aliases: `gs` for status, `gp` for push, `gc` for commit variants.
- Group related aliases: git aliases together, SSH shortcuts together.
- Use `export VAR=value` with quotes when values contain spaces.
- Comments at top of sections only; keep file scannable.

### SSH Configuration
- Group related blocks: host-specific settings together.
- Use `Host` directive for server shortcuts with memorable names.
- Include `IdentityAgent` and `IdentitiesOnly` for 1Password integration.
- Use `~/.ssh/key-name` paths (not absolute paths).
- Set `User` directive to `git` for GitHub/Bitbucket hosts.
- Wildcard (`Host *`) defaults at the end.

### TMUX Configuration
- Use lowercase `set -g` for global options.
- Comment sections with `#` and space.
- Keep status bar config consolidated.

### JSON Configuration Files
- Use standard JSON format (no trailing commas).
- Include `$schema` at top when available for validation.
- 2-space indentation for readability.

## Error Handling
- Shell: Functions return nonzero on failure; `set -e` handles most cases.
- Check for existing files before symlinking: use `backup_file()` and `backup_dir()` helper functions.
- For Neovim, use `pcall` or `xpcall` for risky operations in custom Lua modules.
- SSH config: Verify syntax with `ssh -F <config-file> -G <hostname>` before deploying.
- Lua configs: Lazy.nvim will report plugin errors; run `:Lazy sync` to fix issues.

## Import & Require Patterns
- Lua: Use `require("nilesh.module")` pattern for internal modules.
- Lazy.nvim: Define plugins in `nvim/lua/nilesh/lazy.lua`; use tag for stable versions (`tag = 'v0.2.0'`).
- Plugin configs: Inline `config = function()` setup inside plugin table.

## Adding Plugins and LSP Servers
To add a new Neovim plugin:
1. Add plugin table to `nvim/lua/nilesh/lazy.lua` array
2. Include `tag` or `branch` for version stability
3. Use `dependencies` array for related plugins
4. Define keybindings inside `config` function

To add a new LSP server:
1. Add server name to `ensure_installed` in mason-lspconfig section:
   ```lua
   ensure_installed = { 'kotlin_language_server', 'lua_ls', 'tsserver' }
   ```
2. Enable the server in lspconfig section:
   ```lua
   vim.lsp.enable('kotlin_language_server')
   ```

## Testing Guidelines
- No automated tests. Manual validation via symlink checks and tool launches.
- For Neovim changes: open nvim, run `:Lazy` to verify plugin sync, test keybindings.
- For shell changes: source the file or re-run install script in dry-run mode.
- After modifying configs: restart the affected tool or reload config (e.g., `source ~/.zshrc`).

## Commit & Pull Request Guidelines
- Commit messages: short, imperative summaries without scope prefixes (e.g., "Fix SSH agent path", "Add Kotlin LSP").
- PR description: brief summary, list of touched files/configs, manual verification steps.
- When committing changes to `install.sh`, test on a clean macOS system first if possible.

## Security & Configuration Tips
- Never commit secrets, API keys, or private keys to this repo.
- Keep SSH private keys outside the repo; reference them in `ssh/config`.
- The installer sets `chmod 600` on `~/.ssh/config`; preserve this permission scheme.
- 1Password agent socket link at `~/.1password/agent.sock` should remain intact.
- Remove or redact any sensitive IPs, passwords, or tokens before committing changes.
- When modifying `install.sh`, test symlink creation in a temporary directory first.

## File Conventions
- Config filenames are lowercase: `config`, `.zshrc`, `.tmux.conf`, `opencode.json`.
- Directory names are lowercase: `nvim/`, `zsh/`, `ssh/`, `ghostty/`, `tmux/`.
- Lua filenames are lowercase and descriptive: `set.lua`, `remap.lua`, `lazy.lua`.
- Hidden config dirs use dot prefix: `.claude/`, `.opencode/` (symlinked to config location).
- No trailing whitespace; keep line length reasonable (~80-100 chars for readability).
