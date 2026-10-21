# Code review

**Applies when:** Repos with multiple contributors or required review

**Probe first:** The hosting platform's branch protection and required review count; existing CODEOWNERS

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Review checklist | Correctness → security → tests → readability → scope (any unrelated changes smuggled in?) | none |
| What blocks | Which problems must be fixed before merging (missing tests, security issues, broken compatibility) | none |
| Merge rights | How many approvals, who can merge | 1 approval + green CI |
| Responding to review | Verify before changing; disagreement needs a technical reason | none |

## Where it lands

- Layer 2: set the required review count and required CI checks in branch protection
- Layer 5: the checklist and blocking items go in CLAUDE.md; judgement-call rules go in `CODING_STANDARDS.md` for `code-review` to check; incoming feedback goes through `receiving-code-review`
