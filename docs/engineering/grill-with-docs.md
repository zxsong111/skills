## 它做什么

`grill-with-docs` 就一个计划或设计盘问你，直到你和 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 对它有一致的理解，同时把词汇和难做的决定写进你的仓库。它和 [grill-me](https://aihero.dev/skills-grill-me) 做的是同一种盘问（一轮问题，等你回答，再下一轮），只是对准了一个代码库。

它是**[有状态的](https://www.aihero.dev/ai-coding-dictionary/stateful)**。其他盘问类 skill 把[会话](https://www.aihero.dev/ai-coding-dictionary/session)的成果留在你脑子里；这个则在磁盘上留下文件。一个术语一旦确定，skill 立刻把它写进 `GLOSSARY.md`，而不是到最后批量写入。一个决定通过三道关卡，skill 就把它写成一份 ADR。区别仅此而已，而大家用这个 skill 遇到的麻烦也大多由此而来。这些工件是真实仓库里的真实文件，所以你以为该有的时候它们可能不在，多人一起写的时候它们也可能逐渐走样。

## 什么时候用

输入 `/grill-with-docs` 调用它，agent 不会自己去用它。

在仓库里开始一项改动时用它，此时计划还很模糊，描述这件事的用词也还没定下来。它是单会话的工具。选哪个盘问类 skill，取决于你手上有什么：

| 你有什么 | 该用 |
| --- | --- |
| 你根本不在一个工作目录里 | [grill-me](https://aihero.dev/skills-grill-me) |
| 一个仓库，以及一项能在一个会话内敲定的改动 | `grill-with-docs` |
| 一件一个会话装不下的事（从零开始的构建、一个大功能） | [wayfinder](https://aihero.dev/skills-wayfinder) |
| 一个完全没有领域文档的仓库，也没有特定的功能要做 | `grill-with-docs`，对准整个仓库而不是某项改动 |
| 一个决定卡在别人脑子里的知识上 | [to-questionnaire](https://aihero.dev/skills-to-questionnaire) |

和 wayfinder 的分界在于会话数量：单会话的规划用 `/grill-with-docs`，多会话的规划用 `/wayfinder`。

## 前置条件

这个 skill 会往你的仓库里写东西，所以你得在一个可以安全写入的地方。确定下来的术语写进根目录的 `GLOSSARY.md` 术语表；如果根目录有 `GLOSSARY-MAP.md`，表明这是个多上下文的仓库，就写进对应上下文的 `GLOSSARY.md`。决定写进 `docs/adr/`。两者都是 skill 需要时才创建。第一个术语或决定敲定之前什么都不存在，所以你不用提前准备任何东西。

它还需要另外两个 skill 在场，因为它自己的 `SKILL.md` 只有一行，就是委托给它们。[grilling](https://aihero.dev/skills-grilling) 负责盘问，[domain-modeling](https://aihero.dev/skills-domain-modeling) 负责写入。只装 `grill-with-docs` 一个，得到的是一个用不了的 skill。

## 留下的书面记录

一次会话会产出三样东西，它们的地位并不相同。

| 确定了什么 | 落在哪里 |
| --- | --- |
| 一个术语：项目对某样东西的专属叫法 | `GLOSSARY.md`，边聊边写，确定的那一刻就写入 |
| 一个难以撤回、缺少背景时会令人意外、并且是真正权衡取舍的决定 | `docs/adr/` 下的一份 ADR |
| 你决定的其他所有事情 | 对话里，别无他处 |

第三行是最容易让人措手不及的。`GLOSSARY.md` 只是术语表。它不放实现细节，不放 [spec](https://www.aihero.dev/ai-coding-dictionary/spec)，也不放草稿笔记。ADR 需要三个条件同时满足，所以大多数决定都不够格，大多数会话一份 ADR 都不会产出。一次会话产出了更精准的术语表、零份 ADR，这正是设计的本意；但这也意味着你们商定的大部分内容只存在于商定它们的那个[上下文窗口](https://www.aihero.dev/ai-coding-dictionary/context-window)里。把这段对话原样交给 [to-spec](https://aihero.dev/skills-to-spec)，而不是[清空](https://www.aihero.dev/ai-coding-dictionary/clearing)它。

术语表是主要产出。这个 skill 构建的是领域语言：项目自己的用词，一次商定，这样你、agent 和你的同事都不必再重新推敲一遍。并不是所有人都认为这能提升 agent 的表现。最有力的反对意见是：一个术语和它的通俗英文展开，从[模型](https://www.aihero.dev/ai-coding-dictionary/model)那里得到的结果是一样的，这套词汇主要缩短的是共享它的人之间的沟通。照这种看法，术语表依然有价值，只是价值归于人。

## 常见问题

**该用这个还是 `/wayfinder`？**
由范围决定。能在一个会话内敲定的事用这个；事情大到一个会话装不下时用 [wayfinder](https://aihero.dev/skills-wayfinder)，它会先把工作绘制成一张由决策 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) 组成的地图。wayfinder 更慢、更密集，在一个范围清晰的功能上用它是常见的错误。它不取代这个 skill，对于地图中适合盘问的部分，它可以发起一次盘问会话。

**它跑完了，但既没有出现 `GLOSSARY.md`，也没有 ADR。**
已知有两种原因。第一种是没有东西够格。ADR 需要通过全部三道关卡，而一次没有新词汇的改动会话本来就没什么可写。第二种是真实的 bug。当这个 skill 在另一个编排层里运行时（spec 驱动开发的包装器、多 agent 框架、把它当作别人流水线中一步来调用的规则），用户报告说写文件的那一半会悄无声息地不执行，而盘问照常进行。这个 bug 已登记，尚未修复。如果你处在这种环境里，先检查工作目录，再相信会话的产出。

**它一次把所有问题都抛出来，没有任何推荐答案，也从没提到 `GLOSSARY.md`。**
这是 skill 没能加载它的两个依赖。因为 `SKILL.md` 只是一行委托，没有加载 [grilling](https://aihero.dev/skills-grilling) 和 [domain-modeling](https://aihero.dev/skills-domain-modeling) 的 agent 只能去猜「盘问」是什么意思，于是你会一次收到所有问题，毫无结构。只加载了一部分的情况更让人困惑。`grilling` 加载了，`domain-modeling` 没加载，你得到一次不错的盘问，却没有任何书面记录。发生的频率取决于模型和 [effort](https://www.aihero.dev/ai-coding-dictionary/effort) 级别，这也是这个 skill 被报告最多的问题。如果你怀疑发生了这种情况，直接问 agent 它加载了哪些 skill。

**我其他那些决定都去哪了？**
只在对话里。这是关于这个 skill 最严重的未解决抱怨。术语表不是 spec，大多数回答够不上 ADR，也没有任何记录把每个确定的回答与 spec、ticket 和测试关联起来。后续步骤会把精确的回答（顺序保证、否定性需求、数值默认值）软化成更弱的文字，结果看起来很完整，却漏掉了你决定过的事。目前的办法是保留这个会话，直接交给 [to-spec](https://aihero.dev/skills-to-spec)。然后对照你自己的回答重读 spec，而不是默认它都记下了。

**我能把它指向一个完全没有文档的现有仓库吗？**
能。对于一个没有 ADR、没有领域语言、也没有设计原则的代码库，这正是合适的 skill：调用它，说「help me document my repo」。用户常把它和 [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) 搭配使用，来建立或修复 `GLOSSARY.md`。要做好引导它的准备。它读代码，就发现的东西问你，由你决定代码库里已有的哪些词才是对的。

**会话结束后我该做什么？**
skill 的结束语常常没有明确指向，这是已知问题。在主流程(main flow)里，答案是在同一个对话里接着用 [to-spec](https://aihero.dev/skills-to-spec)。如果改动小到可以马上动手，就直接用 [implement](https://aihero.dev/skills-implement)。

**为什么叫这个名字？**
没人对这个名字满意。有个未关闭的建议是改名为 `grill-domain-model`，更准确地描述了它的行为。目前没有进展。如果哪天真的改名，文档页会跟着移动，URL 也会改变。

## 起作用的标志

- `GLOSSARY.md` 在会话*进行中*一个术语一个术语地变化，而不是在最后一股脑儿冒出来。
- 术语表读起来是纯粹的词汇（你项目的用词加上精确的定义），不含任何实现细节或类似 spec 的文字。
- 代码库能回答的问题，它会去读代码库来回答，而不是来问你。
- 你得到的 ADR 很少甚至没有，而得到的那些，都是你不想再争一遍的决定。
- 你用的某个词与现有术语表的定义不同时，它会提出质疑。

## 在体系中的位置

`grill-with-docs` 是主构建链路的起点：

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review → retro
```

它在任何东西被写成 spec 之前出场。它产出共同的理解和定下来的词汇，[to-spec](https://aihero.dev/skills-to-spec) 随后在此基础上综合整理，不再重新盘问你。它的近邻是 [grill-me](https://aihero.dev/skills-grill-me)（同样的盘问，但没有仓库、没有文件）和 [domain-modeling](https://aihero.dev/skills-domain-modeling)（它所驱动的术语表与 ADR 纪律）；两者在盘问环节都使用 [grilling](https://aihero.dev/skills-grilling) 这个基础构件。在它的上游，[wayfinder](https://aihero.dev/skills-wayfinder) 负责绘制一个会话装不下的大型工作，并可以把地图的部分内容交还给它。当你拿不准该用哪个 skill 或哪条流程时，[ask-matt](https://aihero.dev/skills-ask-matt) 会为你指路。
