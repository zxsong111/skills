## What it does

`receiving-code-review` sets how the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) answers review feedback once it arrives: read all of it, restate what is being asked, check it against the codebase, judge whether it holds up for this codebase, and only then implement it or push back. **Technical correctness comes before social comfort.** Performative agreement such as "You're absolutely right!" is banned, and so is "I'll fix that now" before anything has been checked.

It also feeds lessons back. The second time the same kind of problem is pointed out, it adds a line to Known pitfalls in the project's `CLAUDE.md`, in the same PR. A judgement-call rule that keeps coming up becomes a suggestion for `CODING_STANDARDS.md`, so the next [code-review](https://aihero.dev/skills-code-review) checks for it.

## When to reach for it

Type `/receiving-code-review`, or the agent reaches for it automatically when a task fits: when you paste review comments to it, or have it work through a `code-review` report.

| The feedback comes from | How it is handled |
| --- | --- |
| You (the partner) | Trusted: implemented once understood, though it still asks when the scope is unclear |
| The two-axis `code-review` report | Treated as an external review: each item is checked before anything changes |
| An external reviewer on the PR | Five checks: is it correct for this codebase, will it break something else, is there a reason for the current code, does it work on every platform, does the reviewer have the full context |

It covers how to take feedback, not how to give it. To run a review, use [code-review](https://aihero.dev/skills-code-review).

## Ask first, then act

If two of six comments are unclear, the right move is to stop and get those two clarified, not to do the four you understand first. Comments are often related, and understanding half of them means implementing them wrong. The order of work is fixed: blocking issues, then simple fixes, then complex ones, with each fix tested on its own.

## Common questions

**What if the reviewer is wrong?**
Push back on technical grounds: say what the change would break, cite a test or code that works, ask specific questions. Pull the partner in when it touches architecture. If the pushback turns out to be wrong, one line ("Checked it, you're right") and the fix, with no long apology.

**The review questions the requirement itself, not the implementation.**
That is not the review's call. The skill puts the question to you as it stands, and goes back to [grill-with-docs](https://aihero.dev/skills-grill-with-docs) where needed. It will not change the [spec](https://www.aihero.dev/ai-coding-dictionary/spec) or the [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) to keep a reviewer happy.

**Why not even a "thanks"?**
Actions speak. Fix it and move on: the code itself shows the feedback was heard.

## It's working if

- The replies contain no "You're right", "Great point" or "Thanks for catching that".
- Every comment gets a line on what was checked and what turned up, before the decision to change it or not.
- Fixes land one comment and one test at a time, not as a batch with a single test run at the end.
- The second time the same kind of problem is flagged, Known pitfalls in `CLAUDE.md` gains a line.

## Where it fits

`receiving-code-review` is a **chain step** at the close of the main flow: after [code-review](https://aihero.dev/skills-code-review) or a PR review produces feedback, and before the changes land. Its neighbours are [code-review](https://aihero.dev/skills-code-review), because it produces the feedback this skill takes in, and [retro](https://aihero.dev/skills-retro), because it turns recurring problems into environment improvements systematically. [ask-matt](https://aihero.dev/skills-ask-matt) has the map of the whole set.
