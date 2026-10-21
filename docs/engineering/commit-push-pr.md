## 它做什么

`commit-push-pr` 按固定的约定走完 commit、push、开 PR 这一套流程。它读取 diff，按 `type(scope): short description` 的格式写 commit message，commit 之后停下来问你要不要 push，你同意后再 push 并开 PR。它和其他 commit 方式的区别在于：**branch 守卫排在一切之前**。当前 branch 是仓库主干（`main`、`master`，或者这个仓库实际用作主干的任何 branch）时，它既不 commit，也不替你开 branch。它把现状和可选项摆出来，等你决定。

它不决定 PR 正文的结构。它调用 [pr](https://aihero.dev/skills-pr) 来写摘要和改动前后的证据，自己只追加一张**验证**表，列出真正运行过的命令。如果一条命令都没跑，它就写「未验证：无」，而不是编一张每行都写着「通过」的表。

## 什么时候用

输入 `/commit-push-pr`，或者在任务匹配时由 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 自动调用：比如你说「commit」「push 一下」或「开个 PR」。

| 情况 | 它怎么做 |
| --- | --- |
| 在功能 branch 上，工作区有改动 | 读取 diff，写 message，commit，然后停下问要不要 push |
| 在主干上 | 停下并给出两个选项：「开一个功能 branch」或「照样 commit 到主干」，本轮不动 git |
| 仓库还没有任何 commit | 放行第一个 commit（它本就该在主干上），并在最后提醒你确定 branch 策略 |
| 超过 13 个文件或 3 类改动 | 先建议拆分，等你拍板 |
| 没有可 commit 的内容 | 告诉你没有改动可提交，然后停下 |

它只管 commit 这个动作本身。实现过程中的 commit 是 [implement](https://aihero.dev/skills-implement) 自己的事，PR 正文的写法规则在 [pr](https://aihero.dev/skills-pr) 里。

## 守卫是停下，而不是绕过去

守卫触发时，这个 skill 明确不会执行 `git checkout -b` 之类的命令。理由就写在 skill 里：agent 自己挑的 branch 名和基点，事后都得你来改。个人仓库也可以直接 commit 到主干。选定一次，它就会被写进项目 `CLAUDE.md` 的项目约定下面，之后 skill 就不再问了。

## 常见问题

**在我的个人仓库里，每次在主干上它都要停下，很烦。**
在项目 `CLAUDE.md` 的项目约定下加一行，比如「this repo commits straight to main」，skill 就会照做。守卫依据的是项目约定，而不是 branch 名。

**它会不经我同意就 push 吗？**
不会。commit 之后它会停下，给你看 message，直接问你要不要 push。push 共享 branch 是别人能看到的，所以它每次都问。

**最初的版本会在 commit 前扫描密钥，这一步去哪了？**
最初的版本依赖其 plugin 里的一个 hook 脚本来扫描暂存区。这个仓库还没有 hook，所以这个版本只对 `git diff --cached` 跑一次 grep。等 hook 到位后，完整的步骤会回来。

## 起作用的标志

- 在主干上说「commit」，得到的是两个选项，而不是一个 commit。
- commit message 第一行是 `type(scope): short description`，末尾没有句号，message 以一行 `Co-Authored-By` 结尾。
- PR 正文里有一张验证表，每一行都对应一条你亲眼看到运行过的命令。
- push 之前问过你一次。

## 在体系中的位置

`commit-push-pr` 是主流程收尾处的**链路中的一步**：在 [code-review](https://aihero.dev/skills-code-review) 通过之后、PR 推上去之前。它的邻居是 [pr](https://aihero.dev/skills-pr)，因为它调用 `pr` 来写正文；还有 [receiving-code-review](https://github.com/zxsong111/skills/blob/main/skills/engineering/receiving-code-review/SKILL.md)，因为 PR 上的评审意见回来之后由它接手。整套 skill 的地图在 [ask-matt](https://aihero.dev/skills-ask-matt) 里。
