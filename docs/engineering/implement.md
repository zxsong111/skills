## 它做什么

`implement` 负责把已经决定好的工作做出来。你把它指向一个 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket)、一份 [spec](https://www.aihero.dev/ai-coding-dictionary/spec)，或者你们刚在对话里商定的计划，它就写代码，在接缝(seam)处驱动 [tdd](https://aihero.dev/skills-tdd)，边写边做类型检查，最后运行 [code-review](https://aihero.dev/skills-code-review)，并 commit 到当前 branch。

它从不重新打开计划。没有盘问，没有澄清环节，也不会提议换一种做法。上游敲定的一切就是输入，skill 的全部工作就是把它变成一个 commit。这正是它和对一个新的 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 说「把这个做出来」的区别，后者常常一边做一边重新设计。

## 什么时候用

输入 `/implement` 调用它，agent 不会自己去用它。它带着 `disable-model-invocation: true` 发布，所以其他 skill 也无法调用它。凡是 [ask-matt](https://aihero.dev/skills-ask-matt) 或 [to-tickets](https://aihero.dev/skills-to-tickets) 说「然后每个 ticket 跑一次 `/implement`」的地方，那都是给你的指令，而不是 agent 会主动去做的事。

工作目前在哪里，决定了这是不是合适的 skill：

| 工作现在是… | 该用 |
| --- | --- |
| tracker 上的一个 ticket | `/implement #42`，每个[会话](https://www.aihero.dev/ai-coding-dictionary/session)一个 ticket，ticket 之间[清空](https://www.aihero.dev/ai-coding-dictionary/clearing)上下文 |
| 一份还没拆分的 spec，而且构建要跨多个会话 | 先用 [to-tickets](https://aihero.dev/skills-to-tickets)，然后每个 ticket 跑一次 `/implement` |
| 一份 spec，而且构建规模不大 | 直接对着 spec 跑 `/implement` |
| 只存在于你刚进行的对话里，而且规模仍然不大 | 就在原地、同一个窗口里跑 `/implement` |
| 还没在任何地方写下来 | [grill-with-docs](https://aihero.dev/skills-grill-with-docs)，没有代码库的话用 [grill-me](https://aihero.dev/skills-grill-me) |
| 一个你想测试先行的具体行为，没有 spec | 直接用 [tdd](https://aihero.dev/skills-tdd) |
| 已经做好了，你想检查一下 | 直接用 [code-review](https://aihero.dev/skills-code-review) |

同一会话的情况值得单独说一下，因为 skill 自己的第一行没有覆盖它。`SKILL.md` 写的是「spec 或 ticket」，这会促使[模型](https://www.aihero.dev/ai-coding-dictionary/model)去找一个并不存在的文件。如果计划只存在于这段对话里，调用时说明这一点。

## 前置条件

`implement` 会 commit 到你当前所在的 branch。它不会新建 branch，也不会问你。开始之前，确认你在想放这份工作的 branch 上。

如果 ticket 来自 [to-tickets](https://aihero.dev/skills-to-tickets)，那么它们所在的 tracker 是由 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 配置的。`code-review` 在收尾时读取同一份配置来找到源头 spec。

## 一次运行做什么

一次运行有五个步骤，按顺序：

1. 读 ticket 或 spec，确定接缝。
2. 在事先商定的接缝处驱动 [tdd](https://aihero.dev/skills-tdd)，一次一个红-绿切片。
3. 频繁做类型检查，边做边跑单个测试文件。
4. 最后跑一次完整测试套件。
5. 运行 [code-review](https://aihero.dev/skills-code-review)，然后 commit 到当前 branch。

一次运行覆盖一个 ticket。[to-tickets](https://aihero.dev/skills-to-tickets) 产出的 ticket 是曳光弹(tracer bullet)式的垂直切片，大小刚好能装进一个全新的[上下文窗口](https://www.aihero.dev/ai-coding-dictionary/context-window)，所以预期的节奏是：清空上下文，实现一个 ticket，commit，再清空。每个 ticket 都是自包含的，所以你可以丢掉上一个 ticket 的上下文。

## 事先商定的接缝

这个 skill 的核心概念是**接缝**：一个公开的边界，你在那里观察行为，而不必伸手到内部。测试就放在接缝上。如果接缝在任何代码出现之前就商定好，测试就能长久有效，你可以在底下重写实现而不必改测试。

「事先商定」这一点很重要，同时也是这个 skill 最薄弱的地方。`implement` 内部没有任何环节负责商定接缝。负责提问的是 `tdd`，它拒绝在未经确认的接缝上写测试。所以实际上，商定要么发生在上游的 spec 里，要么发生在运行的第一轮交流里。如果哪里都没发生，运行就变成了「直接写代码」，而且不会有任何警告。在 spec 里写明接缝，才能防止这种情况。

## 常见问题

**它跑完了，但我的 ticket 还开着，验收标准也还没勾上。**

没错，这是预期行为。`implement` 没有收尾步骤。它在 commit 处结束，从不碰工作项。在 GitHub Issues 和本地 markdown tracker 上都是如此，所以这不是 tracker 集成的问题。它也不会处理 `code-review` 产出的发现，不会勾选源头 issue 上的 `- [ ]` 复选框。自己去关闭 ticket、核对验收标准。这在依赖链上最要紧，因为 `to-tickets` 把前沿(frontier)定义为所有阻塞项都已关闭的 ticket。如果什么都没关闭，就永远不会有 ticket 明显地解除阻塞。

**我能一次把所有 ticket 都丢给它，或者并行跑好几个吗？**

用 `/implement` 不行：一次调用，一个 ticket。要一次运行完成整份 spec，用 [implement-spec](https://aihero.dev/skills-implement-spec)，它把就绪前沿上的每个 ticket 交给各自 worktree 里的一个[子 agent](https://www.aihero.dev/ai-coding-dictionary/subagent)，再把结果 merge 到同一个集成分支(integration branch)上。在同一个检出目录里并排跑多个 `/implement` 会话，比「不受支持」还糟。有一份实地报告描述了一个下午、三个 issue 之间发生的事：一个会话里的 `git commit --amend` 落到了另一个会话的 commit 上，一个 stash 从 `refs/stash` 里消失了，还有 commit 落到了错误的 branch 上。这些会话共用一个工作目录、一个索引和一个 HEAD。用户用 git worktree 来绕过，但 `refs/stash` 在 worktree 之间也是共享的，所以光靠 worktree 解决不了 stash 的问题。

**它能开 pull request，而不是直接 commit 吗？**

没有内置。它直接 commit 到当前 branch。好几个人觉得这太急了，因为代码在他们验证能不能用之前就落地了。没有配置开关，也没有 PR 模式。大家在调用时覆盖它（「commit to a branch and open a PR」），或者修改自己本地的 skill 副本。当 agent 真的写 PR 时，由 [pr](https://aihero.dev/skills-pr) 来组织正文。

**`code-review` 说它看不到我的改动。**

`code-review` 评审的是 `git diff <fixed-point>...HEAD`，不包含暂存区和工作区的改动。`implement` 在 commit 之前运行它，所以除非已经有一个中间 commit，否则那个 diff 里没有任何可评审的内容。已经有多人报告过，两边都还没修。先 commit，再对照你开 branch 的那个点做评审。

另外，有些人根本不想在运行内部做评审，因为让 agent 评审它刚写的代码，会偏向它自己的方案。在一个新会话里对照固定点运行 [code-review](https://aihero.dev/skills-code-review) 是一个可行的替代办法。同样的偏差，也是那个 skill 把两条轴放在不同子 agent 里运行的原因。

**一个 ticket 烧掉了 15 万 token。是我用错了吗？**

多半不是，更可能是 ticket 太大了。一次运行要探索代码库、在每个接缝上走一遍红-绿循环、跑完整套件，还要做评审，所以一个不算简单的 ticket 超过 10 万 [token](https://www.aihero.dev/ai-coding-dictionary/token) 是正常的，并不代表出了问题。修复在上游。在 [to-tickets](https://aihero.dev/skills-to-tickets) 里把 ticket 切到合适的大小，让每个都能装进一个全新的窗口。如果某个 ticket 总是超出，就拆分它，而不是调高 [effort](https://www.aihero.dev/ai-coding-dictionary/effort) 级别。

**在新会话里跑 `/implement #2`，它做的却是完全不相关的东西。**

agent 把 `#2` 解析成了上下文里另一份带编号的列表，比如一个 todo 文件或清单，而不是配置好的 tracker。现在 `implement` 会从 issue tracker 拉取传入的引用，并在开始前说出它的标题；引用有歧义时会问你。核对一下标题是否就是你想要的那个 ticket；传入 issue URL 或 `owner/repo#2` 可以彻底消除歧义。

## 起作用的标志

- 会话一开始就去读 ticket 或 spec，并复述它要做什么，而不是问你要做什么。
- 你能在 trace 里看到一次真实的 `tdd` Skill 工具调用，而不只是 diff 里冒出了测试。
- 运行过程中反复跑类型检查和单个测试文件，完整套件在接近结束时跑一次。
- 运行一直走到在你当前 branch 上 commit，不需要你催它继续。
- diff 只是一个 ticket 的改动量：一个贯穿所有层的垂直切片，而不是把好几个 ticket 一锅端。

## 在体系中的位置

`implement` 是主链路的构建步骤：

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review → retro
```

它的邻居是 [to-tickets](https://aihero.dev/skills-to-tickets)，后者产出它要消费的 ticket，并声明决定它们顺序的阻塞边(blocking edges)；[tdd](https://aihero.dev/skills-tdd)，它在每个接缝处于内部驱动这个 skill；以及 [code-review](https://aihero.dev/skills-code-review)，它在 commit 之前运行这个 skill。它位于规划类 skill 的下游，并且信任它们。它不会重新验证交给它的东西的结构，所以一张结构糟糕的地图，或者一个按水平分层切分的 ticket，会被原样照做。

正是这份信任，使得 [wayfinder](https://aihero.dev/skills-wayfinder) 在 [to-spec](https://aihero.dev/skills-to-spec) 处汇入链路，而不是把它的地图直接接到 `implement`。只有当这件事最终证明规模很小时，才从地图直接跳到 `implement`。

当你不确定自己处在哪条流程里时，[ask-matt](https://aihero.dev/skills-ask-matt) 是覆盖整套 skill 的路由器。
