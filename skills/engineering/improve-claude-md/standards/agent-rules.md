# Agent rules (Claude-specific)

**Applies when:** All projects that use Claude Code

**Probe first:** The permissions in any existing `.claude/settings.json`; prohibitions the user has stressed out loud; the "Known pitfalls / mistakes Claude has made" table

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Autonomy boundary | What must be asked first: deleting files, changing schema / migrations, adding dependencies, changing CI, pushing externally, sending messages | none |
| Pre-authorized run | When Claude runs the whole loop without asking, stated as four parts: when it applies, where it stops, what still needs asking, what to report | "feature branch + gates green + review done + spec approved: commit, push, PR, merge to dev, retest, one report; still ask before prod writes and before merging auth changes" |
| Off-limits | Files and directories that must not be read or changed | Generated code, `.env*`, `vendor/`, published migrations |
| Context hygiene | Send an Explore subagent into large directories first; which files are the source of truth | `openapi.yaml` wins over code comments |
| Output conventions | Reply language, commit attribution, PR description format | none |
| Failure handling | After 2 failed attempts at the same fix, stop and report; never change tests / assertions to make tests pass; never use `--no-verify` | none |
| Completion bar | Before saying "done", there must be command output as evidence | none |

## Where it lands

- Layer 1: off-limits paths and dangerous commands go in `permissions.deny` in `.claude/settings.json` (user approval required)
- Layer 5: the autonomy boundary and failure handling go in CLAUDE.md "Don'ts / non-goals"; the pre-authorized run gets its own short CLAUDE.md section, because it changes the default flow every session follows, and its four parts all have to be there
- Layer 6: personal preferences such as reply language go in `CLAUDE.local.md`

## Companion file skeleton

If the target file already exists, skip it and say so in the report. Don't overwrite it.

Every `Bash` form below was live-tested: the `*` wildcard matches anywhere in the command, so the `git -C *` variants are what catch worktree and subdirectory calls that a bare `git push --force` rule misses, and `Read(.env*)` also blocks a Bash `cat` of the file and of copies in subdirectories. Whatever this audit adds, replay it against the command it is meant to stop before reporting it done.

```json
{
  "permissions": {
    "deny": [
      "Read(.env*)",
      "Read(./secrets/**)",
      "Edit(src/gen/**)",
      "Bash(git push --force*)",
      "Bash(git push * --force*)",
      "Bash(git -C * push * --force*)",
      "Bash(git reset --hard*)",
      "Bash(git -C * reset --hard*)",
      "Bash(git clean*)",
      "Bash(git checkout .)",
      "Bash(git checkout -- .)",
      "Bash(git commit * --no-verify*)",
      "Bash(git -C * commit * --no-verify*)"
    ]
  }
}
```
