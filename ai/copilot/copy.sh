#!/bin/bash
# intellij does not see symlinks change, so we force it to reload

rm "$HOME/.config/github-copilot/intellij/mcp.json"
rm "$HOME/.config/github-copilot/intellij/global-copilot-instructions.md"
ln -sf "$DOTFILES/ai/copilot/mcp.json" "$HOME/.config/github-copilot/intellij/mcp.json"
ln -sf "$DOTFILES/ai/copilot/global-copilot-instructions.md" "$HOME/.config/github-copilot/intellij/global-copilot-instructions.md"
