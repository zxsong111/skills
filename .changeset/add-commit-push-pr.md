---
"zxs-skills": minor
---

Add **`commit-push-pr`** (Engineering, model-invoked): commits the current changes to a Git convention, then pushes and opens a PR. On the trunk (`main` or `master`) it stops and offers options instead of committing; commit messages follow `type(scope): short description`; a change of more than 13 files or 3 kinds of problem gets a split suggested first; it asks before pushing; and the PR body comes from `pr`, plus a Verification section of commands that really ran. Adapted from the skill of the same name in zxsong111/claude-config, with its main/develop/release enterprise branching model removed.
