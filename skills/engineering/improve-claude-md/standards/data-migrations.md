# Data and migrations

**Applies when:** Has a database schema or migrations directory (`migrations/`, `alembic/`, `prisma/`)

**Probe first:** Migration tool and directory; existing table / column naming

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Naming | Plural / singular table names, snake_case columns, foreign keys `<table>_id`, indexes `idx_<table>_<cols>` | none |
| Reversible | Every migration must have a down / be reversible; an irreversible one states why and needs human approval | none |
| No business logic | Migrations don't call application code; data backfills are separate scripts | none |
| Large-table changes | Add columns with defaults, add indexes concurrently, avoid locking the table | `CREATE INDEX CONCURRENTLY` |
| Published migrations | Once merged into the main branch, a migration file must never be modified; only add new ones | none |

## Where it lands

- Layer 1: the published migrations directory can get `Edit(migrations/**)` in `permissions.deny`, while `Write` for new files stays allowed
- Layer 3: `.claude/rules/migrations.md`, `paths: ["migrations/**"]`
