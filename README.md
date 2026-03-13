# rig

My development environment, one command away.

## Quick Start

```bash
git clone https://github.com/nileshteji/rig.git ~/rig
cd ~/rig
./install.sh
```

Use arrow keys + spacebar to pick what you need, then hit enter.

```
Dotfiles Installer
==================
Homebrew will be installed automatically.

Use arrow keys to navigate, spacebar to toggle, enter to confirm:

  [x]  1. Shell              (Oh My Zsh + .zshrc)
  [x]  2. Neovim             (neovim + config)
  [x]  3. Tmux               (tmux + config)
  [x]  4. Git Tools          (lazygit)
  [x]  5. Amp                (Amp + config)
  [x]  6. Codex              (Codex + config, skills, agents)
  [x]  7. OpenCode           (OpenCode + config)
  [x]  8. Claude             (Claude Code, Cursor, Claude Desktop + configs)
  [x]  9. Terminal            (Ghostty + config)
  [x] 10. Google Cloud       (GWS CLI, gcloud + credentials)
  [x] 11. SSH & Security     (SSH config, 1Password socket)
```

For CI or scripted setups, install everything non-interactively:

```bash
./install.sh --all
```

## Secrets

Secrets are never committed. Two files (both gitignored) hold everything:

| File | What goes in it | Used by |
|------|----------------|---------|
| `.env` | `CONTEXT7_API_KEY=...` | `install.sh` injects into Amp, Claude, Codex, OpenCode configs |
| `zsh/.zshrc.local` | SSH aliases, DB passwords, API keys | Sourced at the end of `.zshrc` |

Copy `.env.example` to `.env` and fill in your keys:

```bash
cp .env.example .env
```

Save both `.env` and `zsh/.zshrc.local` in 1Password. On a new machine, pull them down before running the installer.

## What's Inside

```
zsh/              .zshrc with git aliases, PATH setup
  .zshrc.local    Machine-specific secrets (gitignored)
nvim/             Neovim config — Lazy.nvim, LSP, Telescope, Harpoon, Gruvbox
tmux/             Tmux with C-a prefix, minimal dark status bar
ghostty/          Ghostty terminal — JetBrainsMono Nerd Font
ssh/              SSH client config with 1Password agent
amp/              Amp AI coding tool config
codex/            Codex config, skills, and agents
opencode/         OpenCode config
claude/           Claude Code settings, statusline, agents
claude-desktop/   Claude Desktop config
gws/              Google Workspace CLI setup
iterm/            iTerm2 color preset (legacy)
.env              API keys (gitignored)
.env.example      Template for .env
install.sh        Interactive installer
```

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

### Git Aliases

```
gs    git status          gp   git push origin
ga    git add .           gpl  git pull
gcm   git commit          gco  git checkout
gca   git commit --amend  gcb  git checkout -b
gd    git diff            gl   git log --oneline --graph
```

## Customization

### Theme

Edit `nvim/lua/nilesh/lazy.lua`:

```lua
vim.cmd.colorscheme("gruvbox")  -- change to "catppuccin", "tokyonight", etc.
```

### Font

Edit `ghostty/config`:

```
font-family = "Your Font Name"
font-size = 14
```

### LSP Servers

In `nvim/lua/nilesh/lazy.lua`, add to mason-lspconfig:

```lua
ensure_installed = {
    'kotlin_language_server',
    'lua_ls',
    'tsserver',  -- add more here
},
```

Then enable:

```lua
vim.lsp.enable('tsserver')
```

## Requirements

- macOS (Homebrew-based)
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)
- [1Password](https://1password.com/) for SSH agent
- [gum](https://github.com/charmbracelet/gum) for the interactive menu (auto-installed if you have Homebrew)

---

<p align="center">
  <img src="https://img.shields.io/badge/neovim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white" alt="Neovim"/>
  <img src="https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white" alt="Lua"/>
  <img src="https://img.shields.io/badge/tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=white" alt="Tmux"/>
</p>
