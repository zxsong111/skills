# Error handling and logging

**Applies when:** Any service / app that runs

**Probe first:** Sample how errors are thrown, wrapped, and returned; the logging library and existing fields

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Error categories | Which type each of business errors / validation errors / external dependency errors / program bugs uses | `DomainError`, `ValidationError` |
| Throw or return | When to throw an exception, when to return an error value | Catch at the boundary layer, throw in the domain layer |
| Error response format | The uniform shape of external errors and the encoding rule for error codes | `{code: "ORDER_NOT_FOUND", message}` |
| No swallowed exceptions | `except: pass` / empty catch is always banned; if something truly must be ignored, state why | none |
| Log levels | ERROR needs a human, WARN self-heals, INFO is a business event, DEBUG is for troubleshooting | none |
| Log fields | Always include request_id / trace_id / the business key | none |
| Never log | Secrets, passwords, tokens, full card numbers, PII | none |

## Where it lands

- Layer 2: empty catches and `print` debug output go to the linter (ruff `BLE`/`T20`, eslint `no-empty`)
- Layer 3: the external error format goes in `.claude/rules/errors.md`, with `paths:` scoped to the interface layer
- Layer 5: error categories and what each log level means go in CLAUDE.md
