---
description: Review the git diff and verify the unit tests covering the changed code still make correct assumptions. Reports stale assumptions, outdated assertions, and coverage gaps; never changes assertions without confirmation.
argument-hint: "[base ref or range to diff against, e.g. main]"
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git rev-parse:*), Read, Grep, Glob
---

Validate that the unit tests covering the current code changes still hold.

Apply the conventions from the `unittesting` skill — especially each test's header
(its human-readable description and **Assumptions** list) and the rule that
**existing assertions are never changed without user confirmation**.

## 1. Establish the diff

- If an argument was given (`$ARGUMENTS`), diff against it: treat it as a git ref or
  range (e.g. `git diff main...HEAD` for a branch, or `git diff <ref>`).
- Otherwise review uncommitted work with `git diff HEAD`. If that is empty, say so
  and stop.

Separate the changes into **source/code changes** and **test changes**.

## 2. Map changes to tests

For each changed unit of source code, locate the unit tests that exercise it — using
the project's naming/layout conventions and by grepping for the symbols involved.
Note any changed code that has **no** corresponding test.

## 3. Check each related test against the change

For every related test, read its header and its assertions, then judge them against
the new code:

- **Assumptions still valid?** Compare each item in the test's *Assumptions* list to
  the changed code. Flag any precondition the diff has invalidated — a changed
  default, signature, return shape, raised exception, or mocked dependency.
- **Assertions still correct?** Decide whether each assertion still reflects the
  intended behavior, or whether the change has made it stale or wrong.
- **Shared fixtures/mocks still accurate?** If the change touches something modeled
  by a shared fixture or mock (e.g. in `conftest.py`), flag fixtures that no longer
  match reality.

## 4. Report

Produce a concise report:

- **Per related test:** OK / assumptions-invalidated / assertion-likely-stale — each
  with a one-line reason tied to the specific code change.
- **Coverage gaps:** changed or new behavior with no test.
- **Shared setup:** fixtures or mocks the change has made inaccurate.

## 5. Changes require confirmation

This command **reviews and reports** — it does not silently rewrite tests.

- To fix an invalidated assumption or stale assertion in an **existing** test, follow
  the skill's guardrail: show the current vs. proposed assertion/assumption and why
  the code change forces it, then wait for explicit approval before editing.
- You may offer to add **new** tests for coverage gaps, but confirm scope first.
- Non-assertion fixes (rewording a header, adopting a shared fixture, refactoring
  setup) may be applied directly, per the skill.
