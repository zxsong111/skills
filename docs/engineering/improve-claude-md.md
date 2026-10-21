## What it does

`improve-claude-md` audits and improves a project's memory files (the root `CLAUDE.md` or `AGENTS.md`, `.claude/rules/`, and any subdirectory `CLAUDE.md`), then works through a 29-category standards menu to generate the development conventions this project will actually use. It is **report-first throughout**: it surveys the repo, reports problems and proposals, waits for your approval, and only then writes any file. It suits old projects and new ones. On an old project the weight falls on the audit, which looks for:

- missing sections
- commands that don't match the repo
- empty quality gates
- generic filler
- prose rules that could move into a linter
- rules written globally that hold only for some paths
- duplication and contradictions
- excess length
- stale content

Every convention is tagged with the layer it lands in:

| The convention | Where it lands |
| --- | --- |
| Can be blocked outright with `permissions.deny` | There, never as prose |
| Can be enforced by a linter | The linter config, not `CLAUDE.md` |
| Is a judgement call | `CODING_STANDARDS.md`, which [code-review](https://aihero.dev/skills-code-review) reads |
| Must be read in every [session](https://www.aihero.dev/ai-coding-dictionary/session) | The root `CLAUDE.md`, which keeps only this |

## When to reach for it

Type `/improve-claude-md`, or the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) reaches for it automatically when a task fits: when you say "optimize CLAUDE.md", "clean up AGENTS.md" or "set conventions", or ask about code style or how to lay out directories. You can pass an argument to narrow the scope, for example `/improve-claude-md audit` to audit without generating conventions.

| Situation | Use it? |
| --- | --- |
| Wiring this skill set into a project for the first time | Yes, after [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) |
| An old project's `CLAUDE.md` runs to hundreds of lines and nobody dares touch it | Yes, with `/improve-claude-md audit` |
| The architecture design is approved and the first line of code is not yet written | Yes, to settle the conventions first |
| A small single-entry script with no external interface | No, and it won't fire |

It does not touch `docs/agents/*.md`, `GLOSSARY.md` or `docs/adr/`. Those belong to [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) and [domain-modeling](https://aihero.dev/skills-domain-modeling).

## Conventions are summarized, not invented

In a non-empty repo, the skill first samples 8 to 12 source files to infer the conventions already in use. It lists the places where it proposes a change separately, and you choose item by item between "the code wins" and "the new convention wins". Only an empty repo gets the mainstream defaults for its stack. Every convention has to be a checkable sentence: "function names use snake_case", not "naming should be clear".

## Common questions

**How is it different from `retro`?**
[retro](https://aihero.dev/skills-retro) looks back at one session and derives environment improvements from what happened in it. `improve-claude-md` audits the whole repo's memory files and does not depend on a session. Their output lands in the same files, so the Known pitfalls table in `CLAUDE.md` is maintained by both.

**Will it overwrite what I wrote by hand?**
No. When it edits an existing section it only replaces placeholder comments and fixes wrong entries. Known pitfalls is append-only. An existing `.editorconfig`, PR template or `CODEOWNERS` is skipped and reported.

**Do all 29 templates get loaded?**
No. It reads only `standards/INDEX.md` to filter, and only the templates you tick are opened into the [context window](https://www.aihero.dev/ai-coding-dictionary/context-window).

**I have both `CLAUDE.md` and `AGENTS.md`. Now what?**
Only one of them can hold the body. If you also use Codex, the body goes in `AGENTS.md` and `CLAUDE.md` imports it with `@AGENTS.md`. If you use only Claude, everything merges into `CLAUDE.md`. Conflicting entries are listed for you to decide.

## It's working if

- The first reply is a problem table with `file:line` references plus a checklist of conventions to tick, and no file in the working tree has changed.
- Every verification command is followed by a sample of healthy output, and that sample came from a real run.
- The root `CLAUDE.md` gets shorter, with the detail moved into `CODING_STANDARDS.md` or `.claude/rules/`.
- Every convention written down can be checked: either a command backs it, or it is a sentence you can judge true or false.

## Where it fits

`improve-claude-md` is a **run-once setup** when the skills come into a project, and **periodic maintenance** after that. Together with [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) it forms the groundwork. Its neighbours are [retro](https://aihero.dev/skills-retro), because it does the same kind of work at session level, and [code-review](https://aihero.dev/skills-code-review), because it reads the `CODING_STANDARDS.md` this skill writes. [ask-matt](https://aihero.dev/skills-ask-matt) has the map of the whole set.
