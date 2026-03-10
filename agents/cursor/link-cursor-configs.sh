#!/bin/bash
# Force-recreate Cursor config symlinks.
# Symlinks each item inside rules/ and skills/ (not whole folders).
# Auto-discovers items in agents/cursor/ and agents/skills/ — no manual updates needed when files are added.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_AGENTS="$(cd "$SCRIPT_DIR/.." && pwd)"

CURSOR_RULES_SRC="$SCRIPT_DIR/rules"
CURSOR_SKILLS_SRC="$REPO_AGENTS/skills"

CURSOR_DIR="$HOME/.cursor"
RULES_DEST="$CURSOR_DIR/rules"
SKILLS_DEST="$CURSOR_DIR/skills"

# Link a single file or directory
link_item() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo "linked: $(basename "$src") -> $dest"
}

# Symlink each item inside source dir into target dir (not the whole folder)
link_contents() {
    local src="$1" dest="$2"
    [[ -d "$src" ]] || return 0
    mkdir -p "$dest"

    for item in "$src"/*; do
        [[ -e "$item" ]] || continue
        local name
        name="$(basename "$item")"
        link_item "$item" "$dest/$name"
    done
}

# ── Cursor (global) ──────────────────────────────────────────
mkdir -p "$CURSOR_DIR"
link_item "$SCRIPT_DIR/mcp.json" "$CURSOR_DIR/mcp.json"
link_contents "$CURSOR_RULES_SRC" "$RULES_DEST"
link_contents "$CURSOR_SKILLS_SRC" "$SKILLS_DEST"

echo "Done. Rules in $RULES_DEST, skills in $SKILLS_DEST."
