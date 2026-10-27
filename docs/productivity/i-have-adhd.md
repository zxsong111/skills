## What it does

`i-have-adhd` sets the shape of replies. The first line is an action the reader can take, multi-step tasks are numbered, the state is restated every turn, tangents are held back, finished work is stated in concrete terms, and there is no preamble, no after-the-fact recap and no closing pleasantries. It comes from one fact: **knowing the answer is not the same as doing it**. The small friction between "got it" and "done" is where work dies, so output is shaped into something the reader can act on directly, not just made short.

This version loads automatically. Compared with upstream, it drops the rule to give concrete time estimates (an estimate is a guess, not evidence), it exempts evidence output from the five-item cap: every row of a gate table, a list of review findings or a list of test failures is shown, and it restricts numbering to ASCII (`1.`, `2.`, sub-items `(a)`): circled numbers like `①` or `②a` are East Asian Ambiguous width characters that several terminals, iTerm2 included, draw overlapping into garbage, so the skill bans them along with emoji numbering (`1️⃣`) and decorative checkmarks and arrows in lists.

## When to reach for it

Type `/i-have-adhd`, or the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) reaches for it automatically when a task fits: the agent loads it when replying, and typing the command switches it on explicitly. Say `stop adhd mode` or `normal mode` to turn it off for the rest of the [session](https://www.aihero.dev/ai-coding-dictionary/session).

| Situation | How the rules change |
| --- | --- |
| An ordinary reply | Lead with the action, and stop once the answer is given |
| A multi-step task | A numbered list, one action per step, as few steps as possible |
| An error | The cause and the fix, no "oops" |
| You ask it to "explain" or "walk me through" | The body can run long, still with no preamble or pleasantries |
| Before a destructive operation | Confirm first, because safety beats brevity |
| Three debugging turns in a row of "still broken" | Stop iterating on the code and name the assumption that is probably wrong |

Automatic loading happens only when the agent judges that the task fits, so it is not guaranteed on every reply. To make it take effect from the start of every session, run `touch ~/.claude/.i-have-adhd-always`. A companion SessionStart hook (to be added in the hooks phase) then injects it into the session.

## The check before sending

Before a reply goes out, the skill cuts:

- the first sentence, if it announces what is about to happen
- the last sentence, if it asks whether there is anything else
- any by-the-way aside
- vague adverbs that carry no information
- idioms, replaced with the literal action

Then it checks: reading only the first and last lines, does the reader know what to do next and what just happened?

## Common questions

**Will it cut things that need saying?**
No. When a rule conflicts with the task, the task wins and the shape stays. "What are my options" gets 2 to 4 ranked options, because those options are the answer. Evidence output is exempt from the five-item cap entirely.

**What if it conflicts with the harness's system prompt?**
The system prompt wins. If the [harness](https://www.aihero.dev/ai-coding-dictionary/harness) asks for tool calls to be announced, it announces them, and when there is work to do, it does the work. The constraint wins and the shape stays.

## It's working if

- The first line of a reply is an action, a command or a path, not background.
- At step three of a five-step task, the reply says "step 3 of 5 done".
- A reply ends with "Next: ...", not "Hope this helps".
- An error shows the cause and the fix straight away.

## Where it fits

`i-have-adhd` is a **reach-for-it-anytime standalone** that works as an output layer across every flow. It is not a step on the main chain and changes no skill's steps, only the shape of replies. Its neighbours are [humanizer](https://github.com/zxsong111/skills/blob/main/skills/productivity/humanizer/SKILL.md), because that governs the tone of prose while this governs the structure of replies, and [wait-what](https://aihero.dev/skills-wait-what), the after-the-fact fix when one message didn't land. [ask-zxs](https://github.com/zxsong111/skills/blob/main/docs/engineering/ask-zxs.md) has the map of the whole set.
