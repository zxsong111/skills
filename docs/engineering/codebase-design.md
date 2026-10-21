## 它做什么

`codebase-design` 把你设计模块时用的词固定下来：**模块**(module)、**接口**(interface)、**深度**(depth)、**接缝**(seam)、**适配器**(adapter)、**杠杆**(leverage)、**局部性**(locality)。它给每个词下精确定义，禁用那些松散的替代词（「component」「service」「API」「boundary」），并陈述由这些词推出的几条原则。

它是一份参考，不是一个流程。它不跑循环，不产出工件，也从不停下来问你问题。其他所有涉及设计的 skill 都使用它的词汇。单独使用时，它给你这些词，然后就停下。调用之前要清楚这一点。如果你把一个[会话](https://www.aihero.dev/ai-coding-dictionary/session)指向一个既没有流程、也没有停止规则的 skill，然后说「开始」，agent 就会自己编一个流程出来。下面的常见问题展示了那是什么样子。

## 什么时候用

输入 `/codebase-design`，或者在任务匹配时由 agent 自动调用。

当你已经知道要重新设计哪段代码，需要思考它的形状时用它：接缝放在哪里，接口能缩到多小，一次抽取是否真的把复杂度从调用方那里移走了。也可以用它来平息关于某个设计用词含义的争论。

有几个 skill 和它相近。按你手上的问题来选：

| 问题 | 对应的 skill |
|---|---|
| 单个模块的形状：它的接口、接缝、深度 | `codebase-design` |
| *领域里的用词*：「account」有三种含义，两个人说「cancellation」指的不是一回事 | [domain-modeling](https://aihero.dev/skills-domain-modeling) |
| 你还不知道该重新设计*哪个*模块 | [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture)（负责找出候选的巡查） |
| 你希望有人和你争论这个设计，而不只是给它命名 | [grilling](https://aihero.dev/skills-grilling) |
| 有具体的行为要实现，你想要能扛过重构的测试 | [tdd](https://aihero.dev/skills-tdd) |

## 词汇

术语表就是这个 skill 本身。skill 把每个术语都对照其他术语来定义，并给出它所取代的那个词。

| 术语 | 含义 | 别说 |
|---|---|---|
| **模块** | 任何拥有接口和实现的东西。刻意不限定尺度：一个函数、一个类、一个包、一个跨越多层的切片。 | unit、component、service |
| **接口** | 调用方要正确使用它所必须知道的一切：类型签名，加上不变量、顺序约束、错误模式、必需的配置、性能特征。 | API、signature |
| **深度** | 接口处的杠杆：调用方或测试每学习一单位接口，能调动多少行为。**深**：小接口背后有大量行为。**浅**：接口几乎和实现一样复杂。 | 无 |
| **接缝** | Michael Feathers 的术语：一个无需修改该处代码就能改变行为的位置。它是接口所在的*位置*，放在哪里是一个独立的决定，与它背后放什么无关。 | boundary |
| **适配器** | 在某个接缝处满足某个接口的具体实现。它指的是一个角色，而不是某类东西：内存里的 fake 和 Postgres 仓储都是适配器。 | 无 |
| **杠杆** | 调用方从深度中得到的东西：每学习一单位接口，获得更多能力。 | 无 |
| **局部性** | 维护者从深度中得到的东西：改动、bug 和验证都集中在一处，修一次就覆盖所有调用方。 | 无 |

这个 skill *不*把深度定义为实现行数与接口行数之比，那是 Ousterhout 自己的定义。这个指标会鼓励把实现写得臃肿，所以 skill 改用「深度即杠杆」。

## 四条原则

- **深度是接口的属性，不是实现的属性。** 一个深模块(deep module)内部可以由许多可替换的小部件构成，只是调用方看不到它们。一个模块可以有供自己测试使用的内部接缝，同时在接口处有一个外部接缝。
- **删除测试。** 设想把这个模块删掉。如果复杂度随之消失，说明这个模块只是个转手的中间层。如果复杂度在 N 个调用方那里重新冒出来，说明这个模块确实隐藏了真实的复杂度。
- **接口就是测试面。** 调用方和测试跨越的是同一个接缝。如果你想*绕过*接口去测试，说明这个模块的形状不对。
- **一个适配器意味着假想的接缝，两个适配器才是真正的接缝。** 在接缝两侧真的有东西会变化之前，不要切出接缝。只有一个适配器的接缝不过是多了一层间接。

有两个辅助文件讲得更深，skill 按需读取，而不是一开始就读。[DEEPENING.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/codebase-design/DEEPENING.md) 把候选模块的依赖分成四类（进程内、可本地替代、远程但自有、真正外部），因为类别决定了你如何跨接缝测试加深后的模块。[DESIGN-IT-TWICE.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/codebase-design/DESIGN-IT-TWICE.md) 启动并行的[子 agent](https://www.aihero.dev/ai-coding-dictionary/subagent)，为同一个模块产出三个或更多截然不同的接口，然后从深度、局部性和接缝位置三方面比较它们。

## 常见问题

**在 TypeScript 里到底怎么构建一个深模块？**

这是关于这个 skill 被问得最多的问题，而 skill 并没有回答它。它定义了深模块*是*什么，却没说怎样防止一条随手的 import 绕过接口。[Issue #458](https://github.com/mattpocock/skills/issues/458) 说得很直白：「let's say we're happy with the interface, it hides the details, etc. But how do we enforce it? I think without linting or clear guardrails, humans and LLMs alike will start making it messy over time.」那个讨论串里给出了三个选项：用类或 IIFE 包起来，接受这个类会变得巨大；把它做成 monorepo 里的一个包，接受 monorepo 的工具链；或者用 [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) 这样的 linter 禁止绕过接口的 import。这几种机制里，Effect 最好，dependency-cruiser 次之。仓库的 `in-progress/` 分组里有一个 `setup-ts-deep-modules` skill，它约定了 `src/packages/<name>/index.ts` 的结构，但它是测试通道的 skill，没有文档页，也不附带 lint 规则。

**我把一个会话指向它，结果它烧掉了 10 万 [token](https://www.aihero.dev/ai-coding-dictionary/token)，去重新设计我根本没问的东西。**

这是已知问题，登记为 [issue #449](https://github.com/mattpocock/skills/issues/449)。这个 skill 是模型自动调用(model-invoked)的，自称是一份词汇，但其中没有任何东西能硬性阻止 agent 把它当成可执行的流程。有个 agent 被告知「resume in /codebase-design and drive the open decisions」，就挑了 skill 里最接近流程的部分：`DESIGN-IT-TWICE.md` 里的并行子 agent。它重新探索了之前的会话早已摸清的代码，干了很久才问了第一个问题。这个 skill 没有驱动型 skill 所具备的任何防护栏(guardrail)（检查点、一次一个问题、不自动推进），因为它是一份参考。绕过办法是调用一个驱动型 skill（`/grill-with-docs`、`/improve-codebase-architecture` 或 `/tdd`），把 `codebase-design` 当作它的词汇来用。这个 issue 仍未关闭。

**`design-an-interface` 去哪了？有没有 `/interface-design` 这个 skill？**

这个 skill 取代了 `design-an-interface`，接管了它的内容，没有任何东西丢失。它的「design it twice」技巧（并行子 agent 生成截然不同的设计，源自 Ousterhout）在这里以 `DESIGN-IT-TWICE.md` 的形式提供。另外，有好几个人要求为深模块/薄接口的理念专门做一个 `/interface-design` skill；这个 skill 已经覆盖了这套理念，不打算另做一个。如果你是冲着这两个名字来的，就是这一页。

**这不就是一种文件结构约定吗，比如文件夹、barrel 文件、功能切片？**

不是。很多人对此提出过异议，skill 没有改变。[Issue #95](https://github.com/mattpocock/skills/issues/95) 提议用一种形式化的分形树文件结构作为深模块的具体实现；回复是两者相互独立：「deep modules are about the design of the interface and accessing through a strict interface, no matter what the file system looks like. It seems perfectly possible that you could have shallow modules with this approach.」#458 里也出现过同样的讨论：「I think you might be tying the concept of modules too closely to the file system. The file system can certainly be a useful hint to the shape of modules, but there's no need to use the file system in the construction of deep modules.」术语表有意把**模块**定义为不限尺度。

**`tdd` 真的用了这套词汇吗？**

现在用了，但很长一段时间里没有。v1.0 从 `tdd` 里删掉了内联的深模块说明，改用这个共享 skill，但没人补上一个指向它的指针，于是 `tdd` 自己定义了「seam」，什么都没引用。现在 `tdd` 里有了这个指针，当悬而未决的问题是接口形状而不是测试时，agent 会顺着它过来。`tdd` 仍然负责「接缝」作为你*测试*所在的边界这层含义；这个 skill 负责它背后的模块形状。

**design-it-twice 模式在 Claude Code 之外能用吗？**

不太顺畅。`DESIGN-IT-TWICE.md` 写的是「spawn 3+ sub-agents in parallel using the Agent tool」，而「Agent」是 Claude Code 的一个[工具](https://www.aihero.dev/ai-coding-dictionary/tool)的名字。仓库为其他 [harness](https://www.aihero.dev/ai-coding-dictionary/harness)（包括 Codex）提供了元数据，而那些 harness 可能没有叫这个名字的工具。所以并行设计这一阶段的可移植性不如 skill 元数据暗示的那么好。[Issue #564](https://github.com/mattpocock/skills/issues/564) 在跟踪这个问题，仍未关闭。

**我能往术语表里加自己的概念吗，比如 connascence、module secrets、[渐进式披露](https://www.aihero.dev/ai-coding-dictionary/progressive-disclosure)？**

有人提过这些。[Issue #180](https://github.com/mattpocock/skills/issues/180) 加入了 Parnas 的 module secrets 和 Page-Jones 的 connascence，作为描述*什么*在跨接缝泄漏的命名层，并附了一个可用的 diff；[issue #303](https://github.com/mattpocock/skills/issues/303) 提议在实现内部做渐进式披露，让一个在公共接口处很深的模块内部也有结构。两者都未关闭、未合并。正式发布的术语表刻意保持小巧，skill 本身给出了理由：一致的用语才是全部意义所在，一个没人一致使用的术语比没有术语更糟。

## 起作用的标志

- 设计讨论里不再出现「component」「service」「boundary」这些词，开始出现「模块」「接口」「接缝」。
- 有人能指着一个拟议的抽取，毫不含糊地说出它能否通过删除测试。
- 拟议的接缝会附带点名第二个适配器，而不只是第一个。
- 对接口的讨论涵盖不变量、顺序和错误模式，而不只是类型签名。
- 调用它不会开启一个工作会话。如果 agent 单凭 `/codebase-design` 就开始读文件、提重构方案，说明它把这份参考当成了驱动型 skill。

## 在体系中的位置

`codebase-design` 是一个**随时可用的独立工具**，是工程类 skill 底下的词汇层，而不是任何链路中的一步。它最近的邻居是 [domain-modeling](https://aihero.dev/skills-domain-modeling)，那是针对*问题领域*用词（而不是模块形状）的平行参考。两者通常一起用，因为给深模块起个好名字两者都需要。另一个邻居是 [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture)：它巡查代码库寻找可加深的候选，并用这份术语表来描述每一个候选，所以它负责找到模块，你用这个 skill 的词汇去设计它。当你拿不准该用哪个 skill 或哪条流程时，[ask-matt](https://aihero.dev/skills-ask-matt) 会为你指路。
