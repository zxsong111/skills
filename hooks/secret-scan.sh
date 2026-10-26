#!/bin/bash
# secret-scan: deny `git commit` when the lines about to be committed look like credentials.
# Opt-in per repo with .claude/guards. Reads only the diff, never the whole tree. See ADR 0003.
set -u
. "$(dirname "$0")/lib.sh"

read_payload
is_git_commit || exit 0
guard_enabled || exit 0

# Key-shaped strings. A line that carries `secret-scan:allow` is skipped on purpose.
PATTERNS='AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{22,}|xox[abprs]-[A-Za-z0-9-]{10,}|sk-ant-[A-Za-z0-9_-]{20,}|sk-[A-Za-z0-9]{32,}|AIza[0-9A-Za-z_-]{35}|(api[_-]?key|secret[_-]?key|access[_-]?token|auth[_-]?token|password|passwd)[[:space:]]*[:=][[:space:]]*["'"'"'][^"'"'"'[:space:]]{8,}["'"'"']'

# Staged changes, plus tracked modifications when the command stages them itself (-a / --all).
diff_cmd="git diff --cached --no-color --unified=0"
if printf '%s' "$HOOK_COMMAND" | grep -Eq '(^|[[:space:]])(-a|--all|-[a-zA-Z]*a[a-zA-Z]*)([[:space:]]|$)'; then
  diff_cmd="git diff HEAD --no-color --unified=0"
fi

found=$($diff_cmd 2>/dev/null | awk -v pat="$PATTERNS" '
  /^\+\+\+ / { file = substr($0, 7); next }
  /^@@/      { split($0, parts, "+"); split(parts[2], nums, /[, ]/); line = nums[1] + 0; next }
  /^\+/      {
    text = substr($0, 2)
    if (text ~ pat && text !~ /secret-scan:allow/) printf "  %s:%d\n", file, line
    line++
    next
  }
')

if [ -n "$found" ]; then
  deny "secret-scan: the staged changes contain strings that look like credentials:
$found
Move the value into an environment variable or an ignored file and stage again. If a line is a false positive, append a comment containing secret-scan:allow to it. To stop guarding this repo, delete .claude/guards."
fi
exit 0
