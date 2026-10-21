## 它做什么

`writing-for-agents` 是写给 agent 看的文档的参考：一个 skill、一份 `AGENTS.md` 或 `CLAUDE.md`、一份 [spec](https://www.aihero.dev/ai-coding-dictionary/spec)、一段运行时 prompt、一份 README，任何 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 会读的文档。格式各异，但写法不变。同样几根杠杆让每一种都变得可预测，于是 agent 每次运行都遵循同一个*过程*（产出不必相同）。

它的默认修法是删除，不是解释。让一个 agent 为另一个 agent 写指令，它会把大部分字花在解释[模型](https://www.aihero.dev/ai-coding-dictionary/model)已经知道的东西上。这样的每一行都是**空转**：消耗[上下文](https://www.aihero.dev/ai-coding-dictionary/context)，却不改变任何行为。这份参考帮你找到它们，所以它对手里已有的文档和对一个空文件一样有用。

它在 v1.1 之前叫 `writing-great-skills`。新名字更贴合它一直以来的样子。它几乎没有任何内容是 skill 专用的。skill 专有的机制（frontmatter、模型自动调用还是用户手动调用的选择、路由器 skill）放在一份链接过去的 `SKILL-MECHANICS.md` 里，只有当眼前的文档确实是一个 skill 时才去读。

## 什么时候用

输入 `/writing-for-agents`，或者在任务匹配时由 agent 自动调用：你正在创建或修改 skill，或者改动 `AGENTS.md` 或 `CLAUDE.md`，就是匹配。

agent 会读的其他一切文档，手动用它：你的文档、spec 和 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket)、系统 prompt 和 [AFK](https://www.aihero.dev/ai-coding-dictionary/afk) prompt。判断标准只有一个问题：agent 会读它吗？agent 怎么拿到这份文档不重要：一个指针点名它，一个人粘贴它，或者它就在仓库里。想知道一个代码库里有什么，用 [grill-with-docs](https://aihero.dev/skills-grill-with-docs)。这份参考管的是文档怎么读，不是它知道什么。

## 两种负担

中心思想是每一份文档和每一个指针都在花的两笔预算：

- **上下文负担**：常驻材料在 agent 窗口上的成本：`AGENTS.md` 里的一行、一段 skill 描述，任何每一[轮](https://www.aihero.dev/ai-coding-dictionary/turn)都坐在上下文里、不论是否触发的东西。
- **认知负担**：你记住哪些文档存在、各自什么时候用的成本。你就是索引。不要试图把这笔成本压到最低，因为它是人的能动性的价格。

一旦用这两种负担思考，大多数写作决策（拆还是不拆、内联还是披露、指过去还是塞过去）就都变成了同一笔交易在不同地方的下单。

## 杠杆

- **[上下文指针](https://www.aihero.dev/ai-coding-dictionary/context-pointer)**（context pointer）：持在上下文里的那段参照，它点名上下文之外的材料，并编码什么时候去取。一段 skill 描述和一行点名某文档的 `AGENTS.md` 是同一个东西。决定 agent 跟随它的可靠程度的，是指针的*措辞*，不是它的目标。
- **信息层级**：从文件内的步骤，到文件内的参考，再到指针背后的披露式参考，这样一架梯子。**[渐进披露](https://www.aihero.dev/ai-coding-dictionary/progressive-disclosure)**（progressive disclosure）就是把材料沿这架梯子往下搬，让顶层保持好读。
- **完成标准**：每一步的完成条件有多清晰、多苛刻，以及这种苛刻引发的**跑腿**。它们是对**过早宣布完成**的防御。
- **核心词**：模型预训练里已经有的一个紧凑概念（*tight*、*red*、*tracer bullet*），agent 运行文档时用它思考。它在两处起作用：在正文里引导执行，在指针里触发调用。
- **修剪**：单一事实来源、相关性，以及逐句套用的空转测试，针对**重复**、**沉积**和**蔓延**。

## 常见问题

**`/writing-great-skills` 去哪了？**
就是这个 skill，在 v1.1 改了名。早在改名之前，用户就把它用在 `AGENTS.md`、文档、spec、ticket 和运行时 prompt 上。结构、核心词和修剪适用于 agent 会读的任何文本。没有别名。用新名字重新安装。

**「为 agent 写作」：所以是 agent 来写？**
正好反过来。你是作者；agent 是读者。这正是它难的地方。你为一个已经读过一切东西的读者写作，所以解释是浪费，精确才是全部工作。

**我不能直接让 agent 替我写吗？**
可以，它会产出一篇啰嗦的东西。没人管着的时候，模型会解释它已经知道的东西，也不会自己去套空转测试、去找核心词。用这份参考去审那份草稿。它的大部分价值来自这一遍审查。

**我让 agent 精简一份文档，它把功能也剪掉了。**
被要求「streamline」的 agent 会为长度优化，因为长度是它看得见的东西。空转测试检查的是行为，不是文风：删掉那一行，问 agent 的行为变没变。一句话没过测试，就整句删掉，而不是从里面抠词；对它有分歧，就跑一遍文档来裁决，不要靠争论。

**我怎么知道什么时候算完？**
当它能用了，而且你再也找不到重复、沉积或空转的时候。没有自动化的评估。你靠亲手运行文档、用失败模式的词汇来诊断问题。当一份文档行为不端，同一套词汇也帮你修：先点名失败模式，再修它。

**这个该放进 `CLAUDE.md` 还是别的地方？**
问自己想付哪一种负担。`CLAUDE.md` 无条件地加载进每个[会话](https://www.aihero.dev/ai-coding-dictionary/session)。指针背后的材料在触发之前，只花指针自己那一行的成本。十次会话里才用上一回的东西，在另外九次里都在付上下文负担。

**换新模型要重写我的文档吗？**
多数时候不用，而且过拟合到一个模型有它自己的问题。为新模型做更新，通常又是一次空转清理，而不是重写。

**我的 skill 只在我最初照着搭它的那个任务上有效。**
常见做法（先把活干一遍，再让 agent 把它写成 skill）对那一次运行贴得太紧，例子也变得太具体。把那次运行留作证据，然后有意地泛化：剥掉只属于那个仓库、那些文件的东西，为这一类任务而写。

**英语不是我的母语。我会失去核心词的优势吗？**
不会。找到那个用最少的 [token](https://www.aihero.dev/ai-coding-dictionary/token) 装下最多行为的词，正是这份参考替你干的活。

## 起作用的标志

- 文档越改越好，也越改越短，而且剩下之少让你意外。
- 你能指着一个核心词，看到它在不止一处改变了 agent 的行为。
- 没有任何东西以任何形式被说第二遍。重复是一份文档从未被测试过的最可靠信号。
- 只有一条分支需要的参考材料放在指针背后，而不是放在主文件里。

## 在体系中的位置

这是一份随时可用的独立参考。它适用于整套体系，不限于某一个 skill。这里的每个 skill 都是用它写成的，而且其他 skill 产出的文档（`GLOSSARY.md` 和它的 ADR、spec、ticket），一旦要有 agent 去读，也归它管。唯一直接调用它的是 [retro](https://aihero.dev/skills-retro)，它在提议任何引导文件或 skill 之前先加载它。拿不准哪个 skill 或流程适合一项任务时，[ask-matt](https://aihero.dev/skills-ask-matt) 会在整套体系里为你指路。
