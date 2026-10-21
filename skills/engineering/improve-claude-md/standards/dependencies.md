# Dependency management

**Applies when:** Projects with a package manager

**Probe first:** Which lockfiles and how many, dependency update tool (dependabot / renovate), audit command

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| One package manager | The lockfile decides the single package manager; never mix | With `pnpm-lock.yaml`, use only pnpm |
| Bar for adding | Prefer the standard library and existing dependencies; a new one needs a stated reason, maintenance status, and license | none |
| Version pinning | The lockfile must be committed; applications pin exact versions | none |
| Vulnerability audit | Audit command and fix deadline | `pnpm audit --prod`, `pip-audit` |
| Banned | `npx` without `--no-install` downloading on the fly; installing project dependencies globally | none |

## Where it lands

- Layer 1: `permissions.deny` rejects the wrong package manager (e.g. a pnpm project denies `Bash(npm install:*)`)
- Layer 2: audit goes into CI, with severity recorded as "warning" or "blocking"
- Layer 5: the bar for adding dependencies goes in CLAUDE.md; the agent rules say "ask before adding a dependency"
