## 它做什么

`tdd` 以测试先行的方式构建功能或修复 bug：先写一个失败的测试，再写刚好够让它通过的代码，然后进入下一个行为。它带着让这个循环产出值得保留的测试的那些标准：什么是好测试，测试该放在哪里，mock 是用来做什么的，以及让一套测试变得毫无价值的三种反模式。

在你事先同意之前，它不会在任何接缝(seam)上写测试。在写出任何测试之前，它会说出打算在哪些公开边界上测试，然后停下来等你确认。测试的精力是有限的，这一步把精力花在关键路径上，而不是每个边界情况上。`tdd` 也是一份**参考**，而不是驱动者。它包含这个循环的规则，由别的东西（你，或者 [implement](https://aihero.dev/skills-implement)）来运行应用这些规则的那个[会话](https://www.aihero.dev/ai-coding-dictionary/session)。

## 什么时候用

输入 `/tdd`，或者在任务匹配时由 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 自动调用：比如以测试先行的方式构建功能或修复 bug，或者你说出「red-green-refactor」的时候。

当有一个具体的行为要构建、它有输入也有可观察的输出，并且你想要能在重构后存活下来的测试时，就用它。

| 你的情况 | 去哪里 |
| --- | --- |
| 一个输入输出明确的行为（业务逻辑、请求/响应契约、数据转换、校验） | `tdd` |
| 行为还没确定下来 | [to-spec](https://aihero.dev/skills-to-spec)，它还会在写任何代码之前就把测试接缝商定好 |
| 问题其实是接口的形状，而不是测试 | [codebase-design](https://aihero.dev/skills-codebase-design) |
| 你手上有 [spec](https://www.aihero.dev/ai-coding-dictionary/spec) 或 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket)，想让整个构建替你跑完 | [implement](https://aihero.dev/skills-implement)，它会按 ticket 逐个驱动 `tdd` |
| 配置、接线、胶水代码、类型标注、直接的 CRUD 委托 | 这里没有合适的；见下面那个尚未解决的缺口 |

最后一行是一个真实存在的缺口。这个 skill 决定接缝放在*哪里*，但其中没有任何东西决定一个改动*是否*值得走这个循环。如果你在一个没有独立事实来源可供断言的改动上运行它，得到的测试只会把实现复述一遍。这正是 skill 警告过的同义反复反模式，只不过是从另一个方向走到了那里。这是 [issue #746](https://github.com/mattpocock/skills/issues/746)，目前仍未关闭。在它关闭之前，这个判断由你自己来做，或者把规则写进你的 `CLAUDE.md`。

## 前置条件

需要安装 [codebase-design](https://aihero.dev/skills-codebase-design)。`tdd` 以前自带关于深模块和接口设计的笔记；v1.0 删掉了它们，改用这个共享的 skill，现在 `tdd` 使用的是它的接口设计词汇。除此之外不需要别的；这个 skill 是[无状态](https://www.aihero.dev/ai-coding-dictionary/stateless)的，不会写任何属于自己的文件。

## 循环，以及它运行所在的接缝

这个 skill 建立在三个术语之上。

**红-绿(red-green)。** 先写失败的测试，然后只写刚好够让它通过的代码。不要为下下个测试写代码。没有重构阶段。这个 skill 在 2026 年 6 月去掉了它，因为 agent 几乎从不执行这一步，也因为 review 和实现作为两个独立的会话效果更好。重构归 [code-review](https://aihero.dev/skills-code-review) 管。

**垂直切片(vertical slice)。** 在一个接缝上写一个测试，然后写最小的实现，然后重复。第一个循环是一颗**曳光弹(tracer bullet)**，端到端地证明一条路径走得通。与之相反的是水平切分：先写完所有测试，再写所有代码。批量写出来的测试验证的是*想象中*的行为。它们检查的是事物的形状，而不是用户实际做的事，而且在你理解实现之前就把你锁定在某种测试结构上。

**事先商定的接缝。** 接缝是你无需深入内部就能观察行为的那个公开边界。这条规则没有例外：未经确认的接缝上不放任何测试。在完整的链路中，接缝会更早在 [to-spec](https://aihero.dev/skills-to-spec) 阶段商定好：「`/tdd` 被告知只在事先商定的测试接缝上工作，`/code-review` 检查是否只用了商定好的测试接缝。」单独调用时，`tdd` 会直接问你。

它要防止的三种反模式：

| 反模式 | 迹象 |
| --- | --- |
| 与实现耦合 | 你重命名一个内部函数，测试就挂了，尽管行为并没有变。mock 掉内部协作者、断言调用次数、用数据库查询而不是接口来验证。 |
| 同义反复 | 期望值的计算方式和代码的计算方式一样，所以测试天然就会通过。期望值必须来自别处：一个已知正确的字面量、一个推演过的例子、spec。 |
| 水平切分 | 在任何实现之前就落下了一批测试。 |

mock 只用于系统边界：外部 API、时间、随机数，有时还有文件系统或数据库。永远不要 mock 你自己的模块。

## 常见问题

**为什么它不重构？描述里写的是「red-green-refactor」。**

因为重构这一步被删掉了，而描述没有改。删除是有意的。agent 几乎从不执行这一步，而且让实现和 review 分属不同的会话效果更好。结果是否还算教科书式的 TDD，不如这个循环能否产出更好的代码重要。触发短语和正文之间的不一致已经提交为 [issue #589](https://github.com/mattpocock/skills/issues/589)，目前仍未关闭，所以「red-green-refactor」仍然可以作为触发这个 skill 的短语。你得到的是红-绿，重构放在 [code-review](https://aihero.dev/skills-code-review) 里。

**它让我选一个测试接缝，我完全不知道该选哪个。**

这是这个 skill 被报告最多的摩擦点（[issue #607](https://github.com/mattpocock/skills/issues/607)）。提示里只按名称列出候选接缝，没有说明每个能抓到什么、会漏掉什么，所以你是在几个标签之间做选择。目前还没有发布修复。实际可行的变通办法是在回答之前先问 agent 各自的取舍：组件级接缝会漏掉哪些集成接缝能抓到的东西，它又慢多少。这也是为什么链路会在 `to-spec` 里提前商定接缝，在那里你看得到整个功能，而不只是一个提示。

**它在测试之前就写了实现，尽管 skill 说的是先红。**

这确实会发生。有位用户就此追问[模型](https://www.aihero.dev/ai-coding-dictionary/model)，得到了一个罕见的坦白回答：「我知道 skill 说的是『一次一个测试，看着它因为正确的原因失败』。我读过。我只是回到了我平常的习惯。」这个 skill 接受这一点。没有任何指令能让 agent 百分之百服从，更严格的措辞会限制 agent 的创造力，收益却很小。即使 agent 没有严格遵循，这个循环也值得跑，因为总体结果还是更好。如果某个切片非常需要严格遵循，就盯着这次运行，而不是指望 skill 去强制执行。

**它应该先写浏览器测试或端到端测试吗？**

通常不应该，而这个 skill 不会阻止它。有位用户报告说，agent 先写了一个 Playwright 测试，然后花了很长一段循环反复运行它，最后断定是*测试*坏了，而那个功能根本还不存在。浏览器测试慢到让红-绿反馈回路得不偿失。在你仓库的 `CLAUDE.md` 里写明：浏览器测试要在行为跑通之后再写。

**`/tdd` 能取代 `/implement` 或者课程里的 `/do-work` 吗？**

不能。`/tdd` 记录的是方法论；`/implement` 是一个简单的「干活 → 反馈 → commit」循环，是 `/do-work` 的直接替代。课程里单独的 `/do-work` 这一步，现在拆分到了 `/implement`、`/tdd` 和 `/code-review` 里。如果你在问针对一个 ticket 该运行哪个，答案几乎总是 `/implement`。

**关于深模块和接口设计的指导去哪了？**

在 v1.0 里移到了 [codebase-design](https://aihero.dev/skills-codebase-design)，并做了泛化，让几个 skill 共享同一套词汇。`refactoring.md` 也在同一时间移走了；重构现在是 [code-review](https://aihero.dev/skills-code-review) 的工作，那个 skill 带着 Fowler 的代码坏味道基线。

**它知道我的其他 ticket 吗？**

不知道。针对一个 ticket 运行时，它可能会提议做属于某个兄弟 ticket 的工作，因为它看不到 issue 图的其余部分（[issue #129](https://github.com/mattpocock/skills/issues/129)）。这不是 `tdd` 的职责。把 spec 和 ticket 一起传给它会有帮助；一开始就把 ticket 的大小切得合适，帮助更大。

## 起作用的标志

- 在任何测试文件出现之前，它会停下来说出打算在哪些接缝上测试，然后等待。
- 出现一个测试，变红，补上刚好够通过的代码，然后才出现下一个测试，而不是一批测试之后跟着一批代码。
- 测试名称读起来像能力（「user can checkout with valid cart」），而不像内部细节（「checkout calls paymentService.process」）。
- 断言里的期望值是你能追溯到 spec 的字面量，而不是按代码的计算方式重新算出来的值。
- 重命名一个内部函数不会让测试套件里的任何东西挂掉。
- mock 只出现在外部边界上（支付 API、时钟），从不包裹你自己的模块。

## 在体系中的位置

`tdd` 在主链路的构建步骤内部运行；它本身不是独立的一步：

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review → retro
```

[to-spec](https://aihero.dev/skills-to-spec) 预先商定测试接缝，[implement](https://aihero.dev/skills-implement) 按 ticket 逐个驱动 `tdd`，[code-review](https://aihero.dev/skills-code-review) 事后检查是否只用了商定好的接缝，并负责 `tdd` 不再做的重构。它的另一个邻居是 [codebase-design](https://aihero.dev/skills-codebase-design)，`tdd` 所用的接缝和深模块词汇都来自这个共享来源。只要有具体的行为要构建、又没有完整的 spec，你也可以单独使用它。当你不确定哪个 skill 适合你的情况时，[ask-matt](https://aihero.dev/skills-ask-matt) 会为你指路。
