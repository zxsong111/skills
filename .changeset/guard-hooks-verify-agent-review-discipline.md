---
"zxs-skills": minor
---

Ship the deterministic layer the skills could only recommend (ADR 0003, after the AI-native SDLC playbook):

- **Guard hooks**, opt-in per repo through a `.claude/guards` marker and silent otherwise. `trunk-guard` denies `git commit` on the repo's trunk, making `commit-push-pr`'s branch guard deterministic. `secret-scan` denies a commit whose staged lines look like credentials and lists `file:line`; `secret-scan:allow` on a line marks a false positive.
- **`verify-app` agent** (`zxs-skills:verify-app`): a reporting-only subagent with `Bash` and `Read` that runs build, tests and the changed flow in a fresh context and returns a READY / NOT READY verdict.
- **`code-review` report discipline**: every finding is `Important` or `Nit` (`Important` only for broken behaviour, leaked data or a breached standard or spec), at most five nits shown with the rest counted, a `## Do not report` section in `CODING_STANDARDS.md` is honoured, and both sub-agent briefs now forbid re-invoking `/code-review` or spawning further agents.
