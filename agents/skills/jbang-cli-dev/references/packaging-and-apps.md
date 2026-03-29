# Packaging and global commands

## `jbang app install`

Installs a script as a command on `PATH` (JBang manages launchers).

- `jbang app install script.java`
- `jbang app install --name mytool script.java`
- `jbang app install --force --name mytool script.java` — replace existing
- `jbang app list` / `jbang app uninstall mytool`

Optional: `//GAV` in the script helps metadata when exporting or publishing.

## `jbang export`

Produces distributable artifacts or projects (each subcommand has its own flags; use `jbang export <subcommand> -h`).

| Subcommand | Purpose |
|------------|---------|
| `fatjar` | Single executable JAR with dependencies inside |
| `portable` | JAR plus `lib/` for relative classpath |
| `local` | JAR with machine-local classpath layout |
| `native` | GraalVM `native-image` binary |
| `jlink` | Custom runtime image |
| `maven` | Maven project (`-g` / `--group`, `-a` / `--artifact`, `-v` / `--version`, `-O` output) |
| `gradle` | Gradle project (same style of coordinates) |
| `mavenrepo` | Layout suitable for publishing as a Maven repo |

Examples:

```bash
jbang export fatjar myapp.java
jbang export portable myapp.java
jbang export native myapp.java
jbang export maven -g org.acme -a mytool -v 1.0.0-SNAPSHOT myapp.java
jbang export gradle -g org.acme -a mytool -v 1.0.0-SNAPSHOT myapp.java
```

Native image requires a GraalVM-capable JDK and correct `//NATIVE_OPTIONS` when reflection/resources need registration.
