# Agent rules (Claude-specific)

**Applies when:** All projects that use Claude Code

**Probe first:** The permissions in any existing `.claude/settings.json`; prohibitions the user has stressed out loud; the "Known pitfalls / mistakes Claude has made" table

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Autonomy boundary | What must be asked first: deleting files, changing schema / migrations, adding dependencies, changing CI, pushing externally, sending messages | none |
| Off-limits | Files and directories that must not be read or changed | Generated code, `.env*`, `vendor/`, published migrations |
| Context hygiene | Send an Explore subagent into large directories first; which files are the source of truth | `openapi.yaml` wins over code comments |
| Output conventions | Reply language, commit attribution, PR description format | none |
| Failure handling | After 2 failed attempts at the same fix, stop and report; never change tests / assertions to make tests pass; never use `--no-verify` | none |
| Completion bar | Before saying "done", there must be command output as evidence | none |

## Where it lands

- Layer 1: off-limits paths and dangerous commands go in `permissions.deny` in `.claude/settings.json` (user approval required)
- Layer 5: the autonomy boundary and failure handling go in CLAUDE.md "Don'ts / non-goals"
- Layer 6: personal preferences such as reply language go in `CLAUDE.local.md`

## Companion file skeleton

If the target file already exists, skip it and say so in the report. Don't overwrite it.

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Edit(src/gen/**)",
      "Bash(git push --force:*)",
      "Bash(git commit --no-verify:*)"
    ]
  }
}
```
