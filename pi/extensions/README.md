# Pi Extensions

This directory contains extensions for the Pi coding agent that will be automatically installed when you run the dotfiles installer.

## How It Works

The `install.sh` script reads the `manifest.txt` file and installs each extension using `pi install`. Extensions are installed globally to `~/.pi/agent/git/` for git-based packages or `~/.pi/agent/npm/` for npm packages.

## Adding Extensions

To add a new extension:

1. Edit `manifest.txt`
2. Add the extension on a new line using one of these formats:
   - `git:github.com/user/repo@version` (git repository)
   - `npm:@scope/package@version` (npm package)
   - `/absolute/path/to/extension` (local path)
   - `./relative/path/to/extension` (relative path)

3. Re-run the installer: `./install.sh` and select the "Pi" module

## Removing Extensions

To remove an extension:

1. Edit `manifest.txt` and remove the line
2. Run: `pi remove <extension-id>` (e.g., `pi remove git:github.com/xRyul/pi-nvidia-nim`)

## Current Extensions

- **pi-nvidia-nim**: NVIDIA NIM API provider extension - access 100+ models from build.nvidia.com including DeepSeek V3.2, Kimi K2.5, MiniMax M2.1, GLM-5, GLM-4.7, Qwen3, Llama 4, and many more.

- **@ollama/pi-web-search**: Web search and fetch tools for pi - uses your local Ollama instance's web search and fetch APIs. Provides `web_search` and `web_fetch` tools. Requires Ollama running locally.

- **pi-auto-theme**: Automatically switches between light and dark themes based on your system's appearance settings.

## Notes

- Extensions run with full system access. Only install from sources you trust.
- After installation, you may need to set environment variables (e.g., `NVIDIA_NIM_API_KEY` for the NVIDIA NIM extension).
- Use `pi list` to see installed packages.
- Use `pi update` to update all non-pinned packages.
