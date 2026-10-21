## 它做什么

`improve-codebase-architecture` 巡查代码库，寻找**加深机会**：那些浅模块（接口几乎和它所隐藏的东西一样复杂）有望变成深模块(deep module)的地方。它把这些机会整理成一份自包含的 HTML 报告，然后就你选中的那一个对你进行[盘问](https://www.aihero.dev/ai-coding-dictionary/grilling)。

它从不改代码。整个运行只产出一段对话和一个放在操作系统临时目录里的 HTML 文件。重构由你之后在另一个[会话](https://www.aihero.dev/ai-coding-dictionary/session)里、通过常规的构建流程去做。这使它成为一次巡查，而不是重构工具，所以你可以把它用在一个还没准备好动手的代码库上。

有两道过滤让报告不至于变成泛泛的清理建议。第一，每个候选都必须通过**删除测试**：如果删掉这个模块，它的复杂度是会收拢到一个更小的接口后面，还是会散落到各个调用方？只有前一种情况才会得到一张卡片。第二，除非你把它指向某个特定区域，它会先读最近的 commit 历史，把扫描集中在经常变动的路径上。在没人碰的代码上做加深，是一次永远收不回成本的重构。

## 什么时候用

输入 `/improve-codebase-architecture` 调用它，[agent](https://www.aihero.dev/ai-coding-dictionary/agent) 不会自己去用它。

它不是主构建循环中的一步。你定期运行它，为改进代码库排上更多的工作。大家在四种情况下用它：

| 情况 | 怎么用 |
| --- | --- |
| 日常维护 | 每隔几天跑一次，或者有空的时候跑，免得结构在功能开发之间逐渐腐化。 |
| 大型构建之前 | 把它指向 [spec](https://www.aihero.dev/ai-coding-dictionary/spec)，问「怎样让这次改动变得容易？」这是对它最有效的 prompt。 |
| 存量代码审计 | 在一个庞大、缺乏结构或者[凭感觉写出来](https://www.aihero.dev/ai-coding-dictionary/vibe-coding)的仓库上跑，看看它现在是什么状况。 |
| 遗留代码的测试工作 | 在对难以测试的代码写测试之前，用它找出缺失的接缝(seam)。 |

和兄弟 skill 容易混淆的地方：

- 要设计一个你已经选定的模块，用 [codebase-design](https://aihero.dev/skills-codebase-design)。这个 skill 负责找到要处理的模块，`codebase-design` 是你设计它的地方。
- 对于一整件一个会话装不下的事，用 [wayfinder](https://aihero.dev/skills-wayfinder)。
- 对于「这个具体的东西坏了」，用 [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs)。当真正的发现是没有合适的接缝来锁住 bug 时，它会把你送回这里。

## 前置条件

运行它什么都不需要。如果存在 `GLOSSARY.md` 或 `docs/adr/` 里的 ADR，它会读取它们，使用你领域里自己的名词。这样候选读起来就是「加深 Order 接收模块」，而不是「重构 FooBarHandler」。

它会写入两个地方。报告写到仓库之外的 `<tmpdir>/architecture-review-<timestamp>.html`。在盘问循环中，它会在 `GLOSSARY.md` 里新增或打磨术语，文件不存在时会创建它。它还会提议把被否决的候选记录成 ADR，这样以后的运行就不会再建议它。

## 深度，以及寻找深度的报告

这个 skill 建立在一个概念上：**深度**(depth)。深模块在一个小而稳定的接口背后放了大量行为。浅模块则通过一个几乎和底下代码一样宽的接口暴露自己的实现。报告寻找三种形式的浅：

- 仅仅为了可测试性而抽出来的纯函数，而真正的 bug 出在调用方如何使用它们（缺乏**局部性**(locality)）。
- 跨越自身**接缝**泄漏的模块。
- 不打开五个文件就无法理解的概念。

对每一种，它都会提出能修复它的加深方案。

每个候选是一张卡片，包含涉及的文件、摩擦点、一段通俗的解决方案、以**局部性**和**杠杆**(leverage)来衡量的收益、一张改动前后对比图，以及一个强度徽章。

| 徽章 | 对你意味着什么 |
| --- | --- |
| `Strong` | 删除测试明确通过，摩擦是真实的。认真对待这些。 |
| `Worth exploring` | 加深说得通，但回报取决于代码接下来往哪个方向走。 |
| `Speculative` | 为完整起见才列出来。大部分可以忽略。 |

报告以一条 **Top recommendation**（首选推荐）结尾，也就是它会最先做的那个候选。然后 skill 停下来，问你想深入哪个候选。到这时你还什么都没决定，也没有任何代码被改动。

## 选定之后会发生什么

你选定一个候选后，就会围绕它开始一次[盘问](https://aihero.dev/skills-grilling)会话。它涵盖约束条件、接缝后面放什么、哪些测试能保留下来，以及加深后的接口应该是什么样子。这次会话的产出是一个决定，而不是一个 diff。从这里开始走常规流程：把决定带进 [to-spec](https://aihero.dev/skills-to-spec)，然后是 [to-tickets](https://aihero.dev/skills-to-tickets)，再然后是 [implement](https://aihero.dev/skills-implement)。

## 常见问题

**它就一个想法盘问了我一个小时，而不是给我看选项。能关掉吗？**

能。调用时说明就行（「don't grill me, just show the report」）。这是对这个 skill 最常见的抱怨。有位用户本来很喜欢它，觉得它是「a convenient way to get a thorough analysis of improvements」，但加入盘问循环之后，觉得它「borderline unusable」。在他们的会话里，它只提出一个方案，然后问了「10's or 100's of questions」。设计本意是先出报告，只有在你选定的候选上才开始盘问。但能力较弱的[模型](https://www.aihero.dev/ai-coding-dictionary/model)会直接跳到针对它想到的第一个点子的盘问。那个讨论串里的结果因模型而异，差别很大。这是一个未关闭的 issue，skill 目前还没有成文的免盘问模式。

**报告打开后是没有样式的原始 HTML，也没有图。怎么回事？**

报告从 CDN 加载 Tailwind 和 Mermaid，所以打开时需要联网。如果有东西拦住了这些脚本，页面就会坏掉，而且不报任何错。在被报告的那个案例里，一个安全 hook 要求 SRI 哈希。agent 加上了哈希，但 CDN 给浏览器的字节和给计算哈希的 `curl` 的字节不一样，于是浏览器拦下了脚本。离线环境和受限环境也有同样的问题。agent 看不到这一点，因为它从不渲染页面。绕过办法是要求用内联 CSS 和手工绘制的 SVG 图，而不是 CDN 方案。这是一个未关闭的 issue。

**它给了我十二个候选。我是在同一个会话里逐个处理，还是开新会话？**

一个会话一个候选。如果在一段对话里处理好几个，[上下文窗口](https://www.aihero.dev/ai-coding-dictionary/context-window)会同时被报告、盘问、领域模型的修改和代码改动塞满。报告只是个临时文件，所以要带走的是候选，而不是文件。选一个，盘问它，把决定带进 `/to-spec`。把其余的变成 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket)，以后再分别处理。把选中的改进写进 spec，而不是直接去实现。大家经常问这个问题，而 skill 本身并没有记录相应的工作流。

**该怎么给它写 prompt？**

用你接下来要做的东西作为 prompt。如果有大型构建要来，把它指向 spec，问「怎样让这次改动变得容易？」不带 prompt 的运行会自己去找热点。用于日常维护没问题，但有了方向，报告才可以落地执行。

**它在大型遗留代码库上管用吗？**

部分管用。在缺乏一致结构的大型现有代码库上，它表现不错，也是任何一次性结构整顿之后推荐的维护工具。但项目已经失控的用户报告说它「helped a little but still doesn't seem to cut it」。有位维护八年老代码库的开发者报告说模型在原地兜圈子，而同一个 skill 在整洁的仓库上能产出清晰的图。针对这种情况，目前还没有专门的 `/refactor` skill。如果代码库没有共享的词汇，先跑 [grill-with-docs](https://aihero.dev/skills-grill-with-docs) 建立一套。这通常会让这个 skill 的产出好很多。

**它和 `/codebase-design` 有什么区别？**

`/codebase-design` 是一份参考，不是会话的驱动者。它提供词汇（模块、接口、深度、接缝、适配器、杠杆、局部性），这个 skill 使用这些词汇。如果你把 `/codebase-design` 当作任务交给一个新的 agent，它会以一种已知的方式失败。它没有自己的流程可循，于是 agent 自己编一个，重新探索代码，跑很长时间才问你第一个问题。运行这个 skill，让它去用那个。

**它会告诉我代码库没问题吗？**

很少，所以开始之前要清楚这一点。这个 skill 存在的目的就是输出发现，所以它倾向于产出候选，而不是得出「什么问题都没有」的结论。用强度徽章来校正这一点。如果一份报告里所有候选都是 `Speculative`，说明 skill 什么都没找到。

**它在 Codex 或其他 harness 里能用吗？**

部分能用。探索步骤直接点名了 Claude Code 的 `Agent` 工具和 `subagent_type=Explore`。没有这个工具的 [harness](https://www.aihero.dev/ai-coding-dictionary/harness) 可能会跳过并行探索，而不是改用它自己的等价物。skill 照样能跑，但扫描不那么彻底。有人提议改写成与 harness 无关的版本，但还没合并。

**在 TypeScript 里到底怎么实现深模块？**

skill 没有给出好答案。大家经常要求有一份 `TYPESCRIPT.md`，为这些原则给出具体的文件和模块布局，但它并不存在。skill 告诉你加深应该放在哪里、接缝后面放什么。把这些落实成包或目录结构，得你自己来。

## 起作用的标志

- 候选使用你领域里的概念，而不是编造的类名：「Order 接收模块」，而不是「FooBarHandler」。
- 候选位于你最近改过的文件里，而不是仓库里没人碰的角落。
- 运行期间没有任何代码被改动。唯一的新文件是临时目录里的 HTML 报告。
- 它在报告之后停下，问你想要哪个候选，不会自己继续往下走。
- 每张卡片都用局部性或杠杆来解释回报，并说明哪些测试会变简单，而不只是「这样更干净」。
- 当你出于长期有效的理由否决一个候选时，它会提议记录一份 ADR，这样下次运行就不会再建议它。

## 在体系中的位置

`improve-codebase-architecture` 属于**定期维护**。你每隔几天、在任何链路之外运行它，目的是排上工作，而不是去做这些工作。它的邻居：

- [codebase-design](https://aihero.dev/skills-codebase-design) 掌管每个候选都在用的「深度与接缝」词汇。
- [grilling](https://aihero.dev/skills-grilling) 在你选定候选后，沿着决策树逐一推进。
- [domain-modeling](https://aihero.dev/skills-domain-modeling) 在你做决定的过程中保持 `GLOSSARY.md` 和 ADR 的更新。

它的产出是一个想法，这个想法会在 [grill-with-docs](https://aihero.dev/skills-grill-with-docs) 或 [to-spec](https://aihero.dev/skills-to-spec) 处回到主构建流程。它在主流程末端的对应物是 [retro](https://aihero.dev/skills-retro)。这个 skill 改进 agent 工作所在的代码，`retro` 则在一次构建之后改进围绕代码的环境（检查、规范、引导文件）。要知道某种情况该用哪个 skill，[ask-matt](https://aihero.dev/skills-ask-matt) 是覆盖整套 skill 的路由器。
