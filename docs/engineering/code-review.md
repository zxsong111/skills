## 它做什么

`code-review` 沿两条轴评审 `HEAD` 与你指定的某个固定点（一个 commit、一个 branch、一个 tag、`main`、`HEAD~5`）之间的 diff。**Standards**（规范）轴问的是：代码是否符合这个仓库的写法。**Spec** 轴问的是：代码是否做到了源头 issue 或 [spec](https://www.aihero.dev/ai-coding-dictionary/spec) 要求的事。每条轴在各自的[子 agent](https://www.aihero.dev/ai-coding-dictionary/subagent) 里运行，互相看不到对方的推理。

这个 skill 从不合并两条轴，也不在两条轴之间重新排序。报告最后给出*每条轴*最严重的问题，拒绝跨轴评出唯一的头号问题。一个改动可能通过一条轴、却挂在另一条上。遵守所有约定但实现错了东西的代码，通过 Standards、挂在 Spec 上。完全按 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) 要求实现、却破坏了仓库约定的代码，情况正好相反。混在一起的结论会让通过的那条轴掩盖失败的那条。

## 什么时候用

输入 `/code-review`，或者在任务匹配时由 agent 自动调用。比如你要求评审一个 branch、一个 PR、进行中的工作，或者任何「自 X 以来」的改动。

| 你的情况 | 该用 |
| --- | --- |
| 已经有 diff，你想知道它是否做得对，*并且*做的是对的事 | `code-review` |
| 你想在 diff 里找 bug：空值路径、竞态、差一错误 | Claude Code 自带的内置评审，不是这个（见下文的重名问题） |
| 什么都还没写，你想用测试先行的方式来写 | [tdd](https://aihero.dev/skills-tdd) |
| 需要把整个 spec 做出来，包括评审 | [implement](https://aihero.dev/skills-implement)，它自己会调用这个 skill |
| 整个代码库都走偏了，而不只是一个 diff | [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) |
| 有东西坏了，你不知道为什么 | [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs) |

固定点必须由你提供。如果你没给，skill 会问你要，而不是去猜。在启动任何东西之前，它会检查这个 ref 能否解析、diff 是否为空，这样拼错的 branch 名会当着你的面失败，而不是在两个子 agent 里面失败。

## 前置条件

Standards 轴什么都不需要。它读取仓库里写下的任何规范（`CODING_STANDARDS.md`、`CONTRIBUTING.md` 之类），仓库什么都没写时就退回到内置的基线。

Spec 轴需要 spec 存在并且能被找到。它按以下顺序查找：

1. commit message 里的 issue 引用（`#123`、`Closes #45`、GitLab 的 `!67`），通过 tracker 文档去拉取。
2. 你作为参数传入的路径。
3. `docs/`、`specs/` 或 `.scratch/` 下与 branch 名或功能名匹配的 spec 文件。
4. 问你。

第 1 步依赖 tracker 文档，它由 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 写入。没有它的话，只要你给一个路径，这条轴照样能用。如果根本没有 spec，skill 会跳过 Spec 子 agent，报告里写「no spec available」，而不是凭空编造需求。

## 两条轴

| | Standards | Spec |
| --- | --- | --- |
| 问题 | 做得对吗？ | 做的是对的事吗？ |
| 读取 | 仓库写下的规范，加上代码坏味道基线 | 源头 issue 或 spec |
| 报告 | 违反成文规范之处（可能是硬性的），以及坏味道（永远是判断性的） | 缺失或只做了一部分的需求、范围蔓延、实现错了的需求 |
| 每条发现都引用 | 规范文件及其中的规则，或者具名的坏味道加上对应的代码块 | spec 中的那一行 |

这样设计，是为了避免一个不懂你家规范的通用评审 skill。那种 skill 会把你代码库里有意为之的东西标出来，却漏掉代码库所依赖的不变量。所以在 Standards 轴上，仓库自己的文档是[一手资料](https://www.aihero.dev/ai-coding-dictionary/primary-source)，**仓库永远优先**。

**坏味道基线**位于仓库规范之下。它是 Fowler《重构》（_Refactoring_）第 3 章里的十二种代码坏味道：Mysterious Name、Duplicated Code、Feature Envy、Data Clumps、Primitive Obsession、Repeated Switches、Shotgun Surgery、Divergent Change、Speculative Generality、Message Chains、Middle Man、Refused Bequest。每一种都是带标签的启发式判断（「possible Feature Envy」），从不算硬性违规。每一种都说明这个坏味道是什么、怎么修，所以每条发现都附带修复方法，而不只是一句抱怨。linter 已经强制的东西，两条轴都会跳过。

## 常见问题

**它和 Claude Code 自带的 `/code-review` 撞名了，怎么办？**

这是这个 skill 被报告最多的问题，目前没有修复。Claude Code 自带一个 `/code-review`，做的是另一件事：它在 diff 里找 bug，而这个 skill 检查的是是否符合 spec 和仓库规范。安装这个库之后，两者只有一个会生效，哪个生效取决于你的安装方式：

- **Plugin marketplace。** 每个 skill 都带上 `mattpocock-skills:` 前缀，内置的那个用不带前缀的名字就很难调到了。
- **普通的 skill 安装。** 本地文件优先，这个 skill 会遮蔽内置的那个。

一种办法是彻底移除 Claude Code 的内置 skill。这样能省下大量[上下文](https://www.aihero.dev/ai-coding-dictionary/context)，撞名也就无所谓了。遮蔽本身可以说是 Claude Code [harness](https://www.aihero.dev/ai-coding-dictionary/harness) 的 bug（skill 作者应该可以随意给 skill 起名），所以另一种办法是给本地副本改名。`npx skills update` 会撤销你对 frontmatter 的修改或目录的重命名。用户报告的长期可行的绕过办法是把这个 skill fork 成一个新名字，并把 `code-review` 从托管集合中去掉。记下你 fork 时所基于的 commit，以便手动重新同步。

**它的子 agent 不停地再次调用 `/code-review`，又派生出更多 agent。**

这是一个已知、尚未关闭的 bug。好几个人复现过，而且不止在一种 harness 里。Standards 和 Spec 的 prompt 没有禁止委派，所以子 agent 可能再次找到这个 skill，再次扇出。有一份报告里 agent 数量超过了 50 个。大家在 fork 里用的修复办法是在两个子 agent 的简报末尾各加一行：「Do not invoke `/code-review` or spawn additional agents: perform this review directly.」也有人更愿意在 harness 层面处理，让每个 skill 都继承这道防护。这两种都还没进入正式发布的 skill。如果你无人值守地运行它，留意 agent 的数量。

**我应该在写代码的同一个[会话](https://www.aihero.dev/ai-coding-dictionary/session)里运行它吗？**

最好用一个新的会话。正如一位读者所说：「Same context reviewing itself isn't review, it's confirmation bias with a slash command.」在编写代码的会话里做评审的 agent，上下文里装着塑造这段代码的所有假设。一个独立的评审者不会有这些上下文。这也是为什么有人希望 [implement](https://aihero.dev/skills-implement) 去掉内置的评审步骤，因为那一步是在刚写完 diff 的会话里做评审。独立的做法是你自己在一个干净的会话里调用 `/code-review`。

**每个 ticket 之后跑一次，还是最后跑一次？**

两种都行，skill 不替你决定。按 ticket 跑能让每个 diff 足够小，Spec 轴有一份清晰的 spec 可以对照，`implement` 用的就是这种方式。攒到 branch 末尾一起跑，能抓到各个 ticket 之间的相互影响，这是逐个 ticket 评审时都会漏掉的。拿不准的话，就按 ticket 评审，最后再对照 branch 起点跑一遍。

**我能信任它的发现吗？**

不检查就不能。子 agent 的输出是假设，不是证据。有个团队报告说它找出了十几处破坏性变更，都是基于文字的评审漏掉的。skill 把两份报告原样合并，或者只稍加整理。它不会对照文件逐条复核，所以一条发现可能引错位置，或者夸大影响。动手之前先看每条发现的引用。skill 要求每条发现都带引用（一条规范规则、一个坏味道加上对应代码块，或者 spec 中的一行），正是这一点让发现变得可以核查。

**为什么我每次运行它都会发现新问题？**

每次修复都会引入新的待评审代码，而 Standards 轴里判断性的那一半，每次运行结果都不一样。一位读者描述了这个循环：「/code-review and /improve-code-architecture always find new stuff every time. I implement fixes, rerun these skills, and again and again.」它不保证收敛。把一次评审当作一份线索清单。处理那些背后有引用规则的，然后停下。不要循环运行到它返回干净为止，因为它永远不会。

**它会评审我还没 commit 的工作吗？**

不会。它 diff 的是 `<fixed-point>...HEAD`。三点形式从 merge-base 算起，不包含暂存区和工作区的改动。如果 `implement` 还没做中间 commit，评审就看不到即将进入下一个 commit 的工作。先 commit，再评审，然后 amend 或者追加一个 fixup。

## 起作用的标志

- 遇到错误的 ref 或空 diff 时，它在派生任何子 agent 之前就拒绝开始。
- 报告以 `## Standards` 和 `## Spec` 下的两个独立块呈现，而不是一张合并的清单。
- 每条 Standards 发现要么点名你仓库某个文件里的一条规则，要么点名十二种坏味道之一，并引用对应代码块；每条 Spec 发现都引用 spec 中的一行。
- 结尾的总结给出每条轴最严重的问题，拒绝评出一个总的头号问题。
- 没有 spec 时，Spec 块会直说，而不是列出它从代码里推断出来的需求。

## 在体系中的位置

`code-review` 是构建链路尾部附近的评审步骤：`grill-with-docs → to-spec → to-tickets → implement → code-review → retro`。它也可以单独用在你指给它的任何 branch 或 PR 上。

- [implement](https://aihero.dev/skills-implement) 是最近的邻居。它驱动构建，并在 commit 之前调用这个 skill 作为自己的收尾评审。[implement-spec](https://aihero.dev/skills-implement-spec) 也一样，只是在整个集成分支(integration branch)上做一次。
- [retro](https://aihero.dev/skills-retro) 在它之后，负责调校它。当某次会话暴露出评审漏掉了某一类错误，`retro` 会提出一项检查，或者一条 `CODING_STANDARDS.md` 规则，供 Standards 轴之后读取。
- [pr](https://aihero.dev/skills-pr) 在评审过的工作推上去之后撰写 pull request 正文。
- [to-spec](https://aihero.dev/skills-to-spec) 和 [to-tickets](https://aihero.dev/skills-to-tickets) 产出 Spec 轴对照的文档，所以 spec 写得含糊，这条轴也会含糊。
- [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) 是面向整个代码库的对应物，因为这个 skill 只看一个 diff。

当你拿不准当前情况该用哪个 skill 时，[ask-matt](https://aihero.dev/skills-ask-matt) 会在整套 skill 中为你指路。
