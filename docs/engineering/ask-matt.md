## 它做什么

`ask-matt` 是这个仓库所有 skill 之上的路由器。你描述自己所处的情况（一个不知如何下手的想法、一堆涌进来的 bug 报告、一个已经拖得很长的[会话](https://www.aihero.dev/ai-coding-dictionary/session)），它告诉你适合的 skill 或 skill 序列，以及这个序列里哪些地方需要人来做决定。

它只推荐，然后停下。它不盘问、不写 [spec](https://www.aihero.dev/ai-coding-dictionary/spec)、不打开文件，也不替你触发它刚点名的 skill；你拿到的是下一步该输入什么，由你自己来输入。它还是一张手写的地图，覆盖的是这个仓库里的 skill，而不是扫描你装了什么，所以它不会把你路由到你自己写的或其他作者的 skill 上。

## 什么时候用

输入 `/ask-matt` 调用它，agent 不会自己去用它。

| 你的情况 | 路由器给你什么 |
| --- | --- |
| 有个想法，但不知道从哪开始 | 主流程(main flow)的起点，以及这次构建是否小到可以跳过 spec |
| 别人提来的 bug 和需求 | [triage](https://aihero.dev/skills-triage) 这个入口(on-ramp)，以及为什么你自己生成的 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) 不该走它 |
| 两个看起来可以互换的 skill | 两者的分界线，通常是一个具体的检验，而不是口味问题。[grill-me](https://aihero.dev/skills-grill-me) 还是 [grill-with-docs](https://aihero.dev/skills-grill-with-docs)，取决于你是否在一个工作目录里；[grill-with-docs](https://aihero.dev/skills-grill-with-docs) 还是 [wayfinder](https://aihero.dev/skills-wayfinder)，取决于这件事能否在一个会话内完成 |
| 会话很长，要决定怎么处理[上下文](https://www.aihero.dev/ai-coding-dictionary/context) | 阶段边界上五个选项的有序决策树 |
| 你已经选好了某个 skill | 没什么用。直接调用那个 skill。 |

## 前置条件

路由器只点名 skill，不负责安装。它指向的每个 skill 都得已经装好，推荐才能落地；而且它只认识这个仓库里被推广的 skill。

依赖 issue tracker 的路线（triage、`to-spec`、`to-tickets`、`implement`）假定 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 已经在仓库里配置好了 issue tracker。即使还没配置，路由器照样会推荐它们。

## 是流程，不是单个 skill

这个 skill 的核心词是**流程**(flow)：一条*贯穿*多个 skill 的路径，而不是单个 skill。你说出自己的情况，路由器就把你放到某条流程的某一步上。这和「这是匹配你关键词的那个 skill」是两种不同的回答。路线一共有五类，skill 本身有完整描述：

- **主流程**，从想法到上线。盘问、spec、ticket、实现（一次一个 ticket，或者用 [implement-spec](https://aihero.dev/skills-implement-spec) 并行跑完整个任务图）、评审，然后是[复盘](https://aihero.dev/skills-retro)，把这次构建学到的东西反馈回 agent 的环境。它有两个分支。一个是原型支路，用于需要可运行代码才能定论的问题。另一个是拆分 spec 和 ticket，只有当构建跨越不止一个会话时才值得付出这个成本。
- **入口**，针对那些会产生工作、随后汇入主流程的情况：涌入的 bug 报告、某个东西坏了，或者一件事太模糊、太大，一个会话装不下。
- **代码库健康**，属于维护而非功能开发。[improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) 巡查代码寻找加深机会，找到的每一个都作为一个想法重新进入主流程。
- **独立工具**，不在任何流程上，单独使用：原型、问卷、研究。
- **底层的词汇层**，当问题出在用词而不是流程上时，其他 skill 会引入的两份参考。

## 阶段边界

这个 skill 的另一个关键概念是**阶段边界**(phase boundary)。阶段是会话内部的一段工作（[盘问](https://www.aihero.dev/ai-coding-dictionary/grilling)、实现、QA），两个阶段之间的边界是唯一该问「这些上下文怎么处理？」的地方。阶段中途没什么可决定的：要么继续，要么把剩下的工作拆给[子 agent](https://www.aihero.dev/ai-coding-dictionary/subagent)。

| 选项 | 什么时候选 |
| --- | --- |
| **继续** | 下一阶段需要原封不动地用到这一阶段的内容，或者你还在[智能区间](https://www.aihero.dev/ai-coding-dictionary/smart-zone)内。这是唯一能让会话保持为[一手资料](https://www.aihero.dev/ai-coding-dictionary/primary-source)的做法，所以先排除它 |
| **`/clear`** | 之前的一切都可以丢掉。最便宜的选项，判断错了也无法撤销 |
| **[handoff](https://aihero.dev/skills-handoff)** | 有东西需要带走：换一个新的 [harness](https://www.aihero.dev/ai-coding-dictionary/harness)、换目录、交给同事、阶段中途分出一个旁支任务 |
| **子 agent** | 任务范围收得足够紧，可以在你[离开键盘](https://www.aihero.dev/ai-coding-dictionary/afk)时运行 |
| **`/compact`** | 以上都不适用。它是默认选项，决策树经常走到这里结束 |

其中两个经常被用错，所以路由器给的是顺序，而不只是清单。`/handoff` 看起来像是在上下文窗口之间切换的通用办法，其实不是，它只给你可移植性。`/compact` 是决策树里的最后一个选项而不是第一个，因为它上面的四个选项每一个都更便宜或更精确。

## 常见问题

**难道没有一张按正确顺序排好的 skill 列表吗？**

一直有人要求在 README 里放一张。这个 skill 就是那张列表。一张静态表会写成 `wayfinder → to-spec → to-tickets → implement → code-review → retro`，而对大多数情况来说都是错的。重要的是分支：有没有代码库，构建是否跨会话，聊天能不能解决这个问题。代价是路由器靠手工维护，会落后于仓库。`/grilling` 上线很久之后路由器才提到它。

**它说一半的 skill 没装。**

这是已知 bug，还没修。路由器经过的大多数 skill 都设置了 `disable-model-invocation: true`，这意味着 harness 不会把它们放进注入 agent 上下文的 skill 列表。agent 把这个列表当成完整清单，于是报告它们缺失。在一次被报告的会话里，它宣布整个 spec 加 ticket 流程都不存在，转而路由到光秃秃的 `/grilling` 和 `/tdd`。plugin 的二十七个 skill 里有十六个带这个标志，所以这是常态而非边缘情况。它们其实装了。照样输入斜杠命令，或者查看 `.claude-plugin/plugin.json`，那里才是判断有什么的权威来源。

**它描述了某个 skill 的行为，但那个 skill 并不这么做。**

这也是真实的 bug，也没修。路由器根据自己给每个 skill 写的一行摘要来回答，而不是根据 skill 本身。一份详细报告在一次会话里记录了三处，其中包括仅凭「把讨论变成 spec」这句摘要就建议跳过 [to-spec](https://aihero.dev/skills-to-spec)。路由器从没打开过 `to-spec/SKILL.md`。每次都是用户反驳之后它才去核实，从不主动。那次跳过 `to-spec` 的代价是少了一次真正的接缝(seam)检查，产出的 ticket 低估了工作量。当路由器关于别的 skill 说了什么、而你要据此行动时，先让它打开那个 `SKILL.md`。地图完全没覆盖的问题也一样，比如要不要用 [plan mode](https://www.aihero.dev/ai-coding-dictionary/agent-mode)：那个答案是[模型](https://www.aihero.dev/ai-coding-dictionary/model)的推断，不是这里写下来的东西。

**为什么写成大段文字，而不是编号清单？**

这个抱怨有道理。有个未关闭的 issue 认为大部分路由是确定性的，叙述体让人难以扫读。没人拦着你要压缩版：说「直接给我顺序」就能拿到顺序。文字承载的是条件部分：分支、哪里需要人做决定、步骤之间在哪里清空或压缩上下文。扁平的清单恰恰丢掉了这些。

**它能在我自己的 skill 或其他作者的 skill 上做路由吗？**

不能。已经有三个独立提案要求做一个能读取本地 `skills/` 目录、根据已安装内容推荐的路由器。`ask-matt` 不是那个东西。它是一套 skill 的地图，手工维护，对你自己写的或从别处装的 skill 一无所知。

**它让我去改某个 SKILL.md。**

这个建议往往没错，但改动很少能保留下来。有人问它怎样让 [implement](https://aihero.dev/skills-implement) 关闭 ticket，被告知在 skill 里加一行，随即就发现了问题。`npx skills update` 会覆盖这个文件，而 plugin 安装是只读的。把长期行为写进你自己的 `CLAUDE.md` 或 `AGENTS.md`，或者在调用时说明。写在 prompt 里的改动不受更新影响。有人就是这样把流程指向 Linear 而不是 GitHub，或者让它找出哪些未关闭的 ticket 可以并行。

**它提到了一个我没有的 skill，或者漏掉了一个我有的。**

先去 changelog 查是否改了名，再下结论说它没了。`writing-great-skills` 改名为 [writing-for-agents](https://aihero.dev/skills-writing-for-agents)，没有别名；`to-prd` 改成了 [to-spec](https://aihero.dev/skills-to-spec)；`pathfinder` 改成了 [wayfinder](https://aihero.dev/skills-wayfinder)。有四个 skill 被直接退役，并入了吸收它们的 skill：`ubiquitous-language`、`design-an-interface`、`qa` 和 `request-refactor-plan`。如果它漏掉了你有的 skill，那就是上面说的路由器自身的滞后。

## 起作用的标志

- 它最后告诉你该输入什么，然后就停下，而不是自己动手开始干活。
- 它给的路线会提到在哪里清空或压缩上下文、哪里需要你来评审，而不只是一串 skill 名称。
- 两个 skill 相近时，它会说该用哪个，以及为什么另一个不适合你。
- 它对别的 skill 行为的任何断言，在 trace 里都能看到它去读了那个 skill 的 `SKILL.md`。
- 你能在它给的回答里认出自己的真实情况，而不是一个最接近的通用场景。

## 在体系中的位置

`ask-matt` 是凌驾于整套 skill 之上的**独立路由器**。它从来不是链路中的一步。它指向每一条链路，其他文档页也都链接回它，这样谁都不用重画这张图。从这里出发，你最常落到 [grill-with-docs](https://aihero.dev/skills-grill-with-docs)（主流程的起点），或者 [triage](https://aihero.dev/skills-triage)（针对别人送来的工作而不是你自己发起的工作的入口）。

对于它所描述的 skill，它是[二手资料](https://www.aihero.dev/ai-coding-dictionary/secondary-source)。路由器和某个 `SKILL.md` 说法不一致时，以 `SKILL.md` 为准。
