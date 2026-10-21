# Language conventions

**Applies when:** Mixed Chinese and English teams, or projects heavy in domain terms

**Probe first:** The language existing comments, commits, and docs use; how domain nouns are written in code

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Comment language | Chinese / English | none |
| Commit / PR language | Chinese / English | none |
| Docs language | Chinese / English | none |
| Glossary | A one-to-one mapping of each domain noun's Chinese term, English term, and code identifier | `<Chinese term>` / dine-in / `DINE_IN` |

## Where it lands

- Layer 5: language conventions go in CLAUDE.md; personal preferences such as reply language go in `CLAUDE.local.md`
- Companion: when there are many terms, generate `docs/glossary.md`

## Companion file skeleton

If the target file already exists, skip it and say so in the report. Don't overwrite it.

```markdown
# Glossary

| Chinese | English | Code identifier | Notes |
|---|---|---|---|
|  |  |  |  |
```
