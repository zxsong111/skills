# License compliance

**Applies when:** Closed-source commercial projects, or ones that vendor third-party code

**Probe first:** Dependency license scan results; vendor directories in the repo

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Allowed | MIT, BSD, Apache-2.0, and the like | none |
| Banned / needs approval | GPL, AGPL, SSPL, and the like | none |
| Vendored code | Copied-in third-party code keeps its original LICENSE and source commit | none |

## Where it lands

- Layer 2: license scanning goes into CI (license-checker, pip-licenses)
- Layer 5: goes in CLAUDE.md; the agent rules say "check the license before adding a dependency"
