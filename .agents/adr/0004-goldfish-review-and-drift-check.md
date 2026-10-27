# Borrow goldfish review and drift detection from EGM; leave the rest

Google's Elephant-Goldfish Model ([google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model), Apache 2.0) is a spec-driven workflow built on one observation: the agent that drafts a design holds the whole conversation, so it reads its own assumptions back into the page, and only a reviewer with none of that context can see what the page fails to say. We adopt that observation and two mechanisms that follow from it, and decline the rest of the method.

## Decision

1. **`goldfish-review`** reviews a document (spec, design doc, ADR, RFC, plan) with three subagents, `goldfish-zoom-out`, `goldfish-reader` and `goldfish-code-fit`, each defined in `agents/` with `tools: Read, Grep, Glob`, `omitClaudeMd: true` and `model: inherit`. A reviewer gets the document, the files it names, the repository source and the context files the skill lists out loud; never the conversation or a summary of it. The isolation is enforced by the agent definitions, not by prompt wording. If the harness cannot spawn subagents, the skill stops rather than reviewing inline.
2. **`goldfish-review` is model-invoked**, like `code-review`. The two are the repo's two review gates: the spec passes the goldfish before `to-tickets`, the code passes `code-review` before the PR, both report `Important` / `Nit` with at most five nits shown, and both hand their findings to `receiving-code-review`. A user-invoked goldfish gate would have made the two gates behave differently for no reason the story could explain.
3. **`receiving-code-review`** takes two goldfish-specific rules: a Reader gap is never contested (if a reviewer with the page could not follow it, the page is unclear), and evidence that lives outside what the reviewers could read goes to the user before anything is written into the document. The skill keeps its name; its description widens to findings on documents as well as code.
4. **`drift-check`** reuses `goldfish-code-fit` in its "description" mode on documents that already describe the code: ADRs, `GLOSSARY.md`, the top-level `README.md` and the docs pages, one subagent per document. `CLAUDE.md` and `AGENTS.md` are left to `improve-claude-md`, which already audits them for stale commands and paths; two skills reporting on the same file would make the router lie. Findings stay in the conversation, each tagged fix the doc, fix the code, or your call; a "fix the code" finding is an idea that enters the main flow, which is the same exit `improve-codebase-architecture` uses. Deterministic invariants stay in `scripts/check-skills.mjs`.

## What we did not take, and why

- **The brainstorm → draft pipeline** (`concepts_brief.md`, section-by-section drafting with approval gates). `grill-with-docs` → `to-spec` already covers it, publishes to the issue tracker rather than to `docs/designs/`, and running both would leave two spec flows for `ask-zxs` to route between.
- **Five review stages and seven personas, with a synthesizer agent.** Sized for large design documents. Three lenses cover the questions that do not reduce to each other; style belongs to `humanizer`, structure to the document template. A synthesizer would reintroduce one context's judgement over three independent reports, and `code-review` already records why findings are not merged.
- **One question per turn, options without a recommendation.** Contradicts `grilling`, which asks the whole frontier each round with a recommended answer. Those rules belong to EGM's drafting flow, which we did not take.
- **Bootstrap** (a contract `README.md` per directory). It manufactures a second set of documents that then drift too; the documents worth protecting are the ones the repo already keeps.
- **Dated drift report files and a weekly rotation.** A dated report is itself a document that goes stale. Drift findings are acted on, not filed.
- **Cross-harness packaging and the scenario YAML.** ADR 0002 covers packaging; the repo's `evals/` already execute, where EGM's scenario files are only schema-checked.

## Provenance and licence

The idea and the lens names are EGM's. Every prompt, persona and skill body here is written from scratch; no text was copied from the Apache 2.0 sources, so the licence's attribution and modification-marking terms for copied material do not apply. This ADR is the attribution.

## Verified

2026-10-27, Claude Code 2.1.311, `claude -p --plugin-dir`: a scratch repo with a random marker in `CLAUDE.md` and another in `.claude/rules/marker.md`; the parent session saw both, `zxs-skills:goldfish-reader` asked to quote any marker in its window replied `NONE` and listed its tools as `Read`, `Grep`, `Glob`. The docs promise `omitClaudeMd` withholds `CLAUDE.md` and say nothing about unscoped rules files; in practice both were withheld.

## Invariants this creates

- A goldfish agent carries `omitClaudeMd: true` and read-only tools, and its persona is in its own body, so it never has to read a file outside the working directory to know what it is.
- A goldfish brief contains the document path, the context file list, the plan-or-description flag and the report discipline, and nothing from the conversation.
- `Important` / `Nit` is the only severity vocabulary in the repo; a new reviewer uses it or does not ship.
- Each new review gate hands off to `receiving-code-review`; there is one place findings are worked through.
