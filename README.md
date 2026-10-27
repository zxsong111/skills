# zxs Skills

Personal agent skills for real engineering: a hard fork of [Matt Pocock's skills](https://github.com/mattpocock/skills), customized for daily use by [zxsong111](https://github.com/zxsong111).

> **Credits**: nearly everything here (the skills, the docs, the ideas) comes from [mattpocock/skills](https://github.com/mattpocock/skills) by Matt Pocock, MIT licensed. This fork renames the plugin (`zxs-skills`) and two skills (`ask-zxs`, `setup-zxs-skills`), adds a few personal skills, and is maintained independently. It does not track upstream. Credit for the original design and content belongs to Matt; the mistakes introduced by the fork are mine.

Small, composable skills, designed to be adapted. Hack around with them. Make them your own.

## Installation

The plugin is `zxs-skills`, served by this repo's own marketplace (`zxs`). Pick one route per agent: the plugin routes and skills.sh are mutually exclusive, because installing both gives you every skill twice. Managed routes reinstall when the `version` in `plugin.json` changes.

<details>
<summary><strong>Claude Code</strong></summary>

```bash
claude plugin marketplace add zxsong111/skills
claude plugin install zxs-skills@zxs
```

When developing this repo itself, point a local directory marketplace at the checkout instead (see `extraKnownMarketplaces` in `~/.claude/settings.json`).

</details>

<details>
<summary><strong>Codex</strong></summary>

```bash
codex plugin marketplace add zxsong111/skills
codex plugin add zxs-skills@zxs
```

Updates itself at startup.

</details>

<details>
<summary><strong>GitHub Copilot</strong> (CLI and VS Code)</summary>

```bash
copilot plugin marketplace add zxsong111/skills
copilot plugin install zxs-skills@zxs
```

Then, once, add to `~/.copilot/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "zxs": { "source": { "source": "github", "repo": "zxsong111/skills" }, "autoUpdate": true }
  }
}
```

In VS Code, run **Chat: Install Plugin From Source** and enter `https://github.com/zxsong111/skills`. It updates daily.

</details>

<details>
<summary><strong>Gemini CLI</strong> (manual updates)</summary>

```bash
gemini skills install https://github.com/zxsong111/skills.git --path skills/engineering
gemini skills install https://github.com/zxsong111/skills.git --path skills/productivity
```

Re-run both commands to update.

</details>

<details>
<summary><strong>Any other agent, or editable files</strong> (manual updates)</summary>

```bash
npx skills@latest add zxsong111/skills -a <agent>  # cursor, opencode, devin, windsurf, amp, pi; omit -a to choose
```

When the installer asks which skills to take, include `setup-zxs-skills`. To update, run `npx skills@latest update`, and re-run `add` to pick up new skills.

</details>

### After installing

Run `/setup-zxs-skills` once per repo: it configures the issue tracker, triage labels, and domain doc layout the engineering skills assume. When you cannot remember which skill fits, `/ask-zxs` routes you.

## Reference

These split on one axis: who can invoke them. **User-invoked** skills are reachable only when you type them (e.g. `/grill-me`); their job is to orchestrate. **Model-invoked** skills can be invoked by you _or_ reached for automatically by the agent when the task fits; they hold the reusable discipline. A user-invoked skill may invoke model-invoked skills, but never another user-invoked one.

### Engineering

Skills for daily code work.

**User-invoked**

- **[ask-zxs](./skills/engineering/ask-zxs/SKILL.md)**: Ask which skill or flow fits your situation. A router over the user-invoked skills in this repo.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)**: Grilling session that also builds your project's domain model, sharpening terminology and updating `GLOSSARY.md` and ADRs inline.
- **[triage](./skills/engineering/triage/SKILL.md)**: Move issues through a state machine of triage roles.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)**: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
- **[setup-zxs-skills](./skills/engineering/setup-zxs-skills/SKILL.md)**: Configure this repo for the engineering skills (issue tracker, triage labels, domain doc layout). Run once per repo before using the other engineering skills.
- **[to-spec](./skills/engineering/to-spec/SKILL.md)**: Turn the current conversation into a spec and publish it to the issue tracker. No interview, just synthesizes what you've already discussed.
- **[to-tickets](./skills/engineering/to-tickets/SKILL.md)**: Break any plan, spec, or conversation into a set of tracer-bullet tickets, each declaring its blocking edges, written as text in a local file, or as native blocking links on a real tracker.
- **[implement](./skills/engineering/implement/SKILL.md)**: Build the work described by a spec or set of tickets, driving `/tdd` at pre-agreed seams and closing out with `/code-review` before committing.
- **[implement-spec](./skills/engineering/implement-spec/SKILL.md)**: Implement a whole spec on one integration branch. Works the tickets as a task graph, running implementer subagents across the ready frontier for maximum concurrency, then closes out with `/code-review`.
- **[wayfinder](./skills/engineering/wayfinder/SKILL.md)**: Plan a huge chunk of work, more than one agent session can hold, as a shared map of decision tickets on the issue tracker, and resolve them one at a time until the way to the destination is clear.
- **[retro](./skills/engineering/retro/SKILL.md)**: Suggest improvements to the coding agent's environment (navigation, automated checks, coding standards, steering files, tooling) after a session, most severe first.
- **[drift-check](./skills/engineering/drift-check/SKILL.md)**: Check the repo's narrative docs (ADRs, `GLOSSARY.md`, the top-level README, docs pages) against the code they describe, one goldfish reviewer per document, and tag each finding fix the doc / fix the code / your call. `CLAUDE.md` and `AGENTS.md` stay with `improve-claude-md`.

**Model-invoked**

- **[prototype](./skills/engineering/prototype/SKILL.md)**: Build a throwaway prototype to answer a design question, either a single shareable HTML file for state/logic questions, or several radically different UI variations toggleable from one route.
- **[diagnosing-bugs](./skills/engineering/diagnosing-bugs/SKILL.md)**: Disciplined diagnosis loop for hard bugs and performance regressions: build a feedback loop that goes red on this bug, then minimise, hypothesise, instrument, fix, and regression-test.
- **[research](./skills/engineering/research/SKILL.md)**: Investigate a question against high-trust primary sources and capture the findings as a cited Markdown file in the repo, run as a background agent.
- **[tdd](./skills/engineering/tdd/SKILL.md)**: Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[domain-modeling](./skills/engineering/domain-modeling/SKILL.md)**: Actively build and sharpen a project's domain model: challenge terms against the glossary, stress-test with edge-case scenarios, and update `GLOSSARY.md` and ADRs inline.
- **[codebase-design](./skills/engineering/codebase-design/SKILL.md)**: Shared discipline and vocabulary for designing deep modules: a lot of behaviour behind a small interface, placed at a clean seam, testable through that interface.
- **[code-review](./skills/engineering/code-review/SKILL.md)**: Two-axis review of the diff since a fixed point: **Standards** (does it follow the repo's coding standards, plus a Fowler smell baseline?) and **Spec** (does it faithfully implement the originating issue/spec?), run as parallel sub-agents so neither pollutes the other.
- **[goldfish-review](./skills/engineering/goldfish-review/SKILL.md)**: Review a spec, design doc, ADR or plan with three read-only subagents that see the document and the code but none of the conversation that wrote it: **Zoom-out** (is this the right amount to build?), **Reader** (can someone build from the page alone?) and **Code-fit** (does it agree with the code?). The first of the two review gates; `code-review` is the second.
- **[pr](./skills/engineering/pr/SKILL.md)**: The shape a pull request body should take: a summary as the smallest visual that makes the change clear, before/after evidence that it works, and a merge-danger call (one-way or two-way door, plus blast radius).
- **[wizard](./skills/engineering/wizard/SKILL.md)**: Generate an interactive bash wizard that walks a human through steps only they can perform: provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, or running a one-off migration or cutover.
- **[commit-push-pr](./skills/engineering/commit-push-pr/SKILL.md)**: Commit, push and open a PR to a fixed convention, with a trunk guard (on `main` / `master` it stops and asks instead of committing). The PR body is handed to `pr`. The agent reaches for it when you say "commit" or "push it".
- **[receiving-code-review](./skills/engineering/receiving-code-review/SKILL.md)**: Take review feedback (a `code-review` report, a `goldfish-review` report, PR comments) by verifying before implementing, with no performative agreement. A Reader gap is never contested; a judgement-call rule that keeps coming back is routed into `CODING_STANDARDS.md`.
- **[security-and-hardening](./skills/engineering/security-and-hardening/SKILL.md)**: A security checklist for changes that touch auth, sessions, payments, PII, file uploads, webhooks, untrusted external input or new dependencies: map the trust boundaries first, then harden item by item against OWASP.
- **[improve-claude-md](./skills/engineering/improve-claude-md/SKILL.md)**: Audit and improve a project's `CLAUDE.md` / `AGENTS.md` / `.claude/rules/` (existing projects included), then generate the coding standards this project actually needs from a 29-item menu, each tagged with the layer it belongs in. Reports first, writes only after approval.

### Productivity

General workflow tools, not code-specific.

**User-invoked**

- **[grill-me](./skills/productivity/grill-me/SKILL.md)**: Get relentlessly interviewed about a plan or design until every branch of the design tree is resolved.
- **[handoff](./skills/productivity/handoff/SKILL.md)**: Compact the current conversation into a handoff document so another agent can continue the work.
- **[teach](./skills/productivity/teach/SKILL.md)**: Teach the user a new skill or concept over multiple sessions, using the current directory as a stateful teaching workspace.
- **[to-questionnaire](./skills/productivity/to-questionnaire/SKILL.md)**: Turn a decision you can't answer alone into a Markdown questionnaire for the one person who can, filled in async, or together over a meeting. It grills you about the send (who it's for, what you need back), not the subject.
- **[wait-what](./skills/productivity/wait-what/SKILL.md)**: Fire this the moment a message doesn't land. The agent re-pitches it with the context you're missing, in plain English, using your `GLOSSARY.md` vocabulary.
- **[resume-handoff](./skills/productivity/resume-handoff/SKILL.md)**: In a fresh session, find the document `/handoff` wrote, check the working tree still matches it, and carry on from its next step. The other half of `handoff`.

**Model-invoked**

- **[grilling](./skills/productivity/grilling/SKILL.md)**: Interview the user relentlessly about a plan, decision, or idea until every branch of the design tree is resolved. The reusable interview primitive behind `grill-me`, `grill-with-docs`, `triage`, `wayfinder` and `improve-codebase-architecture`.
- **[writing-for-agents](./skills/productivity/writing-for-agents/SKILL.md)**: Writing documents for agents: skills, AGENTS.md/CLAUDE.md, and any doc an agent reaches by a pointer.
- **[humanizer](./skills/productivity/humanizer/SKILL.md)**: Strip the AI tone from prose written for people (PR descriptions, READMEs, docs, reports) automatically: rewrites against 26 patterns without changing the meaning or inventing facts, and touches prose only, never code.
- **[i-have-adhd](./skills/productivity/i-have-adhd/SKILL.md)**: Shape every reply automatically: the first line is the next action, multi-step work is numbered, state is restated each turn, and there are no openers or sign-offs. Say "stop adhd mode" to turn it off for the session.

## Guard hooks and agents

The plugin also ships two deterministic guards and four agents, the layer the skills alone cannot provide (see [ADR 0003](./.agents/adr/0003-ship-guard-hooks-agents-and-evals-in-the-plugin.md) and [ADR 0004](./.agents/adr/0004-goldfish-review-and-drift-check.md)).

The guards are **opt-in per repository**: they stay silent until the repo contains a marker file, `.claude/guards` (an empty file; commit it with `git add -f` if the repo ignores `.claude/`). With the marker present, both run before any `git commit`:

- **trunk-guard** denies a commit on the repo's trunk (`origin/HEAD`, else `main` or `master`) and names the branch to open instead. It is the deterministic twin of `commit-push-pr`'s branch guard.
- **secret-scan** denies a commit whose staged lines look like credentials (cloud keys, API tokens, private keys, quoted passwords) and lists `file:line`. Append a comment containing `secret-scan:allow` to a false positive.

Delete the marker to switch both off for that repo.

- **[verify-app](./agents/verify-app.md)** (`zxs-skills:verify-app`) is a reporting-only subagent with `Bash` and `Read`: it runs the build, tests and the changed flow in a fresh context and returns a READY / NOT READY verdict with the command output, without touching a file.
- **[goldfish-zoom-out](./agents/goldfish-zoom-out.md)**, **[goldfish-reader](./agents/goldfish-reader.md)** and **[goldfish-code-fit](./agents/goldfish-code-fit.md)** are the goldfish reviewers `goldfish-review` spawns: read-only (`Read`, `Grep`, `Glob`), loading no `CLAUDE.md`, each answering one question about a document (is this the right amount to build, can someone build from the page alone, does it agree with the code). `drift-check` reuses `goldfish-code-fit` on documents that describe existing code.

## Evals

`evals/` is a [`claude plugin eval`](https://code.claude.com/docs/en/plugin-evals) suite: the regression tests for the configuration that steers the agent, rerun whenever a skill, hook or agent changes. Eight cases so far, all graded deterministically (no judge model, so no judge cost):

- `trigger-*`: does a prompt phrased the way a user types it load the skill it should? One case each for `humanizer`, `i-have-adhd` (a Chinese prompt, the known weak spot), `security-and-hardening`, `commit-push-pr` and `goldfish-review`.
- `behaviour-tdd`: a test-first request writes the test, runs it red, and only then writes the implementation.
- `behaviour-code-review`: a review against a fixed point loads the skill, runs both axes in sub-agents, reports `## Standards` and `## Spec` with `Important` tags, catches the planted spec gap and honours `## Do not report`.
- `behaviour-goldfish-review`: a review of a design doc loads the skill, spawns the three goldfish agents, reports `## Zoom-out`, `## Reader` and `## Code-fit`, and catches both the planted undefined term and the planted contradiction with the code.

Run it locally from the repo root (Bash cases need `bubblewrap` and `socat` on Linux):

```bash
claude plugin eval . --trust-plugin --ablation none --scaffold \
  --allow-tools Write Edit "Bash(node *)" "Bash(git *)" --no-publish
```

CI runs the same command nightly and on pull requests that touch `skills/`, `hooks/`, `agents/`, `evals/` or the manifest. The job reports and never fails the build until the pass rate has a baseline. Results land in `evals/results/`, which is ignored.

## Maintainer notes

- Skill wiring is enforced by `npm run check-skills`, also run in CI on every push to `main`.
- `hooks/` and `agents/` are plugin components, not skills: they take no README entry under the skill rules and no docs page, and `claude plugin validate . --strict` must stay green after touching them.
- Changelog entries come from changesets (`npm run changeset`); the release workflow opens a "chore: version skills" PR on this repo when one merges to `main`.
- The local daily driver loads this checkout as a directory marketplace, so it refreshes when `plugin.json`'s `version` changes.
