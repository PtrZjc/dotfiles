---
name: Global Copilot Instructions
description: Repository-wide guidance for Copilot agents and code generation
applyTo: '**'
---

# Global Engineering Standards
- **Implementation**: Default to the simplest functional implementation (KISS/YAGNI). Introduce abstractions (SRP/DRY) only when a pattern repeats at least three times.
- **Robustness**: Always implement structured logging for diagnostics and explicitly handle edge cases and errors.

# Created File Locations
- **Markdown Output**: Any markdown file created by the agent MUST always be saved to the `docs/` directory.

# Tool Usage Guidelines
## Directory Navigation and File Discovery
- **Use `#tool:filesystem/directory_tree` for exploration**: When searching for multiple files, understanding project structure, or locating existing functionality, use this tool to get a comprehensive view of the codebase.
- **Target Specific Directories**: NEVER use `#tool:filesystem/directory_tree` at the repository root. Always target specific subdirectories to avoid fetching the `.git` folder and irrelevant metadata.

## File Reading Strategy
- **Use `#tool:filesystem/read_multiple_files` for batch operations**: Use this for efficient batch processing when you need to read the contents of multiple files simultaneously.
- **Single file operations**: Use standard file reading tools for targeted single file operations.
- **Multi-file analysis**: Combine `#tool:filesystem/directory_tree` (for discovery) with `#tool:filesystem/read_multiple_files` (for content analysis) when examining relationships between files or analyzing architectural patterns.