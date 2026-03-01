#!/bin/bash
# Force-recreate all AI tool config symlinks.
# Auto-discovers files in ai/copilot/ — no manual updates needed when files are added.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/copilot"

# Target base directories
VSCODE_USER="$HOME/Library/Application Support/Code/User"
INTELLIJ_DIR="$HOME/.config/github-copilot/intellij"

# Link a single file
link_file() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo "linked: $(basename "$src") -> $dest"
}

# Link all files matching a glob pattern into a flat target directory
link_glob() {
    local pattern="$1" dest="$2"
    mkdir -p "$dest"
    for file in $pattern; do
        [[ -f "$file" ]] || continue
        link_file "$file" "$dest/$(basename "$file")"
    done
}

# Recursively link all files from source dir into target dir (preserving structure)
link_dir() {
    local src="$1" dest="$2"
    [[ -d "$src" ]] || return 0
    mkdir -p "$dest"
    find "$src" -type f ! -name '.DS_Store' | while read -r file; do
        relative="${file#"$src"/}"
        target="$dest/$relative"
        mkdir -p "$(dirname "$target")"
        ln -sf "$file" "$target"
        echo "linked: $relative -> $target"
    done
}

# ── VS Code (global) ─────────────────────────────────────────
link_file "$SOURCE_DIR/mcp.json"                          "$VSCODE_USER/mcp.json"
link_glob "$SOURCE_DIR/agents/*.agent.md"                 "$VSCODE_USER/prompts"
link_glob "$SOURCE_DIR/instructions/*.instructions.md"    "$VSCODE_USER/prompts"
link_glob "$SOURCE_DIR/prompts/*.prompt.md"               "$VSCODE_USER/prompts"

# ── IntelliJ (global) ────────────────────────────────────────
link_file "$SOURCE_DIR/mcp.json"                          "$INTELLIJ_DIR/mcp.json"
link_file "$SOURCE_DIR/global-copilot-instructions.md"    "$INTELLIJ_DIR/global-copilot-instructions.md"
link_glob "$SOURCE_DIR/instructions/*.instructions.md"    "$INTELLIJ_DIR"

# ── Copilot CLI (global) ─────────────────────────────────────
link_glob "$SOURCE_DIR/agents/*.agent.md"                 "$HOME/.copilot/agents"
link_dir  "$SOURCE_DIR/skills"                            "$HOME/.agents/skills"