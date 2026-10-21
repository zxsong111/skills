## 它做什么

`to-spec` 把你刚刚进行的对话变成一份 **[spec](https://www.aihero.dev/ai-coding-dictionary/spec)**，并作为单个 issue 发布到你的 issue tracker。

它不会再访谈你。当你用到它时，决定已经做完了。所以它综合已知的内容（来自对话、代码库、你的 `GLOSSARY.md` 和 ADR），不会开启新一轮问题。spec 记录的是你已经做出的决定，不是做新决定的地方。

## 什么时候用

输入 `/to-spec` 调用它，[agent](https://www.aihero.dev/ai-coding-dictionary/agent) 不会自己去用它。

当构建大到一个 agent [会话](https://www.aihero.dev/ai-coding-dictionary/session)装不下、必须拆到几个会话里时用它。触发条件就这一条：

| 你在哪个阶段 | 运行什么 |
| --- | --- |
| 还什么都没决定 | 先用 [grill-with-docs](https://aihero.dev/skills-grill-with-docs) |
| 已经决定，工作量一个[上下文窗口](https://www.aihero.dev/ai-coding-dictionary/context-window)装得下 | [implement](https://aihero.dev/skills-implement)：跳过 spec |
| 已经决定，工作要跨好几个会话 | `/to-spec`，然后 [to-tickets](https://aihero.dev/skills-to-tickets) |
| 一张 [wayfinder](https://aihero.dev/skills-wayfinder) 地图已经清空迷雾 | `/to-spec #<map_issue>` |

## 前置条件

`to-spec` 把 spec 作为 issue 发布，所以必须先由 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 为这个仓库配置好 tracker 和分诊(triage)标签词汇。两种 tracker 都可以：像 GitHub 这样的真正 tracker，或者 `.scratch/` 下的本地 markdown 文件，后者不需要额外设置。

## spec 是一份决策记录

spec 之所以存在，是因为上下文窗口会结束。你在[盘问](https://www.aihero.dev/ai-coding-dictionary/grilling)时定下了很多事：解决方案的形状，你逐一争论过的选择，以及你有意拒绝的东西。这些都在一段你马上就要清空的对话里。spec 把它们保留下来。

所以 spec 不验证也不决定任何事。它用你项目自己的词汇记录你决定了什么，让一个新会话无需你再解释一遍就能接手工作。如果 spec 里写了你从没说过的东西，那就是缺陷。

## 先接缝，后文字

在写任何东西之前，`to-spec` 会勾勒出功能将被测试的那些**接缝**(seam)，并和你确认。它优先使用已有的接缝而不是新的，并尽量挑最高层的接缝。一次改动理想的接缝数量是一个。

其他 skill 之后会用到这些商定好的接缝。[tdd](https://aihero.dev/skills-tdd) 只在你事先同意的接缝上工作。[code-review](https://aihero.dev/skills-code-review) 对照 spec 审查 diff，所以一个没人同意过的接缝会作为 review 发现冒出来。这两条联系都经过这份文档。这就是为什么你应该在这里认真对待关于接缝的讨论，而不是把它留到实现阶段。

## 常见问题

**`/to-prd` 去哪了？**
就是这个 skill，在 v1.1 改了名。现在全程统一用「spec」这一个术语，旧的 `to-prd` slug 不再可用，所以请用新名字重新安装。旧的词汇被 *spec* 和 *ticket* 这一对替代了。spec 是目的地以及确定它的那些决定。[ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) 是抵达那里的步骤。如果你改变了方向，就删掉未完成的 ticket，保留 spec。

**为什么 spec 会被打上 `ready-for-agent` 标签？我不想让 agent 照着它直接实现。**
这个标签的意思是「不需要进一步分诊」：文档已经完整到 agent 可以据此工作。它标记的是一份输入，而不是一张工单。但是轮询 `ready-for-agent` 的 [AFK](https://www.aihero.dev/ai-coding-dictionary/afk) agent 看不出这个区别。它们会试图在一次运行里构建整份 spec，而不是去领 ticket 切片。这是这个 skill 被报告最多的问题。在它改变之前，请在你的 AFK agent 的 prompt 里明确排除父级 spec，或者在 `/to-tickets` 运行之后去掉这个标签。

**为什么不从盘问直接走到 `/to-tickets`，跳过 spec？**
很多时候你确实应该这样。spec 只在跨多个会话的工作上才值得这一步。它的价值在于 ticket 是用完即弃的，而 spec 不是。每个 ticket 的大小都按一个全新的上下文窗口来切，用完就删掉或关闭，而 spec 作为记录它们背后理由的唯一地方保留下来。在单会话的改动上，这什么也给不了你，你还要为一个额外的综合步骤买单，而[模型](https://www.aihero.dev/ai-coding-dictionary/model)在这一步可能会跑偏。直接从盘问走到 `/implement`。

**我刚完成一张 wayfinder 地图。该喂给它什么？**
给它主地图 issue，`/to-spec #<map_issue>`，而不是那些单独的决策 ticket。[wayfinder](https://aihero.dev/skills-wayfinder) 产出的是分散在一张地图上的决定，而不是交付物。`to-spec` 把它们收拢成一份你可以据此构建的文档。如果你把地图直接接到 `/implement`，就丢掉了这一步。

**spec 是给我审阅的，还是只给 agent 看的？**
主要给 agent 看，读起来也是这个样子：完整、密集、满是引用。读一读接缝和超出范围那两节。在这两个地方，错误的决定现在发现代价最小，以后才发现代价最大。确实有人抱怨要读完整份文档，而且没有摘要模式。但如果 spec 让你感到意外，那是盘问太浅了，而不是 spec 太长。

**ticket 开始之后，我是把 spec 冻结，还是让 agent 改写它？**
没有任何东西让它保持同步。实际上它是你那一刻所知内容的一张快照，实现第一次让你学到新东西时它就过时了。工作上线后就把它当作可丢弃的。你的 `GLOSSARY.md` 和 ADR 才是要长期保留的文件。如果你在实现过程中学到了应该长期保留的东西，就写到那里，而不是去改 spec。

**我的工作是一次重构或一个模块边界，不是一个功能。这个模板合适吗？**
不太合适，这是一个已知的局限。模板非常依赖用户故事，而用户故事不适合架构类工作。你最终会围绕着那些其实关于接口和不变量的决定，写出一堆没人要的故事。改用实现决策和测试决策那两节。把长期的架构决策通过 [grill-with-docs](https://aihero.dev/skills-grill-with-docs) 记录为 ADR，而不是写进 spec。

**它会检查 tracker 里的相关工作，或者引用它所遵循的 ADR 吗？**
两个都不会。它会读取并遵循所涉及领域的 ADR，但不会链接它们。它在写之前也不会在 tracker 里搜索重叠的 issue，所以一份 spec 可能和别人已经提交的工作重复，而且没有任何东西提醒你。如果这个领域很热闹，先自己搜一下 tracker。

**`/to-tickets` 读不了我的 spec：内容一直被截断。**
tracker 的 issue 可能无法完整返回一份很大的 spec，而且也没有本地副本可以替代。要解决这个问题，不要在 `/to-spec` 和 `/to-tickets` 之间[清空](https://www.aihero.dev/ai-coding-dictionary/clearing)或[压缩](https://www.aihero.dev/ai-coding-dictionary/compaction)上下文。在同一个窗口里运行它们，`/to-tickets` 就根本不需要再去抓取 spec。

## 起作用的标志

- 它直接开始写，而不是再问你新一轮问题。
- 它在写之前先给你看接缝，并且提出的接缝尽可能少。
- 它用的是你项目里的名词，而不是泛泛的产品管理套话。
- 里面的每个决定你都记得是自己做的。它没有为了填满某一节而编造任何东西。
- 超出范围那一节列的是真实的东西。你拒绝过的那些，通常是整页里最有用的几行。

## 在体系中的位置

`to-spec` 是主构建链路中的一步，但只在其中跨多会话的那个分支上：

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review → retro
```

在上游，[grill-with-docs](https://aihero.dev/skills-grill-with-docs) 做出决定，而这个 skill 只负责记录；一张完成的 [wayfinder](https://aihero.dev/skills-wayfinder) 地图也在这里汇入链路。在下游，[to-tickets](https://aihero.dev/skills-to-tickets) 把 spec 切成曳光弹(tracer bullet)式的 ticket，交给 [implement](https://aihero.dev/skills-implement) 去构建。当你不确定哪个 skill 或流程合适时，[ask-matt](https://aihero.dev/skills-ask-matt) 会为你指路。
