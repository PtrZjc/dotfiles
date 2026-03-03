---
name: Java Development Standards
description: General coding standards, immutability, and Lombok guidelines for Java files.
applyTo: "**/*.java"
---

# Java Development Guidelines

## Data Structures: Records vs. Classes
- **Records for Data**: Use Java `record` as the default choice for immutable data carriers like DTOs, Value Objects, and API models.
- **Classes for Behavior**: Use standard `class` for components that encapsulate business logic, services, and stateful behavior.
- **Smart Construction**: Enhance both record and class types with Lombok's `@Builder` when construction is complex. For classes with behavior, use `@RequiredArgsConstructor` for dependency injection.

## Code Style & Conventions
- **Immutability First**: Default to immutable objects and data structures. Never mutate state unless absolutely necessary.
- **Functional Style**: Prefer streams, collectors, and lambda expressions over traditional `for` or `while` loops.
- **Restrictive Visibility**: Use the most restrictive access modifier possible (e.g., `private`, package-private).
- **Modern Collections**: Use `List.of()`, `Set.of()`, and `Map.of()` to create unmodifiable collections.
- **Optional Usage**: Use `Optional` strictly for return types that might be null. Never use `Optional` for method parameters or class fields.

## Lombok Usage
- Use Lombok annotations to reduce boilerplate.
- Do not use `@Value` or `@Data` annotations; use `record` instead.