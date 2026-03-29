---
name: jbang-cli-dev
description: >-
  Covers authoring and running single-file Java (and Kotlin/Groovy) scripts with JBang: //DEPS,
  //JAVA, Picocli CLIs, jbang init and templates, jbang edit (IDE projects), jbang run/build,
  jbang export (fatjar, portable, native, maven, gradle, jlink), jbang app install,
  remote URLs, trust, aliases/catalogs, and debugging. External subprocesses must use
  org.zeroturnaround zt-exec (ProcessExecutor) only—never ProcessBuilder, Runtime.exec,
  or Apache Commons Exec for that purpose. Use when the user mentions JBang, .java scripts
  with directives, Picocli, jbang edit, export, app install, catalogs, running Java from a
  URL or gist, zt-exec, ProcessExecutor, or shelling out to git, curl, or other CLIs.
---

# JBang and Picocli development

JBang runs and builds Java (and other JVM languages) from minimal or single-file sources without a permanent Maven/Gradle project. This skill focuses on scripts and small CLIs, especially with Picocli.

## When to read which reference

| Task | Open |
|------|------|
| Dependencies, repos, Java version, compile/runtime/native options, `//SOURCES` / `//FILES`, `//GAV`, `//MAIN` | [references/directives.md](references/directives.md) |
| New Picocli CLI shape, `main`, exit codes | [references/picocli-template.md](references/picocli-template.md) |
| `jbang init`, templates, `deps@jbangdev`, `jbang build` / `jbang info` | [references/scaffolding-and-discovery.md](references/scaffolding-and-discovery.md) |
| `jbang app`, `jbang export` subcommands | [references/packaging-and-apps.md](references/packaging-and-apps.md) |
| `jbang edit`, sandbox, debugging, `JBANG_EDITOR` | [references/ide-and-debugging.md](references/ide-and-debugging.md) |
| HTTPS/GitHub scripts, `jbang trust`, aliases like `script@repo` | [references/remote-trust-and-catalogs.md](references/remote-trust-and-catalogs.md) |
| Spawning external processes (CLIs, shell commands) with zt-exec | [references/external-processes.md](references/external-processes.md) |

## Quick commands

- Run: `jbang Script.java [args]` (default command is `run`).
- Override JDK for one run: `jbang -j 21 Script.java`.
- Extra deps on CLI: `jbang --deps com.example:lib:1.0 Script.java` (comma-separated coordinates).

## Gotchas

- **Directives**: Must start at the beginning of a line with `//` and sit in the first comment block before code. **No space** between `//` and the directive name (e.g. `//DEPS`, not `// DEPS`).
- **Shebang**: For executable scripts use `///usr/bin/env jbang "$0" "$@" ; exit $?` on line 1. A normal `#!` breaks Java parsing in many tools.
- **Class name and file**: Prefer the public/top-level class name to match the file stem (e.g. `Hello.java` and `class Hello`). Lowercase class names are common when the file is also the installed command name.
- **Default package**: Omit `package` for typical single-file scripts. **Exception**: `jbang --interactive` uses JShell, which cannot see default-package classes—add a `package` if using interactive mode.
- **`//REPOS`**: If any custom repo line is present, **include Maven Central explicitly** (e.g. `central` or `https://repo1.maven.org/maven2/`). Built-in shortcuts include `central`, `google`, `jitpack`.
- **Debug JBang itself** vs script: script debugging uses `jbang --debug ...`. For the JBang process, use `JBANG_JAVA_OPTIONS` (see IDE reference).

## External processes

- **Rule**: To run any external program (CLI tools, shell commands, pipes to other binaries), use **only** [zt-exec](https://central.sonatype.com/artifact/org.zeroturnaround/zt-exec) (`org.zeroturnaround.exec.ProcessExecutor`). Add `//DEPS org.zeroturnaround:zt-exec:1.12` to the script.
- **Do not use** for subprocesses: `ProcessBuilder`, `Runtime.getRuntime().exec(...)`, Apache Commons Exec, or hand-rolled stream pumping **except** through zt-exec’s configuration (redirects, `readOutput`, line handlers, etc.).
- **Patterns**: See [references/external-processes.md](references/external-processes.md) for exit codes, capturing UTF-8 output, timeouts, environment variables, and optional SLF4J redirection.
- **Killing processes**: zt-exec does not focus on arbitrary kill semantics; timeouts destroy the process. For dedicated kill workflows, see [zt-process-killer](https://github.com/zeroturnaround/zt-process-killer).

## Out of scope

Full multi-module backends (e.g. Spring Boot with JPA across many modules) are not what this skill optimizes for. Prefer a normal Gradle/Maven app; JBang can still bootstrap prototypes via `jbang init` or exports.
