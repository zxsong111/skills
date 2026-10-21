# 范围

这个仓库是我每天在用的那一套 skill。它是精心挑选的：欢迎提想法，每个想法都会对照下面的标准来评判。issue 用于跟踪对 skill 的改动。提问和讨论请去 [GitHub Discussions](https://github.com/mattpocock/skills/discussions)。

## 标准

一个想法或反馈类 issue，只有**同时**满足以下两点才会保持打开：

1. **观察到的失败。** 它描述了在一次真实会话中出的问题：你运行了什么，skill 做了什么，你原本期望什么。假设性的改进（「如果……会更好」）不满足这一点。
2. **符合理念。** 它不与 [`.out-of-scope/`](./.out-of-scope/) 里的任何内容或以往的拒绝相符，也不是一个配置项、某个 harness 特有的分支，或者为了迁就某一个人的工作流而做的调整。这些应该放进你自己的 `CLAUDE.md` / `AGENTS.md`，或者放进一个 fork（skills.sh 会给你一份可编辑的副本）。

改动大小无关紧要：一个单词的修正和一次重写面对的是同一个标准。表情回应和 +1 评论不计入。

## 按分类目录

- **`engineering/`、`productivity/`、`in-progress/`**：适用上面的标准。
- **`misc/`**：已冻结，不再维护。所有 issue 都会被关闭。见 [`frozen-misc-skills.md`](./.out-of-scope/frozen-misc-skills.md)。
- **新 skill**：提议和贡献都会被关闭。如果这个行为可以由现有 skill 组合出来，就不会为它新增 skill。见 [`new-skills.md`](./.out-of-scope/new-skills.md)。

## 已经决定的事

[`.out-of-scope/`](./.out-of-scope/) 里的每个文件记录一个被拒绝的概念及其原因。提交之前先读一读：

- [`frozen-misc-skills.md`](./.out-of-scope/frozen-misc-skills.md)
- [`harness-name-collisions.md`](./.out-of-scope/harness-name-collisions.md)
- [`mainstream-issue-trackers-only.md`](./.out-of-scope/mainstream-issue-trackers-only.md)
- [`native-question-tool.md`](./.out-of-scope/native-question-tool.md)
- [`new-skills.md`](./.out-of-scope/new-skills.md)
- [`question-limits.md`](./.out-of-scope/question-limits.md)
- [`setup-skill-verify-mode.md`](./.out-of-scope/setup-skill-verify-mode.md)
- [`subagent-recursion.md`](./.out-of-scope/subagent-recursion.md)

## 不清楚的 issue

无法对照标准判断的 issue，会收到一轮问题并被打上 `needs-info` 标签。如果报告者 14 天内没有回复，issue 会被关闭。被拒绝的 issue 以「not planned」关闭。
