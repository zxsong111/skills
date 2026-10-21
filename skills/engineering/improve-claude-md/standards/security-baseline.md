# Security baseline

**Applies when:** Any project that handles user input, auth, or secrets

**Probe first:** Whether `.gitignore` ignores `.env`; how secrets are loaded; where the auth middleware lives

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Secrets | Read only from environment variables / a secrets manager; `.env` is never committed | none |
| Input validation | Validate with a schema at the boundary layer; internal code trusts validated data | zod, pydantic |
| Where auth happens | Which layer does authentication and authorization checks; never scattered through business code | none |
| Output encoding | HTML escaping, parameterized SQL; never build queries by string concatenation | none |
| Sensitive operations | Deletions, permission changes, and money operations must write an audit log | none |

## Where it lands

- Layer 1: add `Read(./.env)`, `Read(./.env.*)`, `Read(**/secrets/**)` to `permissions.deny`
- Layer 2: secret scanning (gitleaks) and SAST go into CI
- Layer 5: the key points go in CLAUDE.md, with details referencing this plugin's `references/security-checklist.md`; deep audits go through `security-and-hardening`
