# Picocli template for JBang

Official pattern: a single class with `@Command`, `Runnable`, and `CommandLine` in `main`. Prefer **`jbang init --template=cli MyCli.java`** (or `-t cli`) for an up-to-date starter; `jbang template list` shows built-ins.

## Minimal example

Use the shebang only when the file is executed directly (`chmod +x`); omit it for plain `jbang MyCli.java`.

```java
///usr/bin/env jbang "$0" "$@" ; exit $?
//DEPS info.picocli:picocli:4.7.0

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

@Command(name = "mycli", mixinStandardHelpOptions = true, version = "1.0",
        description = "Example JBang + Picocli CLI")
class mycli implements Runnable {

    @Option(names = {"-n", "--name"}, description = "Name to greet", defaultValue = "World")
    String name;

    @Parameters(index = "0", arity = "0..1", description = "Action", defaultValue = "greet")
    String action;

    @Override
    public void run() {
        if ("greet".equalsIgnoreCase(action)) {
            System.out.println("Hello, " + name + "!");
        } else {
            System.err.println("Unknown action: " + action);
        }
    }

    public static void main(String... args) {
        int exitCode = new CommandLine(new mycli()).execute(args);
        System.exit(exitCode);
    }
}
```

## Notes

- **`execute` return value**: Picocli returns an exit code; propagate with `System.exit` in CLI tools (or use `CommandLine` IExecutionStrategy if you standardize elsewhere).
- **Subcommands**: add `@Command(subcommands = { ... })` on the parent command class.
- **Naming**: match the filename stem to the class name when possible; lowercase class/file names are common for Unix-style command names.
