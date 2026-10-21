# Productivity（效率）

通用的工作流工具，不限于代码。

## 用户手动调用

只有在你输入它们时才会触发（Claude Code：`disable-model-invocation: true`；Codex：`agents/openai.yaml` 里的 `policy.allow_implicit_invocation: false`）。

- **[grill-me](./grill-me/SKILL.md)**：就一个计划或设计接受毫不留情的追问，直到决策树的每个分支都有定论。
- **[handoff](./handoff/SKILL.md)**：把当前对话压缩成一份交接文档，让另一个 agent 能接着干。
- **[teach](./teach/SKILL.md)**：在多次会话中教用户一项新技能或新概念，把当前目录当作有状态的教学工作区。
- **[to-questionnaire](./to-questionnaire/SKILL.md)**：把一个你独自无法回答的决策，变成一份 Markdown 问卷，交给唯一能回答的那个人（可以异步填写，也可以开会时一起填）。
- **[wait-what](./wait-what/SKILL.md)**：一旦某条消息没看懂，马上用它。agent 会补上你缺的上下文，用大白话和你 `GLOSSARY.md` 里的词汇重新讲一遍。
- **[resume-handoff](./resume-handoff/SKILL.md)**：在一个新会话里，找到 `/handoff` 写下的文档，检查工作区是否仍与之相符，然后从它的下一步接着干。它是 `handoff` 的另一半。

## 模型自动调用

模型和用户都能触发（描述里写了丰富的触发短语，方便模型自动调用）。

- **[grilling](./grilling/SKILL.md)**：就一个计划、决策或想法毫不留情地追问用户，直到决策树的每个分支都有定论。
- **[writing-for-agents](./writing-for-agents/SKILL.md)**：为 agent 写文档：skill、AGENTS.md/CLAUDE.md，以及 agent 通过指针找到的任何文档。
- **[humanizer](./humanizer/SKILL.md)**：自动去掉写给人看的文字（PR 描述、README、文档、报告）里的 AI 腔：对照 26 种模式改写，不改变原意，不编造事实，只动文字，绝不碰代码。
- **[i-have-adhd](./i-have-adhd/SKILL.md)**：自动调整每一条回复的形态：第一行就是下一步行动，多步骤的工作编号列出，每轮都重申当前状态，没有开场白和结束语。说「stop adhd mode」可以在本次会话中关闭它。
