# Code ownership

**Applies when:** Repos where several people or teams contribute

**Probe first:** Existing CODEOWNERS, how directories map to teams

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Ownership | The owner or team for each directory / module | `/src/payment/ @team-payment` |
| Required review | Which directories need the owner's review for any change | Payments, auth |

## Where it lands

- Layer 2: `.github/CODEOWNERS` + the branch protection setting "Require review from Code Owners"
- Companion: with no CODEOWNERS, generate a skeleton and leave the owners blank for the user to fill in
