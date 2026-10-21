# Concurrency and async

**Applies when:** Has async IO, background jobs, queues, multithreading, or offline sync

**Probe first:** The async framework, task queue, how locks and transactions are used, timeout settings on external calls

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Timeouts | Every external call must set a timeout; state the value | HTTP default 10s |
| Retries | Retry only idempotent operations; exponential backoff + a cap | none |
| Idempotency | Message and callback handlers must be idempotent, deduplicated by idempotency key | none |
| Locks / transactions | How shared state is protected, and where the boundaries are | none |
| Banned | Blocking IO inside async functions; unbounded concurrency | none |

## Where it lands

- Layer 2: what can be checked goes in the linter (ruff `ASYNC`)
- Layer 3: `.claude/rules/concurrency.md`, with `paths:` scoped to worker / sync modules
- For high-risk concurrency changes, run `/grill-with-docs` first to settle the decisions, and record an ADR
