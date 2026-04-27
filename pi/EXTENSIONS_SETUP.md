# Pi Extensions Setup

## Overview

This setup automatically installs Pi extensions when you run the dotfiles installer. Extensions are managed through a manifest file in `pi/extensions/manifest.txt`.

## What's New

### Directory Structure

```
pi/
├── AGENTS.md              # Pi agent instructions
└── extensions/            # NEW: Extensions directory
    ├── README.md          # Documentation for extensions
    └── manifest.txt       # List of extensions to install
```

### Files Added

1. **`pi/extensions/manifest.txt`** - Lists extensions to install
2. **`pi/extensions/README.md`** - Documentation for managing extensions

### Scripts Updated

1. **`install.sh`** - Added `install_pi_extensions()` function
2. **`removal.sh`** - Added `remove_pi_extensions()` function

## How It Works

### Installation

When you run `./install.sh` and select the "Pi" module:

1. The script reads `pi/extensions/manifest.txt`
2. For each line in the manifest, it runs `pi install <extension>`
3. Extensions are installed globally to `~/.pi/agent/git/` or `~/.pi/agent/npm/`

### Removal

When you run `./removal.sh` and select the "Pi" module:

1. The script reads `pi/extensions/manifest.txt`
2. For each line in the manifest, it runs `pi remove <extension>`
3. Extensions are removed from your Pi installation

## Adding Extensions

To add a new extension:

1. Edit `pi/extensions/manifest.txt`
2. Add the extension on a new line:

   ```bash
   # Git repository
   git:github.com/user/repo@version

   # NPM package
   npm:@scope/package@version

   # Local path
   /absolute/path/to/extension
   ```

3. Re-run the installer: `./install.sh` and select "Pi"

## Current Extensions

- **pi-nvidia-nim** (`git:github.com/xRyul/pi-nvidia-nim`)
  - NVIDIA NIM API provider extension
  - Access 100+ models from build.nvidia.com
  - Includes DeepSeek V3.2, Kimi K2.5, MiniMax M2.1, GLM-5, GLM-4.7, Qwen3, Llama 4, and more

- **@ollama/pi-web-search** (`npm:@ollama/pi-web-search`)
  - Web search and fetch tools for pi
  - Uses your local Ollama instance's web search and fetch APIs
  - Provides `web_search` and `web_fetch` tools
  - Requires Ollama running locally with web search enabled

- **pi-auto-theme** (`npm:pi-auto-theme`)
  - Automatically switches between light and dark themes
  - Follows your system's appearance settings

## Setup After Installation

After installing the NVIDIA NIM extension, you need to set your API key:

```bash
export NVIDIA_NIM_API_KEY=nvapi-your-key-here
```

Add this to your `~/.zshrc` or shell profile to persist it.

## Usage

Once installed, NVIDIA NIM models appear in the `/model` selector under the `nvidia-nim` provider:

- Press **Ctrl+L** to open the model selector
- Search for `nvidia-nim`
- Use `/scoped-models` to pin your favorite NIM models

### CLI Examples

```bash
# Use a specific NIM model
pi --provider nvidia-nim --model "deepseek-ai/deepseek-v3.2"

# With thinking enabled
pi --provider nvidia-nim --model "deepseek-ai/deepseek-v3.2" --thinking low

# Limit model cycling to NIM models
pi --models "nvidia-nim/*"
```

### Using Web Search (Ollama)

The `@ollama/pi-web-search` extension provides two tools:

- **`web_search`** - Search the web for real-time information
- **`web_fetch`** - Fetch and extract content from a web page URL

**Requirements:**
- Ollama must be running locally: `ollama serve`
- Web search must be enabled in Ollama

**Usage:**
```bash
# Start Ollama if not running
ollama serve &

# Use pi with web search capabilities
pi

# In pi, you can now ask things like:
# "Search for the latest news about AI"
# "Fetch the content from https://example.com"
```

**Testing web search:**
```bash
# Test if Ollama web search is working
curl -X POST http://localhost:11434/api/experimental/web_search \
  -H "Content-Type: application/json" \
  -d '{"query":"test","max_results":1}'
```

## Managing Extensions

### List installed extensions

```bash
pi list
```

### Update all extensions

```bash
pi update
```

### Remove a specific extension

```bash
pi remove git:github.com/xRyul/pi-nvidia-nim
```

### Try an extension without installing

```bash
pi -e git:github.com/user/repo
```

## Security Notes

- Extensions run with full system access
- Only install extensions from sources you trust
- Review the source code before installing third-party packages
- The NVIDIA NIM extension is free during the preview period (rate-limited)

## Troubleshooting

### Extension not appearing after installation

1. Check if the extension was installed: `pi list`
2. Try reloading: `pi` then press `/reload`
3. Check the extension's README for setup requirements

### API key errors

Make sure you've set the required environment variable:

```bash
echo $NVIDIA_NIM_API_KEY
```

### Rate limiting

NVIDIA NIM preview keys have rate limits. If you encounter 429 errors, wait a few minutes before trying again.

### Web search not working (Ollama)

If the `web_search` or `web_fetch` tools aren't working:

1. Make sure Ollama is running:
   ```bash
   pgrep -f ollama || ollama serve &
   ```

2. Test the Ollama web search API:
   ```bash
   curl -X POST http://localhost:11434/api/experimental/web_search \
     -H "Content-Type: application/json" \
     -d '{"query":"test","max_results":1}'
   ```

3. Check if you need to sign in to Ollama:
   ```bash
   ollama signin
   ```

4. Verify the extension is installed:
   ```bash
   pi list | grep ollama
   ```

5. Restart pi and try again
