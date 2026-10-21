## 它做什么

`wayfinder` 接手的是一个一次 agent [会话](https://www.aihero.dev/ai-coding-dictionary/session)装不下的工作。这是一个你能说出**目的地**(destination)、却还看不清路线的想法。wayfinder 把它绘制成你 issue tracker 上一张由**决策 ticket** 组成的共享**地图**(map)，然后一次解决一个 ticket，直到路线变得清晰。

它只规划，不构建。每个 ticket 提出一个问题，答案是一个决定，而不是构建的一个切片。当有人动手构建之前已经没有任何东西需要决定时，这张地图就完成了。这条规则把 wayfinder 的 ticket 和普通的实现 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) 区分开来，也是 agent 最常违反的规则。地图清空后，wayfinder 就交接出去，不会继续写代码。

## 什么时候用

输入 `/wayfinder` 调用它，[agent](https://www.aihero.dev/ai-coding-dictionary/agent) 不会自己去用它。

它是整套 skill 里最重的流程，所以触发条件很窄。工作量必须大于一次 agent 会话能容纳的范围，而且通往目的地的路线必须不清楚。分界线是会话数量：单会话的规划用 `/grill-with-docs`，多会话的规划用 `/wayfinder`。

| 你面前的是什么 | 运行什么 |
| --- | --- |
| 一个范围清楚、一次坐下来就能定下来的功能 | [grill-me](https://aihero.dev/skills-grill-me)，有代码库时用 [grill-with-docs](https://aihero.dev/skills-grill-with-docs) |
| 一个全新项目，或者一个跨很多会话的构建，路线仍不清楚 | `/wayfinder` |
| 一段决定已经做完的对话 | [to-spec](https://aihero.dev/skills-to-spec)：直接跳过地图 |
| 一张已清空的 wayfinder 地图 | [to-spec](https://aihero.dev/skills-to-spec)，然后 [to-tickets](https://aihero.dev/skills-to-tickets) 和 [implement](https://aihero.dev/skills-implement) |
| 一个已经膨胀得太大的现有会话 | 说「交接给 `/wayfinder`」（[handoff](https://aihero.dev/skills-handoff) 既能把工作交接进地图，也能交接出来） |

全新项目不是必要条件。人们经常在遗留代码库和做了一半的代码库上使用 wayfinder，而且在那里可能更有用，因为很多迷雾是「这里现在实际是什么情况」，而不是「我们应该做什么」。

## 前置条件

地图和它的 ticket 都住在仓库的 issue tracker 上，所以 wayfinder 需要 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 完成的 tracker 设置。那一步会写入一个 "Wayfinding operations" 小节，描述如何在 GitHub、GitLab 或本地 markdown 上表达地图、它的子 ticket、阻塞边和前沿查询。wayfinder 是通过你 `CLAUDE.md` / `AGENTS.md` 里的指针找到这份文档的，而不是在某个固定路径。如果没有配置 tracker，它会退回到本地 markdown 文件。

tracker 承担着实际的工作。它原生的阻塞链接能在 tracker 自己的 UI 里显示前沿。在没有原生依赖链接的 tracker 上（比如自托管的 Gitea），wayfinder 会从地图文本中推断阻塞关系。这样可行，但你必须更密切地监督它。

## 地图、迷雾和前沿

**地图**是一个打上 `wayfinder:map` 标签的 issue，它的 ticket 是它的子 issue。它是**索引，不是仓库**。一个决定只存在于一个地方，也就是它的 ticket，地图只给出一行摘要和一个链接。会话以低分辨率加载地图，需要时再打开单个 ticket。这让地图可以不断增长，而不必让每个会话都加载它的全部历史。

地图有四个小节：

- **Destination(目的地)。** 这张地图的终点是什么样子。你要最先说出它，在任何 ticket 存在之前，因为目的地确定了你衡量每个 ticket 所用的范围。
- **Decisions so far(目前的决定)。** 每个已关闭的 ticket 一行，各自链接到细节所在的地方。
- **Not yet specified(尚未明确)。** 这就是**战争迷雾**(fog of war)：你能感觉到即将到来、但还没法清晰表述的决定。区分迷雾和 ticket 的标准，是你*现在*能否准确地陈述这个问题，而不是你能否回答它。当你解决一个 ticket 时，它前方的迷雾就会散去，任何现在能够明确的东西都会升级为一个新的 ticket。
- **Out of scope(超出范围)。** 目的地之外的工作。迷雾只会*朝着*目的地聚集，所以超出范围的工作保持关闭，永远不会升级。

**前沿**(frontier)是那些未关闭、未被阻塞、未被认领的 ticket 的集合（已知区域的边缘）。会话在做任何工作之前，先把 ticket 分配给自己来认领它。被分配人*就是*认领，所以并发的会话会跳过这个 ticket。会话用名称来指代 ticket，从不用光秃秃的 `#42`，因为一堆 issue 编号在叙述中很难读。

## 四种决策 ticket 类型

每个 ticket 都带有一个 `wayfinder:<type>` 标签。每个 ticket 要么是 **[HITL](https://www.aihero.dev/ai-coding-dictionary/human-in-the-loop)**（和一个为自己发言的人一起处理），要么是 **[AFK](https://www.aihero.dev/ai-coding-dictionary/afk)**（由 agent 独自推进）。HITL ticket 只能通过实时交流来解决。一个自问自答[盘问](https://www.aihero.dev/ai-coding-dictionary/grilling)问题的 agent 就破坏了它。

| 类型 | 模式 | 什么时候用 | 由什么解决 |
| --- | --- | --- | --- |
| `grilling` | HITL | 默认类型。问题可以通过讨论来解决。 | [grilling](https://aihero.dev/skills-grilling) 加 [domain-modeling](https://aihero.dev/skills-domain-modeling)，在一个全新会话里 |
| `prototype` | HITL | 「这个该长什么样」或「这个该怎么表现」：讨论解决不了的问题。 | [prototype](https://aihero.dev/skills-prototype)，ticket 上链接到构建出的产物 |
| `research` | AFK | 工作目录之外的某个事实阻塞了一个决定。 | 一个 [research](https://aihero.dev/skills-research) [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent)，在你绘制地图时启动，在 `research/<name>` branch 上并行运行 |
| `task` | 两者皆可 | 没什么要决定的，但有手动工作阻塞了一个决定，比如开通权限、注册某个服务，或者搬运数据以便看清它的形态。 | 能做的部分由 agent 独自完成，否则给人一份精确的检查清单 |

`task` 是唯一一种*去做*而不是去决定的类型。它之所以属于地图，只是因为它能解除对某个决定的阻塞，而绝不是因为它交付了目的地的一部分。实践中这种类型最常出问题。agent 会把它读成一个实现步骤，开始在地图里写产品代码。

research 是「一个会话一个 ticket」规则的唯一例外。

## 常见问题

**这和 `/grill-with-docs` 有什么不同？我该从哪个开始？**
看会话数量，而不是项目大小。`/grill-with-docs` 是单会话规划；wayfinder 是多会话规划。如果你能在一段对话里装下整件事，盘问更便宜也更好，而 wayfinder 在这种情况下更慢、更密集。社区里的简短说法是：只有当工作装不进一个会话时，wayfinder 才有意义。这是关于 wayfinder 被问得最多的问题，没有之一。人们之所以一再问，是因为 skill 的描述并没有告诉你自己的任务落在这条线的哪一边。会话数量得由你自己判断。

**它问「目的地」时，指的是这次会话的终点，还是一切的终点？**
是整张地图的终点，而不只是第一个会话。这个问题读起来有歧义，但 wayfinder 按定义就是多会话工具，所以以会话为范围的回答永远说不通。典型的目的地有：一份要交接出去的 [spec](https://www.aihero.dev/ai-coding-dictionary/spec)，一个要在规划开始前锁定的决定，一个概念验证，或者一次原地进行的改动，比如数据迁移。

**地图已经清空了。wayfinder 不是已经写好了 spec、建好了 ticket 吗？为什么我还需要 `/to-spec` 和 `/to-tickets`？**
不是。wayfinder 的 ticket 是决策 ticket，到地图关闭时它们也都已经关闭了。剩下的是一张满是链接起来的决定的地图，那不是一份构建计划。[to-spec](https://aihero.dev/skills-to-spec) 把这些链接起来的决定收拢成一份 spec（`/to-spec #<map_issue>`），[to-tickets](https://aihero.dev/skills-to-tickets) 再把这份 spec 切成曳光弹(tracer bullet)式的实现 ticket。如果你把地图直接接到 [implement](https://aihero.dev/skills-implement)，就跳过了收拢这一步，丢掉了那些链接起来的细节。只有当工作最后发现其实很小时，才直接进入实现。有些人跑的是更短的流水线，并报告说也能用。多出来的两步给你一份明确的 spec，reviewer 或同事都能读，当你不是一个人工作时，这一点更重要。

**我的 agent 在一次 wayfinder 会话中途开始写生产代码了。**
这是这个 skill 被报告最多的失败，而且是 skill 里一个真实存在的缺口导致的。你可以在地图的 **Notes** 里覆盖 wayfinder「只规划，不动手」的默认设定。但 Notes 是 agent 写的，所以约束和它的豁免都住在一个由受约束的 agent 自己掌控的文件里。有位用户亲眼看到一个 agent 在自己的 Notes 里写下「this map carries execution」。在后来的会话里，agent 把这一行读回来当作许可，在一台线上服务器上动手构建了。这个 skill 没有针对「我指的是默认设定」的硬性停止机制。在有之前，对任何不是你自己绘制的地图都要读一读它的 Notes，把实现放在单独的会话里，并把任何看起来像构建切片的 `wayfinder:task` 视为类型标错了。

**我绘制了 27 个 ticket，等做到第十三个时，剩下的已经说不通了。**
这个问题原封不动来自一份用户报告，其他人也报告了同样的结果。默认情况下，wayfinder 会做全面的规划。当后面的 ticket 建立在被前面的 ticket 推翻了的假设之上时，地图就掉进了批评者指责这个 skill 的那个瀑布式陷阱。有两件事有帮助。第一，把地图的范围限定在一个有边界的目的地，而不是整个产品。用户报告说，限定在一个明确 epic 上的地图，表现比一个铺天盖地的「实现 V1」好。目标是交付小的增量，而不是规划一个非常大的东西。第二，积极地做[原型](https://www.aihero.dev/ai-coding-dictionary/prototyping)。路线之所以能保持最新，是因为廉价而具体的产物能在实现依赖于不确定性之前把它暴露出来。wayfinder 是「原型拉满」，而不是「规划拉满」。

**我能并行处理几个 ticket 吗？**
前沿会告诉你哪些 ticket 可以领，阻塞边让并行工作在纸面上是安全的。实践中，一次一个 ticket 是更安全的默认做法。如果你同时处理两个 grilling ticket，一个会话可能会问你一个你刚在另一个会话里回答过的问题，因为会话之间不共享[上下文](https://www.aihero.dev/ai-coding-dictionary/context)。prototype ticket 也有一个已知缺口。有位用户报告说，一个 agent 构建了三个 UI 变体，自己挑了一个，然后关闭了 ticket。那个选择应该由你来做，而 skill 目前还没有把这一点说得足够清楚。如果你确实要并行处理 ticket，先自己审一遍依赖图。

**我必须用 GitHub Issues 吗？**
不必。任何 issue tracker 都可以。GitHub 的支持最好，因为它原生的子 issue 和阻塞关系让你不打开地图也能看到前沿。人们也在用 GitLab、Linear、Jira 和本地 markdown。有两点要注意。在没有原生阻塞的 tracker 上，wayfinder 会从文本推断依赖图，你必须手动修正。本地 markdown 会把这些产物放进你的仓库，这不推荐，因为存放在仓库里的材料往往会意外地一直留下来。开源维护者遇到的是相反的问题（公开的 tracker 被 agent 生成的规划 ticket 塞满），所以往往还是会选择本地 markdown。

**盘问太累了。每个问题都有三段长。**
这是关于 wayfinder 最尖锐的未解决抱怨，至今没人修好。有位用户是这样拆解的：冗长本身就会造成决策疲劳，而且篇幅掩盖了 agent *为什么*要问这个问题，所以随着地图增长，你会丢失从一个决定到下一个决定的链条。冗长看起来是当前这批[模型](https://www.aihero.dev/ai-coding-dictionary/model)的特性，而不是这个 skill 的特性。用户尝试过两种缓解办法：调低[推理强度](https://www.aihero.dev/ai-coding-dictionary/effort)，以及在全局 `CLAUDE.md` 里加一条用平实语言的指令。不管怎样，都要做好在这里费力思考的准备。wayfinder 要求你做大量思考，而这正是它大部分的意义所在，不是缺陷。

**一个我已经关闭的决定后来发现是错的。我该改旧 ticket 还是新建一个？**
没有官方的指导，而 agent 的默认做法帮不上忙。它倾向于绕着那个坏决定去设计，而不是挑战它，所以你必须自己掌舵。有效的做法是直接告诉 wayfinder 什么变了。它会更新地图，修订受影响的 ticket，并在已关闭的 ticket 上发评论。地图进行到一半时的范围变化是可以挽回的。但如果你*设计*地图时就打算让它变，那说明范围定错了。

**`decision-mapping` 去哪了？**
就是这个 skill。v1.1 把它改名为 `wayfinder`，你用 `/wayfinder` 调用它。「决策地图」是行话，而且也不准确，因为四种 ticket 类型里只有一种本身就是决定。新名字给了这个 skill 一套一致的词汇（目的地、战争迷雾、前沿、地图），而不是在上面再叠一个自创的术语。单元保留了「决策」这个词：wayfinder 的 ticket 是**决策 ticket**，这样人们就不会把它读成实现 ticket。

## 起作用的标志

- 在任何一个 ticket 存在之前，目的地就已经写下来并达成一致。
- 每个未关闭的 ticket 读起来都是一个问题。任何读起来像「构建 X」的 ticket，要么类型标错了，要么属于地图的下游。
- 你看一眼 tracker 就知道哪些 ticket 可以领，不需要打开地图，因为原生的阻塞关系显示了前沿。
- 一个会话解决一个 ticket，把答案作为解决评论发出来，关闭它，往地图的 *Decisions so far* 里加一行，然后停下。
- **Not yet specified** 随着时间缩小。当迷雾升级为 ticket 时，它会离开那一节，不会同时出现在两个地方。
- 如果开场的广度优先盘问完全没发现迷雾，skill 会停下来告诉你，这项工作小到可以跳过地图。
- 完成地图的那个会话会把你引向一份 spec，而不是一个 pull request。

## 在体系中的位置

`wayfinder` 是一个**视情况使用的入口**(on-ramp)，不是默认的起点。大多数工作仍然从以盘问开头的「想法 → 上线」链路开始。当想法大到一个会话装不下时，你才用 wayfinder。它在 [to-spec](https://aihero.dev/skills-to-spec) 处重新汇入那条链路，因为一张清空的地图会交接出去，而不是自己构建。

大部分工作发生在 wayfinder 调度的其他 skill 里。[grilling](https://aihero.dev/skills-grilling) 和 [domain-modeling](https://aihero.dev/skills-domain-modeling) 解决默认类型的 ticket，[prototype](https://aihero.dev/skills-prototype) 解决讨论无法解决的 ticket，[research](https://aihero.dev/skills-research) 作为 subagent 运行，让它的阅读不进入你的会话。[handoff](https://aihero.dev/skills-handoff) 负责把工作移进移出：从一段膨胀得太大的对话移进地图，以及在会话中途冒出一个支线任务时移出地图。其他情况，[ask-matt](https://aihero.dev/skills-ask-matt) 会在整套 skill 上为你指路。
