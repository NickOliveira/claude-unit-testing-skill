# unittesting

A Claude Code skill (plus a slash command) for creating and updating unit tests,
packaged for easy install into your user-space `~/.claude` folder.

## Overview

Writing unit tests by hand — and keeping them honest as code evolves — is repetitive
and easy to get subtly wrong. This skill gives Claude Code a consistent, opinionated
methodology for both, so the tests it produces are readable, reusable, and
trustworthy rather than throwaway. It is language-agnostic by design: the methodology
lives in `SKILL.md`, with concrete syntax in per-language example files (Python today,
more can be added).

Three things make it distinctive:

- **Shared fixtures and mocks.** Test setup is written once and shared across modules
  (e.g. via `conftest.py`) rather than copy-pasted, so a change to a mocked dependency
  is a one-line edit instead of a hunt through every test file.
- **Every test documents itself.** Each test carries a header stating, in plain
  language, *what behavior it asserts* and the *assumptions* it makes about the code.
  A failing test becomes a clear signal — you can tell whether a real regression broke
  it or an assumption simply went stale.
- **Assertions are never changed behind your back.** Claude freely writes new tests
  and refactors test scaffolding (fixtures, setup, naming), but if a code change means
  an existing assertion must change, it stops and asks you to confirm first. The suite
  stays a faithful record of intended behavior, not something quietly rewritten to go
  green.

## Use case

1. **Authoring tests.** Ask Claude to add or update tests for some code. It applies
   the methodology — shared fixtures/mocks, self-documenting headers, sensible
   coverage of happy paths, boundaries, and errors — and asks before altering any
   existing assertion.
2. **Validating after a change.** After editing code, run `/validate-test-coverage`
   (optionally against a base branch, e.g. `/validate-test-coverage main`). Claude
   reads the diff, finds the tests covering the changed code, and reports which now
   rest on invalid assumptions, which assertions look stale, and where coverage is
   missing — without rewriting anything until you approve.

## What's included

- **`unittesting` skill** — a language-agnostic methodology for writing and updating
  unit tests: shared fixtures/mocks, per-test headers (description + assumptions),
  coverage, anti-patterns, and a guardrail that existing assertions are only changed
  with your confirmation. Language-specific examples live in `skill/examples/`
  (Python available now).
- **`/validate-test-coverage` command** — reviews the git diff and verifies the unit
  tests covering the changed code still make correct assumptions; reports stale
  assumptions, outdated assertions, and coverage gaps.

## Layout

```
.
├── install.sh                          # Installs the skill + commands into ~/.claude
├── skill/                              # The skill (source of truth)
│   ├── SKILL.md                        # Skill definition (frontmatter + instructions)
│   └── examples/
│       └── python.md                   # Python-specific patterns
├── commands/
│   └── validate-test-coverage.md       # /validate-test-coverage slash command
└── README.md
```

## Install

```sh
./install.sh
```

This copies `skill/` to `~/.claude/skills/unittesting/` and each command in
`commands/` to `~/.claude/commands/`. Re-run any time to update an existing install.
Set `CLAUDE_CONFIG_DIR` to install somewhere other than `~/.claude`.
