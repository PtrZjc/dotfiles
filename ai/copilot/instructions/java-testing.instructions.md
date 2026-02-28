---
name: Java Testing Standards
description: Guidelines for writing, structuring, and running tests using AssertJ and JUnit 5.
applyTo: "src/test/java/**/*.java,**/*Test.java,**/*Tests.java"
---

# Java Testing Standards

## Testing Framework & Assertions
- **Always use AssertJ**: Use AssertJ assertions (e.g., `assertThat()`) for all test assertions. DO NOT use JUnit's built-in assertions (`assertEquals`, `assertTrue`, etc.).
- **Single Assertion for DTOs**: For data transfer objects (DTOs), simple value objects, maps, and unordered collections, use a single `assertThat(result).usingRecursiveComparison().isEqualTo(expected)` to verify state.

## Test Structure & Naming
- **Test Naming**: Use short, descriptive names following the `shouldXxxx` pattern (e.g., `shouldReturnEmptyWhenListIsNull`).
- **Test Structure**: Always structure tests using `// given`, `// when`, `// then` comments. The `// given` section can be omitted if no setup is required.
- **Readability**: Focus on test readability and clear intent over complex setup or clever assertions.

## Parameterization & Data
- **Parameterized Tests**: Use `@ParameterizedTest` where possible to reduce code duplication and test multiple scenarios efficiently.
- **Data Sources**: Prefer `@CsvSource` over `@MethodSource` when possible for better readability and simpler test data management.

## Test Execution (When using Chat/Agents)
- **Running Tests**: When executing tests or verify your work, ALWAYS use the `--info` flag to prevent timeouts: `./gradlew test --info`.
- **Run Targeted Tests**: Always run the specific test class or method you are working on, rather than the entire test suite, to save time and resources.
- **Compilation**: Do not make a separate step for checking compilation. Always run the tests directly.
- **Output**: Do not pipe into `tail` or similar commands that truncate output. Always read the full execution output.