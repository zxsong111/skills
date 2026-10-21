---
name: commit-push-pr
description: >
  Commit the current changes following Git conventions, then push and open a PR once the user agrees. Has a branch guard: refuses to commit directly on the trunk (main / master).
  Commit messages use the type(scope): short description format; more than 13 files or more than 3 separate concerns gets a split suggestion first.
  Use when the user says "commit", "commit this", "open a PR", "push it", "merge it for me", or runs /commit-push-pr.
argument-hint: "[optional: a one-line summary of this change]"
allowed-tools: Bash(git:*), Bash(gh:*), Read, Grep, Glob, Bash(tail:*)
---

# Commit, push, open a PR

## 0. Prefetched context

### Current repo state (already fetched, do not rerun these commands)

- Current branch: !`git branch --show-current || true`
- Working tree: !`git status --short || true`
- Diff stats: !`git diff HEAD --stat | tail -20 || true`
- Recent commits: !`git log --oneline -5 || true`
- Remote trunk: !`git branch -r --list 'origin/main' 'origin/master' 2>/dev/null || true`

### Note for this change

$ARGUMENTS

> Everything above is fetched automatically when this skill loads (the same whether it runs manually as `/commit-push-pr` or the model triggers it). When the same kind of command comes up later in the body, **use the results above, do not rerun it**.

Every item below is a hard requirement and self-contained; you do not need to read any external file.
If the project root `CLAUDE.md` sets a different branch policy, the project wins.

### 1. Branch guard (before anything else)

**The guard protects the repo's trunk, not the literal `main`.** `git init` creates `master` by default: a different name, the same role, and it is blocked just the same.
If the repo uses some other trunk name (`trunk`, `dev` and the like), the same applies: what counts is whether it is this repo's trunk, not what it is called.

If the current branch is the trunk, **stop** and do not commit.

"Stop" means: this turn you **do not run** `git commit`, and you **do not run** `git checkout -b` / `git switch -c` / `git branch -m` either.
Which branch to open, and what to name it, is the user's decision. Lay out the current state and the options, then **end the turn and wait for the user's answer**.
"At least it isn't a commit to the trunk" is not a reason to open a branch: a branch name and base you picked on your own are something the user then has to fix.

Options to show the user:

```bash
# Open a feature branch off the trunk, and PR it back into the trunk
git checkout -b feature/<module-name>

# Or the user explicitly says "just commit to the trunk" (common in personal, single-maintainer repos)
```

If the user picks "commit straight to the trunk", do it, and record that under "Project conventions" in the project `CLAUDE.md` so the question doesn't come up again every time.

### Exception: the first commit in a repo with no commits

The guard is there to stop direct commits to a **trunk that already has history**. When the repo has no commits yet, the first commit has to land somewhere and the trunk is the normal place for it, so **do not block it**:

```bash
git log --oneline -1 2>/dev/null   # no output = repo with no commits, let the first commit through
```

Once it is through, mention in the wrap-up report that it is time to settle a branch policy, but do not hold up the flow.

### 2. Read the change before writing the message

Working tree is clean → say "nothing to commit" and stop.

Otherwise read `git diff` to see what actually changed. **Do not guess from file names alone.**

### 3. Single-commit self-check

- More than 13 changed files, or more than 3 separate concerns → **suggest a split first**, show how to split it, and wait for the user to decide
- One commit does one thing. Mixed changes get split into several commits
- Changes to specs, tickets, ADRs and similar docs **go in the same commit as the implementation**; land docs and code separately and they drift apart again
- Before committing, check the staging area for credentials (API keys, tokens, private keys, `.env` contents): `git diff --cached | grep -niE 'api[_-]?key|secret|token|password|BEGIN .*PRIVATE KEY|AKIA[0-9A-Z]{16}'`.
  On a hit, stop and show the user where it is; switch to reading an environment variable or a placeholder. Credentials that reach history can't be fully scrubbed, so this step has no "commit now, sort it out later"

### 4. Commit message

Format `type(scope): short description`:

- `type` is required, one of `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore`
- `scope` is optional: the module name
- The description is in the imperative mood, concise, with **no trailing period**
- Not backward compatible → add `!` after `type`, and write `BREAKING CHANGE: <explanation>` in the body

End with a `Co-Authored-By` line naming **the model actually running right now** (the line given in the system prompt, used verbatim; do not hard-code an old name):

```
Co-Authored-By: <current model name> <noreply@anthropic.com>
```

### 5. Push: get consent first

Once the commit is done, **stop**, show the user the commit message, and ask explicitly whether to push.
Pushing a shared branch is visible to others, so get confirmation every time. **Do not `git push` until you have consent.**

### 6. Open a PR

Once the push is approved, run `git push -u origin <current-branch>`, then open a PR with the repo's trunk as the base:

```bash
gh pr create --base <trunk> --head <current-branch> --title "<same as the commit subject>" --body "<description>"
```

Hand the shape of the PR body to the `pr` skill: Call the Skill tool with "pr". It supplies the minimal visual summary, the before / after evidence, and the one-way door or two-way door call.
On top of that, **there must be a "Verification" section** saying what was actually run and what the real results were:

```markdown
## Verification

| Check | Command | Result |
|---|---|---|
| Build | pnpm build | Passed |
| Tests | pnpm test | 42/42 passed |

Not verified: <what was skipped, and why>
```

- The content comes from **commands that were really run**
- **If nothing was run at all, write "Not verified: nothing was run"**; do not make up a table that says "Passed" all the way down
- Skipped checks must be stated outright. Leaving one out is worse than writing "skipped": whoever comes next will assume it was verified

This section is the only evidence of this change that survives: the session will end, the PR will not.

Append to the end of the PR description:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

If the repo has `.github/PULL_REQUEST_TEMPLATE` or `pull_request_template.md`, follow the template's structure for the body.

### 7. Wrap up

Report: what was committed, whether it was pushed, and the PR link. Do not say unverified things like "should be fine".
