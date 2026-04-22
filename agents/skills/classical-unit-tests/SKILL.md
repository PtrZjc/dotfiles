---
name: classical-unit-tests
description: Write Java unit tests following the Classical (Detroit) school. Covers the four pillars, state-over-interactions, fakes vs mocks for managed/unmanaged dependencies, strict Given/When/Then, and in-memory fakes as private nested classes. Use when writing, reviewing, or refactoring Java unit tests (JUnit 5 + AssertJ), when the user mentions classical school, test doubles, fakes, mocks, regression protection, or resistance to refactoring.
---

# Classical-School Java Unit Tests

Writes unit tests that maximize all four pillars (regression protection, resistance to refactoring, fast feedback, maintainability) using the Classical (Detroit) school. Targets Java 21 + JUnit 5 + AssertJ + Spring Boot projects. See `README.md` for the source of this philosophy.

## Core Decision Flow

Before writing a test, answer in order:

1. **What unit of behavior am I verifying?** (NOT "what class/method")
2. **Is the observable outcome a return value, final state, or outgoing command?**
3. **For each collaborator: is it a managed or unmanaged dependency?**
4. **Can the logic be restructured as a mathematical function?** (pure, no I/O, no mutation)

Then pick the matching test shape from [Test Shapes](#test-shapes) below.

## The Four Pillars (Non-Negotiable)

| Pillar                    | Hard rule                                                                                                                                            |
| ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Regression protection     | Exercise real domain code; do not mock the domain model.                                                                                             |
| Resistance to refactoring | Assert observable behavior only — no private methods, no internal fields, no interaction checks on collaborators that aren't unmanaged side effects. |
| Fast feedback             | Milliseconds per test. No Spring context, no `@SpringBootTest`, no DB, no network in `src/test/`.                                                    |
| Maintainability           | One behavior per test; minimal setup; factory methods over shared mutable state.                                                                     |

A test that fails when the production code is refactored but external behavior is unchanged is a **false positive** and must be rewritten.

## Test Doubles: The Rules

Use this table — do not deviate:

| Dependency kind                                             | Example                                                                     | Double to use                                                          |
| ----------------------------------------------------------- | --------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Domain entity / value object                                | `Match`, `Score`, `Money`                                                   | **Real object. Never mock.**                                           |
| Managed out-of-process (app-owned DB, app-owned table)      | PostgreSQL owned by this service                                            | **Fake** (in-memory) in unit tests; real instance in integration tests |
| Unmanaged out-of-process (external, observable side effect) | SMTP server, payment gateway, Kafka **producer** to another bounded context | **Mock** and verify the outgoing command                               |
| Pure read stub (incoming data)                              | Config provider, clock                                                      | **Stub** — never verify calls on it                                    |
| In-process collaborator with only logic                     | Domain service                                                              | **Real instance.** Do not mock.                                        |

### Fake Implementation Rule

Write **in-memory fakes** (`HashMap`-backed repos, `List`-backed outboxes) to replace managed dependencies.

- If the fake is used in **only one test class**, declare it as a `private static` nested class in that test file.
- If the fake is reused across ≥2 test classes, promote it to `src/testFixtures/` (or the project's shared test source set).
- The fake must implement the **same port interface** the production code depends on — never a test-only subinterface.

#### Declare collaborators and SUT as `private final` fields — not inside each test

JUnit 5 instantiates the test class **once per test method**, so `private final` fields are effectively fresh per test. This is the default, and it yields the cleanest tests. Do **not** re-instantiate the same fakes in every `// given` block.

Only fall back to a private factory method when a test needs to vary dependency configuration (e.g. a different `Clock`, a stub with a specific canned response).

```java
// PREFERRED: fields, constructed once in declaration order
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

```java
// WRONG: re-instantiating the same fakes in every test
@Test
void shouldMarkOrderPaidWhenPaymentSucceeds() {
    // given
    var orderRepository = new InMemoryOrderRepository();   // DON'T — promote to field
    var orderService = new OrderService(orderRepository);  // DON'T — promote to field
    // ...
}
```

#### Noop by default — add behavior to a fake only when the test asserts on it

A fake's sophistication must match what the test actually verifies. If a collaborator's interactions and state are **not** asserted in the test class, the fake must be a **Noop** with empty method bodies. Do not pre-emptively record invocations, capture arguments, or expose getters that no test reads.

Name fakes by their role so the intent is obvious at the declaration site:

- `NoopXxx` — inert, empty method bodies. Use when the collaborator is a required constructor argument but its behavior is orthogonal to the test's subject (e.g. a logging/MDC wrapper in a processing test).
- `InMemoryXxx` — backing store that supports real reads after writes (repositories, caches).
- `RecordingXxx` — captures arguments/events for later assertion. Only when a test asserts on the captured data.
- `StubXxx` — returns a canned value for pure queries (e.g. `Clock`, config provider).
- `ConfigurableXxx` — test configures a scripted response or exception. Only when ≥2 tests need different scripted behaviors.

```java
// CORRECT — logging is irrelevant to the behavior under test
private static final class NoopLoggingContextWrapper implements LoggingContextWrapper {
    @Override public void populateContext(OriginalEvent event) { }
    @Override public void clearContext() { }
}

// WRONG — recording machinery the test never asserts on
private static final class RecordingLoggingContext implements LoggingContextWrapper {
    private final List<OriginalEvent> populated = new ArrayList<>();
    private int clearCount;
    @Override public void populateContext(OriginalEvent event) { populated.add(event); }
    @Override public void clearContext() { clearCount++; }
    List<OriginalEvent> populatedEvents() { return List.copyOf(populated); }
    int clearCount() { return clearCount; }
}
```

If **some** tests assert on the collaborator and others don't, keep the Noop as the default field and construct a `RecordingXxx` locally (or via a factory method) only in the tests that assert on it. Do not universally upgrade every fake to Recording "just in case".

### Mocks: Only for Unmanaged Side Effects

Use Mockito **only** to verify outgoing commands to the outside world (emails, external APIs, cross-boundary Kafka, webhooks). Never mock:

- Domain entities, value objects, or aggregates
- The application's own database/repository
- Pure query collaborators (use a stub or a real instance)
- Anything whose interactions aren't externally observable

```java
// CORRECT - verifying an outgoing command to an unmanaged dependency
verify(emailGateway).send(argThat(e -> e.to().equals("a@b.com")));

// WRONG - interaction check on a managed dependency leaks implementation details
verify(orderRepository).save(any());   // DON'T
```

Never assert `verify(...)` on a stub that only provides inbound data.

## Structural Rules

### Strict Given / When / Then

```java
@Test
void shouldRejectNegativeDeposit() {
    // given
    var account = Account.opened(Money.zero());

    // when
    ThrowingCallable act = () -> account.deposit(Money.of(-1));

    // then
    assertThatThrownBy(act)
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("positive");
}
```

- **Exactly one** method invocation in `when`. If two are needed, the API lacks cohesion — redesign the SUT, don't compromise the test.
- Omit `// given` only when there is zero setup.
- **Zero branching in tests.** No `if`, `for`, `while`, `switch`, ternaries. Use `@ParameterizedTest` with `@CsvSource` for variation.
- No `static` mutable state and no `@BeforeEach` SUT initialization. Declare the SUT and its collaborators as `private final` instance fields (JUnit instantiates the test class per method, so fields are fresh each test). See [Fake Implementation Rule](#fake-implementation-rule).
- Fall back to a private factory method only when dependency configuration varies per test:

```java
private static OrderService newService(OrderRepository repo) {
    return new OrderService(repo, Clock.fixed(...));
}
```

### Naming

`shouldXxxWhenYyy` or a plain English sentence describing behavior. Never name tests after methods (`testCalculate1`, `testSave_whenNull`).

## Test Shapes

Pick one shape per test. Do not combine.

### 1. Output-Based (Preferred — Mathematical Function)

Pure input → pure output. Maximizes all four pillars.

```java
@Test
void shouldComputeDiscountedPriceForPremiumCustomer() {
    var result = PricingCalculator.compute(Money.of(100), CustomerTier.PREMIUM);
    assertThat(result).isEqualTo(Money.of(80));
}
```

If production code isn't pure enough for this shape, **consider extracting logic into a pure function** (Functional Core, Imperative Shell) before writing the test.

### 2. State-Based

SUT mutates a real collaborator; assert against final observable state.

```java
// then
assertThat(orders.findById(id).orElseThrow().status()).isEqualTo(PAID);
```

Read state through the **same public API** production code uses. Don't reach into private fields via reflection.

### 3. Communication-Based (Rarely — Unmanaged Only)

```java
// then
verify(paymentGateway).charge(eq(CardToken.of("tok")), eq(Money.of(100)));
verifyNoMoreInteractions(paymentGateway);
```

## Assertions (AssertJ, Always)

- Use `assertThat(...)` exclusively. **Never** `org.junit.jupiter.api.Assertions.*`.
- Exceptions: `assertThatThrownBy(...)` or `assertThatExceptionOfType(...)`.
- DTOs, records, value objects, maps, unordered collections:
  `assertThat(actual).usingRecursiveComparison().isEqualTo(expected);`
- Prefer one logical assertion per test. Multiple `assertThat` lines are fine if they describe **one** behavior.

## Humble Object / Architectural Alignment

If the SUT is hard to unit-test, the issue is almost always architectural, not test-tooling.

**Refactor before adding mocks:**

- Pull I/O, framework glue, or Kafka plumbing into a thin "humble" adapter.
- Move the logic it wrapped into a pure domain class.
- Unit-test the domain class output-based; cover the humble adapter with a single integration test.

Signals the architecture — not the test — is wrong:
- You need >2 mocks for a single test.
- A mocked method's signature would change under a non-behavioral refactor.
- You want to assert on private state or `spy()` on the SUT.

## Parameterized Tests

Use `@ParameterizedTest` + `@CsvSource` to collapse near-duplicate tests. Prefer over `@MethodSource` for readability.

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

## Spring Boot Specifics

- `src/test/` is for **pure** unit tests. No `@SpringBootTest`, no `@MockBean`, no `@DirtiesContext`, no DB, no Kafka.
- Slice tests and Spring context tests belong in `src/componentTest/` or `src/integrationTest/`.
- Reset state with explicit `@BeforeEach` / `@AfterEach` — never with `@DirtiesContext`.
- For time, inject `java.time.Clock`. Use `Clock.fixed(...)` in tests — never `Instant.now()` directly in production code.

## Checklist Before Finishing a Test

- [ ] Exactly one `when` action.
- [ ] No `if` / `for` / `while` / `switch` / ternary in the test body.
- [ ] No mocks of domain objects, value objects, or the app's own DB.
- [ ] No interaction verification on stubs or managed dependencies.
- [ ] SUT and collaborators declared as `private final` fields (or a private factory method if dependencies vary per test) — never re-instantiated in every `// given`.
- [ ] Every fake is as minimal as the assertions require: `Noop*` when the collaborator is irrelevant to the test, `Recording*` only when a test asserts on the captured data.
- [ ] Assertions use AssertJ only.
- [ ] Test still passes if production code is refactored without changing behavior.
- [ ] Test name describes observable behavior, not the method called.

## Anti-Patterns (Reject On Sight)

- `when(repo.save(any())).thenReturn(...)` for an app-owned repository → replace with in-memory fake.
- `verify(repo).save(any())` → assert on state via the fake, not on the call.
- `@BeforeEach` initializing the SUT → use `private final` fields or a factory method instead.
- Re-instantiating the same fake (`var repo = new InMemoryRepo();`) inside every test's `// given` → promote it to a `private final` field.
- A `Recording*` or `Configurable*` fake whose captured data or scripted behavior is never referenced by any assertion → replace with a `Noop*` fake with empty method bodies.
- `ReflectionTestUtils.setField(...)` or `@InjectMocks` digging into privates → sign the API is wrong.
- Tests named `test1`, `testSaveCase2`, `testMethodX` → rename to behavior.
- One test covering three behaviors via multiple `// when` blocks → split into three tests.
- `assertTrue(list.size() == 3)` → `assertThat(list).hasSize(3)`.
