# Privacy and data retention

**Applies when:** Handles personal data (names, phone numbers, emails, addresses, payment info)

**Probe first:** PII fields in the data model; whether PII shows up in logs and analytics events

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| PII inventory | Which fields are PII, and where they are marked | none |
| Minimization | Collect only data with a clear purpose | none |
| Retention period | How long each kind of data is kept, and how it is deleted when it expires | Order PII is anonymized after 3 years |
| Masking | Masking rules for PII in logs, analytics events, and error reports | Keep only the last 4 digits of phone numbers |
| Deletion requests | How user deletion / export requests are handled | none |

## Where it lands

- Layer 3: `.claude/rules/privacy.md`, with `paths:` scoped to the user / order models and logging modules
- Deeper compliance questions (GDPR, CCPA) go through `security-and-hardening`
