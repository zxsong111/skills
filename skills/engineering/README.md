# Engineering

Skills I use daily for code work.

## User-invoked

Reachable only when you type them (Claude Code: `disable-model-invocation: true`; Codex: `policy.allow_implicit_invocation: false` in `agents/openai.yaml`).

- **[ask-zxs](./ask-zxs/SKILL.md)**: Ask which skill or flow fits your situation. A router over the user-invoked skills in this repo.
- **[grill-with-docs](./grill-with-docs/SKILL.md)**: Grilling session that also builds your project's domain model, sharpening terminology and updating `GLOSSARY.md` and ADRs inline.
- **[triage](./triage/SKILL.md)**: Move issues through a state machine of triage roles.
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)**: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
- **[setup-zxs-skills](./setup-zxs-skills/SKILL.md)**: Configure this repo for the engineering skills (issue tracker, triage labels, domain doc layout). Run once per repo.
- **[to-spec](./to-spec/SKILL.md)**: Turn the current conversation into a spec and publish it to the issue tracker.
- **[to-tickets](./to-tickets/SKILL.md)**: Break any plan, spec, or conversation into a set of tracer-bullet tickets, each declaring its blocking edges, whether as text in a local file or as native blocking links on a real tracker.
- **[implement](./implement/SKILL.md)**: Build the work described by a spec or set of tickets, driving `/tdd` at pre-agreed seams and closing out with `/code-review` before committing.
- **[implement-spec](./implement-spec/SKILL.md)**: Implement a whole spec on one integration branch. Works the tickets as a task graph, running implementer subagents across the ready frontier for maximum concurrency, then closes out with `/code-review`.
- **[wayfinder](./wayfinder/SKILL.md)**: Plan a huge chunk of work (more than one agent session can hold) as a shared map of decision tickets on the issue tracker, resolved one at a time until the way to the destination is clear.
- **[retro](./retro/SKILL.md)**: Suggest improvements to the coding agent's environment (navigation, automated checks, coding standards, steering files, tooling) after a session, most severe first.
- **[drift-check](./drift-check/SKILL.md)**: Check the repo's narrative docs (ADRs, `GLOSSARY.md`, the top-level README, docs pages) against the code they describe, one goldfish reviewer per document, and tag each finding fix the doc / fix the code / your call. `CLAUDE.md` and `AGENTS.md` stay with `improve-claude-md`.

## Model-invoked

Model- or user-reachable (rich trigger phrasing so the model can reach for them).

- **[prototype](./prototype/SKILL.md)**: Build a throwaway prototype to answer a design question: a single shareable HTML file for state/logic, or several toggleable UI variations.

- **[diagnosing-bugs](./diagnosing-bugs/SKILL.md)**: Disciplined diagnosis loop for hard bugs and performance regressions: build a feedback loop that goes red on this bug → minimise → hypothesise → instrument → fix → regression-test.
- **[research](./research/SKILL.md)**: Investigate a question against high-trust primary sources and capture the findings as a cited Markdown file in the repo, run as a background agent.
- **[tdd](./tdd/SKILL.md)**: Test-driven development with a red-green-refactor loop. Builds features or fixes bugs one vertical slice at a time.
- **[domain-modeling](./domain-modeling/SKILL.md)**: Actively build and sharpen a project's domain model by challenging terms, stress-testing with scenarios, and updating `GLOSSARY.md` and ADRs inline.
- **[codebase-design](./codebase-design/SKILL.md)**: Shared discipline and vocabulary for designing deep modules: small interfaces, clean seams, testable through the interface.
- **[code-review](./code-review/SKILL.md)**: Two-axis review of the diff since a fixed point: **Standards** (does it follow the repo's coding standards, plus a Fowler smell baseline?) and **Spec** (does it faithfully implement the originating issue/spec?), run as parallel sub-agents.
- **[goldfish-review](./goldfish-review/SKILL.md)**: Review a spec, design doc, ADR or plan with three read-only subagents that see the document and the code but none of the conversation that wrote it: **Zoom-out** (is this the right amount to build?), **Reader** (can someone build from the page alone?) and **Code-fit** (does it agree with the code?). The first of the two review gates; `code-review` is the second.
- **[pr](./pr/SKILL.md)**: The shape a pull request body should take: a summary as the smallest visual that makes the change clear, before/after evidence that it works, and a merge-danger call (one-way or two-way door, plus blast radius).
- **[wizard](./wizard/SKILL.md)**: Generate an interactive bash wizard that walks a human through steps only they can perform: provisioning infrastructure, setting up credentials or CI secrets, walking an unfamiliar third-party dashboard, or running a one-off migration or cutover.
- **[commit-push-pr](./commit-push-pr/SKILL.md)**: Commit, push and open a PR to a fixed convention, with a trunk guard (on `main` / `master` it stops and asks instead of committing). The PR body is handed to `pr`. The agent reaches for it when you say "commit" or "push it".
- **[receiving-code-review](./receiving-code-review/SKILL.md)**: Take review feedback (a `code-review` report, a `goldfish-review` report, PR comments) by verifying before implementing, with no performative agreement. A Reader gap is never contested; a judgement-call rule that keeps coming back is routed into `CODING_STANDARDS.md`.
- **[security-and-hardening](./security-and-hardening/SKILL.md)**: A security checklist for changes that touch auth, sessions, payments, PII, file uploads, webhooks, untrusted external input or new dependencies: map the trust boundaries first, then harden item by item against OWASP.
- **[improve-claude-md](./improve-claude-md/SKILL.md)**: Audit and improve a project's `CLAUDE.md` / `AGENTS.md` / `.claude/rules/` (existing projects included), then generate the coding standards this project actually needs from a 29-item menu, each tagged with the layer it belongs in. Reports first, writes only after approval.
