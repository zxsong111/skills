# zxs Skills

A collection of agent skills (slash commands and behaviors) loaded by Claude Code. Skills are organized into buckets and consumed by per-repo configuration emitted by `/setup-zxs-skills`.

## Language

**Issue tracker**:
The tool that hosts a repo's issues: GitHub Issues, Linear, a local `.scratch/` markdown convention, or similar. Skills like `to-tickets`, `to-spec`, and `triage` read from and write to it.
_Avoid_: backlog manager, backlog backend, issue host

**Issue**:
A single tracked unit of work inside an **Issue tracker**: a bug, task, spec, or slice produced by `to-tickets`.
_Avoid_: ticket (use only when quoting external systems that call them tickets, or for a **Decision ticket**, see below)

**Decision ticket**:
A `wayfinder` unit: a child **Issue** of a `wayfinder:map` holding a *question* whose resolution is a decision, not a slice of a build to execute. The **decision** qualifier is what keeps it distinct from an implementation ticket; `wayfinder` introduces the term, then uses "ticket".

**Triage role**:
A canonical state-machine label applied to an **Issue** during triage (e.g. `needs-triage`, `ready-for-agent`). Each role maps to a real label string in the **Issue tracker** via `docs/agents/triage-labels.md`.

**Goldfish reviewer**:
A read-only subagent that reviews a document with none of the conversation that produced it: no drafting context, no `CLAUDE.md`, only the document, the files it names and the repository source. `goldfish-review` spawns three (`goldfish-zoom-out`, `goldfish-reader`, `goldfish-code-fit`); `drift-check` reuses the last one. The session that wrote the document is the **elephant**, by contrast: it remembers everything, including what it never wrote down.
_Avoid_: fresh reviewer, independent reviewer (both leave open whether the reviewer still loads project context; a goldfish does not)

**Finding**:
One item a review gate reports, on a diff (`code-review`) or on a document (`goldfish-review`, `drift-check`). Every finding carries one of two severities: **Important** (would break behaviour, leak data, breach a documented standard or the spec, contradict the code, build the wrong thing or block an implementer) or **Nit** (everything else, style and naming included). A review shows at most five nits and counts the rest. Findings are worked through by `receiving-code-review`.
_Avoid_: Blocker, Major, High, Medium, Low (other severity scales; the repo uses two levels only)

## Relationships

- An **Issue tracker** holds many **Issues**
- An **Issue** carries one **Triage role** at a time
- A **Decision ticket** is an **Issue** (a child of a `wayfinder:map`)
- A **Goldfish reviewer** produces **Findings**; so does `code-review`'s pair of sub-agents

## Flagged ambiguities

- "backlog" was previously used to mean both the *tool* hosting issues and the *body of work* inside it. Resolved: the tool is the **Issue tracker**; "backlog" is no longer used as a domain term.
- "backlog backend" / "backlog manager". Resolved: collapsed into **Issue tracker**.
