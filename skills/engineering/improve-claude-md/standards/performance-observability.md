# Performance and observability

**Applies when:** Backend services, or projects with an SLA or performance requirements

**Probe first:** Existing logging / metrics / tracing libraries; monitoring dashboards; performance budget

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Critical paths | Which paths must have metrics and traces | Placing an order, payment |
| Metric naming | Prefix and unit conventions | `order_checkout_duration_seconds` |
| Performance budget | Concrete numbers for endpoint P95, slow query threshold, frontend LCP, and so on | P95 < 300ms |
| Alerts | What triggers an alert, who responds | none |

## Where it lands

- Layer 2: the measurable parts of the performance budget go into CI (lighthouse-ci, benchmarks)
- Layer 5: goes in CLAUDE.md; projects with no performance requirements are judged not applicable
