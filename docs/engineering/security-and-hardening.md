## What it does

`security-and-hardening` is a security hardening checklist that fires on the change in front of it. When a change touches authentication, sessions, payments, personal data, file uploads, webhooks, untrusted external input or new dependencies, it first has you **map the trust boundaries** (where untrusted data enters the system, which assets are worth stealing, and a STRIDE pass over each boundary), then hardens item by item against OWASP. Its stance is that if you cannot name a feature's trust boundaries, you are not ready to protect it.

It splits its rules into three tiers:

- **Always do**: parameterized queries, output encoding, HTTPS, password hashing, security headers, dependency audits.
- **Ask first**: new auth flows, new categories of sensitive data, CORS, uploads, privilege escalation.
- **Never do**: commit secrets, log sensitive data, trust client-side validation, pass LLM output straight into eval or SQL.

## When to reach for it

Type `/security-and-hardening`, or the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) reaches for it automatically when a task fits: when a change touches one of the areas above. The rest of the time it stays out of the [context window](https://www.aihero.dev/ai-coding-dictionary/context-window).

| Situation | What it gives you |
| --- | --- |
| Adding login, changing permissions or sessions | Password hashing, cookie attributes, the rule that every request checks authorization |
| Accepting forms, uploads, webhooks or user-supplied URLs | Schema validation at the boundary, magic-byte checks, a DNS-resolution check against SSRF |
| Adding a dependency, running an audit | A package-manager matrix, gating of install scripts, triage by reachability |
| Handling PII | Field classification, minimal collection, retention periods, a deletion path |
| Wiring in an LLM | Model output treated as untrusted input, prompt injection, tenant isolation |

Concrete code patterns live in `references/hardening-patterns.md` in the skill directory, and the skill opens the matching section when it reaches that code. Before sign-off it walks through `references/security-checklist.md`.

## The excuses it is waiting for

The skill carries a table of rationalizations: internal tools don't need security, the prototype can add it later, the framework handles it, the audit passed so the dependencies are fine, collect the data now in case it's useful later. Each one is paired with the reality. The table exists to be read at the exact moment you want to skip a step.

## Common questions

**Does it change code itself?**
Yes, within the scope you have authorized. For changes in the ask-first tier (new auth flows, new sensitive data, CORS, uploads, privilege escalation) it stops and asks first.

**How does it relate to `code-review`?**
This skill is for implementation; [code-review](https://aihero.dev/skills-code-review) reviews afterwards. Write the project's security baseline into `CODING_STANDARDS.md`, and both read the same rules.

**My project has no web interface.**
Then most sections don't apply, and the skill won't fire. The sections on handling secrets, destructive operations on the file system, and paths passed in by external processes apply to any program.

## It's working if

- When you add an endpoint that takes external input, the reply lists the trust boundaries and assets before any code.
- No password, token or `.env` content shows up in any diff.
- Code for uploads, SSRF and rate limiting follows the patterns the skill supplies, not something improvised on the spot.
- When a new dependency comes in, the audit result and the handling of its install scripts are reported explicitly.

## Where it fits

`security-and-hardening` is a **reach-for-it-anytime standalone**, not a step on the main chain. It gets pulled in when code driven by [tdd](https://aihero.dev/skills-tdd) during implementation reaches a security-sensitive area. When a security incident needs its root cause found first, use [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs). [ask-zxs](https://github.com/zxsong111/skills/blob/main/docs/engineering/ask-zxs.md) has the map of the whole set.
