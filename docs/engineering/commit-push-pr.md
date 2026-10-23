## What it does

`commit-push-pr` runs the commit, push and open-a-PR sequence to a fixed convention. It reads the diff, writes a commit message in `type(scope): short description` form, stops after the commit to ask whether to push, and on a yes pushes and opens the PR. What sets it apart from other ways of committing is that **the branch guard comes before everything else**. When the current branch is the repo's trunk (`main`, `master`, or whichever branch this repo actually uses as its trunk), it neither commits nor opens a branch for you. It lays out where things stand and what the options are, and waits for you to decide.

It does not decide the shape of the PR body. It calls [pr](https://aihero.dev/skills-pr) for the summary and the before/after evidence, and adds only a **Verification** table of commands that really ran. If no command ran at all, it writes "Unverified: none" rather than inventing a table where every row says "pass".

## When to reach for it

Type `/commit-push-pr`, or the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) reaches for it automatically when a task fits: when you say "commit", "push it" or "open a PR".

| Situation | What it does |
| --- | --- |
| On a feature branch, with changes in the working tree | Reads the diff, writes the message, commits, then stops to ask whether to push |
| On the trunk | Stops and offers two options, "open a feature branch" or "commit to the trunk anyway", and leaves git untouched this turn |
| The repo has no commits yet | Lets the first commit through (the trunk is where it belongs) and reminds you at the end to settle a branch strategy |
| More than 13 files or 3 kinds of change | Suggests a split first and waits for your call |
| Nothing to commit | Says there are no changes to commit, and stops |

It handles only the act of committing. Commits made during implementation are [implement](https://aihero.dev/skills-implement)'s own job, and the rules for writing a PR body live in [pr](https://aihero.dev/skills-pr).

## The guard stops instead of routing around

When the guard fires, the skill explicitly does not run commands like `git checkout -b`. The reason is in the skill itself: a branch name and base the agent picked on its own are ones you would have to fix afterwards. A personal repo can commit straight to the trunk as well. Choose that once, and it gets written under Project conventions in the project's `CLAUDE.md`, so the skill stops asking.

## Common questions

**It stops on the trunk every time in my solo repo, and that gets old.**
Add one line under Project conventions in the project's `CLAUDE.md`, such as "this repo commits straight to main", and the skill follows it. The guard goes by the project's conventions, not by the branch name.

**Will it push without my say-so?**
No. After the commit it stops, shows you the message, and asks outright whether to push. Pushing a shared branch is visible to other people, so it asks every time.

**The original version scanned for secrets before committing. Where did that go?**
The original relied on a hook script in its plugin to scan the staging area. This repo has no hooks yet, so this version runs a single grep over `git diff --cached`. The full step comes back once hooks arrive.

## It's working if

- Saying "commit" on the trunk gets you two options, not a commit.
- The first line of the commit message is `type(scope): short description` with no trailing period, and the message ends with a `Co-Authored-By` line.
- The PR body has a Verification table, and every row matches a command you saw run.
- You were asked once before the push.

## Where it fits

`commit-push-pr` is a **chain step** at the close of the main flow: after [code-review](https://aihero.dev/skills-code-review) passes and before the PR goes up. Its neighbours are [pr](https://aihero.dev/skills-pr), because it calls `pr` to write the body, and [receiving-code-review](https://github.com/zxsong111/skills/blob/main/skills/engineering/receiving-code-review/SKILL.md), because that takes over once review comments come back on the PR. [ask-zxs](https://github.com/zxsong111/skills/blob/main/docs/engineering/ask-zxs.md) has the map of the whole set.
