## What it does

`drift-check` reads the repo's narrative documents (ADRs, `GLOSSARY.md`, the top-level `README.md`, the pages under `docs/`) against the code they describe and reports where the two disagree. Each document goes to its own goldfish reviewer, a read-only [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent) that has no memory of why the document was written and no `CLAUDE.md`, so it checks what the page says against what the source does and nothing more. The skill only reports semantic drift; anything a script can check (a missing index entry, a manifest out of step with the disk) is left to the repo's own checks.

It never touches `CLAUDE.md`, `AGENTS.md` or `.claude/rules/`. Those are memory files, and [improve-claude-md](https://aihero.dev/skills-improve-claude-md) already audits them for stale commands and paths; one file gets one auditor.

## When to reach for it

You invoke this by typing `/drift-check`, and the agent won't reach for it on its own. Reach for it after a build or a refactor that touched an area the docs describe, or when a reader (human or agent) was misled by a document and you want to know how many others are wrong too.

| Your situation | Reach for |
| --- | --- |
| The ADRs, glossary, README or docs pages may no longer match the code | `drift-check` |
| `CLAUDE.md` or `AGENTS.md` has gone stale | [improve-claude-md](https://aihero.dev/skills-improve-claude-md) |
| A new spec or design doc needs reviewing before it is built | [goldfish-review](https://aihero.dev/skills-goldfish-review) |
| The code itself has drifted from a good shape, not the docs | [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) |

Pass paths to check only those; with no arguments it builds the default set and shows it. More than ten documents and it asks before spawning, because each one costs a subagent.

## Prerequisites

A [harness](https://www.aihero.dev/ai-coding-dictionary/harness) that can spawn subagents; without one the skill stops rather than comparing documents inline. It finds `GLOSSARY.md` and the ADR directory through the domain doc layout [setup-zxs-skills](https://github.com/zxsong111/skills/blob/main/docs/engineering/setup-zxs-skills.md) writes, and falls back to the root and `docs/adr/` when there is none.

## Three exits

Every `Important` finding is tagged with the move it calls for, and the tag decides where it goes next.

| Tag | Meaning | Where it goes |
| --- | --- | --- |
| fix the doc | The code is right; the page fell behind | Edited now; `GLOSSARY.md` and ADR changes go through [domain-modeling](https://aihero.dev/skills-domain-modeling) |
| fix the code | The page records a decision the code quietly abandoned | An idea for the main flow: [grill-with-docs](https://aihero.dev/skills-grill-with-docs) if large, [implement](https://aihero.dev/skills-implement) if small |
| your call | Either could be right | Waits for you, with a note on what would settle it |

The findings stay in the conversation. The skill writes no report file, because a dated drift report is itself a document that goes stale.

## Common questions

**Why not run it on a schedule?**

Because an unchanged repo yields the same findings every week, and a report nobody asked for is a report nobody reads. Run it when something changed: after a refactor, after a build that touched a documented area, after a reader was misled. If a class of drift keeps coming back, the durable fix is a deterministic check in the repo's scripts, which [retro](https://aihero.dev/skills-retro) will suggest.

**It flagged a README section that is deliberately aspirational.**

Then the page should say so. A goldfish reads "the service retries three times" as a claim about the code; "the service will retry three times once #42 lands" is a claim it can check. Rewrite the sentence or decline the finding with that reason; both are fine, and the second is a "your call".

**Can it fix things itself?**

Doc fixes, yes, once you agree, and glossary or ADR edits go through `domain-modeling` so the vocabulary stays consistent. Code fixes, no: a "fix the code" finding is an idea for the main flow, not a change this skill makes.

## It's working if

- Before anything is spawned, you see the list of documents it will check, and the memory files are not on it.
- Each finding quotes the document and cites a `path:line` in the code.
- Every `Important` finding carries one of the three tags with a one-line reason.
- A clean document gets one line saying what was checked, not silence.
- Nothing is written to disk unless you agreed to a doc fix.

## Where it fits

`drift-check` is **periodic maintenance** under codebase health, next to [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture): one surveys the code's shape, the other the documents' accuracy, and both hand their findings to the main flow as ideas.

- [improve-claude-md](https://aihero.dev/skills-improve-claude-md) is the neighbour on the memory files, because the two split the repo's documents between them and neither reports on the other's.
- [goldfish-review](https://aihero.dev/skills-goldfish-review) uses the same code-fit reviewer on a document that does not describe the code yet, because a plan and a description are checked by the same engineer asking a different question.
- [retro](https://aihero.dev/skills-retro) turns a recurring drift into a deterministic check, because the second time a script could have caught it, it should.

[ask-zxs](https://github.com/zxsong111/skills/blob/main/docs/engineering/ask-zxs.md) routes across the whole set when you are unsure which skill the situation wants.
