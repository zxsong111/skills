# Database access

**Applies when:** Services that read and write a database

**Probe first:** ORM / query style, how transactions are written, slow query log

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| N+1 | List queries must preload associations; never query the database inside a loop | none |
| Transactions | Transaction boundaries live in the service layer; no external calls inside a transaction | none |
| Queries | Parameterized; never build SQL by string concatenation | none |
| Indexes | Assess indexing for every new query condition | none |
| Read/write split | Which queries may go to a read replica | none |

## Where it lands

- Layer 3: `.claude/rules/database.md`, with `paths:` scoped to the repository / dao directories
