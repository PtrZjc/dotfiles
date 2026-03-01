# Project Guidelines

## Code Style
- **Shell (Bash/Zsh)**:
  - Use `#!/bin/bash` or `#!/bin/zsh` shebangs appropriate for the script.
  - Indentation: 4 spaces.
  - Prefer `[[ ]]` over `[ ]` for tests in Bash/Zsh.
  - Use structured variable naming (e.g., `IS_MACOS`, `DOTFILES_DIR`).
- **Lua (Neovim)**:
  - Indentation: 4 spaces (`vim.opt.shiftwidth = 4`, `vim.opt.expandtab = true`).
  - Use `vim.opt` for options and `vim.keymap.set` for mappings.
  - Plugin management via `lazy.nvim`.

## Architecture
- **Structure**:
  - `zsh/`: Modular shell configuration (`custom.zsh`, `utils.zsh`, etc.).
  - `brew/`: macOS package dependencies (`Brewfile`).
  - `linux/`: Linux-specific configurations and scripts.
  - `nvim/`: Neovim configuration (`init.lua`).
  - `1-oh-my-zsh.sh` & `2-configure-rest.sh`: Initialization and setup scripts.
- **Cross-Platform**: Scripts usually detect OS (`IS_MACOS`, `IS_LINUX`) and branch accordingly.

## Build and Test
- **Installation**:
  1. `1-oh-my-zsh.sh`: Installs Oh My Zsh framework.
  2. `2-configure-rest.sh`: Sets up symlinks, installs packages (Brew/apt), and fonts.
- **Testing**:
  - No formal test suite exists.
  - "Test" by sourcing scripts or running them in a safe environment.
  - `shellcheck` is installed via Brew and should be used to lint shell scripts.

## Project Conventions
- **Tooling**:
  - Prefer modern replacements: `bat` (cat), `eza` (ls), `fd` (find), `ripgrep` (grep), `delta` (diff).
  - Use `zoxide` for navigation (if present/configured).
- **Symlinking**:
  - `2-configure-rest.sh` handles symlinking using `create_symlink` helper.
  - Idempotency is key: scripts checks if link/install already exists before acting.
- **Environment**:
  - `DOTFILES` env var points to the repo root.
  - `REPO` points to the workspace root containing `dotfiles`.

## Integration Points
- **Package Managers**: Homebrew (macOS), apt-get (Linux), pip, npm (nvm), cargo.
- **Editors**: Neovim (`nvim`), VS Code (`code`).
- **Terminal**: WezTerm (`wezterm/wezterm.lua`).
- **AI/Copilot**: Configuration stored in `ai/` and symlinked to user config dirs.

## Security
- **Secrets**: Avoid committing secrets. Check `zsh/secrets.zsh` (implied existence, ensure it's gitignored if used).
- **SSH/GPG**: Managed outside this repo, but configs might reference them.
