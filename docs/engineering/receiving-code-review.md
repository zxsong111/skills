## 它做什么

`receiving-code-review` 规定了 review 反馈到来后 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 该如何回应：全部读完，复述对方要求什么，对照代码库核实，判断它对这个代码库是否站得住，然后才去实现或提出异议。**技术上的正确先于社交上的舒适。**「You're absolutely right!」这类表演式的附和是禁止的，在核实任何东西之前就说「I'll fix that now」也一样。

它还会把教训反馈回去。同一类问题第二次被指出时，它会在同一个 PR 里往项目 `CLAUDE.md` 的已知坑(Known pitfalls)一节加一行。一条反复出现的判断性规则会变成对 `CODING_STANDARDS.md` 的建议，这样下一次 [code-review](https://aihero.dev/skills-code-review) 就会检查它。

## 什么时候用

输入 `/receiving-code-review`，或者在任务匹配时由 agent 自动调用：比如你把 review 意见粘贴给它，或者让它逐条处理一份 `code-review` 报告。

| 反馈来自 | 怎么处理 |
| --- | --- |
| 你（搭档） | 信任：理解后就实现，不过范围不清楚时它仍然会问 |
| 双轴的 `code-review` 报告 | 当作外部 review：改动任何东西之前逐条核实 |
| PR 上的外部 reviewer | 五项检查：对这个代码库是否正确，会不会弄坏别的东西，现有代码是否有其原因，是否在所有平台上都能工作，reviewer 是否掌握完整上下文 |

它管的是怎么接收反馈，而不是怎么给出反馈。要做 review，请用 [code-review](https://aihero.dev/skills-code-review)。

## 先问，再动手

如果六条意见里有两条不清楚，正确的做法是停下来把这两条问清楚，而不是先去做你看懂的那四条。意见之间往往相互关联，只理解一半就意味着实现会出错。干活的顺序是固定的：先处理阻塞问题，再处理简单的修复，最后处理复杂的修复，每一处修复都单独测试。

## 常见问题

**如果 reviewer 错了怎么办？**
基于技术理由提出异议：说明这个改动会弄坏什么，引用一个能工作的测试或代码，提出具体的问题。涉及架构时把搭档拉进来。如果最后发现是自己的异议错了，一句话（「Checked it, you're right」）加上修复就行，不需要长篇道歉。

**review 质疑的是需求本身，而不是实现。**
那不归 review 决定。这个 skill 会把问题原样摆到你面前，必要时回到 [grill-with-docs](https://aihero.dev/skills-grill-with-docs)。它不会为了让 reviewer 满意而去改 [spec](https://www.aihero.dev/ai-coding-dictionary/spec) 或 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket)。

**为什么连一句「谢谢」都不说？**
用行动说话。修好就继续：代码本身就表明反馈被听进去了。

## 起作用的标志

- 回复里没有「You're right」「Great point」或「Thanks for catching that」。
- 每条意见都有一行说明核实了什么、发现了什么，然后才决定改还是不改。
- 修复是一条意见配一个测试地逐个落地，而不是攒成一批、最后只跑一次测试。
- 同一类问题第二次被指出时，`CLAUDE.md` 的已知坑里会多一行。

## 在体系中的位置

`receiving-code-review` 是主流程(main flow)收尾处的**链路中的一步**：在 [code-review](https://aihero.dev/skills-code-review) 或 PR review 产生反馈之后、改动落地之前。它的邻居是 [code-review](https://aihero.dev/skills-code-review)，因为它产出这个 skill 接收的反馈；以及 [retro](https://aihero.dev/skills-retro)，因为它会系统地把反复出现的问题转化为对环境的改进。[ask-matt](https://aihero.dev/skills-ask-matt) 有整套 skill 的地图。
