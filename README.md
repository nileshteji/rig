<div align="center">

# `rig`

**My development environment, one command away.**

[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Neovim](https://img.shields.io/badge/neovim-%2357A143.svg?style=for-the-badge&logo=neovim&logoColor=white)](https://neovim.io/)
[![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)
[![Tmux](https://img.shields.io/badge/tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=white)](https://github.com/tmux/tmux)
[![Shell](https://img.shields.io/badge/shell-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.zsh.org/)

<br>

*Opinionated macOS setup with Neovim, Tmux, Ghostty, AI coding tools, and an interactive installer that lets you pick exactly what you want.*

---

</div>

## Quick Start

```bash
git clone https://github.com/nileshteji/rig.git ~/rig
cd ~/rig
./install.sh
```

That's it. The installer walks you through everything.

<br>

## How It Works

The installer gives you a **interactive menu** powered by [gum](https://github.com/charmbracelet/gum) — use arrow keys to navigate, spacebar to toggle, enter to confirm:

```
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

> **No gum?** No problem. Falls back to a number-based menu where you type `1,3,5` or `1-4` to toggle.
>
> **Want everything?** Run `./install.sh --all` for non-interactive mode.

<br>

## What's Inside

<table>
<tr>
<td width="50%">

### Dev Environment

| Module | What you get |
|--------|-------------|
| **Shell** | Zsh + Oh My Zsh + git aliases |
| **Neovim** | Lazy.nvim, LSP, Telescope, Harpoon, Treesitter, Gruvbox |
| **Tmux** | `C-a` prefix, minimal dark status bar |
| **Ghostty** | JetBrainsMono Nerd Font, tabbed titlebar |
| **Git Tools** | Lazygit TUI |

</td>
<td width="50%">

### AI & Cloud

| Module | What you get |
|--------|-------------|
| **Amp** | Config + MCP servers |
| **Codex** | Config, skills, agents |
| **OpenCode** | Config + MCP servers |
| **Claude** | Claude Code, Desktop, Cursor + agents |
| **Google Cloud** | GWS CLI + gcloud |
| **SSH** | 1Password agent socket |

</td>
</tr>
</table>

<br>

<details>
<summary><b>Directory Structure</b></summary>

```
rig/
  zsh/                .zshrc with git aliases, PATH setup
    .zshrc.local      Machine-specific secrets (gitignored)
  nvim/               Neovim config
    lua/nilesh/       Core modules (init, lazy, remap, set)
    after/            Filetype-specific settings
  tmux/               Tmux config
  ghostty/            Ghostty terminal config
  ssh/                SSH client config
  amp/                Amp settings + MCP servers
  codex/              Codex config, skills, agents
  opencode/           OpenCode config
  claude/             Claude Code settings, statusline, agents
  claude-desktop/     Claude Desktop config
  gws/                Google Workspace CLI setup
  iterm/              iTerm2 color preset (legacy)
  .env.example        Template for API keys
  install.sh          Interactive installer
```

</details>

<br>

## Secrets

> **Zero secrets in the repo.** API keys and private aliases live in two gitignored files.

| File | Contents | How it's used |
|------|----------|---------------|
| `.env` | API keys (e.g. `CONTEXT7_API_KEY=...`) | `install.sh` injects into AI tool configs |
| `zsh/.zshrc.local` | SSH aliases, DB passwords, exports | Sourced at the end of `.zshrc` |

**Setup:**

```bash
cp .env.example .env    # fill in your API keys
```

**Tip:** Store both files in [1Password](https://1password.com/) as secure notes. On a new machine, pull them down before running the installer.

<br>

## Key Bindings

<details>
<summary><b>Neovim</b></summary>

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

</details>

<details>
<summary><b>Tmux</b></summary>

| Key | Action |
|-----|--------|
| `C-a` | Prefix (replaces `C-b`) |
| `M-Arrow` | Resize panes |

</details>

<details>
<summary><b>Git Aliases (Zsh)</b></summary>

```
gs    git status            gp    git push origin
ga    git add .             gpl   git pull
gcm   git commit            gco   git checkout
gca   git commit --amend    gcb   git checkout -b
gd    git diff              gl    git log --oneline --graph
gds   git diff --staged     gpf   git push --force-with-lease
```

</details>

<br>

## Customization

<details>
<summary><b>Change Neovim Theme</b></summary>

Edit `nvim/lua/nilesh/lazy.lua`:

```lua
vim.cmd.colorscheme("gruvbox")  -- try "catppuccin", "tokyonight", "rose-pine"
```

</details>

<details>
<summary><b>Change Terminal Font</b></summary>

Edit `ghostty/config`:

```
font-family = "Your Font Name"
font-size = 14
```

</details>

<details>
<summary><b>Add LSP Servers</b></summary>

In `nvim/lua/nilesh/lazy.lua`, update mason-lspconfig:

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

</details>

<br>

## Requirements

| Requirement | Why |
|-------------|-----|
| **macOS** | Homebrew-based installer |
| [**JetBrainsMono Nerd Font**](https://www.nerdfonts.com/) | Icons in Neovim + Ghostty |
| [**1Password**](https://1password.com/) | SSH agent integration |

> `gum` and `Homebrew` are installed automatically by the installer if missing.

<br>

---

<div align="center">

Made by [Nilesh Teji](https://github.com/nileshteji)

</div>
