---
description: A request to review a design doc should load goldfish-review, spawn the three goldfish agents, report under the three lens headings, catch the undefined term (reader) and the contradicted claim about parseLimit (code-fit). Needs --scaffold.
tags: [behaviour]
max_turns: 40
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Agent, Bash]
---

Run a goldfish review on `docs/designs/rate-limiter.md`. The repo has a `GLOSSARY.md`; there are no ADRs and no issue tracker.
