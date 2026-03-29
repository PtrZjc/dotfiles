# Scaffolding and discovery

## `jbang init`

- `jbang init Hello.java` — simple class with `main`.
- `jbang init --template=cli Hello.java` — Picocli-based CLI (`-t cli`).
- `jbang init --edit Hello.java` — generate and open in the configured editor.
- `jbang init -Dkey=value Hello.java` — template properties become `{key}` placeholders in custom templates.

List templates: `jbang template list`. User templates: `jbang template add` (see JBang templates docs).

## `jbang build`

Builds/caches without running: `jbang build Script.java`. Useful for CI or checking compilation.

## Dependency updates

- `jbang deps@jbangdev Script.java` — suggests newer versions for `//DEPS` in the file.
- `jbang deps@jbangdev group:artifact:version` — check a single coordinate.

## `jbang info`

Inspect resolution and setup, e.g. `jbang info classpath Script.java`, `jbang info tools`, `jbang info jar` (see `jbang info -h`).

## Config

Persistent settings: `jbang config list|get|set|unset` (cache, editor, trust behavior, etc.).
