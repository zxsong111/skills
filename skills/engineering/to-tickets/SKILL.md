---
name: to-tickets
description: >
  把计划、spec 或当前对话拆成一组曳光弹式 ticket，每个都声明自己的阻塞边，并发布到已配置的 tracker（本地是每个 ticket 一个文件、阻塞边写成文本；真实 tracker 上用原生的阻塞链接）。
disable-model-invocation: true
---

# To Tickets

把计划、spec 或对话拆成一组 **ticket**：曳光弹(tracer bullet)式的垂直切片(vertical slice)，每个都声明**阻塞**它的那些 ticket。

issue tracker 和分诊(triage)标签词汇表应该已经提供给你了。如果没有，告诉用户运行 `/setup-matt-pocock-skills`。

## 流程

### 1. 收集上下文

基于对话上下文里已有的一切开展工作。如果用户以参数形式传入了一个引用（spec 路径、issue 编号或 URL），就把它拉下来，读完整的正文和评论。

### 2. 探索代码库（可选）

如果你还没有探索过代码库，先探索一下，了解代码的现状。ticket 的标题和描述应该使用项目领域术语表(glossary)中的词汇，并尊重你所触及区域的 ADR。

寻找预先重构(prefactor)代码的机会，让实现变得更容易。"Make the change easy, then make the easy change."（先让改动变容易，再做这个容易的改动。）

### 3. 起草垂直切片

把工作拆成**曳光弹** ticket。

<vertical-slice-rules>

- 每个切片都要贯穿每一层（schema、API、UI、测试），切出一条窄但**完整**的路径：是垂直的，**不是**某一层的水平切分
- 一个完成的切片能单独演示或验证
- 每个切片的大小都要能放进一个全新的上下文窗口(context window)
- 任何预先重构都要最先做

</vertical-slice-rules>

给每个 ticket 标出它的**阻塞边(blocking edges)**：在它开始之前必须完成的其他 ticket。没有阻塞项的 ticket 可以立即开始。

**大范围重构是垂直切分的例外。** **大范围重构(wide refactor)** 是一个机械性的改动（重命名一列、给一个共享符号改类型），它的**影响范围(blast radius)**扩散到整个代码库，单次修改就会同时弄坏成千上万个调用点，没有任何垂直切片能保持绿色落地。不要硬把它塞进曳光弹；按 **expand-contract（扩张-收缩）** 来排序。先扩张：在旧形式旁边加上新形式，这样什么都不会坏。然后按影响范围划定批次大小（按包、按目录）把调用点分批迁移过去，每批是一个独立的 ticket，被扩张 ticket 阻塞；因为旧形式仍然存在，CI 在每批之间都能保持绿色。最后收缩：一旦没有调用方了就删掉旧形式，放在一个被所有迁移批次阻塞的 ticket 里。如果连单个批次都没法单独保持绿色，就保留这个顺序，但让它们共用一个集成分支(integration branch)，全部阻塞最后一个「集成并验证」ticket；只在那里承诺绿色。

### 4. 向用户确认

把拟定的拆分以编号列表的形式展示出来。每个 ticket 显示：

- **标题**：简短的描述性名称
- **Blocked by**：哪些其他 ticket（如果有）必须先完成
- **交付什么**：这个 ticket 让哪个端到端的行为能跑起来

问用户：

- 粒度感觉合适吗？（太粗 / 太细）
- 阻塞边对吗：每个 ticket 是否只依赖那些真正卡住它的 ticket？
- 有没有 ticket 应该合并或者进一步拆分？

反复迭代，直到用户认可这个拆分。

### 5. 把 ticket 发布到已配置的 tracker

发布已认可的 ticket。**怎么发**取决于 `/setup-matt-pocock-skills` 配置的 tracker；无论哪种，ticket 本身都一样，只是阻塞边的形式不同：

- **本地文件** → 每个 ticket 写一个文件，路径为 `.scratch/<feature-slug>/issues/<NN>-<slug>.md`，按依赖顺序从 `01` 开始编号（阻塞项在前）。每个文件的 "Blocked by" 列出它依赖的编号或标题。使用下面的单 ticket 文件模板：一个文件一个 ticket，绝不合并成一个文件。
- **真实的 issue tracker（GitHub、Linear 等）** → 按依赖顺序（阻塞项在前）每个 ticket 发布一个 issue，这样每个 ticket 的阻塞边都能引用真实的标识符。平台有原生阻塞关系的就用原生的；否则把每个 ticket 的 "Blocked by" 设为阻塞它的那些 issue。如果来源是一个已有的 issue，就让每个 ticket 成为它的子 issue（按 tracker 文档里的操作）。除非另有指示，打上 `ready-for-agent` 分诊标签；这些 ticket 从构造上就是 agent 可以直接领取的。

沿着**前沿(frontier)**推进：所有阻塞项都已完成的 ticket。对一条纯线性的链来说，就是从上到下。

**不要**关闭或修改任何父 issue。

<local-ticket-template>

# <NN>: <Ticket 标题>

**What to build:** 这个 ticket 让哪个端到端的行为能跑起来，从用户的视角描述，而不是一份逐层的实现清单。

**Blocked by:** 卡住这个 ticket 的那些 ticket 的编号或标题，或者 "None (can start immediately)"。

**Status:** ready-for-agent

- [ ] 验收标准 1
- [ ] 验收标准 2

</local-ticket-template>

<issue-template>

## 父 issue

指向 tracker 上父 issue 的引用（如果来源是一个已有的 issue；否则省略这一节）。

## 要做什么

这个 ticket 让哪个端到端的行为能跑起来，从用户的视角描述，而不是逐层的实现。

## 验收标准

- [ ] 标准 1
- [ ] 标准 2

## Blocked by

- 指向每个阻塞 ticket 的引用，或者 "None (can start immediately)"。如果阻塞项已设为原生的边，就省略这一节。

</issue-template>

无论哪种形式，都避免写具体的文件路径或代码片段：它们很快就会过时。例外：如果某个原型产出了一段代码，它表达一个决策比文字更精确（状态机、reducer、schema、类型结构），就把它内联进来，并简短注明它来自原型。只保留富含决策的部分，不是一个能跑的 demo，只要关键的几处。
