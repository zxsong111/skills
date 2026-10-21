# 进行中（In Progress）

Beta 阶段。这些 skill 是有意公开的：试试看，告诉我哪里坏了。在升级到稳定的目录之前，它们不会进入 plugin 和顶层 README，也没有文档页，而且可能随时变动或消失，不另行通知。

plugin 不会附带这些 skill。请单独安装：

```bash
npx skills@latest add mattpocock/skills --skill=<name>
```

- **[loop-me](./loop-me/SKILL.md)**：把当前目录当作有状态的工作区，跨多个会话盘问自己，产出可实现的工作流 spec。用户手动调用（user-invoked）。
- **[writing-beats](./writing-beats/SKILL.md)**：以「选择你自己的冒险」的方式，把文章塑造成一段由节拍（beat）组成的旅程。选一个起始节拍，只写这一拍，然后转向下一拍，直到文章自然收尾。
- **[writing-fragments](./writing-fragments/SKILL.md)**：一场盘问会话，从你身上挖掘片段（fragment，形态各异的写作素材），并追加到同一个文档中，作为未来文章的原始素材。
- **[writing-shape](./writing-shape/SKILL.md)**：拿一个装满原始素材的 markdown 文件，逐段塑造成文章，每一步都论证格式选择。
- **[claude-handoff](./claude-handoff/SKILL.md)**：通过 `claude --bg` 把当前对话交接给一个全新的后台 agent，附带交接摘要，让它立即接手工作。用户手动调用。
- **[setup-ts-deep-modules](./setup-ts-deep-modules/SKILL.md)**：在 TypeScript 仓库中接入 dependency-cruiser，让每个包都成为深模块（deep module）：实现隐藏在子目录里，只能通过入口文件访问，测试也通过这些入口来验证它。用户手动调用。
