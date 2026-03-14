#!/bin/bash

# Agentation setup script
# Installs agentation MCP server and skills for all supported AI coding tools.
# Usage: ./agentation/install.sh        (install for all detected tools)
#        ./agentation/install.sh claude  (install for Claude only)
#        ./agentation/install.sh codex   (install for Codex only)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_for_claude() {
    echo "Setting up Agentation for Claude Code..."

    # Install skill
    if command -v npx &> /dev/null; then
        npx skills add benjitaylor/agentation 2>/dev/null || true
        echo "✓ Agentation skill installed for Claude"
    else
        echo "✗ npx not found, skipping Claude skill install"
    fi

    # Add MCP server
    if command -v claude &> /dev/null; then
        claude mcp add agentation -- npx -y agentation-mcp server 2>/dev/null || true
        echo "✓ Agentation MCP server added to Claude"
    else
        echo "  Claude Code CLI not found, skipping MCP setup"
    fi
}

install_for_codex() {
    echo "Setting up Agentation for Codex..."

    # Install skill
    if command -v npx &> /dev/null; then
        npx skills add -a codex benjitaylor/agentation 2>/dev/null || true
        echo "✓ Agentation skill installed for Codex"
    else
        echo "✗ npx not found, skipping Codex skill install"
    fi

    # MCP server config is in codex/config.toml — not managed here
    echo "  Note: Agentation MCP server for Codex should be configured in codex/config.toml"
}

install_all() {
    echo ""
    echo "=== Agentation Setup ==="
    echo ""

    if command -v claude &> /dev/null; then
        install_for_claude
        echo ""
    fi

    if command -v codex &> /dev/null; then
        install_for_codex
        echo ""
    fi

    echo "✓ Agentation setup complete!"
}

# --- Main ---

case "${1:-all}" in
    claude)  install_for_claude ;;
    codex)   install_for_codex ;;
    all)     install_all ;;
    *)
        echo "Usage: $0 [claude|codex|all]"
        exit 1
        ;;
esac
