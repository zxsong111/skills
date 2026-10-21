<p>
  <a href="https://www.aihero.dev/s/skills-newsletter">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skills-repo-dark_2x.png">
      <source media="(prefers-color-scheme: light)" srcset="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skill-repo-light_2x.png">
      <img alt="Skills" src="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skill-repo-light_2x.png" width="369">
    </picture>
  </a>
</p>

# 写给真正工程师的 skill

[![skills.sh](https://skills.sh/b/mattpocock/skills)](https://skills.sh/mattpocock/skills)

这是我每天用来做真正工程开发的 agent skill，不是 vibe coding。

开发真正的应用很难。GSD、BMAD、Spec-Kit 这类方法试图通过接管整个流程来帮你。但这样一来，它们拿走了你的控制权，流程里出了 bug 也很难解决。

这些 skill 的设计目标是小巧、易于改造、可以组合。它们适用于任何模型，背后是几十年的工程经验。随便折腾它们，把它们改成你自己的。玩得开心。

如果你想跟进这些 skill 的变化，以及我新写的 skill，可以订阅我的 newsletter，和另外约 60,000 名开发者一起：

[订阅 Newsletter](https://www.aihero.dev/s/skills-newsletter)

## 安装（30 秒搞定）

plugin 会自己更新。[skills.sh](https://skills.sh/mattpocock/skills) 会把可编辑的文件复制到你的项目里，需要你手动更新。每个 agent 二选一，两个都装的话每个 skill 你都会得到两份。

### 1. 获取 skill

<details>
<summary><strong>Claude Code</strong></summary>

```bash
claude plugin install mattpocock-skills@claude-plugins-official
```

默认自动更新。

</details>

<details>
<summary><strong>Codex</strong></summary>

```bash
codex plugin marketplace add mattpocock/skills
codex plugin add mattpocock-skills@mattpocock
```

启动时自动更新。

</details>

<details>
<summary><strong>GitHub Copilot</strong>（CLI 和 VS Code）</summary>

```bash
copilot plugin marketplace add mattpocock/skills
copilot plugin install mattpocock-skills@mattpocock
```

然后（只需一次）把下面内容加到 `~/.copilot/settings.json`：

```json
{
  "extraKnownMarketplaces": {
    "mattpocock": { "source": { "source": "github", "repo": "mattpocock/skills" }, "autoUpdate": true }
  }
}
```

在 VS Code 里运行 **Chat: Install Plugin From Source**，输入 `https://github.com/mattpocock/skills`。它每天自动更新。

</details>

<details>
<summary><strong>Gemini CLI</strong>（手动更新）</summary>

```bash
gemini skills install https://github.com/mattpocock/skills.git --path skills/engineering
gemini skills install https://github.com/mattpocock/skills.git --path skills/productivity
```

重新运行这两条命令即可更新。

</details>

<details>
<summary><strong>其他任何 agent，或者想要可编辑的文件</strong>（手动更新）</summary>

```bash
npx skills@latest add mattpocock/skills -a <agent>  # cursor, opencode, devin, windsurf, amp, pi; omit -a to choose
```

安装器问你要装哪些 skill 时，记得勾上 `setup-matt-pocock-skills`。更新时运行 `npx skills@latest update`；要获取新 skill，重新运行 `add`。

</details>

### 2. 运行 `/setup-matt-pocock-skills`

在你的 agent 里，每个仓库运行一次。它会：

- 问你想用哪个 issue tracker（GitHub、GitLab、本地文件，或者你描述的任何其他工具）
- 问你分诊（triage）ticket 时会打哪些标签（`/triage` 要用到标签）
- 问你想把我们生成的文档存到哪里

### 3. 搞定，可以开工了。

## 为什么要有这些 skill

我写这些 skill，是为了解决我在 Claude Code、Codex 和其他编码 agent 身上反复看到的常见失败模式。

### #1：agent 没按我想要的做

> 「没有人确切知道自己想要什么。」
>
> David Thomas & Andrew Hunt, [The Pragmatic Programmer](https://www.amazon.co.uk/Pragmatic-Programmer-Anniversary-Journey-Mastery/dp/B0833F1T3V)

**问题**：软件开发中最常见的失败模式是没对齐。你以为开发者知道你想要什么，等看到他们做出来的东西，你才发现对方根本没理解你。

到了 AI 时代也一样。你和 agent 之间存在沟通鸿沟。解决办法是**盘问会话**（grilling session）：让 agent 就你要做的东西向你提出详细的问题。

**解决办法**是使用：

- [`/grill-me`](./skills/productivity/grill-me/SKILL.md)：用于非代码场景
- [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md)：和 [`/grill-me`](./skills/productivity/grill-me/SKILL.md) 一样，但多了一些好东西（见下文）

这是我最受欢迎的几个 skill。它们帮你在动手之前和 agent 对齐，并深入思考你要做的改动。_每次_想做改动时都用它们。

### #2：agent 太啰嗦了

> 有了通用语言，开发者之间的对话和代码的表达都源自同一个领域模型。
>
> Eric Evans, [Domain-Driven-Design](https://www.amazon.co.uk/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)

**问题**：项目刚开始时，开发者和他们为之开发软件的人（领域专家）通常说的不是同一种语言。

我在和 agent 合作时也感受到了同样的张力。agent 通常被直接扔进一个项目，被要求边做边搞懂里面的行话。所以一个词能说清的事，它们要用 20 个词。

**解决办法**是一套共享语言。它是一份文档，帮助 agent 解读项目里使用的行话。

<details>
<summary>
示例
</summary>

这是一个[术语表](https://github.com/mattpocock/course-video-manager/blob/076a5a7a182db0fe1e62971dd7a68bcadf010f1c/CONTEXT.md)示例，来自我的 `course-video-manager` 仓库（在那个固定的 commit 里它还叫 `CONTEXT.md`，那时这些 skill 还没改掉这个命名约定）。哪个更好读？

- **之前**：「当课程某个章节里的一节课被变成『真实的』（也就是在文件系统里分配了位置）时，会出问题」
- **之后**：「实体化级联（materialization cascade）出了问题」

这种简洁会在一次又一次的会话中持续带来回报。

</details>

这已经内置在 [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) 里。它本身是一次盘问会话，但会帮你和 AI 建立共享语言，并把难以解释的决策记录到 ADR 里。

这件事有多强大，很难说清楚。它可能是这个仓库里最酷的一招。试试就知道了。

> [!TIP]
> 共享语言的好处远不止减少啰嗦：
>
> - **变量、函数和文件的命名保持一致**，都使用这套共享语言
> - 因此，对 agent 来说**代码库更容易导航**
> - agent 还会**在思考上花更少的 token**，因为它可以使用一套更简洁的语言

### #3：代码跑不起来

> 「永远迈小而审慎的步子。反馈的速度就是你的速度上限。永远不要接手太大的任务。」
>
> David Thomas & Andrew Hunt, [The Pragmatic Programmer](https://www.amazon.co.uk/Pragmatic-Programmer-Anniversary-Journey-Mastery/dp/B0833F1T3V)

**问题**：假设你和 agent 已经就要做什么对齐了。如果 agent _仍然_产出一堆烂代码，怎么办？

这时候该看看你的反馈回路了。如果得不到它所写代码实际运行情况的反馈，agent 就是在盲飞。

**解决办法**：你需要那一整套常规的反馈回路：静态类型、浏览器访问和自动化测试。

对自动化测试来说，红-绿-重构（red-green-refactor）循环至关重要。也就是让 agent 先写一个失败的测试，再让测试通过。这能给 agent 提供稳定的反馈，产出好得多的代码。

我写了一个 **[`/tdd`](./skills/engineering/tdd/SKILL.md) skill**，可以插进任何项目。它鼓励红-绿-重构，并就什么是好测试、什么是坏测试给 agent 提供大量指导。

针对调试，我还写了一个 **[`/diagnosing-bugs`](./skills/engineering/diagnosing-bugs/SKILL.md)** skill，把最佳调试实践封装成一个有纪律的循环，逐个阶段把关。

### #4：我们造出了一个大泥球

> 「_每天_都要在系统设计上投入。」
>
> Kent Beck, [Extreme Programming Explained](https://www.amazon.co.uk/Extreme-Programming-Explained-Embrace-Change/dp/0321278658)

> 「最好的模块是深的。它们让你通过一个简单的接口访问大量功能。」
>
> John Ousterhout, [A Philosophy Of Software Design](https://www.amazon.co.uk/Philosophy-Software-Design-2nd/dp/173210221X)

**问题**：大多数用 agent 构建的应用都复杂且难以修改。agent 能极大地加快编码速度，也就同样加速了软件熵增。代码库正以前所未有的速度变得越来越复杂。

**解决办法**是一种激进的、全新的 AI 辅助开发方式：在乎代码的设计。

这一点内置在这些 skill 的每一层里：

- [`/to-spec`](./skills/engineering/to-spec/SKILL.md) 会在写 spec 之前追问你要动哪些模块

最关键的是，[`/improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) 会扫描代码库，寻找加深机会，并把候选项交给你。我建议每隔几天在你的代码库上跑一次。它是一次普查，不是救援：在一个真正老旧的代码库上，它会找到实实在在的候选项，但不会替你把泥球理清。

### 总结

软件工程的基本功比以往任何时候都更重要。这些 skill 是我尽最大努力把这些基本功浓缩成可重复的实践，帮你交付职业生涯中最好的应用。玩得开心。

## 参考

这些 skill 按一个维度划分：谁可以调用它们。**用户手动调用**（user-invoked）的 skill 只有在你输入它们时才会触发（例如 `/grill-me`），它们的职责是编排。**模型自动调用**（model-invoked）的 skill 既可以由你调用，_也_可以在任务匹配时由 agent 自动调用，它们承载可复用的方法纪律。用户手动调用的 skill 可以调用模型自动调用的 skill，但绝不调用另一个用户手动调用的 skill。

### Engineering（工程）

我每天写代码时用的 skill。

**用户手动调用**

- **[ask-matt](./skills/engineering/ask-matt/SKILL.md)**：问一问哪个 skill 或流程适合你当前的情况。它是本仓库所有用户手动调用 skill 的路由器。
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)**：一次盘问会话，同时构建项目的领域模型，打磨术语，并随手更新 `GLOSSARY.md` 和 ADR。
- **[triage](./skills/engineering/triage/SKILL.md)**：让 issue 在一个由分诊角色组成的状态机中流转。
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)**：扫描代码库寻找加深机会，以可视化 HTML 报告呈现，然后针对你选中的那个展开盘问。
- **[setup-matt-pocock-skills](./skills/engineering/setup-matt-pocock-skills/SKILL.md)**：为工程类 skill 配置当前仓库（issue tracker、分诊标签、领域文档布局）。在使用其他工程类 skill 之前，每个仓库运行一次。
- **[to-spec](./skills/engineering/to-spec/SKILL.md)**：把当前对话整理成 spec 并发布到 issue tracker。不做访谈，只综合你们已经讨论过的内容。
- **[to-tickets](./skills/engineering/to-tickets/SKILL.md)**：把任何计划、spec 或对话拆成一组曳光弹 ticket，每个 ticket 声明自己的阻塞边，可以写成本地文件里的文本，也可以写成真实 tracker 上的原生阻塞链接。
- **[implement](./skills/engineering/implement/SKILL.md)**：实现 spec 或一组 ticket 描述的工作，在事先约定的接缝处驱动 `/tdd`，并在 commit 之前用 `/code-review` 收尾。
- **[implement-spec](./skills/engineering/implement-spec/SKILL.md)**：在一个集成分支上实现整个 spec。把 ticket 当作任务图来推进，在就绪的前沿上同时运行多个实现子 agent，尽可能提高并发，最后用 `/code-review` 收尾。
- **[wayfinder](./skills/engineering/wayfinder/SKILL.md)**：规划一大块工作（一次 agent 会话装不下的那种），把它做成 issue tracker 上由决策 ticket 组成的共享地图，一次解决一个，直到通往目标的路变得清晰。
- **[retro](./skills/engineering/retro/SKILL.md)**：在一次会话结束后，为编码 agent 的环境（导航、自动化检查、编码规范、引导文件、工具）提出改进建议，最严重的排在最前。

**模型自动调用**

- **[prototype](./skills/engineering/prototype/SKILL.md)**：构建一次性原型来回答一个设计问题，要么是一个可分享的单个 HTML 文件，用于状态或逻辑问题；要么是几个截然不同、可在同一路由中切换的 UI 变体。
- **[diagnosing-bugs](./skills/engineering/diagnosing-bugs/SKILL.md)**：针对疑难 bug 和性能回退的有纪律的诊断循环：建立一个能在这个 bug 上变红的反馈回路 → 最小化 → 提出假设 → 埋点 → 修复 → 回归测试。
- **[research](./skills/engineering/research/SKILL.md)**：对照高可信度的一手资料调查一个问题，并把结论整理成仓库里一个带引用的 Markdown 文件，以后台 agent 的方式运行。
- **[tdd](./skills/engineering/tdd/SKILL.md)**：用红-绿-重构循环做测试驱动开发。一次一个垂直切片地构建功能或修复 bug。
- **[domain-modeling](./skills/engineering/domain-modeling/SKILL.md)**：主动构建并打磨项目的领域模型：拿术语表质疑术语，用边界场景做压力测试，并随手更新 `GLOSSARY.md` 和 ADR。
- **[codebase-design](./skills/engineering/codebase-design/SKILL.md)**：设计深模块的共享方法纪律和词汇：小接口背后藏大量行为，放在干净的接缝处，通过这个接口即可测试。
- **[code-review](./skills/engineering/code-review/SKILL.md)**：对某个固定节点以来的 diff 做双维度审查：**Standards**（是否遵守仓库的编码规范，外加一套 Fowler 代码坏味道基线？）和 **Spec**（是否忠实实现了来源 issue 或 spec？），以并行子 agent 运行，互不干扰。
- **[pr](./skills/engineering/pr/SKILL.md)**：PR 正文应有的结构：用能把改动讲清楚的最小可视化做摘要，给出改动前后能证明它有效的证据，并判断合并风险（单向门还是双向门，外加影响范围）。
- **[wizard](./skills/engineering/wizard/SKILL.md)**：生成一个交互式 bash 向导，带人走完只有人能做的步骤：开通基础设施、配置凭据或 CI 密钥、在陌生的第三方控制台里操作，或者执行一次性的迁移或切换。
- **[commit-push-pr](./skills/engineering/commit-push-pr/SKILL.md)**：按固定约定 commit、push 并开 PR，带主干保护（在 `main` / `master` 上会停下来询问，而不是直接 commit）。PR 正文交给 `pr` 来写。当你说「commit」或「push it」时，agent 会自动调用它。
- **[receiving-code-review](./skills/engineering/receiving-code-review/SKILL.md)**：接收审查反馈（`code-review` 报告、PR 评论）时先验证再实现，不做表演式附和。反复出现的判断性规则会被沉淀进 `CODING_STANDARDS.md`。
- **[security-and-hardening](./skills/engineering/security-and-hardening/SKILL.md)**：针对涉及认证、会话、支付、PII、文件上传、webhook、不可信外部输入或新依赖的改动的安全清单：先画出信任边界，再对照 OWASP 逐项加固。
- **[improve-claude-md](./skills/engineering/improve-claude-md/SKILL.md)**：审计并改进项目的 `CLAUDE.md` / `AGENTS.md` / `.claude/rules/`（包括已有项目），然后从一份 29 项的菜单里生成这个项目真正需要的编码规范，每项都标明它应该放在哪一层。先报告，经批准后才写入。

### Productivity（效率）

通用的工作流工具，不限于代码。

**用户手动调用**

- **[grill-me](./skills/productivity/grill-me/SKILL.md)**：就一个计划或设计接受毫不留情的追问，直到决策树的每个分支都有定论。
- **[handoff](./skills/productivity/handoff/SKILL.md)**：把当前对话压缩成一份交接文档，让另一个 agent 能接着干。
- **[teach](./skills/productivity/teach/SKILL.md)**：在多次会话中教用户一项新技能或新概念，把当前目录当作有状态的教学工作区。
- **[to-questionnaire](./skills/productivity/to-questionnaire/SKILL.md)**：把一个你独自无法回答的决策，变成一份 Markdown 问卷，交给唯一能回答的那个人，可以异步填写，也可以开会时一起填。它盘问的是这次发送（发给谁、你需要拿回什么），而不是问题本身。
- **[wait-what](./skills/productivity/wait-what/SKILL.md)**：一旦某条消息没看懂，马上用它。agent 会补上你缺的上下文，用大白话和你 `GLOSSARY.md` 里的词汇重新讲一遍。
- **[resume-handoff](./skills/productivity/resume-handoff/SKILL.md)**：在一个新会话里，找到 `/handoff` 写下的文档，检查工作区是否仍与之相符，然后从它的下一步接着干。它是 `handoff` 的另一半。

**模型自动调用**

- **[grilling](./skills/productivity/grilling/SKILL.md)**：就一个计划、决策或想法毫不留情地追问用户，直到决策树的每个分支都有定论。它是 `grill-me`、`grill-with-docs`、`triage`、`wayfinder` 和 `improve-codebase-architecture` 背后可复用的访谈基础组件。
- **[writing-for-agents](./skills/productivity/writing-for-agents/SKILL.md)**：为 agent 写文档：skill、AGENTS.md/CLAUDE.md，以及 agent 通过指针找到的任何文档。
- **[humanizer](./skills/productivity/humanizer/SKILL.md)**：自动去掉写给人看的文字（PR 描述、README、文档、报告）里的 AI 腔：对照 26 种模式改写，不改变原意，不编造事实，只动文字，绝不碰代码。
- **[i-have-adhd](./skills/productivity/i-have-adhd/SKILL.md)**：自动调整每一条回复的形态：第一行就是下一步行动，多步骤的工作编号列出，每轮都重申当前状态，没有开场白和结束语。说「stop adhd mode」可以在本次会话中关闭它。
