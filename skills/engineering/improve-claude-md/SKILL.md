---
name: improve-claude-md
description: >
  Audit and improve a project's CLAUDE.md / AGENTS.md / .claude/rules/, and generate development
  standards for the project (coding style, layering, error handling, API, testing, Git, dependencies,
  security, money and time zones, agent rules, and so on).
  Use when the user says "optimize CLAUDE.md", "clean up AGENTS.md", "generate rules", "set standards",
  "set conventions", "coding style", or "how should the directories be split". Also use when an old
  project's CLAUDE.md has gone untended for a long time, after a new project adopts this skill set, or
  after an architecture design is approved and before the first line of code is written.
  Small single-entry scripts with no external interface and no persistence don't need it; don't trigger.
argument-hint: "[optional: only some items, e.g. audit / naming / error handling / agent rules]"
allowed-tools: Bash(git:*), Bash(ls:*), Bash(find:*), Bash(python3 -m json.tool:*), Read, Grep, Glob, Edit, Write, Bash(echo:*), Bash(grep:*), Bash(head:*), Bash(tr:*), Bash(wc:*)
---

# Improve CLAUDE.md and development standards

## 0. Prefetched context

### Repo state (prefetched)

- Tracked files: !`git ls-files 2>/dev/null | wc -l | tr -d ' ' || true`
- Top-level layout: !`ls -1 2>/dev/null | head -25 || true`
- Memory files: !`ls -1d CLAUDE.md CLAUDE.local.md AGENTS.md CODING_STANDARDS.md .claude/settings.json .claude/rules 2>/dev/null || echo "(none)"`
- Subdirectory CLAUDE.md files: !`git ls-files '*/CLAUDE.md' 2>/dev/null | head -10 || true`
- CLAUDE.md line count: !`wc -l < CLAUDE.md 2>/dev/null || echo 0`
- Stack and package manager: !`ls -1 package.json pnpm-lock.yaml package-lock.json yarn.lock pyproject.toml uv.lock go.mod Cargo.toml pom.xml build.gradle Makefile 2>/dev/null || echo "(none)"`
- Existing automated-check config: !`ls -1 .eslintrc* eslint.config.* .prettierrc* biome.json ruff.toml .editorconfig tsconfig.json mypy.ini pyrightconfig.json 2>/dev/null || echo "(none)"`
- CI and collaboration: !`ls -1 .github/workflows .gitlab-ci.yml .github/CODEOWNERS .github/pull_request_template.md 2>/dev/null || echo "(none)"`
- Domain docs and tracker config: !`ls -1 GLOSSARY.md docs/adr docs/agents 2>/dev/null || echo "(none; consider running /setup-matt-pocock-skills first)"`

### Focus

$ARGUMENTS

> All of the above is fetched automatically when this skill loads (the same whether invoked manually with `/improve-claude-md` or triggered by the model). When the same kind of command shows up later in the body, **use the results above; don't rerun it**.

The project-level `CLAUDE.md` is the only standing context Claude reads in every session, and `.claude/rules/` is a
supplement loaded by path. Written well, the same mistake never happens twice. Written badly, every session burns tokens reading noise.

This skill does three things: **audits** the existing memory files, **fills them out** to match the "Target structure" below,
and **generates** the development standards the project will actually use, placing each standard in the layer with the strongest enforcement.

**Report-first throughout: report, wait for approval, then write. Never edit files while reporting.**

## 0. Boundaries with other skills

| | Owns |
|---|---|
| `setup-matt-pocock-skills` (run manually by the user) | Issue tracker, triage labels, and domain docs layout, written to `docs/agents/*.md`. This skill does not touch those files |
| `domain-modeling` | Domain language: `GLOSSARY.md` and ADRs. This skill writes no terms; it only leaves navigation pointers to them in CLAUDE.md |
| `retro` | Suggests environment improvements after a retrospective on **one session**. This skill audits the memory files of the **whole repo**. Both land their output in the same set of files |
| `code-review` | Reads `CODING_STANDARDS.md` for the Standards axis. The judgement-call standards this skill generates go there so it can review against them |
| This skill | **How to write it and how to verify it**: directories, naming, the **concrete form** of errors, gate commands, agent behavior boundaries |

## 1. Inventory (read-only)

Check each item. **Don't go from memory**:

```bash
ls -1 CLAUDE.md CLAUDE.local.md AGENTS.md CODING_STANDARDS.md .claude/settings.json .claude/rules/ 2>/dev/null
find . -name CLAUDE.md -not -path './node_modules/*' -not -path './.git/*'   # subdirectory CLAUDE.md files
git ls-files | head -80                                                       # actual structure
ls -1 package.json pnpm-lock.yaml package-lock.json yarn.lock pyproject.toml uv.lock \
      go.mod Cargo.toml pom.xml build.gradle* Makefile 2>/dev/null           # stack and package manager
ls -1 .eslintrc* eslint.config.* .prettierrc* biome.json* ruff.toml .editorconfig \
      tsconfig*.json mypy.ini pyrightconfig.json 2>/dev/null                 # existing automated-check config
ls -1 .github/workflows/ .gitlab-ci.yml .github/CODEOWNERS \
      .github/pull_request_template.md 2>/dev/null                           # CI and collaboration
ls -1 GLOSSARY.md docs/adr docs/agents 2>/dev/null                           # domain docs and tracker config
```

Read the `scripts` in `package.json`, the tool sections of `pyproject.toml`, and the commands the CI config actually runs.
**Sample 8 to 12 representative source files** and note how they actually handle naming, error handling, logging, and return formats.

## 2. Audit the existing memory files

### Target structure

The root `CLAUDE.md` (or `AGENTS.md`) should have these sections, in this order. Not every missing section needs adding, but each section either has real content or does not exist:

| Section | What goes in it |
|---|---|
| Project overview | One or two sentences: what this is and who it's for |
| Tech stack | Language / framework / package manager, taken from the lockfile, with versions |
| Verification commands | Install, typecheck, build, test, local start. **Follow each with a sample of healthy output** (what the last line looks like, which exit code). Leave out any that don't run |
| Project structure | Only what the directory names don't reveal: where the entry points are, generated code that must not be hand-edited, where `GLOSSARY.md` and the ADRs live |
| Project conventions | Specific to this project. Anything true for only some paths goes in `.claude/rules/<topic>.md` |
| Don'ts / non-goals | Files not to touch, dependencies not to add, explicit non-goals |
| Known pitfalls / mistakes Claude has made | A three-column table of date / symptom / correct approach, append-only |
| Quality gates | Gate / command / severity (blocking or warning). Delete any row whose gate is empty |
| Required workflows | Condition → which skill must be used (vague requirement → grill-with-docs; writing a feature → tdd; hitting a bug → diagnosing-bugs; before saying "done" → run the verification commands first; when finished → code-review; after a build → retro) |

### Check for each problem

| Problem | Example | Fix |
|---|---|---|
| Missing section | No "Verification commands" | Add it from the probe results |
| Command doesn't match the repo | Says `npm test`, but the lockfile is pnpm | Change it to the real command and **actually run it** to confirm |
| Verification command has no healthy output sample | Just `pnpm test`, with no note of what the last line looks like when it passes | Run it and write the last line / exit code as `# healthy: …` |
| Empty gate | A command is blank in the gate table | Delete the whole row. An empty gate is worse than none |
| Generic filler | "Write clear code", "Mind security" | Delete it, or rewrite it as a checkable sentence |
| Text rule that tooling could enforce | "Sort imports" | Move it into the linter config and delete the text |
| Judgement-call rule in CLAUDE.md | "Keep one error-handling style across files" | Move it to `CODING_STANDARDS.md`, where `code-review` checks it. Leave a one-line pointer in CLAUDE.md |
| True for only some paths | "Migrations must be reversible" in the root CLAUDE.md | Split it into `.claude/rules/<topic>.md` with `paths:` |
| Duplicate / contradictory | CLAUDE.md and AGENTS.md each carry a copy, and they differ | Merge into a single source (see step 5) |
| Too long | Root CLAUDE.md over about 200 lines | Move details down into rules or CODING_STANDARDS.md. The root file keeps only global items and navigation pointers |
| Stale | Mentions a deleted directory / script | Delete or correct it |
| No-op instruction | A sentence that won't change the agent's behavior even when read | Delete it |

## 3. Standards menu

Read [standards/INDEX.md](standards/INDEX.md) and check each entry's **Applies when** condition against the inventory.
List the standards that apply to this project. **For any that don't apply, write "not applicable" and a one-sentence reason. Don't pad the list.**

Have the user tick which ones to generate. For each one ticked, read the matching `standards/<topic>.md` template and fill it in item by item:

- **In a non-empty repo, standards are summarized, not invented.** First use the step 1 sample to derive the "current conventions".
  Where something departs from the current conventions and you think it should change, **list it separately** and have the user choose, item by item, "code wins" or "new standard wins".
  Don't mix it into the current conventions and pass it off as fact
- **Only in an empty repo** do you give the stack's mainstream defaults: mature ecosystems with lots of examples make the written code more reliable
- Write each one as a **checkable sentence**: "function names use snake_case", not "naming should be clear"

## 4. Placement layers

**Label every standard with the layer it lands in. If it can go in a higher layer, don't write it as text in a lower one.**

| Enforcement | Mechanism | What goes there |
|---|---|---|
| 1 Hard block | `permissions.deny` / `ask` in `.claude/settings.json`, PreToolUse hook | Off-limits files (`Edit(<dir>/**)`; `Write(...)` rules have no effect), secrets (`Read(./.env)` also blocks Edit / Grep), dangerous commands. Pushing to the main branch and merging go through `ask` |
| 2 Tool-enforced | linter / formatter / type checker config, required CI checks | Naming, import order, types, and other machine-checkable items |
| 3 Path-scoped | `.claude/rules/<topic>.md` + `paths:` | Rules that hold only for certain directories / file types |
| 4 Directory-level | Subdirectory `CLAUDE.md` | Each monorepo package's own conventions |
| 5 Global text | Root `CLAUDE.md` (or imported via `@AGENTS.md`) **and** `CODING_STANDARDS.md` | Project-wide items that can't be machine-checked. The two files split the work: the root CLAUDE.md is read every session, so it holds only navigation pointers, verification commands, gates, required workflows, and known pitfalls. **Judgement-call** rules (cross-file consistency, "matches the surrounding style") go in `CODING_STANDARDS.md`, which the `code-review` Standards axis reads at review time, so they take no context during implementation |
| 6 Personal, not committed | `CLAUDE.local.md`, `~/.claude/rules/` | Personal preferences, kept out of team config |

Mechanical rules (fixed syntax, banned APIs, file locations) always become Layer 1 or Layer 2, never text. This matches `retro`'s classification rule.

`.claude/rules/` file format:

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/server/**/*.ts"
---

# API standards

- Every external endpoint returns `{ data, error }`, where `error` is `{ code, message }`
- ...
```

A rules file without `paths:` applies to the whole project, which is the same as writing it in the root CLAUDE.md. In that case write it straight into CLAUDE.md;
don't split files just to make the structure look tidy.

## 5. CLAUDE.md and AGENTS.md

The two files **must have a single source**. Ask the user whether the project also uses Codex or another tool that reads AGENTS.md:

- **Both**: the body goes in `AGENTS.md`. `CLAUDE.md` keeps only a one-line `@AGENTS.md` plus the Claude-specific sections
  (Required workflows, and the parts of the agent rules that apply only to Claude)
- **Claude only**: the body goes in `CLAUDE.md`. Once any existing `AGENTS.md` content is merged in,
  ask the user whether to delete it or reduce it to a one-line note pointing at CLAUDE.md

Deduplicate when merging. List conflicting entries for the user to decide; don't pick yourself.

## 6. Report (stop here and wait for approval)

```
## Project memory audit and standards proposal

### A. Problems in existing files (by impact)
| File:line | Problem | Suggestion |

### B. Applicable standards (tick the ones to generate)
- [ ] Coding style and naming. Reason: <evidence from the inventory>
- [ ] ...
Not applicable: API / interface design (no external interface); Caching (no cache in use)

### C. Files to create / modify
| File | Action | Layer | Summary |
| CLAUDE.md | Modify | 5 | Add "Verification commands", delete 3 lines of generic filler |
| CODING_STANDARDS.md | Create | 5 | 4 error handling and logging rules, read at review time |
| .claude/rules/migrations.md | Create | 3 | paths: migrations/** |
| .claude/settings.json | Modify | 1 | Add 4 entries to permissions.deny |

### D. Departures from current code that need your call
- <current state> → <proposal>, reason: <why>

### E. How to handle AGENTS.md: <proposal>

Once you confirm, I'll write everything in table C. Say now if you want any row changed.
```

**Write no files before the user approves.**

## 7. Write

- **Don't overwrite user-written content**: when changing an existing section, replace placeholder comments and fix wrong entries, and leave everything else as is.
  Existing `.editorconfig`, PR templates, `CODEOWNERS` and the like are **skipped and reported**, not overwritten
- The "Known pitfalls / mistakes Claude has made" section is **append-only, never deleted from**
- `.claude/settings.json`: merge, don't overwrite. `allow` gets no write operations (`git push`, `git reset --hard`,
  `gh pr merge`); `deny` gets only entries the user approved. Validate with `python3 -m json.tool` after writing
- Don't write machine-specific tools or paths: this config has to work on a fresh machine
- **Actually run** every command in the gate table first. Leave out any that fail, and say so in the report
- Don't touch a single word of `docs/agents/*.md`, `GLOSSARY.md`, or `docs/adr/`. They belong to `setup-matt-pocock-skills` and `domain-modeling`
- Write only what was finally decided, not the discussion or the rejected options

## Wrap-up

State which files changed, which layer each standard landed in, which were judged not applicable, which were skipped because they already existed,
and which gate commands failed and were left out.

One reminder: **standards have to evolve with the project.** Standards that change while the code doesn't, or code that changes while the standards don't,
are worse than no standards, because people assume they still hold. When Claude makes a new mistake in this project, add a row to "Known pitfalls / mistakes Claude has made". After a build, run `/retro`; it surfaces these findings systematically.
