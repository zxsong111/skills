## 它做什么

`triage` 逐个处理你项目 tracker 上的 issue。它让每个 issue 走过一个由**分诊角色**(triage role)构成的小型状态机（一个类别角色和一个状态角色）。每个 issue 最终会成为一份可直接交给 agent 的简报、一个向报告者提出的具体问题，或者一个记录了原因的已关闭 issue。

它只针对**不是你创建的** issue。也就是原始的 bug 报告、新进来的功能请求，或者一个不打招呼就出现的外部 pull request：从外部进入 tracker 的工作，保持着报告者留下的样子。来自 [to-tickets](https://aihero.dev/skills-to-tickets) 的 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) 已经是可直接交给 agent 的了，所以如果你对它们运行 `triage`，就是在浪费工作。规则很简单：`/triage` 只用于新进来的 issue，不用于你自己创建的 issue。

它和手动打标签的另一个区别在于：它先给出建议，然后等待。它会给出它对类别和状态的判断及理由，加上它在代码库里发现的东西，在你发话之前什么都不会应用。

## 什么时候用

输入 `/triage` 调用它，然后用平常的话描述你想要什么，[agent](https://www.aihero.dev/ai-coding-dictionary/agent) 不会自己去用它。例如：「给我看看需要我关注的东西」「我们来看看 #42」「把 #42 移到 ready-for-agent」。

| 你手上有什么 | 去哪里 |
| --- | --- |
| 一个塞满了别人原始报告的 tracker | `/triage` |
| 你自己的一个粗略想法，什么都没写下来 | [grill-with-docs](https://aihero.dev/skills-grill-with-docs) |
| 一段已经有定论、要变成 [spec](https://www.aihero.dev/ai-coding-dictionary/spec) 的对话 | [to-spec](https://aihero.dev/skills-to-spec) |
| 一份要拆成可直接交给 agent 的 ticket 的 spec | [to-tickets](https://aihero.dev/skills-to-tickets) |
| 一个已确认的 bug，需要的是根因而不是标签 | [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs) |

## 前置条件

`triage` 会读写你的 issue tracker，所以必须先由 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 配置好这个 tracker 及其标签词汇。下面的角色名称是**规范名称**。你 tracker 里的标签字符串可能不同，映射由设置提供。如果你的 tracker 已经完全使用规范名称，就没什么要映射的，也没什么要设置的。

tracker 配置还决定外部 pull request 是否算作一个请求入口，以及谁算外部。这个开关默认是关闭的，设置也不再询问它。要把 PR 纳入范围，在 `docs/agents/issue-tracker.md` 里把它打开。

## 状态机

每个经过分诊的条目最终都恰好有一个类别角色和一个状态角色。类别有两个：`bug`（有东西坏了）和 `enhancement`（新功能或改进）。状态有五个：

| 状态 | 含义 |
| --- | --- |
| `needs-triage` | 需要你来评估。没有标签的 issue 通常先落在这里。 |
| `needs-info` | 等待报告者。对方回复后回到 `needs-triage`。 |
| `ready-for-agent` | 已完整说明，附有一份 agent 简报。[AFK](https://www.aihero.dev/ai-coding-dictionary/afk) agent 可以接手。 |
| `ready-for-human` | 同样的简报，外加 agent 为什么做不了：需要判断、需要外部权限、需要手动测试。 |
| `wontfix` | 已关闭，并记录了原因。 |

这就是全部词汇。每个条目恰好一个状态角色的规则让查询保持简单。状态也是这个 [skill](https://www.aihero.dev/ai-coding-dictionary/skill) 被提需求最多的地方。用户要求过一个用于「已说明但被另一个 issue 阻塞」的状态，一个用于等待未来某个触发条件的 `deferred` 状态，以及一个终结性的 `implemented` 状态。这些都还没有发布。见下面的问题。

`wontfix` 有三种情况。区别很重要，因为只有其中一种会写入知识库：

| 你为什么关闭它 | 会发生什么 |
| --- | --- |
| 已经实现了 | 留一条评论，指出这个功能已经在哪里了。不往 `.out-of-scope/` 里写任何东西，因为这是一个已经做好的功能，不是一个被拒绝的功能，在那里放文件会破坏去重检查。 |
| 被拒绝的 bug | 礼貌地解释，然后关闭。 |
| 被拒绝的功能增强 | 在 `.out-of-scope/` 里写一个文件，在关闭评论中链接它，然后关闭。 |

`.out-of-scope/` 为每个被拒绝的**概念**存放一个 markdown 文件，而不是每个 issue 一个。每个文件是一份简短的设计文档，而不是一行数据库记录。它说明拒绝了什么、为什么，并列出所有提过这个请求的 issue。`triage` 在评估任何东西之前会先读完整个目录。它按概念而不是关键词匹配，所以「夜间主题」会匹配到 `dark-mode.md`。找到匹配时，它会把旧的决定给你看，问你是否仍然同意，而不是从头再争论一遍这个请求。

## 先核实，再写简报

在任何[盘问](https://www.aihero.dev/ai-coding-dictionary/grilling)之前，`triage` 会先检查说法是否成立。对于 bug，它按报告者的步骤复现。对于 PR，它 checkout 那个 branch 并运行相关测试。然后它报告三种结果之一：

- 已确认，附上代码路径。
- 复现失败。
- 细节不够，无法尝试。这是最强烈的 `needs-info` 信号。

在同一轮里，它还会对照代码库再做两项检查。**冗余**检查问的是这个功能是否已经实现了，按领域概念而不是报告者的措辞去搜索。**先前拒绝**检查问的是 `.out-of-scope/` 是否已经说过不。两项检查都很便宜，任何一项命中都会产出一个 `wontfix`。

所有这些工作都是为了把一样产出物做好：**agent 简报**。这是 issue 移到 `ready-for-agent` 时 `triage` 发布的那条结构化评论。`triage` 发布之后，简报就是契约，原始报告只是背景。简报追求**持久**而不是精确，因为一个 issue 可能在 `ready-for-agent` 里待上好几周，而代码一直在变。所以简报写的是类型、签名和行为契约，从不写文件路径或行号。一次确认过的复现，能让简报比一个猜测强得多。

## PR 是附带了代码的 issue

如果 tracker 把外部 pull request 当作请求入口，它们就走同一台状态机，用同样的类别、状态和转换。状态作用于 diff。`ready-for-agent` 表示附有简报，应该由 agent 在代码上迈出下一步。`ready-for-human` 表示可以由人来 merge。PR 上的简报描述的是现有 diff 还剩什么要做，而不是怎么从零构建这个东西。

发现阶段只显示*外部* PR，因为协作者进行中的 branch 不是分诊工作。这个过滤只作用于发现阶段。如果你明确点名一个 PR，不管是谁写的，`triage` 都会处理它。

## 常见问题

**我运行了 `/to-spec` 和 `/to-tickets`，现在那些 ticket 放在那里没有分诊。我要对它们运行 `/triage` 吗？**
不要。它们已经是可直接交给 agent 的了。`to-tickets` 发布时会打上 `ready-for-agent` 标签，所以 AFK 运行器不需要再过一遍就能接手。遇到这个问题的那位用户跑了 spec 流程，在产出上看到了 `needs-triage`，结果他们的 AFK 运行器忽略了所有东西。`triage` 是从外部进来的工作的入口(on-ramp)。spec 流程是你自己发起的工作的车道。两者在 `ready-for-agent` 汇合，在此之前不交汇。

**既然已经有了 `to-spec` → `to-tickets` → `implement` 流程，`triage` 还有用吗？**
只在你有外来工作时有用。`triage` 比那个流程更早，做的是另一件事：它处理别人提交的报告。如果你 tracker 里的所有东西都来自你自己的规划，你很少会用到它。如果你维护着任何公开的东西，或者你的团队会给你提 bug，那它就是这类工作开始的地方。主要用途是接收外部贡献者 issue 的开源仓库。

**agent 试图打上 `ready-for-agent`，`gh` 却说这个标签不存在。**
这是一个已知的未解决 bug（[#616](https://github.com/mattpocock/skills/issues/616)）。`setup-matt-pocock-skills` 把标签词汇写进 `docs/agents/triage-labels.md`，但不会在你的 tracker 里创建这些标签。自己用 `gh label create` 或 tracker 的 UI 把五个状态标签和两个类别标签创建一次，错误就没了。那个 issue 链接了一个社区修复 branch，但还没有被 merge。

**五个状态不够用。那 blocked、deferred 或 implemented 呢？**
这是这个 skill 上被提交最多的缺口。它有三种形式：

- 一个已完整说明、但要等另一个 issue 关闭的 issue（[#139](https://github.com/mattpocock/skills/issues/139)）。报告者说在这种情况下 `ready-for-agent`「技术上没错」但有误导性，于是 agent 接手后就卡住了。
- 计划要做、但在等某个触发条件，所以暂时还不可执行的未来工作（[#297](https://github.com/mattpocock/skills/issues/297)）。
- 一个表示「已实现，等待验证」的终结状态。没有它，AFK 运行器可能会把已完成的 ticket 再次排进队列。

blocked 这种情况已被认可是真实存在的，但名字还没定（`blocked` 还是 `paused`）。这些都还没有发布。作为变通办法，人们会在类别旁边加一个仓库本地的额外标签。这样状态槽里放的是准确的值，但 skill 并不知道这个额外标签。有一个社区 fork 走得更远，加了 `needs-slicing`、`tracking` 和工作量标签。这样可行，但它属于那个 fork，不属于这个 skill。

**它和 `/diagnosing-bugs` 有什么不同？**
这里的核实步骤是有意做得很浅的。它回答「这是不是真的，大概在哪里」，不去找根因。如果一个 bug 按报告者的步骤几分钟内复现不了，就用 `needs-info`，或者如果你想现在就调查，就用 [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs)。目前两个 skill 的文本都没有提到对方。有用户报告了这个缺口，至今仍未解决。

**我能把它指向整个 backlog，让它自己跑吗？**
可以这么要求，但要留意它读了什么。「显示需要关注的东西」那一轮是一个用于*挑选*的廉价列表。你挑一个 issue，然后 `triage` 才会收集那个 issue 的完整[上下文](https://www.aihero.dev/ai-coding-dictionary/context)。如果你一次对二十个 issue 运行它，agent 可能会把那个廉价列表当作唯一的证据，而且不告诉你。这个列表返回 issue 正文，但不返回评论。有位用户正好遇到了这种情况：有三个 issue 已经有一条评论写着「已经修好了，建议关闭」，结果三个都被写了新的 agent 简报。做批量处理时，要明确说明它必须读每个 issue 的评论。

**它能用于 Linear，或者 GitHub Issues 以外的东西吗？**
可以。tracker 是配置，不是硬编码的假设。人们在 Linear（通过 `linear` CLI）、GitLab 和 `.scratch/` 下的普通 markdown 文件上运行它。一种常见的分工是：issue 和规划放在 Linear，代码和 PR 放在 GitHub。这样说「issue tracker」的 skill 映射到 Linear，说「PR」的 skill 映射到 GitHub。本地 markdown tracker 有一个未解决的模板 bug：生成的文件可能包含两遍验收标准，一遍在顶层，一遍在 agent 简报里（[#200](https://github.com/mattpocock/skills/issues/200)）。

## 起作用的标志

- 它处理过的每个条目最终都恰好有一个类别角色和一个状态角色，从不为零，也从不出现两个相互冲突的状态。
- 它给你一个附带理由的建议，然后停下。它不会自己改完标签就继续往下走。
- 在任何东西进入 `ready-for-agent` 之前，它复现了 bug，或者 checkout 并运行了 PR。
- 它写的简报说的是类型和行为，不包含文件路径和行号。
- 当一个你六个月前拒绝过的请求又回来时，它会告诉你并引用旧的理由，而不是再分诊一遍。
- 它发布的每条评论都以 `> *This was generated by AI during triage.*` 开头。

## 在体系中的位置

`triage` 是一个**入口**(on-ramp)，不是主链路中的一步。主流程从你自己的想法开始（盘问、spec、ticket、实现、review）。`triage` 是为别人送来的工作准备的平行车道。两条车道终点相同：一个打上 `ready-for-agent` 标签、附有简报的 issue。[implement](https://aihero.dev/skills-implement) 接手它的方式，和接手一个来自 [to-tickets](https://aihero.dev/skills-to-tickets) 的 ticket 完全一样。当一个请求在 `triage` 能写简报之前还需要更多细节时，`triage` 会同时运行 [grilling](https://aihero.dev/skills-grilling) 和 [domain-modeling](https://aihero.dev/skills-domain-modeling)，一次一轮问题，这样你每做出一个决定，它就把决定记录到 `GLOSSARY.md` 和 ADR 里。当你不确定自己在哪条车道上时，[ask-matt](https://aihero.dev/skills-ask-matt) 会为你指路。
