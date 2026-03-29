# IDE integration and debugging

## `jbang edit`

Generates a temporary project (Gradle + IDE metadata) with links to the script so the IDE sees dependencies.

- Default behavior may offer portable editor setup under `~/.jbang/editor`; override with `jbang edit --open=<editor> script.java`.
- **VS Code / VSCodium**: `jbang edit --open=code script.java`
- **IntelliJ IDEA**: `jbang edit --open=idea script.java`
- **Eclipse**: `jbang edit --open=eclipse script.java`
- **Do not open automatically**: `jbang edit --no-open script.java` then pass the printed path to your IDE (e.g. `code "$(jbang edit --no-open script.java)"`).
- **Sandbox** (`-b` / `--sandbox`): use when the IDE has no JBang plugin—temporary project with symlinks to the script.
- **Live**: `jbang edit --live script.java` watches the script and regenerates the project when directives (e.g. `//DEPS`) change.

Set **`JBANG_EDITOR`** to default an editor when you do not pass `--open`.

**Windows**: symlinks for `edit` may require Developer Mode or elevated shell; see JBang editing docs if generation fails.

After changing `//DEPS` or `//SOURCES`, re-run `jbang edit` if not using `--live`.

## Debugging the script (`jbang run`)

- `jbang --debug script.java` — listen for debugger (default port **4004**), suspend until attach.
- `jbang --debug=*:4321 script.java` — port and bind address.
- `jbang --debug=address=5000? script.java` — pick a free port starting at 5000 (`?` suffix).
- `jbang --debug=server=n,suspend=y script.java` — JPDA key/value form (attach from IDE per JDK docs).

JBang compiles with debug info by default (recent versions). Tune with `-C` / `--compile-option` (e.g. `-g` levels) if needed.

## Debugging JBang itself

`JBANG_JAVA_OPTIONS` applies to the JBang JVM (not your script). Example:

```bash
JBANG_JAVA_OPTIONS='-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=1044' jbang version
```

## Other useful run flags

See `jbang run -h`: `--interactive` (JShell), `--jfr`, `-o` / `--offline`, `--fresh`, `-j` / `--java`, `--deps`, `--repos`.
