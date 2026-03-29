# JBang directives (header comments)

JBang reads special `//` comments at the **start of the file** (first comment block, before code). Directives are **case-sensitive**. Many can repeat where noted.

## `//DEPS`

Maven coordinates (Gradle-style locators) or GitHub/GitLab/Bitbucket links (resolved via JitPack).

- Syntax: `//DEPS groupId:artifactId:version[:classifier][@type]`
- One line can list **multiple** coordinates separated by spaces.
- Examples:
  - `//DEPS info.picocli:picocli:4.7.0`
  - Classifier: `//DEPS io.netty:netty-transport-native-kqueue:4.1.107.Final:osx-aarch_64`
  - BOM: first `//DEPS ...@pom` supplies managed versions for later lines without versions.
  - `@fatjar`: dependency packaged as fat JAR; transitive resolution differs—see upstream docs.

## `//REPOS`

Extra Maven repositories. Default is Maven Central only.

- Syntax: `//REPOS [name=]url[,name=url...]` or comma-separated list.
- Shortcuts: `central`, `google`, `jitpack`.
- **If you add any `//REPOS`, add `central` (or the Central URL) if you still need Maven Central.**

Auth for private repos: `~/.m2/settings.xml`.

## `//JAVA`

- `//JAVA 17` — exact major version.
- `//JAVA 17+` — minimum version (JBang can fetch a JDK).

Use with `//PREVIEW` when the language level needs preview flags.

## `//PREVIEW`

Enables preview features (adds the usual `--enable-preview` compile and runtime behavior). Pair with a sufficient `//JAVA`.

## `//COMPILE_OPTIONS` / `//RUNTIME_OPTIONS` / `//NATIVE_OPTIONS`

Space-separated flags for `javac`, `java`, and `native-image` respectively. CLI equivalents: `--compile-option` (`-C`), `--runtime-option` (`-R` / `--java-options`), `--native-option` (`-N`).

## `//JAVAC_OPTIONS`

Additional flags passed to `javac` when `//COMPILE_OPTIONS` is not enough.

## `//SOURCES`

Additional source files compiled with the main script (paths relative to the script).

```java
//SOURCES util/Helper.java
```

## `//FILES`

Resources copied into the run/export layout (properties, data dirs, etc.).

```java
//FILES config.properties templates/
```

## `//GAV`

Coordinates for the script itself (`group:artifact[:version]`). Used when exporting to Maven/Gradle projects.

## `//MAIN`

Fully qualified class name when JBang should not infer `main` (multiple mains or non-standard layout).

## `//MANIFEST`

`key=value` pairs for the generated JAR manifest; entries without `=` default to `true`.

## `//DESCRIPTION` / `//DOCS`

Human-oriented metadata (catalogs, `jbang info docs`, alias listings). `//DOCS` can be tagged, e.g. `//DOCS guide=./readme.md`.

## Other (use when needed)

- `//CDS` — class data sharing (JDK 13+; experimental).
- `//JAVAAGENT` — agents (coordinate, path, or URL).
- `//MODULE` — experimental Java module mode (typically requires a `package`).
- `//KOTLIN` / `//GROOVY` — language version for `.kt` / `.groovy` scripts.

For the full directive list and ordering tips, see JBang’s script directives documentation.
