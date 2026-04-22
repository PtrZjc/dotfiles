---
name: classical-unit-tests
description: Write Java unit tests following the Classical (Detroit) school. Covers the four pillars, state-over-interactions, fakes vs mocks for managed/unmanaged dependencies, strict Given/When/Then, in-memory fakes as private nested records (immutable doubles) or classes (stateful doubles), and Lombok on all stateful implementations. Use when writing, reviewing, or refactoring Java unit tests (JUnit 5 + AssertJ), when the user mentions classical school, test doubles, fakes, mocks, records, regression protection, resistance to refactoring, or Lombok.
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

Name the SUT field after its production type in camelCase (`orderService`, `pricingCalculator`); never `sut` / `SUT`. Extract literals that repeat across the class (IDs, amounts, tokens, usernames) as `private static final` constants at the top of the test class — one source of truth, and each test reads as prose.

```java
class OrderServiceTest {

    private static final OrderId ORDER_ID = OrderId.of("o-1");
    private static final Money AMOUNT = Money.of(100);

    private final OrderRepository orderRepository = new InMemoryOrderRepository();
    private final OrderService orderService = new OrderService(orderRepository);

    @Test
    void shouldMarkOrderPaidWhenPaymentSucceeds() {
        // given
        var order = new Order(ORDER_ID, AMOUNT);
        orderRepository.save(order);

        // when
        orderService.markPaid(ORDER_ID);

        // then
        assertThat(orderRepository.findById(ORDER_ID).orElseThrow().status())
            .isEqualTo(OrderStatus.PAID);
    }

    private static final class InMemoryOrderRepository implements OrderRepository {
        private final Map<OrderId, Order> store = new HashMap<>();
        @Override public void save(Order o) { store.put(o.id(), o); }
        @Override public Optional<Order> findById(OrderId id) { return Optional.ofNullable(store.get(id)); }
    }
}
```

Implementations follow the [Lombok](#lombok) section; `OrderService` above is `@RequiredArgsConstructor`. `InMemoryOrderRepository` cannot be a `record` because it holds a mutable `Map` — see [Records vs classes for doubles](#records-vs-classes-for-doubles).

When dependency configuration varies per test (e.g., a different `Clock`), use a private factory method that returns a freshly-wired SUT for that test.

### Scope

- Used in one test class → `private static` nested class in that file.
- Reused across ≥2 test classes → promote to `src/testFixtures/` (or the project's shared test source set).

### Role-based naming — match sophistication to what the test asserts

A collaborator's behavior must match the test's assertions exactly. Pick the form by role:

| Form             | Role                                                       | When to use                                                                             | Shape      |
| ---------------- | ---------------------------------------------------------- | --------------------------------------------------------------------------------------- | ---------- |
| Bare `mock(...)` | Inert orthogonal collaborator                              | Required constructor arg whose behavior is orthogonal to the test (logging, MDC, tracing, metrics counters no test asserts on) | —          |
| `InMemoryXxx`    | Real reads after writes over an in-memory store            | Repositories, caches                                                                    | class      |
| `RecordingXxx`   | Captures arguments/events for later assertion              | A test asserts on what was recorded                                                     | class      |
| `StubXxx`        | Returns canned value(s) for pure queries                   | `Clock`, config provider, role-selector, or any shared instance tests reconfigure per test | **record** (preferred) / class with `@Setter` when ≥2 tests need different canned responses on a shared field |

The `Shape` column is a default, not an escape valve: the shape follows from whether the double needs mutable state. See [Records vs classes for doubles](#records-vs-classes-for-doubles).

`StubXxx` is the single label for any double that serves indirect inputs (canned return values). Whether it's a `record` built once per test or a class with `@Setter` reconfigured per test is a shape decision, not a separate role.

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
- **No stubbing.** When `when(...).thenReturn(...)` / `doReturn(...)` / `doAnswer(...)` is needed, the collaborator feeds data into logic flow — switch to `StubXxx` / `InMemoryXxx`.
- **Return value not consumed.** Either every invoked method is `void`, or the SUT discards the return. When the SUT reads the result, use `StubXxx` / `InMemoryXxx` so the test documents the contract instead of depending on Mockito defaults.
- **No verification.** No `verify(...)`, no `verifyNoInteractions(...)`, no `ArgumentCaptor`. Interactions that matter belong to an unmanaged dependency (real mock) or a `RecordingXxx` fake.
- **Class-level `private final` field.** Never inline per test — inline placement signals the test is about to stub or verify it.

When any of the five conditions is violated, write the proper `StubXxx` / `InMemoryXxx` / `RecordingXxx` nested class instead.

### Records vs classes for doubles

Prefer a Java `record` for any test double that has no mutable state. Fall back to a class with `@RequiredArgsConstructor` only when the double must carry mutable state. The decision is mechanical:

| Mutable state in the double                                       | Shape                                         |
| ----------------------------------------------------------------- | --------------------------------------------- |
| None — fully defined by constructor args                          | **`record`**                                  |
| `Map` / `List` store written during the test                      | `class` (InMemory / Recording)                |
| `@Setter` field reconfigured per test                             | `class` (Stub with `@Setter`)                 |
| Needs `@Getter` exposure of captured data                         | `class` (Recording)                           |

Records suit `StubXxx` doubles that serve canned values based on their construction (a fixed `Clock`, a role selector, a hard-wired return value), and any inert no-op double you might otherwise hand-write. They enforce immutability, remove boilerplate, and make the absence of `@Setter` self-documenting. When a test needs to swap the canned value per test on a shared field instance, the stub becomes a class with `@Setter` — still a stub, just a mutable shape.

```java
// Stateless stub — record because config is fixed at construction
private record StubClock(Instant fixed, ZoneId zone) implements Clock {
    @Override public Instant instant()        { return fixed; }
    @Override public ZoneId getZone()         { return zone; }
    @Override public Clock withZone(ZoneId z) { return new StubClock(fixed, z); }
}

// Immutable port stub selecting by an enum — record
private record StubTaxCalculator(Country supportedCountry) implements TaxCalculator {
    @Override public Money computeTax(Money amount) {
        return amount.multiply(new BigDecimal("0.20"));
    }
    @Override public Country getSupportedCountry() {
        return supportedCountry;
    }
}

// Mutable store — class, never a record
private static final class InMemoryOrderRepository implements OrderRepository {
    private final Map<OrderId, Order> store = new HashMap<>();
    @Override public void save(Order o)                   { store.put(o.id(), o); }
    @Override public Optional<Order> findById(OrderId id) { return Optional.ofNullable(store.get(id)); }
}

// Captures invocations — class with @Getter, never a record
private static final class RecordingAuditLog implements AuditLog {
    @Getter private final List<AuditEntry> entries = new ArrayList<>();
    @Override public void append(AuditEntry entry) { entries.add(entry); }
}

// Reconfigurable stub — class with @Setter because ≥2 tests need different canned responses
// on this shared field-level instance
private static final class StubPricingPolicy implements PricingPolicy {
    @Setter private Money configured;
    @Override public Money priceFor(Product product) { return configured; }
}
```

When a port's method name would collide with a record accessor, just implement it explicitly (as in `getSupportedCountry()` above) — that's a styling wrinkle, not a reason to reach for a class. When the record would need no extra methods (all interface methods map 1:1 to components), even better: the body stays empty.

Test-only value types (domain stand-ins referenced by these doubles) should also be records.

### Fakes represent working collaborators

A fake records calls, serves canned reads, or mutates an in-memory store. Failure modes live outside the fake: no `willThrow(...)` method, no `nextError` field, no `throw` branch in an overridden port method.

To test how the SUT reacts to a dependency failure, construct a Mockito mock **inline inside that one test**, wire it into a locally-constructed SUT, and keep every other collaborator pointing at its shared field-level fake. Assert on the observable outcome — thrown exception, rolled-back state, or emitted failure event.

```java
class OrderServiceTest {

    private final OrderRepository orderRepository = new InMemoryOrderRepository();
    private final NotificationGateway notificationGateway = mock(NotificationGateway.class);
    private final OrderService orderService = new OrderService(orderRepository, notificationGateway);

    private static final OrderId ORDER_ID = OrderId.of("o-1");
    private static final Money AMOUNT = Money.of(100);

    @Test
    void shouldWrapRepositoryFailureAsDomainException() {
        // given
        var throwingRepository = mock(OrderRepository.class);
        when(throwingRepository.save(any())).thenThrow(new DataAccessException("boom"));
        var orderService = new OrderService(throwingRepository, notificationGateway);
        var order = new Order(ORDER_ID, AMOUNT);

        // when then
        assertThatThrownBy(() -> orderService.place(order))
            .isInstanceOf(OrderPlacementFailedException.class)
            .hasMessageContaining(ORDER_ID.value());
    }
}
```

When the SUT swallows the failure (e.g., a handler that emits a failure event or dead-letter entry), assert on the recorded side effect via a `RecordingXxx` fake — same inline-mock injection, different observable outcome.

If you reach for the inline-mock pattern in a second test to feed canned data (rather than to simulate a failure), build a `StubXxx` with `@Setter` instead.

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

Lombok is the boilerplate remover for **stateful** implementations; `record` is the first choice for immutable ones. Order of preference for any nested test double or small value type:

1. **`record`** — whenever the type has no mutable state (see [Records vs classes for doubles](#records-vs-classes-for-doubles)). Zero Lombok.
2. **Class + `@RequiredArgsConstructor`** — when the type needs mutable state (in-memory store, recording buffer, `@Setter` config).

Implementations (SUT, adapters, stateful fakes) use Lombok — never hand-write what it can generate:

- `@RequiredArgsConstructor` for any class with `private final` collaborators (including stateful fakes). Do **not** apply it to a class that could be a `record`.
- `@Slf4j` for logging.
- `@Getter` on a recording fake's `List`/`Map` field.
- `@Setter` on a reconfigurable `StubXxx` fake's scripted-value field.
- `@Value` only when a `record` won't do; `@Builder` for ≥4 args.
- Forbidden: `@Data`, `@AllArgsConstructor` / `@NoArgsConstructor` on domain types, any Lombok on test methods or on `record` doubles.

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

- Test methods: `shouldXxxWhenYyy`, or a plain English sentence describing behavior.
- SUT field: camelCased production type name (`orderService`, `pricingCalculator`). Never `sut` / `SUT` — it hides what the test is actually exercising.
- Repeated literals (IDs, amounts, tokens, usernames, URLs): `private static final` constants at the top of the test class, named after the role they play (`ORDER_ID`, `AMOUNT`, not `ID_1`).

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
- [ ] SUT field is named after the production type (no `sut` / `SUT`); literals repeated across tests are `private static final` constants.
- [ ] Every collaborator is as minimal as the assertions require (bare `mock(...)` for orthogonal / `InMemoryXxx` / `RecordingXxx` / `StubXxx`).
- [ ] Every immutable double is a `record`; `@RequiredArgsConstructor` classes are reserved for doubles with mutable state (`InMemoryXxx` / `RecordingXxx` / `StubXxx` with `@Setter`). Test-only value types are records.
- [ ] Stateful implementations use Lombok (`@RequiredArgsConstructor`, `@Slf4j`, `@Getter`, `@Setter`); no `@Data` / `@AllArgsConstructor` / `@NoArgsConstructor` on domain types; no Lombok on records or on test methods.
- [ ] Fakes contain no scripted-failure machinery; exception paths use an inline Mockito mock in the one test that needs it.
- [ ] Assertions use AssertJ.
- [ ] Test still passes when production code is refactored without changing behavior.
- [ ] Test name describes observable behavior.
