---
name: implement-spec
description: >
  把 /to-spec 和 /to-tickets 的结果实现为代码。
disable-model-invocation: true
---

你已经拿到了一份 spec。这份 spec 应该关联着若干 ticket，描述如何实现它。

issue tracker 应该已经提供给你了。如果没有，告诉用户运行 `/setup-matt-pocock-skills`。

目标是在单个**集成分支(integration branch)**上实现整个 spec，并且每个 ticket 都按 issue tracker 结束工作的方式被关闭。

这些 ticket 不是一份步骤清单。它们是一张**任务图(task graph)**，彼此之间有阻塞关系。这意味着总有一个由可以立即领取的 ticket 组成的**前沿(frontier)**。

与子 agent 之间的沟通要精简。主要通过**上下文指针(context pointer)**沟通：指向 spec、ticket、调研笔记和之前的 commit。不要重复那些通过指针已经能拿到的信息。

**实现子 agent(implementer subagent)** 尽可能在后台运行，以获得最大并发。

## 步骤

1. 阅读 spec 和 ticket，理解任务图。

2. （可选）使用一个**探索子 agent(exploration subagent)** 完成 ticket 所需的探索：相关的代码库文件或外部文档。确保探索子 agent 能保存文件：它应该把 markdown 笔记存到 repo 之外的一个目录里，所有后续子 agent 都能访问。这样**实现子 agent** 就能专注于实现，而不是探索。

3. 创建集成分支。如果 issue tracker 通过 PR 结束工作，或者用户要求开 PR，就在第 5 步第一次合并之后开一个 draft PR（一个相对 main 没有任何领先 commit 的 branch 开不了 PR），并标记为关闭该 spec 和这些 ticket。

4. 使用**实现子 agent** 实现每个 ticket，每个都在自己的 worktree、自己的 branch 上。每个实现子 agent：
   - 开始前确认自己的 worktree 基于集成分支，如果不是就 reset 到集成分支上；
   - 调用 Skill 工具，参数为 `tdd`，来构建这个 ticket；
   - 在报告完成之前，把集成分支的最新提交 merge 进自己的 branch

5. 一旦某个**实现子 agent** 完成，用一个**合并子 agent(merger subagent)** 把它的工作 merge 到集成分支。

6. 如果这改变了可领取 ticket 的**前沿**，就启动更多**实现子 agent** 去做新的 ticket。这样可以获得最大并发。

7. 所有 ticket 完成后，在集成分支上调用 Skill 工具，参数为 `code-review`。用单个**实现子 agent** 修复代码审查提出的所有问题。

8. 如果存在 draft PR，把它标记为可以审查。否则，按 issue tracker 结束工作的方式逐个关闭 ticket，并报告集成分支。

9. 清理所有**实现子 agent** 的 worktree。
