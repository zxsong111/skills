# Ship guard hooks, a verifier agent and evals inside the plugin

The skills in this repo are advisory controls: a `SKILL.md` makes the agent more likely to do the right thing, and nothing stops a session that ignores it. `commit-push-pr` refuses to commit on the trunk, but only when the model loads it and follows it. The AI-native SDLC playbook (Anthropic Applied AI, 2026; an offline copy sits in the maintainer's notes) names the gap directly: skills make a violation rare, hooks make it close to impossible, and evals are the regression suite for the configuration that steers the agent. Up to v1.3 the plugin shipped the advisory layer only.

The gap matters more on this maintainer's machines than most, because sessions run in `bypassPermissions` mode. Permission prompts never fire there, so hooks are the one deterministic layer still running. (Deny rules in `permissions.deny` also still apply in that mode, per the permission-modes reference, which is why two `Read` denies go into the user settings alongside this work.)

## What a plugin can carry

Checked against the plugin component docs and Claude Code 2.1.309 before deciding:

- `hooks/hooks.json` registers hooks the moment the plugin is enabled, merged with the user's and the project's own hooks. A user cannot disable one plugin hook on its own; they can disable the plugin per project through `enabledPlugins`, or all hooks at once.
- `agents/*.md` ships subagents under the `zxs-skills:` namespace, auto-delegated by description.
- `evals/<case>/prompt.md` plus `graders/*.md` is the `claude plugin eval` format. Four grader types are deterministic and free (`regex`, `tool_used`, `tool_order`, `file_exists`); `llm` and `baseline` cost judge calls.

## Decision

1. **Hooks live in the plugin**, not in the user's `settings.json`. One source of truth, versioned with the skills they back. The cost is the version gate: a hook edit reaches daily sessions only after a reinstall or a version bump, so hook work is iterated in a `claude --plugin-dir` session and lands through changesets.
2. **Guard hooks are opt-in per repository** through a marker file, `.claude/guards`. Plugin hooks fire in every repo the plugin is enabled in, and this repo itself commits straight to `main` by convention, so an unconditional trunk guard would block its own maintainer. A repo that wants the guards commits the empty marker; one that does not stays untouched. One marker, not one per hook: the question is "does this repo want protecting", and the file's content stays free for per-hook settings later.
3. **First batch: `trunk-guard` and `secret-scan`**, both `PreToolUse` on `Bash`, both deciding only on `git commit`. The trunk guard makes `commit-push-pr`'s refusal deterministic. The secret scan reads the staged diff for key-shaped strings before the commit exists. Both answer with `permissionDecision: deny` and a reason that names the way out, because the deny reason is what the model sees and relays. Formatting and test-file locks are deferred: the first needs no help in a Markdown repo, the second needs a task-state signal that does not exist yet.
4. **A `verify-app` agent ships with the plugin.** It is the playbook's verifier: run the app, exercise the change and its neighbours, report what it saw, change nothing. It holds `Bash` and `Read` only, so a fresh context judges the work without the assumptions that produced it.
5. **Evals come in a second batch**, in the plugin's `evals/` directory, run by `claude plugin eval`. The first suite is trigger-rate regression for the model-invoked skills (the 2026-10-21 headless measurements become standing cases) plus one behaviour case each for `tdd` and `code-review`. CI runs the deterministic graders only and reports without blocking until the pass rate has a baseline; judge-based graders run locally until they have earned a budget.
6. **`code-review` adopts the playbook's report discipline**: two severities (Important is reserved for findings that would break behaviour, leak data or breach a policy; everything else is a nit), at most five nits per review with the rest summarised as a count, and a `## Do not report` section in `CODING_STANDARDS.md` that names paths the review skips.

## Invariants this creates

- `hooks/hooks.json` and `agents/` are plugin components next to `skills`; `claude plugin validate . --strict` must stay green after touching any of them, and `scripts/check-skills.mjs` keeps ignoring them (they are not skills and get no `README.md` or docs entry under the skill rules).
- A hook script never blocks on the marker's absence: no `.claude/guards`, exit 0 with no output, so the plugin stays inert in repos that did not ask for it.
- A hook script must finish in well under a second and touch only the current command and the staged diff. Anything heavier belongs in CI.
- Trunk detection follows `commit-push-pr`: the trunk is whatever `origin/HEAD` points at, falling back to `main` or `master`, and a repo with no commits yet is let through.
