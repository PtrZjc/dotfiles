# Implementation Reference

## 1. Entity Pattern with StaticTableSchema

```java
@Getter
@Setter
@NoArgsConstructor
@EqualsAndHashCode
@AllArgsConstructor
@Builder(access = AccessLevel.PACKAGE)
class MyEntity {
    static final String TABLE_NAME = "myTable";
    static final String PARTITION_KEY = "Id";

    private String id;
    private String data;
    private Long expirationTime; // For TTL

    static final TableSchema<MyEntity> TABLE_SCHEMA =
        StaticTableSchema.builder(MyEntity.class)
            .newItemSupplier(MyEntity::new)
            .addAttribute(String.class, a -> a.name(PARTITION_KEY)
                .getter(MyEntity::getId)
                .setter(MyEntity::setId)
                .tags(StaticAttributeTags.primaryPartitionKey()))
            .addAttribute(String.class, a -> a.name("Data")
                .getter(MyEntity::getData)
                .setter(MyEntity::setData))
            .build();
}
```

## 2. Operation Wrapper

Wrap all DB interactions to ensure domain exceptions are thrown instead of AWS SDK exceptions.

```java
final class DynamoRepositoryOperation {
    public static final String ERROR_MESSAGE = "Error during executing DynamoDB operation";

    public static <T> T supply(Supplier<T> operation) {
        try {
            return operation.get();
        } catch (Exception e) {
            throw new CustomDomainRepositoryException(ERROR_MESSAGE, e);
        }
    }

    public static void execute(Runnable operation) {
        try {
            operation.run();
        } catch (Exception e) {
            throw new CustomDomainRepositoryException(ERROR_MESSAGE, e);
        }
    }
}
```

## 3. Repository Implementation

```java
@Slf4j
@RequiredArgsConstructor
class DynamoMyRepository implements MyRepository {
    private final DynamoDbTable<MyEntity> table;
    private final InstantSource instantSource;

    @Override
    public Optional<MyRecord> find(String id) {
        return supply(() -> {
            Key key = Key.builder().partitionValue(id).build();
            return Optional.ofNullable(table.getItem(key))
                    .map(entity -> new MyRecord(entity.getId(), entity.getData()));
        });
    }
}
```
