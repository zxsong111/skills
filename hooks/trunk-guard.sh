#!/bin/bash
# trunk-guard: deny `git commit` on the repo's trunk when the repo opted in with .claude/guards.
# Makes the branch guard in the commit-push-pr skill deterministic. See ADR 0003.
set -u
. "$(dirname "$0")/lib.sh"

read_payload
is_git_commit || exit 0
guard_enabled || exit 0

# A repo with no commits yet: the first commit has to land on the trunk. Let it through.
git rev-parse -q --verify HEAD >/dev/null 2>&1 || exit 0

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || exit 0
[ "$branch" = "HEAD" ] && exit 0   # detached HEAD is not the trunk

trunk=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)
trunk=${trunk#origin/}
if [ -z "$trunk" ]; then
  for candidate in main master; do
    if git show-ref -q --verify "refs/heads/$candidate"; then trunk=$candidate; break; fi
  done
fi
[ -n "$trunk" ] || exit 0

if [ "$branch" = "$trunk" ]; then
  deny "trunk-guard: this repo protects its trunk ($trunk) and you are on it. Open a branch first (git switch -c <type>/<name>) and commit there, then open a PR back into $trunk. To stop guarding this repo, delete .claude/guards."
fi
exit 0
