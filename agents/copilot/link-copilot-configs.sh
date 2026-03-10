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

# Link direct subdirectories from source dir into target dir
link_dir() {
    local src="$1" dest="$2"
    [[ -d "$src" ]] || return 0
    mkdir -p "$dest"
    
    fd --type directory --max-depth 1 --exclude '.DS_Store' . "$src" | while read -r dir; do
        dir="${dir%/}"
        local base
        base="$(basename "$dir")"
        local target="$dest/$base"
        
        # Use -n to prevent placing the symlink inside the target if it already is a symlinked directory
        ln -snf "$dir" "$target"
        echo "linked: $base -> $target"
    done
}

# ── VS Code (global) ─────────────────────────────────────────
link_file "$SOURCE_DIR/mcp.json"                          "$VSCODE_USER/mcp.json"
link_glob "$SOURCE_DIR/agents/*.agent.md"                 "$VSCODE_USER/prompts"
link_glob "$SOURCE_DIR/instructions/*.instructions.md"    "$VSCODE_USER/prompts"
link_glob "$SOURCE_DIR/prompts/*.prompt.md"               "$VSCODE_USER/prompts"
link_dir  "$SOURCE_DIR/skills"                            "$HOME/.agents/skills"

# ── IntelliJ (global) ────────────────────────────────────────
link_file "$SOURCE_DIR/mcp.json"                          "$INTELLIJ_DIR/mcp.json"
link_glob "$SOURCE_DIR/instructions/*.instructions.md"    "$INTELLIJ_DIR"

# ── Copilot CLI (global) ─────────────────────────────────────
link_glob "$SOURCE_DIR/agents/*.agent.md"                 "$HOME/.copilot/agents"