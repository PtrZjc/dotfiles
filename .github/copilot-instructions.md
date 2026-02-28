# Copilot Instructions

## Overview

Personal dotfiles for **macOS and Linux (Ubuntu)**. All configs are **symlinked** to their system locations — edit files here, reload with `rst`. Never copy files; always symlink.

## Setup Commands

```bash
./1-oh-my-zsh.sh        # Phase 1: Install Oh My Zsh (must run first)
./2-configure-rest.sh   # Phase 2: Packages, symlinks, plugins (auto-detects OS)

brew bundle --file=brew/Brewfile   # macOS packages
./linux/packages.sh                # Ubuntu packages

initialize_zsh_symlinks            # Re-link zsh/*.zsh into $ZSH_CUSTOM (defined in zsh/custom.zsh)
```

## Architecture

```
zsh/           # Shell config sourced as Oh My Zsh custom plugins
nvim/          # Neovim config → ~/.config/nvim/init.lua
wezterm/       # WezTerm config → ~/.config/wezterm/wezterm.lua
brew/          # Brewfile (macOS packages)
linux/         # packages.sh (Ubuntu packages)
ai/copilot/    # GitHub Copilot: mcp.json, global-copilot-instructions.md
other/         # .gitconfig, .p10k.zsh, misc
```

## Key Conventions

- **No hardcoded paths**: `$DOTFILES` is detected dynamically via `${0:A:h:h}` in `zsh/custom.zsh`; never `~/dotfiles` or absolute paths
- **Cross-platform guards**: Use `$IS_MACOS` / `$IS_LINUX` (set in `2-configure-rest.sh` and `zsh/os_utils.zsh`) for OS-specific code
- **Clipboard abstraction**: Always `clip_copy` / `clip_paste` — never raw `pbcopy`/`xclip`/`wl-copy`
- **URL/browser abstraction**: Use `open_url` / `open_with_browser` instead of `open` or `xdg-open`
- **Lazy loading**: Heavy tools (`nvm`, `sdkman`, `kubectl`, `docker`, `aws`) are loaded on first use — keep startup fast
- **Modern CLI**: prefer `fd` over `find`, `rg` over `grep`, `eza` over `ls`, `bat` over `cat`, `sd` over `sed`

## Zsh Files

| File | Purpose |
|------|---------|
| `zsh/custom.zsh` | Exports, aliases, global aliases, key functions (`fdf`, `goto`, `ocr`, `pyv`, `l`) |
| `zsh/git.zsh` | Git aliases and functions (`gc`, `ga`, `gcl`, `og`, `opr`, `gcb`) |
| `zsh/text_processing.zsh` | Text/data manipulation helpers |
| `zsh/utils.zsh` | General utilities |
| `zsh/os_utils.zsh` | Cross-platform abstractions (`clip_copy`, `open_url`, OS flags) |

## Coding Standards (from `ai/copilot/global-copilot-instructions.md`)

- **KISS / YAGNI**: Simplest solution; no speculative features
- **DRY — Rule of Three**: Abstract only after 3+ repetitions
- **SRP**: Single responsibility, balanced with simplicity
