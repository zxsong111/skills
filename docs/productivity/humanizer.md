## What it does

`humanizer` rewrites text that reads as AI-written so it reads as human-written. It marks and rewrites 26 kinds of pattern (staging before the point, "not X but Y", forced triads, dashes everywhere, bold as decoration, chatbot residue, re-explaining background to the wrong reader) **without changing the meaning or inventing facts**. It touches only prose, never code, and a rewrite may not add a name, number, date or quote the source doesn't contain.

This version's description has the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) use it automatically whenever it writes prose for people: PR descriptions, commit message bodies, READMEs, docs, reports, issues, summaries for the user. Text someone else has already written, it leaves alone unless you ask.

## When to reach for it

Type `/humanizer`, or the agent reaches for it automatically when a task fits. By hand, type `/humanizer` with pasted text or a file name, or just say "humanize" or "remove the AI tone". The agent also loads it on its own whenever it writes the prose above.

| Situation | Use it? |
| --- | --- |
| The agent is writing a PR description, a README or docs | Automatically |
| You paste a piece of your own writing to polish | Yes |
| Code, commit subject lines, config files | No, it doesn't touch these |
| Quotations, titles, proper names, a passage discussing a phrase itself | It skips them, because these aren't AI tone |

## Patterns are ranked by strength

Patterns 1 to 5 (not X but Y, one-line closers, sayings that sound deep, a staged run-up before the point, arguing with no one) justify an edit on a single sighting. The later patterns marked *weak alone* need other tells in the same passage before the skill acts. It also has a Chinese text section that maps the patterns to their Chinese equivalents (the not-X-but-Y construction, a one-line "this is the key" paragraph, figurative buzzwords such as "empower" and "closed loop", the Chinese dash) and handles them by the same rules.

## Common questions

**Will it strip out my style too?**
No. It keeps the details that carry a writer's voice: a specific, unusual detail, unresolved mixed feelings, dated references, a first-person choice the writer can explain, a genuine aside. It changes default choices, not personal ones.

**Why fire automatically instead of when I ask?**
Because AI tone shows up in every paragraph of prose the agent writes, and by the time you notice and ask, it is too late. The automatic scope is limited to prose the agent is writing itself. It won't touch what you or anyone else has already written.

**Can it translate?**
No. It never switches the text into another language while rewriting it.

## It's working if

- PR descriptions the agent writes have no "not X but Y" contrasts, no clauses chained together with dashes, and no one-line summary closing every paragraph.
- The facts before and after the rewrite match one to one, with no extra numbers or quotes.
- Code blocks, commands, paths and URLs are untouched.
- Text you pasted yourself still sounds like you after the rewrite.

## Where it fits

`humanizer` is a **reach-for-it-anytime standalone** that follows any step producing prose: [pr](https://aihero.dev/skills-pr) writing a PR body, [research](https://aihero.dev/skills-research) writing research notes, [retro](https://aihero.dev/skills-retro) writing its suggestions. For documents written for agents, use [writing-for-agents](https://aihero.dev/skills-writing-for-agents), which is a different set of rules. [ask-zxs](https://github.com/zxsong111/skills/blob/main/docs/engineering/ask-zxs.md) has the map of the whole set.
