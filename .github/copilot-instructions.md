# Copilot Instructions

## Overview

Personal dotfiles for **macOS and Linux (Ubuntu)**. All configs are **symlinked** to their system locations — edit files here, reload with `rst` (`exec zsh`). Never copy files; always symlink.

## Setup Commands

```bash
./1-oh-my-zsh.sh        # Phase 1: Install Oh My Zsh (must run first)
./2-configure-rest.sh   # Phase 2: Packages, symlinks, plugins (auto-detects OS)

brew bundle --file=brew/Brewfile   # macOS packages
./linux/packages.sh                # Ubuntu packages

initialize_zsh_symlinks            # Re-link zsh/*.zsh into $ZSH_CUSTOM (defined in zsh/custom.zsh)
ai/copy.sh                         # Force-reload AI tool config symlinks
```

## Architecture

### Symlink Strategy

`2-configure-rest.sh` creates all symlinks. Key targets:

| Source | Symlink Target |
|--------|---------------|
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/*.zsh` | `$ZSH_CUSTOM/*.zsh` (Oh My Zsh custom plugins) |
| `other/.gitconfig` | `~/.gitconfig` |
| `other/.p10k.zsh` | `~/.p10k.zsh` |
| `nvim/init.lua` | `~/.config/nvim/init.lua` |
| `wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` |
| `other/atuin/config.toml` | `~/.config/atuin/config.toml` |
| `ai/copilot/*` | `~/.config/github-copilot/intellij/` + VS Code MCP config |

The `initialize_zsh_symlinks` function (in `custom.zsh`) uses `fd` to re-symlink all `zsh/*.zsh` files into `$ZSH_CUSTOM`.

### Zsh Dual Mode

`.zshrc` detects `$TERMINAL_EMULATOR == "JetBrains-JediTerm"` to switch between:
- **Normal mode**: Powerlevel10k theme, fzf, syntax highlighting, autosuggestions, full aliases
- **JetBrains Agent mode**: Plain prompt, no colors, coreutils only — optimized for IDE terminal agents

### Lazy Loading Pattern

Heavy tools are loaded on first use via stub functions that unload themselves and initialize the real tool. This keeps shell startup fast. Pattern used for: `nvm`, `sdkman`, `kubectl`, `docker`, `aws`.

### AI Config Management

`ai/copilot/` contains Copilot configurations (MCP servers, global instructions, agents, skills) that are symlinked into `~/.config/github-copilot/intellij/` and VS Code's config directory. Run `ai/copy.sh` to force-refresh these symlinks.

## Key Conventions

- **No hardcoded paths**: `$DOTFILES` is detected dynamically via `${0:A:h:h}` in `zsh/custom.zsh`; never use `~/dotfiles` or absolute paths
- **Cross-platform guards**: Use `$IS_MACOS` / `$IS_LINUX` (set in `zsh/utils.zsh`) for OS-specific code
- **Clipboard abstraction**: Always `clip_copy` / `clip_paste` — never raw `pbcopy`/`xclip`/`wl-copy`
- **URL/browser abstraction**: Use `open_url` / `open_with_browser` instead of `open` or `xdg-open`
- **Modern CLI tools**: prefer `fd` over `find`, `rg` over `grep`, `eza` over `ls`, `bat` over `cat`, `sd` over `sed`, `jaq` over `jq`
- **Git commit convention**: `gc "msg"` extracts the JIRA ticket number from the branch name (2nd `-`-delimited field) and hardcodes an `LDSI-` prefix (e.g., branch `feature/LDSI-1234-foo` → commit `LDSI-1234 msg`). Falls back to plain message if no numeric ticket found.
- **Secrets**: `zsh/secrets.zsh` contains API keys and credentials — never commit real secrets to this file in a public context

## Zsh Files

| File | Purpose |
|------|---------|
| `zsh/.zshrc` | Entry point — dual mode (normal / JetBrains Agent), plugin loading, lazy loaders |
| `zsh/custom.zsh` | `$DOTFILES` export, aliases, global aliases, key functions (`fdf`, `goto`, `ocr`, `pyv`, `l`) |
| `zsh/git.zsh` | Git functions (`gc`, `ga`, `gcl`, `og`, `opr`, `gcb`) |
| `zsh/utils.zsh` | Cross-platform abstractions (`clip_copy`, `clip_paste`, `open_url`, `$IS_MACOS`/`$IS_LINUX`) |
| `zsh/text_processing.zsh` | Text/data manipulation (`line`, `ucase`, `split`, `tostring_to_json`) |
| `zsh/job_specific.zsh` | Work-specific: AWS profile switching (`set_aws_profile`), K8s namespace helpers (`k-set-ns`) |
| `zsh/secrets.zsh` | API keys, tokens, credentials (sensitive — not for public sharing) |

## Coding Standards

- **KISS / YAGNI**: Simplest solution; no speculative features
- **DRY — Rule of Three**: Abstract only after 3+ repetitions
- **SRP**: Single responsibility, balanced with simplicity
