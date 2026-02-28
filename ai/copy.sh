#!/bin/bash
# Force-recreate all AI tool config symlinks.
# Auto-discovers files in ai/copilot/ — no manual updates needed when files are added.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/copilot"

INTELLIJ_TARGET="$HOME/.config/github-copilot/intellij"
VSCODE_TARGET="$HOME/Library/Application Support/Code/User"

mkdir -p "$INTELLIJ_TARGET"

# Symlink all files from ai/copilot/ (recursively, preserving subdirectory structure) into IntelliJ target
find "$SOURCE_DIR" -type f ! -name '.DS_Store' | while read -r file; do
    relative="${file#"$SOURCE_DIR"/}"
    target="$INTELLIJ_TARGET/$relative"
    mkdir -p "$(dirname "$target")"
    ln -sf "$file" "$target"
    echo "linked: $relative -> $target"
done

# VS Code gets only mcp.json
if [[ -d "$VSCODE_TARGET" ]]; then
    ln -sf "$SOURCE_DIR/mcp.json" "$VSCODE_TARGET/mcp.json"
    echo "linked: mcp.json -> $VSCODE_TARGET/mcp.json"
fi
