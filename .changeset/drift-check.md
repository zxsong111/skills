---
"zxs-skills": minor
---

Add **`drift-check`** (Engineering, user-invoked): checks the repo's narrative docs (ADRs, `GLOSSARY.md`, the top-level `README.md`, the pages under `docs/`) against the code they describe, one `goldfish-code-fit` reviewer per document in a fresh context, and reports the disagreements in the conversation, each `Important` finding tagged fix the doc, fix the code, or your call. It leaves `CLAUDE.md` and `AGENTS.md` to `improve-claude-md`, writes no report file, asks before spawning more than ten reviewers, and hands "fix the code" findings to the main flow the way `improve-codebase-architecture` does (ADR 0004). Its first live run, on this repo's own `GLOSSARY.md`, caught a triage role example (`ready-for-afk`) that never existed; the canonical role is `ready-for-agent`, and the glossary now says so.
