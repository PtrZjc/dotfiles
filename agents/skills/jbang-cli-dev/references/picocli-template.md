# Base Picocli Template

When modifying or writing a JBang script from scratch that requires command-line argument parsing, ensure it follows this minimal Picocli structure.

```java
///usr/bin/env jbang "$0" "$@" ; exit $?
//DEPS info.picocli:picocli:4.7.0

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

@Command(name = "myscript", mixinStandardHelpOptions = true, version = "1.0", description = "A simple JBang CLI")
class myscript implements Runnable {

    @Option(names = {"-n", "--name"}, description = "Your name", defaultValue = "World")
    String name;

    @Parameters(index = "0", description = "Target action to perform", defaultValue = "greet")
    String action;

    public void run() {
        if ("greet".equalsIgnoreCase(action)) {
            System.out.println("Hello, " + name + "!");
        } else {
            System.out.println("Unknown action: " + action);
        }
    }

    public static void main(String... args) {
        int exitCode = new CommandLine(new myscript()).execute(args);
        System.exit(exitCode);
    }
}
```
