---
name: drift-check
description: "Check the repo's narrative docs (ADRs, GLOSSARY.md, the top-level README, docs pages) against the code they describe, one goldfish reviewer per document, and report where the two disagree. Does not touch CLAUDE.md or AGENTS.md; improve-claude-md audits those."
disable-model-invocation: true
---

Semantic drift: a document says the code does one thing, and the code does another. Deterministic drift (a missing README entry, a manifest out of step with the disk) belongs to a script such as `scripts/check-skills.mjs`; this skill is for the disagreements only a reader can spot.

Each document is read by `goldfish-code-fit` in its **description** mode, in a fresh context with no memory of why the document says what it says. The reviewer compares every claim the document makes about the code against the source and reports the differences, nothing else.

## Process

### 1. Choose the documents

If the user passed paths, check exactly those. Otherwise build the default set from what the repo has:

- `GLOSSARY.md` at the root (or wherever the domain doc layout puts it).
- Every file under the ADR directory (`docs/adr/`, `.agents/adr/`, or the layout's location).
- The top-level `README.md`.
- Every page under `docs/`, excluding anything that is generated or vendored.

Skip `CLAUDE.md`, `AGENTS.md` and `.claude/rules/`: `improve-claude-md` audits the memory files and already catches stale commands and paths there. Two skills reporting on one file is a router that lies.

Show the list. If it holds more than ten documents, stop and ask which to run, or whether to run all; each document costs one subagent.

### 2. Check that you can spawn reviewers

The reviewers must run as subagents. If this harness has no subagent tool, stop and say so; do not compare the documents yourself in this context.

### 3. Spawn one reviewer per document, in parallel

For each document, one `goldfish-code-fit` call, all issued together in the foreground. The brief contains only:

- The document path.
- The mode: **a description** of code that exists (not a plan).
- `GLOSSARY.md` as a context file, when the document is not the glossary itself.
- The report discipline, pasted in full: tag every finding `Important` or `Nit`; `Important` only for a statement the code contradicts or a path, symbol or command the repo does not contain; at most five nits shown, the rest counted; every finding quotes the document and cites `path:line` in the code; under 400 words; do not spawn further agents.

Nothing from this conversation goes into the brief. In particular, never tell the reviewer what you expect it to find.

### 4. Report

One section per document, `## <path>`, with the reviewer's report as it came back. Documents with no findings get one line saying what was checked.

Then tag each `Important` finding with the move it calls for:

| Tag | When |
| --- | --- |
| **fix the doc** | The code is right and the document fell behind |
| **fix the code** | The document records a decision the code has quietly abandoned |
| **your call** | Either could be right; name what would settle it |

Say which tag you gave and why in one line each. The findings stay in this conversation; do not write a report file.

### 5. Exits

- A **fix the doc** finding: fix it now if the user agrees. A change to `GLOSSARY.md` or an ADR is domain work, so call the Skill tool with "domain-modeling" for those; any other document is a direct edit.
- A **fix the code** finding is an idea, and it enters the main flow the way `improve-codebase-architecture`'s findings do: a large one goes to `/grill-with-docs`, a small one straight to `/implement`. Tell the user which, and leave the choice to them.
- A **your call** finding waits for the user. Do not guess.

One pass per run. Repeated runs on an unchanged repo find the same things; run it after a build or a refactor, not on a timer.
