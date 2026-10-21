# Testing

**Applies when:** Projects with tests, or that plan to write them

**Probe first:** Test framework and config, test directory layout, the test command CI runs, coverage config

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Layers | What unit / integration / e2e tests each cover, and where each lives | `tests/unit/`, `tests/integration/` |
| Naming | Test file and test case naming; case names describe behavior | `test_rejects_expired_coupon` |
| Coverage threshold | If there is one, state the number and put it in CI; if not, leave it out | `--cov-fail-under=80` |
| Mocking | Real implementation > fake > stub > mock; mock only at slow / external boundaries | none |
| Bug fixes | Must come with a reproduction test that fails first and then passes | none |
| Banned | Skipping / deleting tests to turn the suite green; changing assertions to make tests pass | none |

## Where it lands

- Layer 2: the coverage threshold and test command go into CI, and back into the CLAUDE.md "Quality gates" table
- Layer 3: `.claude/rules/testing.md`, with `paths:` scoped to the test directories
- Related: the `test-driven-development` skill and its `writing-good-tests.md`
