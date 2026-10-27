---
"zxs-skills": minor
---

Add **`goldfish-review`** (Engineering, model-invoked) and the three agents behind it, after Google's Elephant-Goldfish Model (ADR 0004):

- `goldfish-review` reviews a spec, design doc, ADR, RFC or plan with three subagents (`zxs-skills:goldfish-zoom-out`, `goldfish-reader`, `goldfish-code-fit`) that see the document, the files it names and the repository source, and nothing of the conversation that produced it. Each agent is read-only (`Read`, `Grep`, `Glob`) and loads no `CLAUDE.md`. The three reports are shown side by side under `## Zoom-out`, `## Reader` and `## Code-fit` with the `Important` / `Nit` discipline `code-review` uses, one round per run, and the skill refuses to run inline when the harness cannot spawn subagents.
- `ask-zxs` now tells the main flow as two review gates: the spec passes `goldfish-review` before `to-tickets`, the code passes `code-review` before the PR, and both sets of findings go through `receiving-code-review`.
- `receiving-code-review` now covers findings on documents as well as code, with two goldfish rules: a Reader gap is never contested, and evidence the reviewers could not read goes to the user before it goes into the document.
- `GLOSSARY.md` defines **Goldfish reviewer** and **Finding**; `SKILLS-MAP.md` gains a plugin components section listing the hooks and agents.
- Evals: `trigger-goldfish-review` and `behaviour-goldfish-review` (three agents spawned, three lens headings, the planted undefined term and the planted contradiction both caught).
