# Config and environments

**Applies when:** Projects with multiple environments or environment variables

**Probe first:** Config files and loading code, existing environment variable names, `.env.example`

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Variable naming | UPPER_SNAKE, prefixed by service | `ORDER_DB_URL` |
| Config layering | Defaults → env file → environment variables; state the precedence | none |
| Required-value check | Validate required config at startup and fail immediately if anything is missing | none |
| Feature flags | Naming, off by default, how long after launch they get cleaned up | `ff_new_checkout` |
| Example file | Update `.env.example` with every variable added | none |

## Where it lands

- Layer 5: goes in CLAUDE.md "Project conventions"
- Companion: with no `.env.example`, generate one from the variables the code reads (variable names and descriptions only, no real values)
