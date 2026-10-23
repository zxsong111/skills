## What it does

`resume-handoff` is the other half of [handoff](https://aihero.dev/skills-handoff). In a new [session](https://www.aihero.dev/ai-coding-dictionary/session) it finds the handoff document by itself, checks the working state against it, and carries on from Next step. **It never asks you where the document is; it goes and looks.** When it finds nothing, it does not make up progress either: it says plainly that nothing turned up and asks you for a path.

The search order is fixed:

1. `tasks/handoff.md` at the repo root.
2. The same file in the repo's other worktrees.
3. Handoff documents from the last 7 days in the system temp directory, where upstream `handoff` writes by default.

If it finds several, it uses the newest and tells you where the others are.

## When to reach for it

You invoke this by typing `/resume-handoff`, and the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) won't reach for it on its own. It takes no arguments.

| Situation | What it does |
| --- | --- |
| The last session ran `/handoff` | Finds the document, checks the branch and working tree, restates the goal and next step, and starts work |
| The branch or changes don't match the document | Stops, tells you what differs, and asks before going on |
| There is no handoff document | Checks the issue tracker for an in-progress ticket; if there is none either, says so and stops |
| The document lists Pending user decisions | Asks first, then acts |

## Check the working state, not the document

A claim the handoff states as fact without evidence ("X is done", "Y doesn't exist") is treated as something to verify. Approaches listed under Ruled out are not tried again unless there is new evidence. Once the task is done and verification has produced evidence, the skill deletes the handoff document, so the next run doesn't pick up a handoff that is already finished.

## Common questions

**Upstream `handoff` writes to the temp directory. Can it find that?**
Yes. Its third step looks in `$TMPDIR` (or `/tmp` when that is unset) for markdown files from the last 7 days with handoff in the name. A file older than 7 days, or one lost when the system cleared temp, it won't find, and it asks you for a path instead.

**How is it different from `/compact`?**
`/compact` compresses the [context](https://www.aihero.dev/ai-coding-dictionary/context) and continues in the same session; `resume-handoff` recovers from a file in a brand-new session. The first keeps your intent. The second has only what was written to disk.

## It's working if

- After `/resume-handoff`, the first two or three lines of the reply are the goal, the current state, and the next step.
- It ran `git status` and `git branch` to check, rather than taking the document at its word.
- Approaches under Ruled out in the document were not tried again.
- Once the task was done, the handoff document was deleted.

## Where it fits

`resume-handoff` is a **reach-for-it-anytime standalone** that works at a phase boundary: `/handoff` writes, `/resume-handoff` reads. Its only neighbour is [handoff](https://aihero.dev/skills-handoff), because that writes the document this skill reads. For choosing among the five options at a phase boundary, see [ask-zxs](https://github.com/zxsong111/skills/blob/main/docs/engineering/ask-zxs.md).
