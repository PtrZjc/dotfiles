# Testing Reference

## 1. Component Tests (src/componentTest/java)

Component tests verify real database queries. Assume the `aws-testing` framework is present.

```java
// Base configuration
@SpringBootTest(classes = {DynamoDbComponentConfig.class}, webEnvironment = SpringBootTest.WebEnvironment.NONE)
@ConfigureDynamoDbServer(value = {
    @DynamoDbTable(
        name = "myTable-v1",
        partitionKey = @Key(name = "Id", type = KeyType.STRING)
    )
}, port = @DynamoDbLocalPort(type = DynamoDbLocalPort.PortType.RANDOM_PORT))
abstract class BaseDynamoComponentTest {
    static final String TABLE_VERSION_SUFFIX = "-v1";

    @Autowired
    protected DynamoDbOperations dynamoDbOperations;
}

// Actual Test
class DynamoMyRepositoryComponentTest extends BaseDynamoComponentTest {
    @Autowired
    private MyRepository repository;

    @BeforeEach
    void setUp() {
        dynamoDbOperations.cleanTable(MyEntity.TABLE_NAME + TABLE_VERSION_SUFFIX);
    }

    @Test
    void shouldSaveAndFindRecord() {
        repository.save("123", new MyRecord("123", "test"));
        assertThat(repository.find("123")).isPresent();
    }
}
```

## 2. Unit Tests (src/test/java)

Unit tests strictly handle corner cases (like underlying DB failures) to guarantee 100% coverage.

```java
@MockitoSettings
class DynamoMyRepositoryTest {
    @Mock
    private DynamoDbTable<MyEntity> table;
    private DynamoMyRepository repository;

    @BeforeEach
    void setUp() {
        repository = new DynamoMyRepository(table, InstantSource.fixed(Instant.now()));
    }

    @Test
    void shouldThrowDomainExceptionWhenSaveFails() {
        doThrow(new RuntimeException("AWS Error")).when(table).putItem(any(MyEntity.class));

        assertThatCode(() -> repository.save("123", new MyRecord("123", "test")))
            .isInstanceOf(CustomDomainRepositoryException.class)
            .hasMessage("Error during executing DynamoDB operation");
    }
}
```
