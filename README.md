# dotfiles

Personal development environment configuration for macOS.

```
./install.sh
```

## Structure

| Directory | Description |
|-----------|-------------|
| `nvim/` | Neovim config with Lazy.nvim, LSP, Telescope, Harpoon, Treesitter, and Gruvbox theme |
| `zsh/` | Zsh aliases for git workflow and server shortcuts |
| `tmux/` | Tmux config with `C-a` prefix and minimal dark status bar |
| `ghostty/` | Ghostty terminal (JetBrainsMono Nerd Font, tabs titlebar) |
| `ssh/` | SSH client config with 1Password agent integration |
| `iterm/` | iTerm2 color preset (legacy) |

## What Gets Installed

The installer handles dependencies and symlinks everything:

- **Homebrew** → package manager
- **Neovim** → `~/.config/nvim`
- **Tmux** → `~/.tmux.conf`
- **Zsh** → `~/.zshrc`
- **SSH** → `~/.ssh/config`
- **Ghostty** → `~/Library/Application Support/ghostty/config`
- **1Password** → SSH agent socket at `~/.1password/agent.sock`

Also installs: Amp, Codex, Claude, Cursor

## Key Bindings

### Neovim

| Key | Action |
|-----|--------|
| `<leader>pf` | Find files |
| `<C-p>` | Git files |
| `<leader>ps` | Grep search |
| `<leader>a` | Add to Harpoon |
| `<C-e>` | Harpoon menu |
| `<C-h/t/n/s>` | Jump to Harpoon 1-4 |
| `<leader>gs` | Git status (Fugitive) |
| `<leader>u` | Undotree |
| `gd` | Go to definition |
| `K` | Hover docs |
| `<leader>vca` | Code actions |
| `<leader>vrn` | Rename symbol |

### Tmux

| Key | Action |
|-----|--------|
| `C-a` | Prefix (replaces `C-b`) |
| `M-Arrow` | Resize panes |

### Git Aliases (Zsh)

```
gs    → git status          gp   → git push origin
ga    → git add .           gpl  → git pull
gcm   → git commit          gco  → git checkout
gca   → git commit --amend  gcb  → git checkout -b
gd    → git diff            gl   → git log --oneline --graph
```

## Customization

### Change Theme

Edit `nvim/lua/nilesh/lazy.lua` and modify the colorscheme setup:

```lua
vim.cmd.colorscheme("gruvbox")  -- change to "catppuccin", "tokyonight", etc.
```

### Change Font

Edit `ghostty/config`:

```
font-family = "Your Font Name"
font-size = 14
```

### Add LSP Servers

In `nvim/lua/nilesh/lazy.lua`, update mason-lspconfig:

```lua
ensure_installed = {
    'kotlin_language_server',
    'lua_ls',
    'tsserver',  -- add more here
},
```

Then enable in lspconfig section:

```lua
vim.lsp.enable('tsserver')
```

## Requirements

- macOS (uses Homebrew)
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)
- [1Password](https://1password.com/) (for SSH agent)

---

<p align="center">
  <img src="https://img.shields.io/badge/neovim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white" alt="Neovim"/>
  <img src="https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white" alt="Lua"/>
  <img src="https://img.shields.io/badge/tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=white" alt="Tmux"/>
</p>
