# JBang Directives (Magic Comments)

JBang uses special comments at the top of the `.java` file to configure the runtime, dependencies, and compiler.

## Dependencies (`//DEPS`)

Used to declare Maven coordinates. JBang will automatically download them.

* Standard: `//DEPS info.picocli:picocli:4.7.0`
* With Classifier: `//DEPS io.netty:netty-transport-native-kqueue:4.1.107.Final:osx-aarch_64`
* Fatjar (Maven 4+ experimental feature): `//DEPS eu.maveniverse.maven.plugins:toolbox:0.1.9:cli@fatjar`
* BOM/POM Management: `//DEPS io.quarkus:quarkus-bom:2.11.2.Final@pom` (Allows subsequent dependencies to omit versions).

## Repositories (`//REPOS`)

By default, JBang uses Maven Central. Add custom repos using `//REPOS`.

* Example: `//REPOS mavencentral,acme=https://maven.acme.local/maven`
* *Note: If you add custom repos, you must explicitly include `mavencentral` if you still need it.*

## Java Version (`//JAVA`)

Forces the script to run with a specific or minimum Java version. JBang will download the JDK if missing.

* Exact version: `//JAVA 17`
* Minimum version: `//JAVA 17+`

## Compiler and Runtime Options

* **Compiler Options**: `//COMPILE_OPTIONS --enable-preview -source 17 -Xlint:unchecked`
* **Runtime Options**: `//RUNTIME_OPTIONS --enable-preview -Xmx2g -Dfile.encoding=UTF-8`
* **Preview Features**: `//PREVIEW` (Automatically adds necessary compile and runtime options for Java preview features).
