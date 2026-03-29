# IDE Integration and Debugging

JBang is designed to seamlessly integrate with standard Java IDEs without requiring a `pom.xml` or `build.gradle` in the project directory.

## Editing in an IDE (`jbang edit`)

JBang can generate a temporary project with symbolic links and resolved dependencies, then open it in an IDE.

* **Open in VS Code / VSCodium**: `jbang edit --open=code myscript.java`
* **Open in IntelliJ IDEA**: `jbang edit --open=idea myscript.java`
* **Open in Eclipse**: `jbang edit --open=eclipse myscript.java`
* **Live Mode**: `jbang edit --live myscript.java` (Watches for file changes and regenerates the temporary project to pick up new dependencies automatically).
* **Sandbox Mode**: `jbang edit -b myscript.java` (Edits in sandbox mode, useful when the editor has no JBang support).

## Debugging

You can suspend script execution and attach a remote debugger using the `--debug` flag.

* **Standard Debug**: `jbang --debug myscript.java` (Suspends execution and listens on port 4004).
* **Custom Port**: `jbang --debug=5006 myscript.java`
* **Dynamic Port**: `jbang --debug=address=5000? myscript.java` (Finds a free port starting at 5000).
* **Advanced Options**: `jbang --debug=server=n,suspend=y myscript.java`
