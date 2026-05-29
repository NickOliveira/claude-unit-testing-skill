# Python

Concrete patterns for applying the methodology in Python. Defaults to **pytest**
(the common choice); `unittest` from the stdlib is also covered briefly. Match
whatever the project already uses.

## Conventions

- **Files:** `test_*.py` or `*_test.py`, usually under a `tests/` directory.
- **Functions:** `test_*`; **classes:** `Test*` (no `__init__`).
- **Run:** `pytest`, `pytest path/to/test_file.py`, a single test with
  `pytest path::test_name`, by keyword with `pytest -k expr`.
- **Asserts:** use plain `assert`; pytest rewrites it to give rich failure output.

## Sharing fixtures and mocks (the priority)

pytest's mechanism for cross-module sharing is **`conftest.py`**. Fixtures defined
there are available to every test module in that directory and below, with no
import. This is where shared setup, fakes, and mocks belong.

```python
# tests/conftest.py — shared across all test modules under tests/
import pytest
from myapp.models import User


@pytest.fixture
def user():
    """A baseline valid user other fixtures/tests can build on."""
    return User(id=1, name="Ada", email="ada@example.com")


@pytest.fixture
def admin(user):
    """Compose from `user` instead of duplicating its setup."""
    user.role = "admin"
    return user


@pytest.fixture
def mock_clock(monkeypatch):
    """Shared deterministic time. Reuse everywhere instead of patching ad hoc."""
    fixed = 1_700_000_000.0
    monkeypatch.setattr("time.time", lambda: fixed)
    return fixed
```

Guidelines:

- **Search `conftest.py` (and any `tests/support/` helpers) before writing a new
  fixture.** Reuse or extend; add new shared fixtures only when nothing fits.
- **Compose** fixtures (`admin` depends on `user`) rather than copy large setup.
- **Scope** with `@pytest.fixture(scope="function" | "module" | "session")`.
  Default to `function` (fresh per test). Broaden only for expensive, read-only
  setup — a shared mutable `session` fixture causes cross-test leakage.
- Nest `conftest.py` files: a package-level one for narrowly shared fixtures, a
  top-level one for project-wide fixtures.
- For complex objects, share a **builder/factory fixture** so each test customizes
  only what it cares about.

## Table-driven tests

Use `parametrize` instead of writing near-identical tests:

```python
import pytest
from myapp.math import clamp


@pytest.mark.parametrize(
    "value, low, high, expected",
    [
        (5, 0, 10, 5),     # within range
        (-1, 0, 10, 0),    # below low
        (11, 0, 10, 10),   # above high
        (0, 0, 10, 0),     # on boundary
    ],
)
def test_clamp(value, low, high, expected):
    """Clamps a value into the inclusive [low, high] range.

    Assumptions:
    - low <= high for every parameter row.
    """
    assert clamp(value, low, high) == expected
```

The header docstring is the human-readable description + assumptions required by
this skill — every test gets one, including parametrized tests.

## Exceptions and floats

```python
import pytest

def test_rejects_negative():
    """Withdrawing a negative amount raises ValueError.

    Assumptions:
    - The account exists and overdraft protection is off.
    """
    with pytest.raises(ValueError, match="must be non-negative"):
        withdraw(-1)

def test_float_result():
    """compute_rate returns the ratio of its arguments.

    Assumptions:
    - Caller passes a non-zero denominator.
    """
    assert compute_rate(1, 3) == pytest.approx(0.3333, rel=1e-3)
```

## Mocking

Prefer `monkeypatch` (built in) for attributes/env, and `unittest.mock` /
`pytest-mock`'s `mocker` for call-based mocks. Mock **at boundaries**, and put
reusable mocks in `conftest.py`.

```python
def test_sends_welcome_email(mocker, user):
    """Registering a user sends exactly one welcome email to their address.

    Assumptions:
    - `user` is a new, valid user (from the shared `user` fixture).
    - Email delivery is mocked at the `myapp.email.send` boundary.
    """
    send = mocker.patch("myapp.email.send")   # mock the I/O boundary
    register(user)
    send.assert_called_once_with(user.email, template="welcome")
```

Mock the dependency *the unit calls*, not the unit itself. Don't assert on mock
internals when an output or state check would do.

## unittest (stdlib) equivalents

If the project uses `unittest`: subclass `unittest.TestCase`, use `setUp`/`tearDown`
for per-test setup, share via a common base `TestCase` subclass, and use
`self.assertEqual`, `self.assertRaises`, and `unittest.mock.patch`.
