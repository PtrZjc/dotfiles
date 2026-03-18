---
name: spring-boot-dynamodb-repository
description: Use this skill when implementing AWS DynamoDB repositories in a Java Spring Boot application using the AWS SDK v2 Enhanced Client. It covers entities with StaticTableSchema, repository operation wrappers, and the dual testing strategy (component tests for real DB, unit tests for edge cases).
---

# Spring Boot DynamoDB Repository Implementation

This skill instructs agents on how to correctly implement and test DynamoDB repositories within a Spring Boot application using the AWS SDK v2 Enhanced Client.

### Architecture & Design Rules

1. **Immutable Domain Objects**: The public interfaces of your repositories must use Java `record` types to ensure immutability and thread safety.
2. **Entity Design**:
   - Entities are internal to the adapter layer.
   - Use Lombok annotations (`@Getter`, `@Setter`, `@NoArgsConstructor`, `@EqualsAndHashCode`, `@AllArgsConstructor`, `@Builder(access = AccessLevel.PACKAGE)`).
   - **Do not use AWS SDK annotations** for mapping. Always define a `StaticTableSchema` on the entity class for performance and programmatic control.
3. **Exception Translation**: All AWS SDK operations must be wrapped in a utility class (e.g., `DynamoRepositoryOperation.execute()` or `supply()`) that catches underlying exceptions and rethrows them as a domain-specific `RuntimeException`.
4. **Configuration**: Instantiate your `DynamoDbTable` and repository beans in a standard Spring `@Configuration` class. Use configuration properties (`@ConfigurationProperties`) to manage table name prefixes and suffixes.
5. **JSON Conversions**: If storing complex nested objects or records, implement a custom `AttributeConverter` using Jackson's `ObjectMapper`.

### Testing Strategy

Testing is strictly separated into two distinct packages to ensure behavior validation and 100% code coverage:

1. **Component Tests (`src/componentTest/...`)**:
   - Check the **actual database logic** (Saves, queries, overwrites, TTLs).
   - Use the `aws-testing` library annotations (`@ConfigureDynamoDbServer`, `@DynamoDbTable`, `@DynamoDbGlobalSecondaryIndex`) to spin up local DynamoDB instances.
   - Clean the table before each test run using the provided operations utility.
2. **Unit Tests (`src/test/...`)**:
   - **Only test corner cases** that are otherwise untestable against a real database.
   - Specifically, mock the `DynamoDbTable` to throw underlying AWS exceptions and verify that the repository correctly wraps them into domain exceptions.

### Instructions

- Read `references/implementation.md` to see the expected structure for Entities, Repositories, and Configuration.
- Read `references/testing.md` to see the setup for the Base Component Test and the strictly mocked Unit Tests.

### Gotchas

- When dealing with Time-To-Live (TTL) or timestamps, **never** use `Instant.now()`. Always inject `java.time.InstantSource` into your repositories so tests can provide a fixed clock.
- Table configurations often include dynamic prefixes and suffixes (e.g., table versions). Construct the final table name in the `@Bean` configuration method before passing it to the Enhanced Client.
- Global Secondary Indexes (GSIs) often require duplicating partition key data into specific `gsi` string fields within your entity.
