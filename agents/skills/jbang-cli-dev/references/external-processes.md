# External processes (zt-exec only)

In JBang scripts, **only** [zt-exec](https://github.com/zeroturnaround/zt-exec) `ProcessExecutor` may spawn subprocesses—**not** `ProcessBuilder`, `Runtime.exec`, or Apache Commons Exec.

## Dependency

```text
//DEPS org.zeroturnaround:zt-exec:1.12
```

zt-exec brings SLF4J API; for `Slf4jStream` redirection to actually log, add a binding such as `//DEPS org.slf4j:slf4j-simple:2.0.9` (or another SLF4J implementation).

## Imports (typical)

```java
import org.zeroturnaround.exec.InvalidExitValueException;
import org.zeroturnaround.exec.ProcessExecutor;
import org.zeroturnaround.exec.ProcessResult;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
```

For logger redirection:

```java
import org.zeroturnaround.exec.stream.slf4j.Slf4jStream;
```

## Run and ignore output

```java
new ProcessExecutor().command("java", "-version").execute();
```

## Exit code

```java
int exit = new ProcessExecutor().command("java", "-version")
    .execute().getExitValue();
```

## Capture stdout as UTF-8

```java
String output = new ProcessExecutor().command("java", "-version")
    .readOutput(true).execute()
    .outputUTF8();
```

## Timeout (process destroyed on timeout)

```java
try {
  new ProcessExecutor().command("java", "-version")
      .timeout(60, TimeUnit.SECONDS).execute();
} catch (TimeoutException e) {
  // handle
}
```

## Allowed exit values

```java
try {
  new ProcessExecutor().command("java", "-version")
      .exitValues(0).execute();
} catch (InvalidExitValueException e) {
  int code = e.getExitValue();
}
```

## Environment

```java
new ProcessExecutor().command("java", "-version")
    .environment("FOO", "bar")
    .execute();

// or .environment(map) with Map<String, String>
```

## Optional: pump stdout to SLF4J

```java
new ProcessExecutor().command("java", "-version")
    .redirectOutput(Slf4jStream.ofCaller().asInfo())
    .execute();
```

## Optional: line-by-line while running

Use `LogOutputStream` (subclass `processLine`):

```java
import org.zeroturnaround.exec.stream.LogOutputStream;

new ProcessExecutor().command("java", "-version")
    .redirectOutput(new LogOutputStream() {
      @Override
      protected void processLine(String line) {
        // handle line
      }
    })
    .execute();
```

## Do not

- `new ProcessBuilder(...)` / `ProcessBuilder.start()` for external commands
- `Runtime.getRuntime().exec(...)`
- Apache Commons Exec
- Raw `Process` stream copy loops **instead of** zt-exec (use zt-exec redirects and `readOutput` / handlers instead)

For kill-focused tooling beyond timeout/`destroyOnExit`, see [zt-process-killer](https://github.com/zeroturnaround/zt-process-killer).
