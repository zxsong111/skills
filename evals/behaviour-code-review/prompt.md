---
description: A review request against a fixed point should load code-review and produce the two-axis report with Important/Nit tags. The scaffold plants one standards breach and one unmet spec requirement. Needs --scaffold and --allow-tools "Bash(git *)".
tags: [behaviour]
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
---

Review the changes on this branch since `main`. The spec for the change is `docs/spec-greet.md` and the coding standards are in `CODING_STANDARDS.md`. There is no issue tracker for this repo.
