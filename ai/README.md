# AI Tool Configurations

Source files live in `ai/copilot/` and are symlinked to their system locations. Run `ai/copy.sh` to force-refresh all symlinks.

## Copilot — IntelliJ

Target: `~/.config/github-copilot/intellij/`

Symlinked files: `mcp.json`, `global-copilot-instructions.md`

## Copilot — VS Code

Target: `~/Library/Application Support/Code/User/`

Symlinked files: `mcp.json`

VS Code also reads custom prompts from its own `prompts/` directory — agents (`*.agent.md`), instructions (`*.instructions.md`), and prompts (`*.prompt.md`).

## Copilot CLI

Global config locations (not currently symlinked):
- Agents: `~/.config/copilot/agents/`
- Skills: `~/.copilot/skills/`
