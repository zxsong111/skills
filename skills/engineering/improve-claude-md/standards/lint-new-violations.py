#!/usr/bin/env python3
"""PostToolUse hook (Edit|Write): send the session back when an edit adds lint violations.

For repos that carry lint debt. A whole-file lint blocks every edit to a dirty
file, and a `--fix` pass over the debt is its own diff; this hook compares the
edited file with its HEAD version and reports only the violations the working
copy gained. Debt already in HEAD is left alone.

Register in the project's `.claude/settings.local.json` (or settings.json):

    "hooks": {
      "PostToolUse": [
        {
          "matcher": "Edit|Write",
          "hooks": [
            {
              "type": "command",
              "command": "python3 .claude/hooks/lint_new_violations.py",
              "timeout": 30,
              "statusMessage": "lint: checking for new violations"
            }
          ]
        }
      ]
    }

The repo is found through the edited file, so the main checkout and its
worktrees behave the same. The linter comes from `LINT_BIN` and falls back to
the repo's `.venv/bin/ruff`. Porting another linter means rewriting `lint()`
and `key()` below; everything else is linter-agnostic.

Exit 2 = blocking: Claude Code feeds stderr back to the model.
Exit 0 = everything else, including every failure of this script itself: a
broken hook must never block an edit.
"""
import json
import os
import re
import subprocess
import sys
from collections import Counter

LINT_ARGS = ["check", "--no-fix", "--force-exclude", "--output-format=json"]


def linter(root):
    return os.environ.get("LINT_BIN") or os.path.join(root, ".venv", "bin", "ruff")


def lint(root, rel, source=None):
    """Violations for `rel` as a JSON list; `source` lints that text instead of the file."""
    args = [linter(root), *LINT_ARGS]
    args += ["--stdin-filename", rel, "-"] if source is not None else [rel]
    out = subprocess.run(args, cwd=root, input=source, capture_output=True, text=True, timeout=15)
    return json.loads(out.stdout or "[]")


def key(violation):
    # Line numbers shift with every edit, so they cannot be part of the identity.
    return violation.get("code"), re.sub(r"line \d+", "line N", violation.get("message", ""))


def main():
    path = (json.load(sys.stdin).get("tool_input") or {}).get("file_path") or ""
    if not path.endswith(".py") or not os.path.isfile(path):
        return 0

    top = subprocess.run(
        ["git", "-C", os.path.dirname(path) or ".", "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, timeout=10,
    )
    if top.returncode != 0:
        return 0
    top = top.stdout.strip()
    rel = os.path.relpath(os.path.abspath(path), top)

    current = lint(top, rel)
    if not current:
        return 0

    head = subprocess.run(
        ["git", "-C", top, "show", f"HEAD:{rel}"], capture_output=True, text=True, timeout=10
    )
    before = lint(top, rel, head.stdout) if head.returncode == 0 else []

    added = Counter(map(key, current)) - Counter(map(key, before))
    if not added:
        return 0

    lines = [f"lint: {sum(added.values())} violation(s) not in HEAD for {rel}:"]
    for violation in current:
        if key(violation) in added:
            row = violation.get("location", {}).get("row", "?")
            lines.append(f"  {rel}:{row}: {violation.get('code')} {violation.get('message')}")
    lines.append("Fix them before continuing.")
    print("\n".join(lines), file=sys.stderr)
    return 2


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:  # a broken hook must never block an edit
        sys.exit(0)
