## 它做什么

`retro` 回顾一次编码[会话](https://www.aihero.dev/ai-coding-dictionary/session)，提出对 agent **[环境](https://www.aihero.dev/ai-coding-dictionary/environment)(environment)**的改进建议，让下一次运行更顺利。它读取会话自己的记录（默认是当前会话，也可以是你在会话日志里指定的某一个），找出 agent 吃力的那些时刻，然后给你一份候选修复清单，最严重的排在最前面。

它改的是环境，不是代码。拿 agent 交付出去的 bug、它花了二十次[工具调用](https://www.aihero.dev/ai-coding-dictionary/tool-call)才找到的文件、reviewer 漏掉的规则来说，`retro` 都不会直接修。它问的是仓库里有什么让这些事得以发生，然后提出能在下次阻止它们的检查、指针或规范。它也只负责提出。在你选中某个候选之前，什么都不会改。

## 什么时候用

输入 `/retro` 调用它，agent 不会自己去用它。

在一次比预期更艰难的会话结束时用它。比如 agent 找某个东西找了太久，犯了一个本可以由工具发现的错误，或者需要一些它拿不到的信息。顺利的会话没什么可学的，发现都来自那些艰难的会话。如果你想对会话产出的代码下一个结论，请改用 [code-review](https://aihero.dev/skills-code-review)。

## 发现落到哪里

每个候选属于一个类别，类别决定修复放在哪里：

| 会话中出了什么问题 | 用什么修复 |
| --- | --- |
| agent 花了很长时间才找到一个文件或事实 | 从它本来就会读的文件里加一个**导航指针**(navigation pointer) |
| 它犯了一个本可以由工具发现的错误 | 一个**[自动化检查](https://www.aihero.dev/ai-coding-dictionary/automated-check)**：lint 规则、类型、测试、pre-commit hook、CI job |
| reviewer 漏掉了一个判断性的错误 | 在 `CODING_STANDARDS.md` 里为 reviewer agent 加一条规则 |
| `AGENTS.md` 或 `CLAUDE.md` 太大 | 把其中的引导内容挪出去，放进规范或检查 |
| 某次工具调用相对于它的返回结果代价太高 | 精简这个工具，或者换掉它 |
| 某个引导文件里塞满了不起任何作用的行 | 删掉这些**空操作**(no-op) |
| agent 需要一些它够不着的信息 | 扩大它的访问范围：把 dev server 日志 tee 到一个文件，给某个服务的只读权限 |

核心思想是：规范属于 **reviewer**，而不是实现者。实现的 agent 上下文压力最大，因为它要探索、写代码、调试失败。负责 review 的 agent 只拿到一个 diff，别无其他。所以新规则要放在有余地去应用它的地方，也就是 review。它永远不放进 [AGENTS.md](https://www.aihero.dev/ai-coding-dictionary/agents-md)，因为那个文件不管相关与否都会加载进每个会话的[上下文窗口](https://www.aihero.dev/ai-coding-dictionary/context-window)。

在写任何规则之前，`retro` 会先给违规分类。**机械性的**违规（被禁用的 API、import 的形式、文件位置规则）用一个确定性的检查来处理，因为检查会失败，而规范文件里的一句话不会。只有真正的判断性问题，也就是没有 linter 能强制执行的那些，才写成文字。如果仓库完全没有防护栏(guardrail)（没有 pre-commit hook，也没有运行 lint、类型检查和测试的 CI job），`retro` 会把这本身作为一条发现报告出来。

## 常见问题

**它是自己写 lint 规则，还是等我同意？能不能把它接成每次会话后自动运行？**

它会等。`retro` 只负责提出。在你选中某个候选之前什么都不会改，所以它不会手动改任何东西，也不会自动安装任何 hook。这是有意为之。有位用户正是在「被那些拦下了好改动的自动 hook 坑过」之后提出了这个要求。决定什么值得一个永久的检查需要判断力，所以这个 skill 保持[人在回路](https://www.aihero.dev/ai-coding-dictionary/human-in-the-loop)(human-in-the-loop)，并且由用户手动调用。确实有些用户在每次实现运行后都跑它。但顺利的会话没什么可学的，所以每次会话后都跑，产出的大多是没人需要的规则。它没有 dry-run 模式。提出的检查和其他代码一样是代码，所以在让它拦截 merge 之前，先在仓库上试一试。

**这样 lint 规则不会无限堆积吗？它会建议删掉某条吗？**

部分会，而这是它最薄弱的地方。它能删掉文字：引导文件里的空操作，以及 `AGENTS.md` 或 `CLAUDE.md` 里本该放进规范或检查的引导内容。文件很大时，它会把这些标记为待删除。它是对照自己读到的那一次会话来判断的，所以把每一条都当作删除测试的候选，而不是定论。它不会审查它上个月提出的 lint 规则、hook 或 CI job。它只看得到一次会话，所以没法告诉你某条规则现在触发得太频繁，或者它背后的那个 bug 已经不存在了。检查仍然得由你自己修剪。一条在好代码上不停触发的规则，就是该删掉它的信号。

**它会不会为了填满类别而编造泛泛的建议？**

这是对它最有力的批评。有位用户发现，「一旦工作完成，AI 往往会忘掉会话中途的那些挣扎，然后编造泛泛的建议来满足复盘的类别」。每个候选都必须来自会话自己的记录，所以建议是针对那次会话的。这有代价也有好处。它很少编造无关的东西，但可能会过分看重这一次会话碰巧涉及的内容。追溯不到具体时刻的候选，丢掉就是。严重程度的排序也当作初稿看待，因为一个安静但代价高的错误，排名可能低于一个吵闹但代价低的错误。

**我的会话很长。现在就跑，还是重新开一个？**

默认它回顾当前会话。这是最好的情况，因为那些挣扎还在上下文窗口里。如果会话已经走出了[智能区间](https://www.aihero.dev/ai-coding-dictionary/smart-zone)(smart zone)，就[清空](https://www.aihero.dev/ai-coding-dictionary/clearing)它，然后在一个新会话里运行 `/retro`，指向会话日志里的上一个会话。

**agent 一直犯同一个错误。我应该往 `CLAUDE.md` 里加一行吗？**

通常不应该，而且 `retro` 对这件事的反对比对任何事都强烈。`CLAUDE.md` 里的一行会加载进每个会话，削弱文件里其他所有内容的分量，还会随着代码变化而过时。如果错误是机械性的，修复方法是一个会失败的检查。如果是判断性的，就放进 reviewer 读的编码规范里。`AGENTS.md` 和 `CLAUDE.md` 是用来放导航指针的，其他东西基本不放。出于同样的原因，`retro` 不是一个[记忆系统](https://www.aihero.dev/ai-coding-dictionary/memory-system)。它不存储发生过什么，而是改变环境，让这个错误不会再发生。

**我的配置里提到了 `CODING_STANDARDS.md`，但我没有这个文件。它从哪里来？**

没有哪个 skill 自带这个文件。当某次会话第一次发现一条给 reviewer 的判断性规则时，`retro` 会提议创建它。你接受之后，[code-review](https://aihero.dev/skills-code-review) 就会读它。你已经在维护的其他规范文档，比如 `CONTRIBUTING.md`，效果也一样。

**它和 `improve-codebase-architecture` 有什么不同？**

输入不同。[improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) 只需要代码，寻找的是代码结构上的改进。`retro` 需要一段会话历史，改进的是 agent 工作所在的环境，而不是代码。两个都要用，谁也替代不了谁。

## 起作用的标志

- 每个候选都能指回会话中的某个具体时刻，而不是一条泛泛的最佳实践。
- 重复出现的错误变成了会失败的检查，你的 `AGENTS.md` 随着时间变短，而不是变长。
- 如果某个检查早就存在只是没有接上，发现会是「把它接上」，而不是提议再造一个新的。
- 下一次处理同类任务的会话，能更快找到它需要的东西。

## 在体系中的位置

`retro` 是主链路的最后一步，你在这里复盘整条链路跑得怎么样：

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review → retro
```

在一次值得从中学习的构建之后运行它，可以在同一个会话里，也可以指向那次会话的日志。构建很顺利的话可以跳过。

- [code-review](https://aihero.dev/skills-code-review) 是 `retro` 最常调校的 reviewer agent。新的编码规范要放在它的 Standards 轴会去读的地方。
- [writing-for-agents](https://aihero.dev/skills-writing-for-agents) 为 `retro` 提出的每个引导文件和 skill 设定写作风格，`retro` 开始前会先加载它。

当你不确定当前情况需要哪个 skill 时，[ask-matt](https://aihero.dev/skills-ask-matt) 会在整套 skill 上为你指路。
