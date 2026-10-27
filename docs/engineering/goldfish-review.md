## What it does

`goldfish-review` reviews a document (a [spec](https://www.aihero.dev/ai-coding-dictionary/spec), a design doc, an ADR, an RFC, a plan) with three reviewers that have no memory of writing it. Each runs as its own [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent) with read-only tools and without the project's `CLAUDE.md`, and each is handed only the document, the files it points at and the repository source. The conversation that produced the document never crosses that line, and neither does the drafting session's summary of it.

The session that wrote the document is the elephant. It remembers every trade-off and reads them back into the page whether or not they are written there. The goldfish does not, so what the goldfish cannot follow, the next fresh [session](https://www.aihero.dev/ai-coding-dictionary/session) will not follow either. That is the whole test.

## When to reach for it

Type `/goldfish-review`, or the agent reaches for it automatically when you ask for a spec or design document to be reviewed, want fresh eyes or a sanity check on a design, or say "goldfish review".

| Your situation | Reach for |
| --- | --- |
| A spec or design doc is written and you are about to split it into tickets | `goldfish-review` |
| An ADR, RFC or plan was drafted in a long session and you want to know what it assumes | `goldfish-review` |
| A code diff needs reviewing | [code-review](https://aihero.dev/skills-code-review) |
| The document is not written yet and the idea needs sharpening | [grill-with-docs](https://aihero.dev/skills-grill-with-docs) |
| Existing docs may no longer match the code | [drift-check](https://aihero.dev/skills-drift-check) |

Give it a path. An issue or URL works too, but it gets fetched into a file first, because the reviewers cannot fetch anything. A document that exists only in the conversation gets written to disk before anything is spawned.

## Prerequisites

A [harness](https://www.aihero.dev/ai-coding-dictionary/harness) that can spawn subagents. Without one the skill stops and says so rather than reviewing the document in the session that wrote it. `GLOSSARY.md` and ADRs are passed to the reviewers when the repo has them, so a repo that has run [grill-with-docs](https://aihero.dev/skills-grill-with-docs) gets a sharper review, but neither is required.

## The three lenses

| Lens | Reviewer | The question | `Important` means |
| --- | --- | --- | --- |
| Zoom-out | `goldfish-zoom-out` | Is this the right amount of thing to build? | The team would build the wrong thing, or something it already has |
| Reader | `goldfish-reader` | Can someone build from this document alone? | A gap an implementer could not close without asking |
| Code-fit | `goldfish-code-fit` | Does it agree with the code, and is it precise enough to act on? | A contradiction with the code, or a decision left to the implementer |

The three reports are shown side by side under `## Zoom-out`, `## Reader` and `## Code-fit`, as they came back. Nothing merges or reranks them: a finding two lenses raise is worth seeing twice, and no overall verdict is given. The severities are the same two `code-review` uses, `Important` and `Nit`, with at most five nits shown and the rest counted.

One round. Revise, then run it again if you want to; the skill never loops on its own.

## Common questions

**Why not just ask the same session to review its own spec?**

Because it already agrees with itself. The session that drafted the document holds every assumption that shaped it, so a gap in the page is invisible to it: it fills the gap from memory without noticing. A reviewer with nothing but the page cannot do that. The isolation is enforced by the agent definitions (read-only tools, no `CLAUDE.md`), not by a request to "pretend you have not seen this".

**Why does the reviewer not get `CLAUDE.md`?**

`CLAUDE.md` is where a project keeps the assumptions nobody writes into a spec. Those are exactly the assumptions the review should surface. If one of them is essential to judging the document, put the file that states it on the context list, and the skill shows you that list before spawning, so what crossed the boundary is never a mystery.

**The reader says a term is undefined, but everyone on the team knows it.**

Then it is undefined in the document, and the next fresh session will not know it either. Reader findings are the one kind [receiving-code-review](https://aihero.dev/skills-receiving-code-review) never contests. Define the term in the document, or in `GLOSSARY.md` so every future review sees it.

**A finding is wrong, but the reason is something we decided in conversation.**

That is evidence the reviewer could not read, so it goes to you first, not into the document. `receiving-code-review` carries the rule: decide whether the decision belongs in the document (then write it in, as a decision, not as a note to the reviewer) or whether the finding is simply declined. Padding the document with context to satisfy a reviewer is the one move the skill forbids.

## It's working if

- Before anything is spawned, you see the list of files the reviewers will get, and the conversation is not on it.
- Three reports arrive under three headings, each citing the document section and, for claims about code, a `path:line`.
- A reader finding quotes the line it could not follow; a code-fit finding quotes both the document and the code.
- The skill refuses to run when the harness cannot spawn subagents, instead of reviewing inline.
- The report ends with counts per lens and no single verdict.

## Where it fits

`goldfish-review` is the first of two review gates on the build chain: `grill-with-docs → to-spec → goldfish-review → to-tickets → implement → code-review → retro`. The spec passes the goldfish, the code passes `code-review`, and both sets of findings go through `receiving-code-review`.

- [to-spec](https://aihero.dev/skills-to-spec) produces the document this skill most often reviews, because a spec synthesised from one long conversation inherits that conversation's blind spots.
- [code-review](https://aihero.dev/skills-code-review) is the second gate, on the diff, with the same severities and the same hand-off.
- [receiving-code-review](https://aihero.dev/skills-receiving-code-review) works through the findings and carries the two goldfish-specific rules.
- [drift-check](https://aihero.dev/skills-drift-check) reuses the code-fit reviewer on documents that already describe the code.

[ask-zxs](https://github.com/zxsong111/skills/blob/main/docs/engineering/ask-zxs.md) routes across the whole set when you are unsure which skill the situation wants.
