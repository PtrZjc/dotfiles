
## 1. Visual Studio Code (VS Code)

**Global (User Profile / System-wide)**
These settings apply across all your open projects and workspaces.

| Configuration Type    | Path / Location                                                     |
| --------------------- | ------------------------------------------------------------------- |
| **MCP Configuration** | `~/Library/Application Support/Code/User/mcp.json`                  |
| **Agents**            | `~/Library/Application Support/Code/User/prompts/*.agent.md`        |
| **Instruction Files** | `~/Library/Application Support/Code/User/prompts/*.instructions.md` |
| **Prompts**           | `~/Library/Application Support/Code/User/prompts/*.prompt.md`       |

**Local (Workspace / Repository)**
Configurations specific to a given project, typically committed to version control.

| Configuration Type           | Path / Location                                                             |
| ---------------------------- | --------------------------------------------------------------------------- |
| **Global Instruction File**  | `.github/copilot-instructions.md`                                           |
| **Instruction Files**        | `.github/instructions/`                                                     |
| **Agents**                   | `.github/agents/`                                                           |
| **Prompts (Slash commands)** | `.github/prompts/`                                                          |
| **Skills**                   | `.agents/skills/` *(also supports `.github/skills/` and `.claude/skills/`)* |

## 2. Copilot — IntelliJ IDEA

**Global (User Profile)**
These configurations are stored in your user profile and apply across your IntelliJ environment. *(Note: Global agents are not supported at this level).*

| Configuration Type          | Path / Location                                                    |
| --------------------------- | ------------------------------------------------------------------ |
| **Global Instruction File** | `~/.config/github-copilot/intellij/global-copilot-instructions.md` |
| **Instruction Files**       | `~/.config/github-copilot/intellij/*.instructions.md`              |
| **MCP Configuration**       | `~/.config/github-copilot/intellij/mcp.json`                       |

**Local (Workspace / Repository)**
Configurations specific to the opened project in IntelliJ.

| Configuration Type | Path / Location   |
| ------------------ | ----------------- |
| **Agents**         | `.github/agents/` |

## 3. Copilot CLI

**Global (User Profile)**
Global configurations for the command-line interface. *(Note: The CLI currently does not support custom `.prompt.md` files).*

| Configuration Type | Path / Location                                 |
| ------------------ | ----------------------------------------------- |
| **Agents**         | `~/.copilot/agents/`                            |
| **Skills**         | `~/.agents/skills/` *(or `~/.copilot/skills/`)* |