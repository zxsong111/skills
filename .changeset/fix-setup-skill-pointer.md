---
"zxs-skills": patch
---

Point every skill at `/setup-zxs-skills` instead of the pre-fork `/setup-matt-pocock-skills`, which no longer exists: `code-review`, `implement-spec`, `improve-claude-md`, `to-spec`, `to-tickets`, `triage` and `wayfinder` told the user to run a command that resolved to nothing. `setup-zxs-skills` itself now carries that name in its frontmatter and Codex metadata, and `GLOSSARY.md` names the fork. ADR 0001 keeps the old name as history.
