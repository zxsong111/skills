> **已归档。** 这个 skill 已在 v1.3.0 从 plugin 中移除，不再维护。没有替代它的 skill：agent 不借助专门的 skill 也能处理 merge 或 rebase 冲突。本页保留以供参考。

## 它做什么

`resolving-merge-conflicts` 逐个 hunk 地处理一次进行中的 git merge 或 rebase，然后运行项目自己的检查，并以一个 commit 完成这次操作。

它拒绝把冲突当成文本问题。动任何一个 hunk 之前，它会把两边各自追溯到它们的**[一手资料](https://www.aihero.dev/ai-coding-dictionary/primary-source)(primary source)**（commit message、PR、最初的 issue），这样它是在两种意图之间做选择，而不是在两段文本之间做选择，并且只要两者兼容就都保留。不兼容时，它选择符合这次 merge 既定目标的那一边，并说明取舍。它不会发明新行为来掩盖冲突，也从不使用 `--abort`。它总是把 merge 推进到一个完成的 commit。

## 什么时候用

输入 `/resolving-merge-conflicts`，或者在任务匹配时由 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 自动调用。

当 git 已经因为它自己解决不了的冲突而停下时用它。它只针对眼前的冲突，不管冲突前后的任何事：

| 你的情况 | Skill |
| --- | --- |
| merge 或 rebase 进行到一半，工作树里有冲突标记 | 就是这个 |
| merge 已完成，但现在有东西出了你看不出原因的问题 | [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs) |
| 规划怎么切分工作，让 branch 之间少冲突 | 都不是：见下面关于并行工作的问题 |

## 一手资料优先于 `ours` 和 `theirs`

这个 skill 的存在是为了防止靠参数解决冲突：用 `--ours`、`--theirs`，或者手动删掉看起来不那么重要的那一段，让冲突标记消失、构建通过。这样的解决在语法上可以完美无缺，却仍然悄悄丢掉了某人有意做的改动。

你没法保留一个你没读过的意图。所以工作从历史开始（commit、PR、[ticket](https://www.aihero.dev/ai-coding-dictionary/ticket)），然后才转到 diff。检查这一步也是出于同样的原因。这个 skill 会找到仓库自己的[自动化检查](https://www.aihero.dev/ai-coding-dictionary/automated-check)，在 commit 之前运行它们，因为在 git 里，merge 是最容易产出「同时满足两个 branch、却通不过任何一边测试」的代码的地方。

## 常见问题

**Claude Code 自己解决冲突就已经挺好了。为什么还需要一个 skill？**

增加的价值在于「找到一手资料」和「运行反馈回路」这两步，否则你每次都得手动提示。没有提示的 agent 通常只根据 diff 产出一个看似合理的解决方案就停了。这个 skill 的价值在于它不让 agent 跳过的那两步：读懂每一边为什么存在，以及事后运行检查。相对于一个好的[模型](https://www.aihero.dev/ai-coding-dictionary/model)，这只是一点小收益，而这是有意为之。至少有一位读者预测，随着模型进步，这整个 skill 会变得没有作用。

**我是否应该让并行的 agent 避开同样的文件，从源头上避免冲突？**

大多数情况下不必。在并行任务之间划分文件领地，代价比收益大，因为 agent 处理 merge 冲突已经足够好，这个取舍并不像看起来那么苛刻。值得保留的一条纪律是先做大规模重构。一次大规模重命名在十个 branch 已经从它分叉出去之后才落地，这才是始终代价高昂的情况。

一条来自并行 worktree 用户报告的提醒：当几个兄弟[会话](https://www.aihero.dev/ai-coding-dictionary/session)各自在自己的工作树里实现一个 ticket 时，合并回去最好由写下那个改动的会话来做，因为它本来就知道意图。如果最后由一个 agent 解决所有人的冲突，它就失去了[上下文](https://www.aihero.dev/ai-coding-dictionary/context)，而这个 skill 的第 2 步就不得不把这些上下文重建出来。

**为什么从不用 `--abort`？**

abort 会扔掉已做的解决工作，下次你再尝试时又回到同样的冲突，原封未动。这个 skill 是为「这次 merge 一定会发生」的情况写的。如果你已经决定它不该发生，那是调用之前就要做的决定，而不是循环里的一个分支。

## 起作用的标志

- agent 在解决冲突时会向你引用 commit message、PR 或 issue，而不只是 diff hunk。
- 每个 hunk 最终要么保留了两边的行为，要么有一条明确的说明，指出丢掉了什么、为什么。
- 结果里不会出现两个 branch 上都没有的东西。
- agent 找到了类型检查、测试和格式化，并在 commit *之前*把它们跑通，而不是等你发现有东西坏了之后。
- 你最终得到一个干净的工作树，操作已经完成，包括多 commit rebase 中剩下的每一个 commit。

## 在体系中的位置

一个随时可用的独立工具，不依赖任何其他 skill：git 停下时它开始，工作树干净且已 commit 时它结束。它唯一真正的邻居是 [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs)，在 merge 干净地解决了、但合并后的代码行为异常时接手：那是诊断问题，不是冲突问题。它在从想法到上线的主流程之外，所以它前后该跑什么，以 [ask-matt](https://aihero.dev/skills-ask-matt) 为地图。
