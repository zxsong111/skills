---
"zxs-skills": minor
---

Add an eval suite (`evals/`, batch 2 of ADR 0003): six cases for `claude plugin eval`, all graded deterministically so CI costs nothing beyond the agent runs.

- `trigger-*` regression cases for `humanizer`, `i-have-adhd` (Chinese prompt), `security-and-hardening` and `commit-push-pr` (scaffolded repo, staged change on the trunk).
- `behaviour-tdd`: asserts the red-green order itself, test written and run before the implementation exists.
- `behaviour-code-review`: asserts the skill loads, both axes report under `## Standards` / `## Spec` with `Important` tags, the planted spec gap is caught and `## Do not report` is honoured.

CI (`.github/workflows/evals.yml`) runs the suite nightly and on pull requests touching `skills/`, `hooks/`, `agents/`, `evals/` or the manifest, reporting only, gated on the `ANTHROPIC_API_KEY` / `ANTHROPIC_AUTH_TOKEN` secret, capped at $10 per run.
