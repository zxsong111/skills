# CI/CD

**Applies when:** Has a CI pipeline, a deployment process, or a quality gate table no workflow runs

**Probe first:** The steps `.github/workflows/` / `.gitlab-ci.yml` actually run; how deployment works; the CLAUDE.md quality gate table and whether anything runs it

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Gate parity | The CI jobs run the same commands as the CLAUDE.md gate table, not a near copy | the gate row and the CI step both say `go vet ./...` |
| Trunk baseline | The first CI run on the trunk is expected to find problems; fix them before treating CI as green | a gate nobody ran locally turns up 5 failures on its first CI run |
| What CI does not cover | The workflow comments and PR descriptions state which gates CI cannot run, and why | DB-backed tests skip in CI, because the job has no database |
| Required checks | Which CI jobs must be green before merging | lint, type, test |
| Who can enforce | Branch protection and auto-merge need repo admin rights; check the account has them before promising the enforcement | none |
| Branch ↔ environment | Which branch deploys to which environment | `develop` → DEV, `main` → PRO |
| Deployment approval | Who approves production deployments | none |
| Rollback | Rollback command / steps | none |
| Local equivalent | How to run each CI step locally | `make ci` |

## Where it lands

- Layer 2: make the must-pass jobs required checks in branch protection
- Layer 5: write the local equivalents of the CI steps back into CLAUDE.md "Verification commands" and "Quality gates"; state in CLAUDE.md which gates CI skips and why
- When the audit finds a gate table with no workflow, wire the blocking rows into CI in the same pass: a blocking gate nothing runs is a stale row with better marketing
