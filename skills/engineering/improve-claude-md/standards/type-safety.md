# Type safety

**Applies when:** TypeScript, Python with type checking, and the like

**Probe first:** strict in `tsconfig.json`, mypy / pyright config, the current count of `any` / `type: ignore`

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| strict | Turn on strict; for an existing project, give a path to tighten it step by step | none |
| No escape hatches | `any`, `as unknown as`, `# type: ignore` must carry a comment giving the reason | `# type: ignore[attr-defined]  # third-party lib has no stubs` |
| Public interfaces | Exported functions / public methods must annotate parameter and return types | none |
| Runtime boundaries | Validate external data at runtime as it enters the system; don't rely on type assertions alone | none |

## Where it lands

- Layer 2: everything goes in tsconfig / mypy / pyright / eslint config, and into the gate table as the "Typecheck" gate
- Layer 5: CLAUDE.md gets just one sentence: "Typecheck must pass; any escape hatch must state its reason"
