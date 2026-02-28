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
ai/copy.sh                         # Force-reload AI tool config symlinks
```

## Architecture

Zsh files in `zsh/` are symlinked into `$ZSH_CUSTOM` and sourced as Oh My Zsh custom plugins. The `.zshrc` runs in two modes: **normal** (full Powerlevel10k, fzf, syntax highlighting) and **JetBrains Agent** (minimal prompt, no colors — detected via `$TERMINAL_EMULATOR`).

## Key Conventions

- **No hardcoded paths**: `$DOTFILES` is detected dynamically via `${0:A:h:h}` in `zsh/custom.zsh`; never use `~/dotfiles` or absolute paths
- **Cross-platform guards**: Use `$IS_MACOS` / `$IS_LINUX` (set in `zsh/utils.zsh`) for OS-specific code
- **Clipboard abstraction**: Always `clip_copy` / `clip_paste` — never raw `pbcopy`/`xclip`/`wl-copy`
- **URL/browser abstraction**: Use `open_url` / `open_with_browser` instead of `open` or `xdg-open`
- **Lazy loading**: Heavy tools (`nvm`, `sdkman`, `kubectl`, `docker`, `aws`) are loaded on first use — keep shell startup fast
- **Modern CLI tools**: prefer `fd` over `find`, `rg` over `grep`, `eza` over `ls`, `bat` over `cat`, `sd` over `sed`
- **Git commit convention**: `gc "msg"` auto-prefixes commit messages with a JIRA ticket extracted from the branch name (e.g., branch `feature/LDSI-1234-foo` → `LDSI-1234 msg`)

## Zsh Files

| File | Purpose |
|------|---------|
| `zsh/.zshrc` | Entry point — dual mode (normal / JetBrains Agent), plugin loading, lazy loaders |
| `zsh/custom.zsh` | `$DOTFILES` export, aliases, global aliases, key functions (`fdf`, `goto`, `ocr`, `pyv`, `l`) |
| `zsh/git.zsh` | Git functions (`gc`, `ga`, `gcl`, `og`, `opr`, `gcb`) |
| `zsh/utils.zsh` | Cross-platform abstractions (`clip_copy`, `clip_paste`, `open_url`, `$IS_MACOS`/`$IS_LINUX`) |
| `zsh/text_processing.zsh` | Text/data manipulation helpers |
| `zsh/job_specific.zsh` | Work-specific: AWS profile switching, K8s namespace helpers |

## Coding Standards

- **KISS / YAGNI**: Simplest solution; no speculative features
- **DRY — Rule of Three**: Abstract only after 3+ repetitions
- **SRP**: Single responsibility, balanced with simplicity

For Java projects (referenced from `ai/copilot/global-copilot-instructions.md`):
- Records for data, classes for behavior; immutability first
- AssertJ for assertions, `shouldXxx` test naming, given/when/then structure
