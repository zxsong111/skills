---
name: receiving-code-review
description: Use when receiving code review feedback (a code-review report, review comments on a PR, feedback the user passes along), before implementing the suggestions, especially when the feedback is unclear or technically questionable. Calls for technical rigor and verification, not performative agreement or blind implementation.
---

# Receiving Code Review

## Overview

Code review calls for technical evaluation, not emotional performance.

**Core principle:** Verify before implementing. Ask before assuming. Technical correctness over social comfort.

## The response pattern

```
When you receive code review feedback:

1. READ: read the whole of the feedback before reacting
2. UNDERSTAND: restate the requirement in your own words (or just ask)
3. VERIFY: check it against what the codebase actually does
4. EVALUATE: is it technically sound for **this** codebase?
5. RESPOND: a technical acknowledgment, or reasoned pushback
6. IMPLEMENT: one item at a time, test each one
```

## Forbidden responses

**NEVER:**
- "You're absolutely right!" (an explicit violation of the instruction files)
- "Great point!" / "Excellent feedback!" (performative)
- "Let me implement that now" (before verifying)

**INSTEAD:**
- Restate the technical requirement
- Ask clarifying questions
- Push back with technical reasoning if they're wrong
- Just start working (actions > words)

## When feedback is unclear

```
If any item is unclear:
  STOP: don't act on any of them yet
  ASK about the unclear items

WHY: items may be related. Half understood = implemented wrong.
```

**Example:**
```
Your human partner: "Fix 1-6"
You understand 1, 2, 3 and 6. 4 and 5 are unclear.

❌ WRONG: do 1, 2, 3 and 6 now, ask about 4 and 5 later
✅ RIGHT: "I understand 1, 2, 3 and 6. Before I start, I need you to clarify 4 and 5."
```

## Feed it back: no mistake gets flagged a third time

As you implement each piece of feedback, also judge whether it is a **repeat mistake**:

- The project `CLAUDE.md` already has a similar entry under "Known pitfalls", or this is the second time the same kind of problem has been flagged in this session or this PR
  → add a line to "Known pitfalls" **in the same PR** (date / symptom / correct approach), and say it has been recorded when you reply to the review.
  If it can be blocked mechanically (off-limits paths, dangerous commands), also suggest a `.claude/settings.json` deny rule or a hook, which is more reliable than prose
- The feedback points out that the "Verification commands", "Project structure" or "Project conventions" in `CLAUDE.md` are out of date → fix them in the same PR
- The feedback questions the **requirement** rather than the implementation ("should it really behave like this?") → that is not the review's call;
  put the question to the user as-is to decide, going back to `/grill-with-docs` if needed; do not change the spec or ticket just to satisfy the reviewer
- The feedback points to a **judgment** rule (cross-file consistency, style) and keeps coming up → suggest writing it into `CODING_STANDARDS.md`, so `code-review` checks it next time; for **mechanical** ones (fixed syntax, banned APIs), suggest a lint rule instead of prose

When the repo root has a `CODING_STANDARDS.md`, its rules on feeding back are the project's version of this section and take precedence.

## Treat feedback by source

### From your human partner
- **Trusted**: implement once you understand it
- **Still ask** when the scope is unclear
- **No performative agreement**
- **Act directly**, or give a one-line technical acknowledgment

### From external reviewers
```
Before implementing:
  1. Check: is it technically correct for **this** codebase?
  2. Check: does it break existing functionality?
  3. Check: is there a reason the current implementation is written this way?
  4. Check: does it work on all platforms/versions?
  5. Check: does the reviewer have the full context?

If the suggestion looks wrong:
  push back with technical reasoning

If you can't easily verify it:
  say so: "I can't verify this without [X]. Should I [investigate / ask / go ahead]?"

If it conflicts with an earlier decision by your human partner:
  stop and discuss it with your human partner first
```

**Your human partner's rule:** "External feedback: be skeptical, but check carefully."

## YAGNI check on "professional" features

```
If a reviewer suggests "implementing this properly":
  grep the codebase for actual usage

  If nothing uses it: "Nothing calls this endpoint. Remove it (YAGNI)?"
  If something uses it: then implement it properly
```

**Your human partner's rule:** "You and the reviewer both report to me. If we don't need this feature, don't add it."

## Implementation order

```
For multiple items:
  1. Clarify everything unclear **first**
  2. Then work in this order:
     - Blocking issues (breakage, security)
     - Simple fixes (typos, imports)
     - Complex fixes (refactoring, logic)
  3. Test each fix on its own
  4. Confirm there are no regressions
```

## When to push back

Push back when:
- The suggestion breaks existing functionality
- The reviewer lacks the full context
- It violates YAGNI (adds a feature nobody uses)
- It is technically incorrect for this stack
- There are legacy/compatibility reasons
- It conflicts with your human partner's architectural decisions

**How to push back:**
- Use technical reasoning, not defensiveness
- Ask specific questions
- Point to tests/code that work
- Bring your human partner in if it touches architecture

**If you're uncomfortable voicing the pushback:** say that you're uncomfortable,
then tell your human partner the problem you see. They will appreciate the candor.

## Acknowledging correct feedback

When the feedback **is** correct:
```
✅ "Fixed. [Brief description of what changed]"
✅ "Good catch: [specific issue]. Fixed in [location]."
✅ [Just fix it and let the code speak]

❌ "You're absolutely right!"
❌ "Great point!"
❌ "Thanks for catching that!"
❌ "Thanks for [anything]"
❌ **ANY** expression of thanks
```

**Why no thanks:** actions speak. Just fix it.
The code itself shows you heard the feedback.

**If you catch yourself about to write "Thanks":** delete it. Say what you fixed instead.

## Backing down from your pushback gracefully

If you pushed back and you were wrong:
```
✅ "You're right: I checked [X] and it does [Y]. Changing it now."
✅ "Verified, and you're right. I misread it at first because [reason]. Fixing it."

❌ A long apology
❌ Defending why you pushed back
❌ Over-explaining
```

State the correction and move on.

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Performative agreement | Restate the requirement, or just act |
| Blind implementation | Verify against the codebase first |
| Testing only after a batch of changes | One item at a time, test each one |
| Assuming the reviewer is right | Check whether it breaks something else |
| Avoiding pushback | Technical correctness > comfort |
| Partial implementation | Clarify every item first |
| Pushing ahead when you can't verify | State the limitation, ask for direction |

## Real examples

**Performative agreement (bad):**
```
Reviewer: "Remove the legacy code"
❌ "You're absolutely right! Let me remove that..."
```

**Technical verification (good):**
```
Reviewer: "Remove the legacy code"
✅ "Checked: the build target is 10.15+, and this API needs 13+.
    The legacy branch has to stay for backward compatibility. The current implementation has the wrong bundle ID:
    fix that, or drop support below 13?"
```

**YAGNI (good):**
```
Reviewer: "Implement the metrics tracking properly: hook it up to the database, add date filters, support CSV export"
✅ "I grepped the codebase and nothing calls this endpoint. Remove it (YAGNI)?
    Or is there usage I missed?"
```

**Unclear items (good):**
```
Your human partner: "Fix items 1-6"
You understand 1, 2, 3 and 6. 4 and 5 are unclear.
✅ "1, 2, 3 and 6 are clear. Before I start, I need you to clarify 4 and 5."
```

## Replying in GitHub threads

When replying to inline review comments on GitHub, **reply in that comment's thread**
(`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`),
not as a top-level PR comment.
