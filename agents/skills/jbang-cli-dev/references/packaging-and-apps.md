# App Installation and Exporting

JBang provides robust ways to package and distribute scripts.

## Installing as a System Command (App)

The `jbang app` system allows installing scripts as system commands, making them available anywhere on the host system.

* **Basic install**: `jbang app install myscript.java`
* **Install with custom name**: `jbang app install --name mytool myscript.java`
* **Update/Force install**: `jbang app install --force --name mytool myscript.java`
* **Uninstall**: `jbang app uninstall mytool`
* **List installed apps**: `jbang app list`

## Exporting Scripts

Use `jbang export` to convert a JBang script into a portable format or full project.

* **Fat JAR (Includes all dependencies)**:
  `jbang export fatjar myscript.java`
* **Portable JAR (Dependencies placed in a relative `lib/` folder)**:
  `jbang export portable myscript.java`
* **Native Executable (Requires GraalVM)**:
  `jbang export native myscript.java`
* **Export to Maven/Gradle Project**:
  `jbang export maven --group org.acme --artifact mytool --version 1.0.0-SNAPSHOT myscript.java`
  `jbang export gradle --group org.acme --artifact mytool --version 1.0.0-SNAPSHOT myscript.java`
