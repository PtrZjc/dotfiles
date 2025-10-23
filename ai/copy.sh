#!/bin/bash
# Force reload of AI tool configs by removing and recreating symlinks
# Some applications (IntelliJ, Claude) don't detect symlink changes automatically

# GitHub Copilot configs
rm "$HOME/.config/github-copilot/intellij/mcp.json"
rm "$HOME/.config/github-copilot/intellij/global-copilot-instructions.md"
ln -sf "$DOTFILES/ai/copilot/mcp.json" "$HOME/.config/github-copilot/intellij/mcp.json"
ln -sf "$DOTFILES/ai/copilot/mcp.json" "$HOME/Library/Application Support/Code/User/mcp.json"
ln -sf "$DOTFILES/ai/copilot/global-copilot-instructions.md" "$HOME/.config/github-copilot/intellij/global-copilot-instructions.md"

# Claude Desktop config
rm "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
ln -sf "$DOTFILES/ai/claude_desktop_config.json" "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
