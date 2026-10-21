# Versioning and release

**Applies when:** Libraries or apps released externally, or services with a formal release process

**Probe first:** Tag history, CHANGELOG, release scripts / workflow

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| Version number | SemVer; when to bump major / minor / patch | none |
| CHANGELOG | One entry per user-visible change, grouped by version | Keep a Changelog format |
| Release process | Which branch, who triggers it, pre-release checks | none |
| Hotfix | Branch from `main`, merge back into both `main` and `develop` when fixed | none |
| Deprecation | Keep a deprecated interface for at least one minor version and provide migration notes | none |

## Where it lands

- Layer 2: the release workflow validates the version number and CHANGELOG automatically
- Layer 5: goes in CLAUDE.md; companion: with no `CHANGELOG.md`, generate a skeleton

## Companion file skeleton

If the target file already exists, skip it and say so in the report. Don't overwrite it.

```markdown
# Changelog

## [Unreleased]

### Added
### Changed
### Fixed
### Removed
```
