---
name: resume-handoff
description: Pick up an unfinished task from a previous session. Finds the handoff document written by /handoff, checks the working state against it, and continues from its Next step. Takes no arguments.
disable-model-invocation: true
---

# Session handoff (read side)

The user typed only the skill name. **Do not ask where the document is; find it yourself.**

## 1. Find the handoff document

Search in this order and stop at the first hit:

```bash
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
tmp=${TMPDIR:-/tmp}
found=$({
  # (1) current repo root  (2) other worktrees of the same repo (the previous session may have been in another worktree)
  ls -1 "$root/tasks/handoff.md" 2>/dev/null
  git worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p' |
    while read -r w; do ls -1 "$w/tasks/handoff.md" 2>/dev/null; done
  # (3) handoff documents from the last 7 days in the system temp dir (where /handoff writes by default)
  find "$tmp" -maxdepth 2 -iname '*handoff*.md' -mtime -7 2>/dev/null
} | sort -u)
# Newest first; prints nothing if none were found (works on macOS and Linux)
[ -n "$found" ] && printf '%s\n' "$found" | tr '\n' '\0' | xargs -0 ls -t
```

- **One found** → use it
- **Several found** → use the first (newest) one, and tell the user the paths of the others and the time each one records in its Time field
- **None found** → check the issue tracker for a half-finished ticket: for a local tracker, files under `.scratch/*/issues/*.md` whose `Status:` is not done; for a real tracker, issues assigned to you with an in-progress status.
  If there are any → list them, let the user pick one, read it and continue; if there are none → tell the user "no handoff document found, and no ticket in progress", ask for a path, then stop. **Do not invent a progress report**

If the handoff document is in another worktree or another directory, do all further work in **that directory**, and tell the user first.

## 2. Check the working state

Read the whole handoff, then compare:

```bash
git -C <repo root containing the handoff> branch --show-current
git -C <repo root containing the handoff> status --short
```

- The branch differs from what the handoff records, files under "Files in progress" have already been committed or are gone, or there are changes the handoff never mentions
  → the handoff may be stale; **stop**, tell the user the differences, and get them cleared up before continuing
- The Time in the document is long ago → confirm first as well
- Claims the handoff states as fact without evidence ("X is already done", "Y doesn't exist") → treat them as still to be verified, do not take them on trust

## 3. Continue

1. In two or three lines, restate for the user: the Goal, the Current state, and the step that comes next
2. "Pending user decisions" is not "none" → ask first
3. Start from "Next step". Do not retry approaches listed under "Ruled out" unless you have new evidence
4. The handoff has a "suggested skills" section → call the skills it names
5. If the state changes materially while you work and the session grows long again → remind the user to run `/handoff` again

## 4. Wrap up

Once the task is done and you have evidence from running the verification commands, **delete the handoff document** (`tasks/handoff.md` in the repo, or the copy in the temp directory), so the next `/resume-handoff` doesn't pick up a handoff that is already finished.
