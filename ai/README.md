# AI Configuration Directory

This directory manages GitHub Copilot configurations and integrations across multiple development tools (VS Code,
IntelliJ IDEA, and Copilot CLI). It provides a centralized location for MCP configurations, custom agents, instruction
files, prompts, and skills.

## Overview

The `ai/` directory contains:

- **`copilot/`** – Source configurations for all AI tools (MCP, agents, instructions, prompts, skills)
- **`link-copilot-configs.sh`** – Automation script that creates symlinks to your system's application config
  directories

All configurations in the `copilot/` subdirectory are automatically discovered and symlinked to the appropriate
locations for each tool (VS Code, IntelliJ, Copilot CLI) when you run the setup script.

## The `link-copilot-configs.sh` Script

### What It Does

This script **automatically creates symbolic links** from the dotfiles repository's AI configurations to your system's
application configuration directories. Benefits:

- **Centralized Management** – Keep all Copilot configs in your dotfiles repository
- **Auto-Discovery** – New files added to `copilot/` are automatically symlinked; no manual updates needed
- **Multi-Tool Support** – Handles VS Code, IntelliJ IDEA, and Copilot CLI in one run
- **Idempotent** – Safe to run multiple times; uses `ln -sf` to force-recreate symlinks

### How the Script Works

The script performs the following operations:

#### 1. **File Discovery**

- Uses `fd` (required tool) to recursively discover files in `copilot/agents/`, `copilot/instructions/`,
  `copilot/prompts/`, and subdirectories
- Automatically detects new files without requiring manual configuration

#### 2. **Symlink Creation**

- Creates individual symlinks for each discovered file
- Creates directory-level symlinks for the `skills/` folder
- Uses `ln -sf` to force-recreate symlinks safely (idempotent behavior)

#### 3. **Multi-Tool Configuration**

The script sets up configurations for three different environments:

- **VS Code**: Links MCP configuration, agents, instruction files, prompts, and skills
- **IntelliJ IDEA**: Links MCP configuration and instruction files
- **Copilot CLI**: Links agents files

## Configuration Locations Reference

### 1. Visual Studio Code (VS Code)

**Global (User Profile / System-wide)**
These settings apply across all your open projects and workspaces.

| Configuration Type    | Path / Location                                                     |
|-----------------------|---------------------------------------------------------------------|
| **MCP Configuration** | `~/Library/Application Support/Code/User/mcp.json`                  |
| **Agents**            | `~/Library/Application Support/Code/User/prompts/*.agent.md`        |
| **Instruction Files** | `~/Library/Application Support/Code/User/prompts/*.instructions.md` |
| **Prompts**           | `~/Library/Application Support/Code/User/prompts/*.prompt.md`       |

**Local (Workspace / Repository)**
Configurations specific to a given project, typically committed to version control.

| Configuration Type           | Path / Location                                                             |
|------------------------------|-----------------------------------------------------------------------------|
| **Global Instruction File**  | `.github/copilot-instructions.md`                                           |
| **Instruction Files**        | `.github/instructions/`                                                     |
| **Agents**                   | `.github/agents/`                                                           |
| **Prompts (Slash commands)** | `.github/prompts/`                                                          |
| **Skills**                   | `.agents/skills/` *(also supports `.github/skills/` and `.claude/skills/`)* |

## 2. Copilot — IntelliJ IDEA

**Global (User Profile)**
These configurations are stored in your user profile and apply across your IntelliJ environment. *(Note: Global agents
are not supported at this level).*

| Configuration Type          | Path / Location                                                    |
|-----------------------------|--------------------------------------------------------------------|
| **Global Instruction File** | `~/.config/github-copilot/intellij/global-copilot-instructions.md` |
| **Instruction Files**       | `~/.config/github-copilot/intellij/*.instructions.md`              |
| **MCP Configuration**       | `~/.config/github-copilot/intellij/mcp.json`                       |

**Local (Workspace / Repository)**
Configurations specific to the opened project in IntelliJ.

| Configuration Type | Path / Location   |
|--------------------|-------------------|
| **Agents**         | `.github/agents/` |

## 3. Copilot CLI

**Global (User Profile)**
Global configurations for the command-line interface. *(Note: The CLI currently does not support custom `.prompt.md`
files).*

| Configuration Type | Path / Location                                 |
|--------------------|-------------------------------------------------|
| **Agents**         | `~/.copilot/agents/`                            |
| **Skills**         | `~/.agents/skills/` *(or `~/.copilot/skills/`)* |
