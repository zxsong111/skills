# CI/CD

**Applies when:** Has a CI pipeline or deployment process

**Probe first:** The steps `.github/workflows/` / `.gitlab-ci.yml` actually run; how deployment works

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Required checks | Which CI jobs must be green before merging | lint, type, test |
| Branch ↔ environment | Which branch deploys to which environment | `develop` → DEV, `main` → PRO |
| Deployment approval | Who approves production deployments | none |
| Rollback | Rollback command / steps | none |
| Local equivalent | How to run each CI step locally | `make ci` |

## Where it lands

- Layer 2: make the must-pass jobs required checks in branch protection
- Layer 5: write the local equivalents of the CI steps back into CLAUDE.md "Verification commands" and "Quality gates"
