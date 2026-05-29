---
name: unittesting
description: >-
  Use when writing new unit tests, updating or fixing existing tests, or improving
  test coverage for a unit of code. Provides a language-agnostic methodology for test
  design — structure, naming, what to cover, isolation — with a strong emphasis on
  sharing fixtures and mocks across test modules. Language-specific examples live in
  examples/ (Python available now).
---

# Unit testing

Methodology for creating and updating unit tests. The principles here are
language-agnostic. For concrete syntax, fixtures, and mocking patterns, read the
matching file in `examples/` for the language you're working in (e.g.
`examples/python.md`). If no file exists for the language, apply these principles
using the conventions already present in the codebase.

## First, orient yourself

Never write a test in a vacuum. Before writing or changing anything:

1. **Read the code under test.** Identify its public contract: inputs, outputs,
   side effects, error/exception conditions, and external dependencies.
2. **Discover the project's test setup.** Find the framework, the test directory
   layout, naming conventions, how tests are run, and — critically — where shared
   fixtures and mocks already live. Mirror what exists. Do not introduce a new
   test framework or restructure the suite without asking.
3. **Find an existing test as a template.** Match its structure, style, and the
   shared helpers it already uses, rather than inventing your own.

## Share fixtures and mocks aggressively

**This is the defining convention of this skill.** Test setup (fixtures, fakes,
mocks, sample data, builders) should be written once and shared across every
module that needs it — not copy-pasted per file.

- Put shared setup in the location the framework provides for cross-module sharing
  (e.g. a `conftest.py` for pytest, a shared test-support module/package, a base
  test fixture). See the language example file for the idiomatic mechanism.
- Before writing a new fixture or mock, **search for an existing one** and reuse or
  extend it. Add a new shared fixture only when nothing suitable exists.
- Prefer **composing** small fixtures over duplicating large setup blocks.
- Scope shared fixtures correctly so they don't leak state between tests (per-test
  by default; broaden scope only when setup is expensive and provably read-only).
- When you find duplicated setup across modules, lift it into the shared location
  as part of your change.

The goal: a new test module should be able to assemble what it needs from existing
shared building blocks, and a change to a mocked dependency should require editing
one shared definition, not many.

## Give every test a header

**Every test carries a header** — a docstring (or the language's equivalent leading
comment) at the top of the test function — with two parts:

1. **Description** — a human-readable statement of *what behavior the test asserts*.
   Describe the expected outcome, not the mechanics.
2. **Assumptions** — the preconditions the test relies on before it exercises the
   behavior: required state, configuration, and what is mocked or treated as given.

```
def test_<name>():
    """<one-line description of the behavior being asserted>.

    Assumptions:
    - <precondition 1>
    - <precondition 2>
    """
```

Why: the header makes intent explicit, so a reader knows what a failure actually
means and can tell whether a changed assumption — rather than a real regression —
is what broke the test. See the language example file for the idiomatic format.

## Creating tests

1. **Enumerate behaviors first.** List the cases before coding: happy path,
   boundaries, invalid input, error/exception paths, and any logic-specific edge
   cases. Each becomes one focused test.
2. **One behavior per test.** Use a descriptive name that states the scenario and
   the expected outcome.
3. **Structure each test as Arrange–Act–Assert** (set up inputs, invoke the unit,
   assert on the result/side effect). Pull the "arrange" step from shared fixtures
   wherever possible.
4. **Keep tests independent and deterministic.** No order dependence, no shared
   mutable state between tests, no reliance on the real clock, network, filesystem,
   or unseeded randomness.
5. **Mock only at boundaries.** Use real objects when they're cheap and reliable.
   Mock I/O, network, time, and randomness — and define those mocks in the shared
   location so other modules reuse them.
6. **Run the tests and confirm they're meaningful.** They must pass for the right
   reason, and each must be able to *fail* if the behavior breaks. A test that
   can't fail is worthless.

## Updating tests

Creating brand-new tests is unrestricted. Editing **existing** tests is governed by
one hard rule:

> **Assertion changes require user confirmation.** If a code change appears to
> require modifying, weakening, or removing an existing assertion, do not make that
> change on your own. Show the user the current assertion, the proposed new
> value/expectation, and why the code change forces it — then wait for explicit
> approval before editing it.

- **Gated (needs confirmation):** changing an assertion's expected value, weakening
  or removing an assertion, changing exception expectations (`raises`/`assertRaises`),
  changing mock-call expectations (`assert_called_*`), changing parametrized expected
  outputs, or deleting/skipping a test (which removes its assertions).
- **Free (no confirmation):** adding new tests, and editing existing tests in ways
  that **don't change what is asserted** — adopting shared fixtures, refactoring the
  arrange step, renaming, restructuring, reformatting, and keeping the header's
  description/assumptions accurate with those non-assertion edits.

When an assertion does change, its header description/assumptions change with it, and
both are part of what the user confirms.

Workflow:

1. **Determine why you're updating.** Did the behavior change on purpose, or is a
   failing test catching a real regression?
2. **When a test fails, decide what's actually wrong** — the code or the test. Do
   not edit a test just to make it green. Understand the failure first.
3. **When behavior changed intentionally and the new contract needs different
   assertions,** surface the change and get confirmation (per the rule above) before
   editing the assertion. You may add new tests for the new behavior without gating,
   and keep existing coverage intact.
4. **Never delete or skip a failing test to reach green** without understanding it —
   and since that removes assertions, confirm it with the user first.
5. **Keep changes consistent** with the suite's existing names, structure, and
   shared fixtures.

## Coverage checklist

Cover the behavior that matters; don't chase 100% for its own sake.

- Happy path / typical inputs
- Boundaries: empty, zero, one, max, off-by-one
- Invalid input and error/exception handling
- Logic-specific edge cases: nulls, duplicates, ordering, overflow
- State changes and observable side effects

## Anti-patterns to avoid

- **Testing implementation details** instead of observable behavior → brittle tests.
- **Over-mocking**: mocking the unit under test, or mocking so much that the test
  only verifies the mocks. Duplicating the same ad-hoc mock in every module instead
  of sharing one definition.
- **Asserting on mock call internals** when an output or state assertion would do.
- **Vacuous assertions** (`assert True`, asserting a value equals itself).
- **Inter-dependent tests**: shared mutable state or reliance on execution order.
- **Non-determinism**: real clock/network, unseeded randomness, `sleep`-based waits.
- **Blindly regenerated** snapshot/golden files.
- **Bending the test to fit a bug** instead of fixing the bug.
- **Testing the language, framework, or a third-party library** rather than your code.
