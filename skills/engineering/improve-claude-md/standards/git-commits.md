# Git and commits

**Applies when:** Any git repo

**Probe first:** `git branch -a`, the commit format in the last 30 `git log --oneline` entries, whether a develop branch exists

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Branch model | `main`+`develop` two-branch, or trunk only | none |
| Branch naming | `feature/<module>`, `hotfix/<issue>`; lowercase with underscores | `feature/cart_opt` |
| Commit format | Conventional Commits: `type(scope): description` | `fix(order): correct stacked discounts` |
| Commit granularity | One thing per commit; formatting and logic changes in separate commits | none |
| PR requirements | The description must include a "Verification" section (commands actually run and their results); a size cap per PR | none |
| Banned | Pushing straight to `main`; force pushing a shared branch | none |

## Where it lands

- Layer 1: add `Bash(git push --force:*)` and `Bash(git push origin main:*)` to `permissions.deny`
- Layer 2: commitlint / branch protection rules (set on the hosting platform; remind the user in the report)
- Layer 5: the branch model (trunk only, or main + develop) goes in CLAUDE.md "Project conventions"; `commit-push-pr`'s branch guard follows it
- Companion: with no `.github/pull_request_template.md`, generate one

## Companion file skeleton

If the target file already exists, skip it and say so in the report. Don't overwrite it.

```markdown
## What changed

## Why

## Verification
<!-- commands actually run and their results; for anything not run, write "not verified" -->

## Risk and rollback
```
