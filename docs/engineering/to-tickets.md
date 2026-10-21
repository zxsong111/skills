## 它做什么

`to-tickets` 接收一份计划、一份 [spec](https://www.aihero.dev/ai-coding-dictionary/spec)，或者你当前所在的对话，把它拆成你 issue tracker 上的一组 **[ticket](https://www.aihero.dev/ai-coding-dictionary/ticket)**。每个 ticket 都声明它的**阻塞边**(blocking edges)：在它能开始之前必须完成的其他 ticket。

每个 ticket 都是一颗**曳光弹**(tracer bullet)：一条窄而完整、贯穿改动每一层（schema、API、UI、测试）的路径，一落地就能单独演示。这正是这个 skill 和显而易见的拆分方式的不同之处，后者是一次切一层、最后再集成。它还会把每个 ticket 的大小控制在一个全新的[上下文窗口](https://www.aihero.dev/ai-coding-dictionary/context-window)装得下的范围内，因为接手这个 ticket 的会是一个从没见过你 spec 的[会话](https://www.aihero.dev/ai-coding-dictionary/session)。

## 什么时候用

输入 `/to-tickets` 调用它，[agent](https://www.aihero.dev/ai-coding-dictionary/agent) 不会自己去用它。

| 你在哪个阶段 | 运行什么 |
| --- | --- |
| 你有一个 spec issue，构建要跨好几个会话 | `/to-tickets`，或 `/to-tickets #<spec_issue>` |
| 计划只存在于对话中，从没写成文档 | `/to-tickets` 直接读取对话，不需要 spec |
| 整个改动一个上下文窗口装得下 | [implement](https://aihero.dev/skills-implement)，跳过 ticket |
| 还什么都没决定 | [grill-with-docs](https://aihero.dev/skills-grill-with-docs)，然后 [to-spec](https://aihero.dev/skills-to-spec) |
| 一张 [wayfinder](https://aihero.dev/skills-wayfinder) 地图已经清空迷雾 | 先用 [to-spec](https://aihero.dev/skills-to-spec) 把地图收拢，再 `/to-tickets` |

`to-tickets` 产出的 ticket 天生就是可直接交给 agent 的。不要对它们运行 [triage](https://aihero.dev/skills-triage)。分诊是给别人送进来的工作用的。

## 前置条件

`to-tickets` 发布到一个 tracker，所以必须先由 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 为这个仓库配置好 tracker 以及分诊(triage)标签词汇。两种都可以：像 GitHub 或 Linear 这样的真正 tracker，或者 `.scratch/` 下的本地 markdown 文件，后者不需要额外设置。

## 曳光弹，而不是分层

**水平**切片一次交付改动的一层。在每一层都落地之前什么都跑不起来，而且每个 ticket 的验收标准都得伸手去够另一个 ticket 负责的工作。**垂直**切片（也就是曳光弹）一次交付一条贯穿所有层的细路径，所以它能单独验证，并且拥有它所考核的全部内容。

这是人们最常违反的规则。有个团队跑了一个按层切分（语料、生产者、聚合器、选择器）的 26 个 ticket 的栈，结果每关闭一个 ticket 大约要跑二十次 agent，其中约四分之三是返工。他们自己的事后复盘把每一类失败都追溯到了水平切分，而不是具体实现。

在发布任何东西之前会发生两件事。`to-tickets` 会寻找预重构(prefactoring)的机会（原则是「先让改动变容易，再做那个容易的改动」），并把那部分工作排在最前面。然后它把拆分结果以编号列表的形式呈现出来，并就此盘问你：粒度对不对，阻塞边是不是真的，有没有该合并或拆开的。在你批准之前，什么都不会进入 tracker，而这次盘问就是你提出异议的地方。

## 阻塞边

边是这份产出的意义所在。根据 tracker 的不同，它们有两种工作方式：

| Tracker | 边存放在哪里 | 你怎么处理它们 |
| --- | --- | --- |
| 本地 markdown | 写在每个 ticket 一个文件的文本里，路径为 `.scratch/<feature>/issues/<NN>-<slug>.md`，按阻塞者优先编号 | 从上到下，手动处理 |
| 真正的 tracker（GitHub、Linear） | 原生的阻塞链接，或者 tracker 支持时的子 issue | 任何阻塞者都已完成的 ticket 都位于**前沿**(frontier)上，可以被领走 |

无论哪种，边都存放在 ticket 里。tracker 只决定是否有东西能并行地据此行动。`to-tickets` 产出这份成果；运行它（一次一个会话，或者一整队）是你的事，不是这个 skill 的事。

## 大范围重构的例外

有一种形态会打破曳光弹规则。**大范围重构**是一个单一的机械性改动（重命名一列、给一个共享符号换类型），而它的**影响范围**(blast radius)覆盖整个代码库。一次编辑就会弄坏成千上万个调用点，所以没有哪个垂直切片能在全绿状态下落地。

`to-tickets` 改用 **expand-contract(扩展-收缩)** 的方式来排序：

- **Expand(扩展)**：在旧形式旁边加上新形式，这样什么都不会坏。
- **Migrate(迁移)**：按影响范围确定批次大小（按包、按目录），分批迁移调用点，每批一个 ticket，每个都被 expand 阻塞。因为旧形式仍然存在，CI 保持绿色。
- **Contract(收缩)**：一旦没有调用方了，就删掉旧形式，放在一个被所有 migrate 批次阻塞的 ticket 里。

如果连各个批次都没法单独保持绿色，它们就共享一个集成分支(integration branch)，并全部阻塞最后一个「集成并验证」的 ticket。CI 只需要在那个 ticket 上是绿的。

## 常见问题

**一个三行的改动，它产出了十二个 ticket。**
过度拆分是这个 skill 被报告最多的问题，很多用户都遇到过。[模型](https://www.aihero.dev/ai-coding-dictionary/model)默认倾向于原子化的单元，丢掉了能让它们有意义的分组。盘问那一步就是你修正这个问题的地方。让它合并 ticket，它就会合并。还有一个下限：如果整个改动一个上下文窗口装得下，你根本不需要这个 skill，直接去用 [implement](https://aihero.dev/skills-implement)。

**ticket 是按层出来的：所有 schema 在一个里，所有 API 在另一个里。**
这正是垂直切片规则所针对的失败，而这个 skill 有时仍然会产出这样的结果。在盘问那一步，对每个 ticket 问一个问题就能抓住它：这个做完之后我能演示什么？答不上来的 ticket 就是水平切片。出于这个原因，有些人会给每个 ticket 加一行「演示路径」，并报告说这能把模型推向垂直切片。

**在 GitHub 上，ticket 没有作为 spec issue 的子 issue 创建。**
这个问题在十几次运行、好几个模型上都被报告过，[在 issue #554 中描述得最完整](https://github.com/mattpocock/skills/issues/554)。已修复：`to-tickets` 现在会把每个 ticket 设为其来源 issue 的子 issue，GitHub tracker 模板也给出了命令（`gh issue create --parent <n>`，需要 `gh` 2.94+）。重新运行 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 来刷新旧版的 `docs/agents/issue-tracker.md`。

**「Blocked by」被写进了 issue 正文，而不是一个真正的阻塞链接。**
这是同一类问题，[在 issue #513 中被报告](https://github.com/mattpocock/skills/issues/513)，当时 agent 甚至声称 GitHub 根本没有原生的阻塞关系。其实有：`gh issue create --blocked-by 12,15`。因为这个 skill 先发布阻塞者，所以创建时它们的编号总是已知的。正文文本本意是给没有原生边的 tracker 用的后备方案，而不是默认做法。现在当边是原生的时候，ticket 模板会省略 `## Blocked by`。

**本地 ticket 放在哪里？v1.1 的说明里写的是根目录下的 `tickets.md`。**
确实写过，而那是个 bug。单个共享文件在多个并行 agent 同时写入时还会造成竞态条件。本地模式现在为每个 ticket 写一个文件，路径为 `.scratch/<feature-slug>/issues/<NN>-<slug>.md`，按依赖顺序排列，与本地 tracker 模板早已描述的布局一致。`NN` 前缀是一个真正的 ticket ID，所以 `/implement 03` 就能用，不必重新输入一个长标题。

**它试图读取我的 spec 时一直被截断。**
一份很大的 spec 可能超出 tracker issue 能干净返回的范围。没有本地副本可以退而求其次，于是 agent 把[工具调用](https://www.aihero.dev/ai-coding-dictionary/tool-call)花在一遍遍重新抓取分块上，永远到不了结尾。不要在 `/to-spec` 和 `/to-tickets` 之间[清空](https://www.aihero.dev/ai-coding-dictionary/clearing)或[压缩](https://www.aihero.dev/ai-coding-dictionary/compaction)上下文。在同一个上下文窗口里运行它们，agent 就根本不需要再把 spec 抓回来。

**验收标准什么也没考核：有些在任何工作完成之前就已经通过了。**
模板要求写验收标准，但没说它们是否必须可能失败，所以这种情况会发生。有三种形态反复出现：一条在基准 commit 时就已经成立的标准，一条只有另一个 ticket 里的工作才能满足的标准，以及一条只是复述需求、而不是从产出物推导出来的标准。垂直切片能防止大部分这类问题，因为一个交付新行为的切片，在基准 commit 时天然就会失败。但手动检查仍然值得做。对每条标准，说出能证明它不成立的那个观察，并确认它在实现者起步的那个 commit 上确实会失败。

**ticket 已经发布了。我实际该怎么运行它们？**
这个 skill 止步于产出物，没有自动派发模式。派发是手动的：看一眼看板，数一数没有未完成阻塞者的 ticket，然后开同样数量的 agent 会话。给每个 ticket 一个全新的上下文，并在它们之间清空。[implement](https://aihero.dev/skills-implement) 完成时并不能可靠地关闭或勾选 ticket，无论在 GitHub 还是本地 markdown 上，所以你要自己更新 ticket 的状态。

## 起作用的标志

- 每个 ticket 都能回答「这个做完之后我能演示什么？」，而且答案是一个行为，而不是一层。
- 在发布任何东西之前，列表会编好号回到你面前，每个上面都有一行「Blocked by」。
- 最上面的那个 ticket 没有阻塞者，可以立刻开始。
- ticket 正文里没有任何文件路径或行号，除了原型产出的代码片段。
- 每个 ticket 读起来都像是一个全新的会话不需要你在场就能完成的东西。
- 如果找到了预重构，它会排在最前面，而不是混在功能 ticket 里。

## 在体系中的位置

`to-tickets` 是主构建链路中的一步：

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review → retro
```

上游是 [to-spec](https://aihero.dev/skills-to-spec)，它交给这个 skill 一份已经定下来的 spec 用来切分。让两者待在同一个上下文窗口里，中间不要清空。下游是 [implement](https://aihero.dev/skills-implement)，它每个全新会话构建一个 ticket，用 [tdd](https://aihero.dev/skills-tdd) 驱动测试，最后以 [code-review](https://aihero.dev/skills-code-review) 收尾。[implement-spec](https://aihero.dev/skills-implement-spec) 是另一条下行的路。它把同样的阻塞边读成一张任务图(task graph)，在一个集成分支上并行构建所有就绪的 ticket。当你不确定哪个 skill 或流程合适时，[ask-matt](https://aihero.dev/skills-ask-matt) 会为你指路。
