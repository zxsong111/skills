## 它做什么

`research` 通过阅读掌握答案的那些来源来回答一个问题，然后在仓库里留下一份带引用的 Markdown 文件。它只依据**[一手资料](https://www.aihero.dev/ai-coding-dictionary/primary-source)(primary source)**工作：官方文档、源代码、规范、第一方 API。它会把每一条论断追溯到真正掌握它的来源，所以只要某个 API 自己的文档能访问到，它就不会去转述一篇博客对这个 API 的描述。

它不在对话里回答你。产出是一个文件，写在仓库本来就存放这类笔记的地方，每条论断都附一个链接。你得到的是一份可以回应、可以交给另一个 agent、也可以扔掉的文档，而不是一个[会话](https://www.aihero.dev/ai-coding-dictionary/session)结束就消失的回答。

## 什么时候用

输入 `/research`，或者在任务变成需要跑腿阅读的活时由 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 自动调用。

当下一步是从工作目录之外*查清某件事*时用它（某个第三方 API 的行为、某份规范怎么说、某个版本相关的说法是否成立），而你又不想让自己的对话卡在阅读上。你需要什么，决定了用哪个 skill：

| 你需要的 | 用这个 |
| --- | --- |
| 一个决定正在等待的外部事实 | `research` |
| 通过访谈*和你一起*做出的决定 | [grilling](https://aihero.dev/skills-grilling) |
| 一个持久的架构决策，写进 `GLOSSARY.md` 和 ADR | [grill-with-docs](https://aihero.dev/skills-grill-with-docs) |
| 弄清某个方案在你的代码库里是否可行 | [prototype](https://aihero.dev/skills-prototype) |
| 一个大到一个会话装不下的计划 | [wayfinder](https://aihero.dev/skills-wayfinder) |

`research` 和 `grill-with-docs` 的分界线在于**产出的保质期**。research 产出的是短命的事实，比如这个库本周的认证机制是怎么做的。ADR 记录的是你要长期保留的决策。如果你产出的是一个决策而不是一个事实，那你是在[盘问](https://www.aihero.dev/ai-coding-dictionary/grilling)，不是在做调研。

## 委派出去的跑腿活

阅读由一个**后台 agent** 来做。它把每条论断追溯到一手资料、写出一份 Markdown 文件、然后回来汇报，这期间你可以继续干活。调研是你委派出去的跑腿活，不是外包出去的思考。你得到的是一份可以拿来盘问、规划或设计的文档，决定仍然由你来做。

没有任何东西阻止这个后台 agent 再派生一个它自己的后台 agent。这是这个 skill 记录最充分的问题。

文件放在哪里由仓库决定，而不是由 skill 决定。它遵循仓库里已有的笔记存放惯例。如果没有，它会挑一个合理的位置并告诉你在哪。每次运行只写一个文件。

## 常见问题

**它又派生了第二个 research agent。这是正常的吗？**

不是。这是一个尚未解决的 bug，[issue #530](https://github.com/mattpocock/skills/issues/530)。这个 skill 让调用方启动一个后台 agent，但没有限制 agent 的类型。于是调用方派生出一个 `general-purpose` agent，它拥有 `Agent` 工具和同样的指令，于是又照着做了一遍。有位报告者测得，一个调研任务在三次相互重叠的运行中大约花掉了 450k [token](https://www.aihero.dev/ai-coding-dictionary/token)，那个重复的运行在半小时后才结束，而且用户看不到它。在 Claude Code 之外也会出现这种情况，有用户确认在 Codex 配合 GPT-5.6-sol 时也有同样的嵌套。目前没有发布修复。有用户在自己安装的副本里加了一行，告诉已经是 [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent) 的 agent 自己完成工作。这有帮助，但它只是一条指令，不是结构上的修复。调用这个 skill 之后，留意你的后台任务列表，把重复的那个停掉。

相反的失败也会发生。如果你自己的全局指令禁止 agent 再次委派工作，后台 agent 就会拒绝这个任务，而这个 skill 什么也不做，也不告诉你。

**文件应该放在哪里，要不要 commit？**

这个 skill 把文件放在仓库已有的笔记存放位置，除此之外没有别的主张。社区的看法基本已有定论：保留 ADR，不保留调研文件。Discord 上关于这个问题的一个讨论说得最清楚：「ADR 要留。其他的东西做完就归档或删掉。否则它会变成工作残渣，一旦你已经偏离了当初的 spec 或调研，它还会污染以后对仓库的读取。」调研文件记录的是它写成那天的事实，所以过时的调研文件比没有还糟。总的来说，这些文件不属于 git，而且也没有一个标准的存放地。人们会改用 Obsidian、一个单独的知识库仓库或者 issue tracker。

**什么算「高可信」的一手资料，由谁来判断？**

由[模型](https://www.aihero.dev/ai-coding-dictionary/model)判断。这个 skill 列出了符合条件的来源*类型*（官方文档、源代码、规范、第一方 API），但没有白名单、没有域名限制，也没有核验步骤。这是这个 skill 最初被提出时最响亮的反对意见，至今也没有人公开回应过：「让五个调研 subagent 去读垃圾，只会让你更快得到五个自信满满的错误答案。你怎么把关什么算高可信来源？」你唯一的保护是每条论断上的引用。随手点开两三个。如果它们指向的是对那个东西的总结而不是那个东西本身，这次运行就失败了。

**之后的会话会复用之前运行的发现吗？**

不会。没有任何东西会自动加载过去的调研文件。文件一直留在仓库里，直到有人或某个 skill 指向它。这是对这个设计最早也最有力的质疑：「价值在于这份 markdown 变成 agent 以后会重新读取的上下文，而不在于抓取本身。一个写完就没人再看的死文件，不过是一次花哨的搜索。」已发布的 skill 没有解决这个问题。实际上，只有当你自己把文件喂给下一步时它才有用：把它附到一份 spec 上，引用到一次盘问会话里，或者让一个 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) 指向它。

**为什么不直接让 agent 去读文档？**

可以，这个 skill 取代的正是一个说的就是这件事的两行 prompt。这个 skill 给了你两样那个 prompt 给不了的东西。它在后台运行，所以你会话的[上下文](https://www.aihero.dev/ai-coding-dictionary/context)保持干净。而且一手资料的约束和带引用的文件产出每次都一样，不取决于你 prompt 怎么措辞。与 [harness](https://www.aihero.dev/ai-coding-dictionary/harness) 自带的深度调研模式相比，区别在于文件和一手资料规则，而不在于搜索本身。如果在一个小问题上两行 prompt 就能拿到你要的东西，那就用两行 prompt。

**它什么时候停止阅读？**

这个 skill 没有停止条件。这表现为两种看似相反、其实同源的抱怨：agent 钻得太深，或者 agent 广泛覆盖了一个主题却漏掉了真正要紧的那个细节。有位实践者是这样说的：「深度调研类 skill 有时候钻得有点太深了。而让 agent 去调研，结果通常是漏掉关键细节。」范围得由你来定。一个窄而可回答的问题（一个 API、一种行为、一条版本相关的说法）得到的结果，远好于「调研一下 X」。

**`/wayfinder` 创建了 research ticket。这些需要我自己解决吗？**

不需要，现在它会替你触发。在 v1.1 之后尚未发布的改动里，一次绘制地图的会话会为每个 research ticket 派生一个 `/research` subagent，并行运行。每个 subagent 把发现记录在一个一次性的 `research/<name>` branch 上，并从 ticket 留一个指向它的[上下文指针](https://www.aihero.dev/ai-coding-dictionary/context-pointer)。research ticket 是 wayfinder「一个会话只处理一个 ticket」规则的唯一例外，因为它们是 [AFK](https://www.aihero.dev/ai-coding-dictionary/afk) 的：没有任何东西需要等你。一个已知问题：之后删掉那个 branch，ticket 里的上下文指针就会失效。

## 起作用的标志

- 你自己的会话一直在推进。如果你坐在那里看着它读，说明委派没有发生。
- 恰好出现一个新的后台任务。如果出现第二个名字几乎一样的，那就是嵌套 bug。
- 出现一个新的 Markdown 文件，位于仓库本来存放笔记的文件夹里，而且 agent 告诉了你路径。
- 里面每条论断都带链接，随机点开两个，落到的是官方文档、规范或者源文件本身，而不是别人对它的转述。
- 只看这个文件，你就能做出之前卡住的那个决定，不必再回去翻来源。

## 在体系中的位置

`research` 是一个随时可用的独立工具。它为那些思考类 skill 提供输入，但不是构建链路中的一步。是你把它的文件*带进*流程里。[grilling](https://aihero.dev/skills-grilling) 和 [grill-with-docs](https://aihero.dev/skills-grill-with-docs) 在已经掌握事实时能问出更尖锐的问题，[to-spec](https://aihero.dev/skills-to-spec) 也可以基于它做综合。[wayfinder](https://aihero.dev/skills-wayfinder) 是唯一直接调用它的 skill：它用一个 `/research` subagent 来解决地图上的每个 research ticket。完整的地图见 [ask-matt](https://aihero.dev/skills-ask-matt)。
