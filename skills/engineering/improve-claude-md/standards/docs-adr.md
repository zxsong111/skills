# Docs and ADRs

**Applies when:** Projects delivered externally or maintained by several people

**Probe first:** Existing README sections, `docs/` structure, whether ADRs already exist

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| README essentials | Overview, quick start, configuration, testing, deployment | none |
| API docs | Where they live, who updates them (in the same PR as the code) | none |
| ADRs | Important architecture decisions go in `docs/adr/NNNN-<title>.md`, append-only, marked when superseded | none |
| Language | Docs describe the current state, not the change history | none |

## Where it lands

- Layer 5: goes in CLAUDE.md; after an interface change, check whether the README / API docs changed with it
- Companion: with no ADR directory, generate `docs/adr/0000-template.md`

## Companion file skeleton

If the target file already exists, skip it and say so in the report. Don't overwrite it.

```markdown
# NNNN. <Decision title>

- Status: proposed / accepted / superseded (by NNNN)
- Date: YYYY-MM-DD

## Context

## Decision

## Consequences
<!-- benefits, costs, follow-up work -->
```
