## 它做什么

`domain-modeling` 在你做设计的过程中构建并打磨项目的**通用语言**(ubiquitous language)。它会质疑与术语表(glossary)冲突的术语，在你用了含糊词语的地方要求一个精确的词，并用具体场景去检验某个关系，直到边界变得清晰。

它是**主动**的纪律，而不是被动的那种。任何 skill 都可以读 `GLOSSARY.md` 来借用其中的词汇。这个 skill 用于你在*修改*模型的时候，所以它会打断你。它在你敲定一个术语的那一刻就把它写进 `GLOSSARY.md`，就在对话进行当中，而不是在最后产出一份整整齐齐的术语表。最后才写的术语表只是一次[会话](https://www.aihero.dev/ai-coding-dictionary/session)的摘要；边聊边写的版本才是会话的产出。

## 什么时候用

输入 `/domain-modeling`，或者在任务匹配时由 agent 自动调用。实际上，自动调用是这个 skill 最薄弱的环节。当 `grill-with-docs` 或 `wayfinder` 说要加载它时，[模型](https://www.aihero.dev/ai-coding-dictionary/model)常常只加载了 `grilling` 而跳过了它。如果一次[盘问](https://www.aihero.dev/ai-coding-dictionary/grilling)会话跑完了，`GLOSSARY.md` 却毫无变化，就是发生了这种情况。和另一个 skill 一起，按名字调用它。

当问题出在*用词*上时用它：

| 情况 | 做法 |
| --- | --- |
| 两个人说「cancellation」指的不是一回事 | `domain-modeling`：选定规范术语，把另一个列在 `_Avoid_` 下 |
| 「Account」在三个文件里干着三份活 | `domain-modeling`：把它拆成 Customer 和 User |
| 你刚做了一个难以撤回的架构选择 | `domain-modeling`：如果这个选择够格，它会提议写一份 ADR |
| 问题出在模块的*形状*上：接缝(seam)放在哪，接口有多深 | [codebase-design](https://aihero.dev/skills-codebase-design) |
| 你想在动手之前把整个计划彻底盘问一遍 | [grill-with-docs](https://aihero.dev/skills-grill-with-docs)，它在底层驱动这个 skill |
| 你只想查一个术语，不想改它 | 什么都不用。去读 `GLOSSARY.md`，它就是个文件。 |

## 前置条件

事先什么都不需要。skill 会写入两个地方，两者都是用到时才创建：

- 仓库根目录的 **`GLOSSARY.md`**。skill 在你敲定第一个术语时创建它。如果仓库根目录有 `GLOSSARY-MAP.md`，术语就写进地图所指向的、对应各个上下文的 `GLOSSARY.md`。
- **`docs/adr/`**。skill 随着第一份够格的 ADR 一起创建它。

开始之前什么都不必存在，skill 也不会提前创建任何东西。

## 两种工件，两道门槛

术语表和 ADR 的门槛不同。这个 skill 的大部分麻烦都来自把两者混为一谈。

| | `GLOSSARY.md` | `docs/adr/NNNN-slug.md` |
| --- | --- | --- |
| 内容 | 术语。用一两句话说明某个东西**是**什么，被弃用的同义词列在 `_Avoid_` 下 | 一个决定，用一到三句话写清：背景、选择、理由 |
| 写入门槛 | 一个含糊的术语变成了规范用语 | **三条同时满足**：难以撤回、缺少背景时会让人意外、是真正权衡取舍的结果 |
| 何时写 | 边聊边写，术语敲定的那一刻 | 由 skill 提议，而不是默认就写 |
| 绝不包含 | 实现细节、[spec](https://www.aihero.dev/ai-coding-dictionary/spec)、草稿、通用的编程概念 | 本次会话所做每个选择的流水账 |

ADR 的三项检验只要有一项不满足，就不写 ADR。容易撤回的决定迟早会被撤回；不令人意外的决定没人会问；没有真正替代方案的决定，记下来的只是你做了显而易见的事。

`GLOSSARY.md` 的规则最重要，因为实际中最容易被打破的就是它。**它是术语表，仅此而已。** 不加约束的话，模型会把「写入 `GLOSSARY.md`」当成许可，把你给出的每个回答都存进去，于是这个文件变成一份不断增长的 spec。这是这个 skill 被报告最多的问题，好几种模型上都出现过。

## 交叉核对，以及它的边界

当你陈述某个东西如何运作时，skill 会去查代码，指出任何矛盾。*「你的代码取消的是整个 Order，但你刚才说可以部分取消，哪个才对？」* skill 会先把语言和代码之间的分歧摆到明面上，让两者一致，然后才去改动其中任何一个。

它交叉核对的是**代码**以及已提交的 `GLOSSARY.md` 和 ADR，别的都不看。它不搜索你的 issue tracker。如果你的团队几个月前就在一个已关闭的 issue 里吵完并解决了某个命名冲突，skill 还会把它当作新问题重新提出来。有[一个未关闭的请求](https://github.com/mattpocock/skills/issues/717)要修复这一点。在那之前，绕过办法是把这条指令写进你自己的 `docs/agents/domain.md`，这些 skill 本来就会读它。

## 常见问题

**我的 `GLOSSARY.md` 有 500 行了。1000 行。3000 行。怎么办？**
体积只是症状。病因是这个文件吸收了本就不属于术语表的实现细节和决定。修复办法是一条直接的指令：`/grill-with-docs make my GLOSSARY.md more concise and remove any implementation details from it`。对一个臃肿的文件跑一遍，大部分内容都会被删掉。只有当文件已经精简、却仍然覆盖两个读者不想同时装在脑子里的领域时，才用 `GLOSSARY-MAP.md` 拆分它。拆分一个臃肿的文件，只会得到好几个臃肿的文件。skill 在这方面的指引还不足以从一开始就阻止膨胀，跟踪这个问题的 issue 仍未关闭。

**为什么叫 `GLOSSARY.md` 而不是 `GLOSSARY.md`？**
这是整套 skill 里争论最多的命名问题，没有定论。反对现名的理由很充分：如果它是「术语表，仅此而已」，`GLOSSARY.md` 这个名字就把这一点说清楚了，而且正如一位读者所说：「with ai agents everything is [context](https://www.aihero.dev/ai-coding-dictionary/context)」。支持现名的理由在于地图：`GLOSSARY-MAP.md` 指向若干个 `GLOSSARY.md` 文件，读起来很自然，`GLOSSARY-MAP.md` 则不然；而 `context` 是 DDD 里指代模型中一块有界区域的通行说法。至少有一个人维护着一个本地 fork，纯粹就是为了给这个文件改名。你也可以这么做，但整套里的其他 skill 都在找 `GLOSSARY.md`，所以改名意味着要给它们全部打补丁。

**`/ubiquitous-language` 去哪了？**
它被移除了，而不是被标记为弃用。它的职责转移到了 `domain-modeling`，后者持续维护整个模型，而不是从一次对话里倒出一份术语表。词汇约束现在更重要了，而不是更不重要。它在盘问、分诊(triage)和绘制地图的底层运行，而不是作为一次需要你记得去做的单独检查。

**一个完全没有术语表的代码库，怎么给它建一份？**
明确地提出要求，而不是等它慢慢积累。`/grill-with-docs help me scaffold my existing repo with a GLOSSARY.md` 是文档里写明的做法。做好被长时间盘问的准备。有用户报告在文件成形之前被问了 50 多个问题。在存量仓库上，靠顺带使用来积累术语表实在太慢了。

**我能保留领域模型，同时用我自己的 ADR 格式吗？**
目前做不到很干净。术语表和 ADR 这两半装在同一个 skill 里，所以一个已有既定 ADR 约定的团队（不同的模板、不同的位置、不同的命名）拿到的指令会和自家风格冲突。目前的选择是把 skill 复制到本地再改，或者在仓库自己的 agent 文档里覆盖 ADR 约定。把两者拆开是[一个未关闭的请求](https://github.com/mattpocock/skills/issues/557)。

**术语表真的物有所值吗？它又多了一个要评审的工件，还可能过时。**
有时候确实不值。DDD 越接近实现就越没用。回报在上游，在于命名和概念对齐，而不在于聚合和分层的繁文缛节。同义词管控在命名边界上才重要：模块名、表名、状态枚举、issue 标题、CLI 命令。在普通的行文里就没那么重要了。还有一种反对意见：领域术语压缩的是*人与人之间*的沟通，前提是双方已经共享这些术语；而 agent 对通俗英文描述的反应是一样的。照这种理解，术语表的价值在于让你和你的评审者跟 agent 正在做的事保持一致，而不是让 agent 变得更好。只做一天的项目就跳过它。另外，未经评审、由 agent 自己写的术语表比没有更糟：里面会塞满言之凿凿的断言，后续会话会把它们当真。

**它能帮我把含糊的 prompt 变成领域语言吗？**
不能，也没有计划做一个能这样做的 skill。一种你自己都不理解的领域语言，写下来也毫无意义。这个 skill 在你已经理解之后强制精确，它不会凭空发明你没有的词汇。与此相关的陷阱是只用领域词汇而不做建模。在错误的概念上套上正确的名词，产出的东西读起来是对的，实际上却不对。

## 起作用的标志

- 它会在你说到一半时打断你，问你指的是两者中的哪一个，而不是随便挑一个就继续。
- `GLOSSARY.md` 在对话**进行中**发生变化，而不是在最后一下子冒出来。
- 对于明天就能撤回的东西，它拒绝写 ADR，并说明三项检验中哪一项没通过。
- 新条目用一两句话定义某个东西*是*什么，并把你弃用的词列在 `_Avoid_` 下。
- 当你的代码和你说的话不一致时，它会把你的代码引出来给你看。
- `GLOSSARY.md` 变短的次数和变长的次数一样多。

## 在体系中的位置

`domain-modeling` 是一份**模型自动调用(model-invoked)的参考**，它在其他 skill *底层*运行的时候比单独运行的时候多。[grill-with-docs](https://aihero.dev/skills-grill-with-docs) 在盘问会话中驱动它，[wayfinder](https://aihero.dev/skills-wayfinder) 在绘制地图时加载它，[triage](https://aihero.dev/skills-triage) 用它让 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) 使用项目自己的用语，[improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) 在决定敲定时调用它。它最近的兄弟是 [codebase-design](https://aihero.dev/skills-codebase-design)。两者一起构成其他一切之下的词汇层，这个负责*领域*，那个负责模块的*形状*。你也可以直接调用它，在想要这套纪律、又不想走那些通常会加载它的 skill 的步骤时。当你拿不准该用哪个 skill 时，[ask-matt](https://aihero.dev/skills-ask-matt) 会为你指路。
