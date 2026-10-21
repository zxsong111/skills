## 它做什么

`implement-spec` 接收一份 [spec](https://www.aihero.dev/ai-coding-dictionary/spec) 及其 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket)，一次运行把整件事做完。负责编排的 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 把每个 ticket 交给一个实现[子 agent](https://www.aihero.dev/ai-coding-dictionary/subagent)，每个子 agent 在自己的 git worktree 里工作；它把每个完成的 branch merge 进同一个**集成分支**(integration branch)，对结果运行 [code-review](https://aihero.dev/skills-code-review)，然后关闭这些 ticket。

它把 ticket 读成一张**任务图**(task graph)，而不是一张清单。阻塞边(blocking edges)决定什么可以开始，所以任何时刻都有一个由「所有阻塞项都已落地」的 ticket 组成的**前沿**(frontier)，前沿上的每个 ticket 同时运行。这就是它和逐个处理 ticket 的区别。决定节奏的是图的形状，而不是 ticket 在 tracker 上的排列顺序。

## 什么时候用

输入 `/implement-spec` 调用它，agent 不会自己去用它。

| 你的情况 | 该用 |
| --- | --- |
| 一份已拆成 ticket、带阻塞边的 spec，你想一次运行全部落地 | `/implement-spec` |
| 一次一个 ticket，在你自己的[上下文窗口](https://www.aihero.dev/ai-coding-dictionary/context-window)里做，ticket 之间[清空](https://www.aihero.dev/ai-coding-dictionary/clearing)上下文 | [implement](https://aihero.dev/skills-implement) |
| spec 还没拆成 ticket | 先用 [to-tickets](https://aihero.dev/skills-to-tickets) |
| 一小块工作，谈不上有什么图 | 直接用 [implement](https://aihero.dev/skills-implement) |

## 前置条件

- **一个 issue tracker。** skill 从 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 配置好的 tracker 上读取 ticket，也在那里关闭它们。如果还没配置，它会停下并告诉你先去跑那个 skill，而不是去猜。
- **带阻塞边的 ticket**，按 [to-tickets](https://aihero.dev/skills-to-tickets) 写出的格式。没有边的话，图是平的，所有 ticket 同时开始。
- **一个能在后台运行子 agent、并给每个子 agent 分配 git worktree 的 [harness](https://www.aihero.dev/ai-coding-dictionary/harness)。** 这个 skill 存在的意义就是同时运行多个 ticket，所以在只能一次运行一个子 agent 的 harness 上，它不过是一个更慢的 `implement`。

## 集成分支

一切都落在同一个 branch 上。每个实现子 agent：

1. 开始前确认自己的 worktree 基于集成分支，
2. 用 [tdd](https://aihero.dev/skills-tdd) 实现自己的 ticket，一次一个切片地走红-绿，
3. 在报告完成之前，把集成分支的最新提交 merge 进自己的 branch，这样落地时就是一次 fast-forward。

是否会有 pull request，由 tracker 决定。如果你的 tracker 通过 PR 来关闭工作，或者你要求开 PR，skill 会在第一次 merge 后开一个 draft PR，并在最后标记为 ready。否则，运行会停在集成分支上，每个 ticket 都按你的 tracker 关闭工作的方式被关闭；搭配本地 markdown tracker 时，这完全可以离线完成。

实现子 agent 与编排者之间通过[上下文指针](https://www.aihero.dev/ai-coding-dictionary/context-pointer)（spec、ticket、共享的探索笔记、之前的 commit）沟通，而不是粘贴摘要。这能让每个子 agent 的 prompt 保持精简，也给编排者的窗口留出容纳整张图的空间。

## 常见问题

**这和我自己对每个 ticket 跑一遍 `/implement` 有什么区别？**

这正是这个 skill 要回答的问题。在它发布之前，大家一直在自己搭类似的东西，有位用户这样描述需求：他们希望「subagents implement the tickets」，而不是「to individually create new session and tell them to implement a ticket one by one, when a spec may contain over 5 tickets.」用 `implement` 时，你自己就是调度员：每个 ticket 一个[会话](https://www.aihero.dev/ai-coding-dictionary/session)，中间清空上下文，自己记着哪些 ticket 已经解除了阻塞。`implement-spec` 把这份工作交给一个负责编排的会话。代价是你不再能在每个 ticket 落地时就读它的改动；你在最后评审集成分支。要开始一次运行，清空上下文，输入 `/implement-spec` 并附上指向 spec 的指针（issue 编号或文件路径）。对于没有真正图结构的小改动，跳过它，直接用 `implement`。

**它需要 GitHub 吗？我希望它停在 branch 上。**

不需要了。有位喜欢开发中版本的用户提出的正是这个抱怨：「it creates a PR at the end, which requires an online repository like GitHub. I wish it could do the same work offline and stop at the branch where all the work is merged.」现在运行会在集成分支上结束。只有当配置的 tracker 通过 PR 关闭工作、或者你要求时才会开 PR，所以在本地 markdown tracker 上，运行结束时每个 ticket 都已关闭，工作都已 merge 到这个 branch 上。

**它的评审加修复循环跑了好几个小时，或者一直在「修复」还没实现的 ticket。**

这两种情况都发生在 `code-review` 跑在了 skill 指定的那个时间点之外。它对照整份 spec 比较代码，所以只有在所有 ticket 都落地后才有意义。如果在运行中途跑，每个还没实现的 ticket 都会被读成失败。agent 于是去实现那个 ticket，这又触发了另一次评审。在最后，skill 运行一次 `code-review`，把所有发现交给一个修复子 agent，但它还没说明修复之后何时停下。有位用户报告，一个五个 ticket 的功能，「the review and fix loop took roughly four hours」。如果你看到第二次全面评审开始了，告诉它只针对已修复的发现做聚焦检查，然后停下。要预期第一次评审会找出真问题。运行的产出是一份由评审来补全的草稿，而不是可以直接上线的东西。

**它会像 implement 那样驱动 tdd 吗？**

现在会，但一开始不会。运行开发中版本的用户注意到「the implementer subagents don't inherit the /tdd directive」，所以一旦从一个 ticket 扩展到整份 spec，红-绿就停了。现在每个实现子 agent 都用 `tdd` 来实现自己的 ticket。不过它仍然没有像 `implement` 会话那样交互式商定接缝(seam)的步骤，所以如果你想把接缝固定下来，就在 spec 或 ticket 里写明。

**两个并行运行的实现子 agent 在同一个文件上撞车了，或者给同一个东西起了不同的名字。**

worktree 并不能消除冲突，只是把冲突推迟到 merge 的时候。根据 ticket 文字写出的阻塞边，只是对每个 ticket 会改哪些文件的猜测，而两个「改代码库不同部分」的 ticket 仍然会共用一个消息目录、一个配置注册表或一个类型。每个实现子 agent 只看得到自己的 ticket 和共享笔记，从来看不到对方正在进行的工作，所以有位用户的 web 端和移动端 ticket 把同一个字符串分别加成了 `blockedSince` 和 `blockedOn`。当前沿上的两个 ticket 会改同一个共享文件时，要么在它们之间加一条阻塞边让它们先后运行，要么让探索笔记把每个 ticket 要新增的确切名称定下来。

**被阻塞的 ticket 一直不开始，即使它的阻塞项已经 merge 了。**

这是 GitHub 上的已知问题。tracker 的 blocked-by 计数只有在阻塞项*关闭*时才会减少，而 ticket 通常在 PR merge 时才关闭，也就是运行结束的时候。tracker 是初始图的正确来源，但在运行中途它的信息已经过时。让编排者自己记录哪些 ticket 已经 merge 进集成分支，并据此计算前沿。

**它能取代 Sandcastle 或 AFK 脚本吗？**

不能。之所以有人问，是因为这些 skill 现在已经伸进了实现环节：「is Sandcastle still relevant? Your skills now seem to be able to handle implementation as well.」`implement-spec` 让一个 agent 在一个 harness 会话里负责编排，不需要任何基础设施，你可以旁观并随时调整方向。对于真正 [AFK](https://www.aihero.dev/ai-coding-dictionary/afk) 的工作，确定性的循环（[Sandcastle](https://github.com/mattpocock/sandcastle)、shell 脚本、CI 任务）更快、更便宜、更可靠，因为没有 agent 来做编排决定。

**某个 ticket 的关键测试在它的 worktree 里被跳过了，它却报告全绿。**

worktree 里只有 git 跟踪的东西。读取被 gitignore 的 fixture、本地数据库或凭据的测试，在那里可能会被悄悄跳过。对于验证依赖未跟踪材料的 ticket，告诉编排者改在主检出目录里运行它。

## 起作用的标志

- 只要图允许，就有多个实现子 agent 同时运行，而不是一个接一个。
- 一个 ticket 的最后一个阻塞项一落到集成分支上，它就开始，而不是等整个运行结束。
- 每个 ticket 的 trace 都显示 `tdd` 在运行，先有失败的测试，再有代码。
- merge 进集成分支的都是 fast-forward，而不是冲突解决。
- 运行在一个 branch 上结束，每个 ticket 都已关闭，只有当你的 tracker 需要时才有 PR。

## 在体系中的位置

`implement-spec` 是主链路的构建步骤，是对每个 ticket 各跑一次 [implement](https://aihero.dev/skills-implement) 的并行替代方案：

```txt
grill-with-docs → to-spec → to-tickets → implement-spec → retro
```

它的邻居是 [to-tickets](https://aihero.dev/skills-to-tickets)，后者声明了它当作任务图来读的阻塞边；以及 [code-review](https://aihero.dev/skills-code-review)，它在收尾前对集成分支运行这个 skill。当你不确定自己处在哪条流程里时，[ask-matt](https://aihero.dev/skills-ask-matt) 是覆盖整套 skill 的路由器。
