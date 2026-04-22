---
name: classical-unit-tests
description: Write Java unit tests following the Classical (Detroit) school. Covers the four pillars, state-over-interactions, fakes vs mocks for managed/unmanaged dependencies, strict Given/When/Then, in-memory fakes as private nested classes, and Lombok on all implementations. Use when writing, reviewing, or refactoring Java unit tests (JUnit 5 + AssertJ), when the user mentions classical school, test doubles, fakes, mocks, regression protection, resistance to refactoring, or Lombok.
---

# Classical-School Java Unit Tests

Writes unit tests that maximize all four pillars (regression protection, resistance to refactoring, fast feedback, maintainability) using the Classical (Detroit) school. Targets Java 21 + JUnit 5 + AssertJ + Spring Boot projects.

## Core Decision Flow

Before writing a test, answer in order:

1. **What unit of behavior am I verifying?** (behavior, not class/method)
2. **Is the observable outcome a return value, final state, or outgoing command?**
3. **For each collaborator: is it a managed or unmanaged dependency?**

Then pick the matching shape from [Test Shapes](#test-shapes).

## The Four Pillars

| Pillar                    | Rule                                                                                                                      |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Regression protection     | Exercise real domain code; domain entities and value objects are real instances.                                          |
| Resistance to refactoring | Assert observable behavior: return values, final state, or outgoing commands to unmanaged dependencies.                   |
| Fast feedback             | Milliseconds per test. Pure JUnit in `src/test/`; Spring context, DB, and network belong in a separate test source set.   |
| Maintainability           | One behavior per test; minimal setup; factory methods over shared mutable state.                                          |

A failing test for unchanged external behavior is a false positive — it means the test is coupled to internals and must be rewritten against observable behavior.

## Test Doubles: The Rules

| Dependency kind                                             | Example                                                                     | Double                                                                 |
| ----------------------------------------------------------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Domain entity / value object                                | `Order`, `Product`, `Money`                                                 | **Real instance**                                                      |
| In-process collaborator with only logic                     | Domain service                                                              | **Real instance**                                                      |
| Managed out-of-process (app-owned DB/table)                 | PostgreSQL owned by this service                                            | **In-memory fake** in unit tests; real DB in integration tests         |
| Unmanaged out-of-process (observable side effect)           | SMTP, payment gateway, cross-context Kafka producer                         | **Mock**; verify the outgoing command                                  |
| Pure read (incoming data)                                   | Config provider, clock                                                      | **Stub** returning canned values                                       |

## Fakes

Write **in-memory fakes** (`HashMap`-backed repos, `List`-backed outboxes) to replace managed dependencies. Fakes implement the same port interface production code depends on.

### Declaration

Declare the SUT and its collaborators as `private final` instance fields. JUnit 5's default PER_METHOD lifecycle instantiates the test class once per test method, so fields are fresh each test.

```java
class OrderServiceTest {

    private final OrderRepository orderRepository = new InMemoryOrderRepository();
    private final OrderService orderService = new OrderService(orderRepository);

    @Test
    void shouldMarkOrderPaidWhenPaymentSucceeds() {
        // given
        var order = new Order(OrderId.of("o-1"), Money.of(100));
        orderRepository.save(order);

        // when
        orderService.markPaid(OrderId.of("o-1"));

        // then
        assertThat(orderRepository.findById(OrderId.of("o-1")).orElseThrow().status())
            .isEqualTo(OrderStatus.PAID);
    }

    private static final class InMemoryOrderRepository implements OrderRepository {
        private final Map<OrderId, Order> store = new HashMap<>();
        @Override public void save(Order o) { store.put(o.id(), o); }
        @Override public Optional<Order> findById(OrderId id) { return Optional.ofNullable(store.get(id)); }
    }
}
```

Implementations follow the [Lombok](#lombok) section; `OrderService` above is `@RequiredArgsConstructor`.

When dependency configuration varies per test (e.g., a different `Clock`), use a private factory method that returns a freshly-wired SUT for that test.

### Scope

- Used in one test class → `private static` nested class in that file.
- Reused across ≥2 test classes → promote to `src/testFixtures/` (or the project's shared test source set).

### Role-based naming — match sophistication to what the test asserts

A collaborator's behavior must match the test's assertions exactly. Pick the form by role:

| Form             | Role                                                       | When to use                                                                             |
| ---------------- | ---------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Bare `mock(...)` | Inert orthogonal collaborator                              | Required constructor arg whose behavior is orthogonal to the test (logging, MDC, tracing, metrics counters no test asserts on) |
| `InMemoryXxx`    | Real reads after writes over an in-memory store            | Repositories, caches                                                                    |
| `RecordingXxx`   | Captures arguments/events for later assertion              | A test asserts on what was recorded                                                     |
| `StubXxx`        | Returns a canned value for pure queries                    | `Clock`, config provider                                                                |
| `ConfigurableXxx`| Test configures a scripted **return value** for a query    | ≥2 tests need different canned responses                                                |

A hand-written `NoopXxx` nested class is rarely needed; reach for one only when Mockito can't mock the type (e.g., a `final` class you don't own) or when a real typed no-op is clearer at the call site.

When some tests assert on a collaborator and others don't, keep a bare `mock(...)` as the default field and construct a `RecordingXxx` inside the specific tests that assert on it.

#### Bare `mock()` for orthogonal collaborators

When a collaborator is truly inert to the test, a bare Mockito mock declared as a `private final` field is the default — no nested class needed. It is a notation choice, not a new test-double category.

```java
class OrderProcessorTest {

    private final LoggingContextWrapper loggingContextWrapper = mock(LoggingContextWrapper.class);

    private final InMemoryOrderRepository orderRepository = new InMemoryOrderRepository();
    private final OrderProcessor processor = new OrderProcessor(orderRepository, loggingContextWrapper);

    @Test
    void shouldPersistOrderWhenEventHandled() {
        // given
        var event = OrderEventFixtures.orderPlaced();

        // when
        processor.handle(event);

        // then
        assertThat(orderRepository.findById(event.orderId()))
            .get().extracting(Order::status).isEqualTo(OrderStatus.PLACED);
    }
}
```

Allowed only when **all** of the following hold:

- **Orthogonal role.** The collaborator is a side-channel the SUT touches but the test does not care about (logging, MDC, tracing, metrics counters no test asserts on). Repositories, gateways, payment clients, Kafka producers, email senders, and app-owned DB ports are never orthogonal — they use `InMemoryXxx` / `RecordingXxx`, or a real Mockito mock under the [unmanaged side-effects rule](#mocks-unmanaged-side-effects-only).
- **No stubbing.** When `when(...).thenReturn(...)` / `doReturn(...)` / `doAnswer(...)` is needed, the collaborator feeds data into logic flow — switch to `StubXxx` / `ConfigurableXxx` / `InMemoryXxx`.
- **Return value not consumed.** Either every invoked method is `void`, or the SUT discards the return. When the SUT reads the result, use `StubXxx` / `InMemoryXxx` so the test documents the contract instead of depending on Mockito defaults.
- **No verification.** No `verify(...)`, no `verifyNoInteractions(...)`, no `ArgumentCaptor`. Interactions that matter belong to an unmanaged dependency (real mock) or a `RecordingXxx` fake.
- **Class-level `private final` field.** Never inline per test — inline placement signals the test is about to stub or verify it.

When any of the five conditions is violated, write the proper `StubXxx` / `InMemoryXxx` / `RecordingXxx` nested class instead.

### Fakes represent working collaborators

A fake records calls, serves canned reads, or mutates an in-memory store. Failure modes live outside the fake: no `willThrow(...)` method, no `nextError` field, no `throw` branch in an overridden port method.

To test how the SUT reacts to a dependency failure, construct a Mockito mock **inline inside that one test**, wire it into a locally-constructed SUT, and keep every other collaborator pointing at its shared field-level fake. Assert on the observable outcome — thrown exception, rolled-back state, or emitted failure event.

```java
class OrderServiceTest {

    private final OrderRepository orderRepository = new InMemoryOrderRepository();
    private final NotificationGateway notificationGateway = mock(NotificationGateway.class);
    private final OrderService orderService = new OrderService(orderRepository, notificationGateway);

    @Test
    void shouldWrapRepositoryFailureAsDomainException() {
        // given
        var throwingRepository = mock(OrderRepository.class);
        when(throwingRepository.save(any())).thenThrow(new DataAccessException("boom"));
        var orderService = new OrderService(throwingRepository, notificationGateway);
        var order = new Order(OrderId.of("o-1"), Money.of(100));

        // when then
        assertThatThrownBy(() -> orderService.place(order))
            .isInstanceOf(OrderPlacementFailedException.class)
            .hasMessageContaining("o-1");
    }
}
```

When the SUT swallows the failure (e.g., a handler that emits a failure event or dead-letter entry), assert on the recorded side effect via a `RecordingXxx` fake — same inline-mock injection, different observable outcome.

If you reach for the inline-mock pattern in a second test, build a `ConfigurableXxx` fake instead.

## Mocks: Unmanaged Side Effects Only

Use Mockito to verify outgoing commands to the outside world (emails, external APIs, cross-boundary Kafka, webhooks):

```java
// then
verify(emailGateway).send(argThat(e -> e.to().equals("a@b.com")));
verifyNoMoreInteractions(emailGateway);
```

For managed dependencies (the app's own DB/repository), assert on final state through the fake's public API. Pure read stubs provide inbound data and are read from, not verified.

For orthogonal collaborators (logging, MDC, tracing, metrics counters no test asserts on), use a bare `mock()` field as described in [Role-based naming](#role-based-naming--match-sophistication-to-what-the-test-asserts).

## Lombok

Implementations (SUT, adapters, fakes with deps) use Lombok — never hand-write what it can generate:

- `@RequiredArgsConstructor` for any class with `private final` collaborators.
- `@Slf4j` for logging.
- `@Getter` on a recording fake's `List`/`Map` field.
- `@Value` only when a `record` won't do; `@Builder` for ≥4 args.
- Forbidden: `@Data`, `@AllArgsConstructor` / `@NoArgsConstructor` on domain types, any Lombok on test classes.

## Structural Rules

### Strict Given / When / Then

```java
@Test
void shouldRejectNegativeDeposit() {
    // given
    var account = Account.opened(Money.zero());

    // when then
    assertThatThrownBy(() -> account.deposit(Money.of(-1)))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("positive");
}
```

- Exactly **one** method invocation in `// when`. When two feel necessary, redesign the SUT for cohesion.
- Omit `// given` when there is zero setup.
- Exception-path tests use a single `// when then` block and pass the lambda directly to `assertThatThrownBy(...)`.
- Zero branching in test bodies: use `@ParameterizedTest` + `@CsvSource` for variation.

### Naming

`shouldXxxWhenYyy`, or a plain English sentence describing behavior.

## Test Shapes

Pick one shape per test.

### 1. Output-Based (preferred — mathematical function)

Pure input → pure output. Maximizes all four pillars.

```java
@Test
void shouldComputeDiscountedPriceForPremiumCustomer() {
    var result = PricingCalculator.compute(Money.of(100), CustomerTier.PREMIUM);
    assertThat(result).isEqualTo(Money.of(80));
}
```

When production code isn't pure enough for this shape, extract the logic into a pure function (Functional Core, Imperative Shell) before writing the test.

### 2. State-Based

The SUT mutates a real collaborator; assert against final observable state, read through the same public API production code uses.

```java
// then
assertThat(orders.findById(id).orElseThrow().status()).isEqualTo(PAID);
```

### 3. Communication-Based (rare — unmanaged only)

```java
// then
verify(paymentGateway).charge(eq(CardToken.of("tok")), eq(Money.of(100)));
verifyNoMoreInteractions(paymentGateway);
```

## Assertions (AssertJ)

- Use `assertThat(...)` exclusively. For exceptions: `assertThatThrownBy(...)` or `assertThatExceptionOfType(...)`.
- DTOs, records, value objects, maps, unordered collections: `assertThat(actual).usingRecursiveComparison().isEqualTo(expected);`.
- One logical assertion per test. Multiple `assertThat` lines are fine when they describe one behavior.

## Humble Object / Architectural Alignment

When a SUT is hard to unit-test, refactor the architecture before adding mocks:

- Pull I/O, framework glue, or Kafka plumbing into a thin "humble" adapter.
- Move the wrapped logic into a pure domain class.
- Unit-test the domain class output-based; cover the humble adapter with one integration test.

Signals the architecture needs this refactor:

- A single test would need more than two mocks.
- A mocked method's signature would change under a non-behavioral refactor.
- The test wants to reach into private state or `spy()` on the SUT.

## Parameterized Tests

`@ParameterizedTest` + `@CsvSource` collapses near-duplicate tests.

```java
@ParameterizedTest
@CsvSource(textBlock = """
    REGULAR, 100, 100
    SILVER,  100,  95
    GOLD,    100,  90
    PREMIUM, 100,  80
""")
void shouldApplyTierDiscount(CustomerTier tier, int gross, int expected) {
    assertThat(PricingCalculator.compute(Money.of(gross), tier))
        .isEqualTo(Money.of(expected));
}
```

Use `@MethodSource` only when inputs can't be expressed as simple scalars.

## Spring Boot Specifics

- `src/test/` holds pure unit tests. Slice tests and Spring context tests belong in `src/componentTest/` or `src/integrationTest/`.
- Reset state with explicit `@BeforeEach` / `@AfterEach`.
- For time, inject `java.time.Clock` and use `Clock.fixed(...)` in tests.

## Pre-Commit Checklist

- [ ] Exactly one `// when` action.
- [ ] Test body is branch-free (no `if` / `for` / `while` / `switch` / ternary).
- [ ] Domain entities, value objects, and the app's own DB are real instances or in-memory fakes.
- [ ] Managed dependencies are asserted via state through the fake's public API; mocks verify only unmanaged outgoing commands.
- [ ] SUT and collaborators are `private final` fields, or come from a private factory method when configuration varies.
- [ ] Every collaborator is as minimal as the assertions require (bare `mock(...)` for orthogonal / `InMemoryXxx` / `RecordingXxx` / `StubXxx` / `ConfigurableXxx`).
- [ ] Implementations use Lombok (`@RequiredArgsConstructor`, `@Slf4j`, `@Getter`); no `@Data` / `@AllArgsConstructor` / `@NoArgsConstructor` on domain types; no Lombok on tests.
- [ ] Fakes contain no scripted-failure machinery; exception paths use an inline Mockito mock in the one test that needs it.
- [ ] Assertions use AssertJ.
- [ ] Test still passes when production code is refactored without changing behavior.
- [ ] Test name describes observable behavior.
