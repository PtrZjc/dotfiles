---
name: jbang-cli-dev
description: >-
  Single-file Java scripting and Picocli CLIs with JBang—create, edit, run, debug,
  package, and IDE workflows. Use when the user works with JBang, Picocli,
  //DEPS directives, jbang app install, jbang export, jbang edit, or debugging
  JBang scripts.
---

# JBang & Picocli Development

JBang enables lightweight, quick scripting using modern Java and popular libraries with zero project setup overhead. This skill provides instructions on authoring, managing, and packaging JBang scripts, with a primary focus on building CLIs using the Picocli library.

## Progressive Disclosure Reference

Read the following reference files based on the specific task the user is trying to accomplish:

* **Read `references/directives.md`** when the user needs to add dependencies, specify Java versions, configure JVM options, or add custom repositories.
* **Read `references/picocli-template.md`** when generating a new script, or when you need the structural boilerplate for a Picocli command-line app.
* **Read `references/packaging-and-apps.md`** when the user wants to install the script as a system command (`jbang app install`) or export it as a binary/jar (`jbang export`).
* **Read `references/ide-and-debugging.md`** when the user asks about editing the script in an IDE (VS Code, IntelliJ, Eclipse) or attaching a debugger.

## Gotchas

* **No spaces in `//DEPS`**: The dependency directive must be placed exactly at the start of the line. There must be NO space between `//` and `DEPS`.
* **Shebang compatibility**: Always use `///usr/bin/env jbang "$0" "$@" ; exit $?` as the first line. Do NOT use the standard bash `#!` because standard Java compilers and IDEs will report a syntax error.
* **Class naming conventions**: The main class name should match the filename (e.g., `myscript.java` -> `class myscript` or `class MyScript`). While standard Java uses CamelCase, JBang scripts often use lowercase class names so the resulting CLI command matches standard lowercase Unix tool conventions.
* **Package declarations**: Single-file CLIs typically do not use `package` declarations. Avoid them unless building a complex multi-file application.
* **Interactive Mode (JShell) Limitation**: JShell cannot access classes in the default package. If the user intends to use interactive mode (`jbang --interactive`), the script *must* include a `package` statement.

## Out of Scope

Full multi-module backends (e.g. Spring Boot with JPA and PostgreSQL) are not single-file JBang/Picocli scripts. Advise accordingly or fall back to general Java knowledge without presenting this skill as the primary guide.
