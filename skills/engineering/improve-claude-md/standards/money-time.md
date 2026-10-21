# Money / time / time zones

**Applies when:** Involves money, prices, taxes, reports, or times across time zones (POS, payments, e-commerce, SaaS billing)

**Probe first:** Sample the money type (float / Decimal / integer cents) and time storage (naive / aware / UTC)

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Money type | Decimal or integer minor currency units, **never float** | `amount_cents: int` |
| Rounding | Rounding mode and timing defined in exactly one place | `ROUND_HALF_UP`, round only at settlement |
| Currency | Every amount carries its currency; amounts in different currencies are never added directly | none |
| Time storage | Always UTC, timezone-aware; never naive datetimes | none |
| Time display | The display layer converts to the store's / user's time zone | none |
| Business day | Definition of the "business day" for stores open past midnight | The day rolls over at 4 a.m. |

## Where it lands

- Layer 2: what can be checked goes in tooling (e.g. custom lints banning `datetime.utcnow()` or float money fields)
- Layer 3: `.claude/rules/money-time.md`, with `paths:` scoped to the pricing / order / reporting modules
