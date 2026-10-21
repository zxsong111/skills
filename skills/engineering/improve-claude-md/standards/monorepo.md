# Monorepo boundaries

**Applies when:** Several packages / services in one repo (workspaces, `packages/`, `apps/`)

**Probe first:** Workspace config, the dependency graph between packages

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Cross-package dependencies | Which packages may depend on which | `apps/*` may depend on `packages/*`, never the reverse |
| Shared code | Where shared code lives; never import across packages by relative path | none |
| Per-package conventions | Each package's own stack and commands | none |
| Blast radius | Which downstream packages' tests to run when a shared package changes | none |

## Where it lands

- Layer 2: dependency boundaries go in tooling (nx enforce-module-boundaries, dependency-cruiser)
- Layer 4: one subdirectory `CLAUDE.md` per package, covering only that package's own commands and conventions
