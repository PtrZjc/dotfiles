# Classical Unit Tests — Source

This skill codifies the unit-testing philosophy taught in:

**Vladimir Khorikov — _Unit Testing: Principles, Practices, and Patterns_ (Manning, 2020)**

- ISBN: 978-1617296277
- Publisher page: <https://www.manning.com/books/unit-testing>
- Author's blog: <https://enterprisecraftsmanship.com/>

## Core ideas borrowed from the book

- **The four pillars of a good unit test**: regression protection, resistance to refactoring, fast feedback, maintainability.
- **Classical (Detroit) school** over the London (mockist) school — prefer real collaborators and state-based assertions over interaction verification.
- **Managed vs. unmanaged dependencies** as the rule for choosing between fakes and mocks:
  - Managed (e.g. the app's own database) → **in-memory fake**.
  - Unmanaged (e.g. SMTP, payment gateway, cross-context Kafka) → **mock** and verify the outgoing command.
- **Output-based > state-based > communication-based** test styles, in that order of preference.
- **Humble Object** pattern: push logic out of hard-to-test shells into pure domain code.
- **Mathematical functions** as the ideal unit — pure inputs, pure outputs, no side effects.

The `SKILL.md` in this folder adapts these ideas to Java 21 + JUnit 5 + AssertJ + Spring Boot, and adds concrete structural rules (strict Given/When/Then, no branching in tests, private nested fakes, etc.).

For the full rationale, examples in C#, and deeper discussion, read the book.
