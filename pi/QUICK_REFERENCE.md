# Pi Extensions - Quick Reference

## Installed Extensions

Your dotfiles now include three Pi extensions that will be automatically installed:

### 1. NVIDIA NIM (`git:github.com/xRyul/pi-nvidia-nim`)
- **Purpose:** Access 100+ AI models from build.nvidia.com
- **Models:** DeepSeek V3.2, Kimi K2.5, MiniMax M2.1, GLM-5, GLM-4.7, Qwen3, Llama 4, and more
- **Setup:** Set `NVIDIA_NIM_API_KEY` environment variable
- **Usage:** Press Ctrl+L in pi, search for `nvidia-nim`

### 2. Ollama Web Search (`npm:@ollama/pi-web-search`)
- **Purpose:** Web search and fetch tools using local Ollama
- **Tools:** `web_search`, `web_fetch`
- **Requirements:** Ollama running locally with web search enabled
- **Usage:** Ask pi to "search the web for X" or "fetch content from URL"

### 3. Auto Theme (`npm:pi-auto-theme`)
- **Purpose:** Automatically switch between light/dark themes
- **Behavior:** Follows your system's appearance settings
- **Setup:** No configuration needed

## Quick Start

### Install All Extensions
```bash
./install.sh
# Select "Pi" module
```

### Verify Installation
```bash
pi list
```

### Test Web Search
```bash
# Make sure Ollama is running
pgrep -f ollama || ollama serve &

# Test the API
curl -X POST http://localhost:11434/api/experimental/web_search \
  -H "Content-Type: application/json" \
  -d '{"query":"test","max_results":1}'
```

### Use in Pi
```bash
pi

# Then ask things like:
# "Search for the latest news about AI"
# "What's the current weather in Tokyo?"
# "Fetch the content from https://example.com"
```

## Managing Extensions

### Add a New Extension
Edit `pi/extensions/manifest.txt` and add:
```bash
git:github.com/user/repo
# or
npm:@scope/package@version
```

Then re-run `./install.sh` and select "Pi".

### Remove an Extension
Edit `pi/extensions/manifest.txt` and remove the line, then run:
```bash
./removal.sh
# Select "Pi" module
```

### List Installed Extensions
```bash
pi list
```

### Update Extensions
```bash
pi update
```

## Troubleshooting

### Web Search Not Working
```bash
# Check Ollama is running
pgrep -f ollama

# Start Ollama if needed
ollama serve &

# Test the API
curl -X POST http://localhost:11434/api/experimental/web_search \
  -H "Content-Type: application/json" \
  -d '{"query":"test"}'
```

### NVIDIA NIM Not Working
```bash
# Check API key is set
echo $NVIDIA_NIM_API_KEY

# Set it if needed
export NVIDIA_NIM_API_KEY=nvapi-your-key-here
```

### Extension Not Loading
```bash
# Check if installed
pi list | grep <extension-name>

# Try reloading in pi
pi
# Then press /reload
```

## File Locations

- **Manifest:** `pi/extensions/manifest.txt`
- **Documentation:** `pi/extensions/README.md`
- **Setup Guide:** `pi/EXTENSIONS_SETUP.md`
- **Pi Config:** `~/.pi/agent/settings.json`
- **Installed Extensions:** `~/.pi/agent/git/` and `~/.pi/agent/npm/`

## Security Notes

- Extensions run with full system access
- Only install from trusted sources
- Review code before installing third-party packages
- NVIDIA NIM is free during preview (rate-limited)
