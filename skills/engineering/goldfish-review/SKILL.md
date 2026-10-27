---
name: goldfish-review
description: "Review a spec, design doc, ADR, RFC or plan with goldfish reviewers: three read-only subagents that see the document and the code but none of the conversation that produced it. Reports under three lenses (zoom-out, reader, code-fit) and hands the findings to receiving-code-review. Use when the user wants a spec or design document reviewed, asks for fresh eyes or a sanity check on a design, or says \"goldfish review\". For a code diff, use code-review instead."
---

Review of a **document** (a spec, a design doc, an ADR, an RFC, a plan) by three reviewers that carry none of the context that wrote it.

The session that drafted the document is the elephant: it remembers every trade-off, every discarded option and every assumption, and it reads them back into the document whether or not they are on the page. A goldfish reviewer has none of that. It sees the document, the files the document points at, the repository source, and nothing else. What it cannot understand, an implementer in a fresh session will not understand either.

This skill reviews documents. A diff is `code-review`'s job; the two share one report discipline and one hand-off.

## Process

### 1. Pin the document

The target is a local Markdown file the user names. If they name an issue or a URL instead, fetch it into a scratch file (`.scratch/review/<slug>.md`, or the OS temp directory if the repo has no `.scratch/`) and review that file; the reviewers cannot fetch anything themselves.

If the user named nothing and the conversation has just produced a document (a `to-spec` output, a plan written to disk), propose that path and confirm it. Do not review a document that exists only in the conversation: write it to a file first, because a reviewer that is handed prose in its prompt is handed your framing with it.

Confirm the file reads and is non-empty before spawning anything.

### 2. Gather the explicit context

List, and show the user, exactly what the reviewers will be given beyond the document and the repository source:

- Every file the document links or names by path.
- `GLOSSARY.md` and any ADR whose area the document touches, if the repo has them (the domain doc layout should have been provided to you; otherwise look for `GLOSSARY.md` and `docs/adr/` at the root).
- Any file the user adds by name.

That list is the whole of what crosses the boundary. Never paste the conversation, a summary of it, the user's stated intent, or your own reading of the document into a reviewer's brief. If a project convention is essential to judging the document, it must be in a file on the list.

### 3. Check that you can spawn reviewers

The three reviewers must run as subagents in their own contexts. If this harness has no subagent tool, stop and tell the user: a review performed in this context is not a goldfish review, because this context remembers the drafting. Do not fall back to reviewing the document yourself.

### 4. Spawn the three reviewers in parallel

Issue all three subagent calls together, in the foreground, one per agent:

- `goldfish-zoom-out`: is this the right amount of thing to build?
- `goldfish-reader`: can someone build from this document alone?
- `goldfish-code-fit`: does the document agree with the code, and is it precise enough to act on?

Each brief contains only:

- The document path.
- The context file list from step 2.
- For `goldfish-code-fit`: whether the document is **a plan** (something to implement) or **a description** (of code that exists). A spec, design doc, RFC or implementation plan is a plan; an ADR describing a decision already in the code, a README or a doc page is a description.
- The report discipline, pasted in full: tag every finding `Important` or `Nit`; `Important` only for something that would make the team build the wrong thing, build what it already has, contradict the code, or block an implementer; at most five nits shown, the rest counted; every finding cites the document section and, where the claim is about code, a `path:line`; under 400 words; do not spawn further agents.

Nothing else. If you find yourself adding "note that we decided..." to a brief, that sentence is what the review exists to test; leave it out.

### 5. Aggregate

Present the three reports as they came back, under `## Zoom-out`, `## Reader` and `## Code-fit`, verbatim or lightly cleaned. Do not merge, deduplicate or rerank them: a finding two lenses both raise is worth seeing twice, and a Nit under one lens is not promoted because another lens cares about it.

End with one line per lens: how many `Important` findings, how many nits (shown plus counted), and the worst `Important` finding under that lens, if any. Do not pick an overall verdict.

One round only. If the user revises the document and wants it checked again, they run the skill again; this skill never loops on its own.

### 6. Hand off

Call the Skill tool with "receiving-code-review" to work through the findings. It carries the rules for findings from goldfish reviewers: a `Reader` gap is never contested, and evidence that lives outside what the reviewers could read goes to the user before it goes into the document.

## Why three lenses and no synthesizer

Each lens answers one question, and the questions do not reduce to each other: a document can be the right size, perfectly clear, and wrong about the code. A single reviewer asked all three questions answers the one it finds first. A synthesizer that merged the reports would reintroduce one context's judgement over three independent ones, which is the thing the goldfish arrangement removes.

Three lenses is also the cap. A fourth (style, structure, security) is a different skill's job: `humanizer` for prose, the document's own template for structure, `security-and-hardening` for the trust boundary.
