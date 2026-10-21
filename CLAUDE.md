skill 按分类目录（bucket）组织在 `skills/` 下：

- `engineering/`：日常写代码用
- `productivity/`：日常非代码工作流工具
- `misc/`：保留但很少用，不推广
- `in-progress/`：beta：有意公开，欢迎反馈，不随 plugin 发布
- `deprecated/`：不再使用

`engineering/` 或 `productivity/`（即**推广的**分类目录）里的每个 skill，都必须在顶层 `README.md` 中有引用，并在 `.claude-plugin/plugin.json` 的 `skills` 数组里有一项（Claude Code plugin 发布的正好就是推广的那一组）。`misc/`、`in-progress/` 和 `deprecated/` 里的 skill 两处都不能出现。

安装命令从 [.agents/install-block.md](./.agents/install-block.md) 原样复制。`.claude-plugin/marketplace.json` 是本仓库自己的 marketplace。除 Claude Code 外，所有 agent 都从它安装以获得自动更新，Claude Code 则使用 `claude-plugins-official`。改动这两个清单中的任何一个之后，运行 `claude plugin validate . --strict`。原因记录在 [ADR 0002](./.agents/adr/0002-ship-as-a-claude-code-plugin.md) 里。

顶层 `README.md` 里的每个 skill 条目，都必须把 skill 名链接到它的 `SKILL.md`。

每个分类目录都有一个 `README.md`，列出该目录里的每个 skill，并附一行描述，skill 名链接到它的 `SKILL.md`。推广分类目录的 `README.md` 和顶层 `README.md` 把条目分成**用户手动调用**（User-invoked）和**模型自动调用**（Model-invoked）两组；非推广分类目录的 `README.md`（`misc/`、`in-progress/`）用平铺列表。

`engineering/` 和 `productivity/` 里的 skill 还有一个写给人看的文档页，位于 `docs/<bucket>/<skill-name>.md`（docs 目录树镜像 `skills/` 下的这两个分类目录）。不管属于哪个分类目录，发布的 URL 都是 `https://aihero.dev/skills-<skill-name>`：docs 路径只是仓库内部的组织方式。当你新增、重命名 `engineering/` 或 `productivity/` 里的 skill，或改变它的行为时，按照 [.agents/writing-docs.md](./.agents/writing-docs.md) 创建或重新同步它的文档页。一个完成的文档页包含四个部分：**它做什么**、**什么时候用**、**常见问题**和**起作用的标志**。`writing-docs.md` 里有模板、各部分的顺序，以及去哪里找问题。非推广分类目录（`misc/`、`in-progress/`、`deprecated/`）里的 skill **没有**文档页。唯一的例外是被彻底删除的推广 skill：它的文档页保留，并标记为已归档（见 `writing-docs.md`）。

每个 `SKILL.md` 要么是用户手动调用的（`disable-model-invocation: true`，外加 `agents/openai.yaml` 里的 `policy.allow_implicit_invocation: false`，只有人能触发），要么是模型自动调用的（模型或用户都能触发）。见 [.agents/invocation.md](./.agents/invocation.md)。

[`ask-matt`](./skills/engineering/ask-matt/SKILL.md) 是路由器，它描绘了每个用户可触发的 skill 以及它们之间的关系。触发文档页重新同步的那些情况同样适用于它：每当你新增、重命名、删除一个用户可触发的 skill，或者改变它在各流程中的位置时，重新读一遍 `ask-matt` 的 `SKILL.md` 并更新它，让这张地图保持准确：一个它从未提到的新 skill，或者一个它仍在路由过去的过时 skill，都会让这个路由器说谎。

要把 `deprecated/` 和 `misc/` 之外的每个 skill（重新）链接到本地 harness 的 skill 目录（`~/.claude/skills`、`~/.agents/skills`），运行 `scripts/link-skills.sh`。每一项都是指向本仓库的符号链接，所以 `git pull` 就能让已安装的 skill 保持最新；新增、删除或重命名 skill 之后，重新运行这个脚本。

本仓库的所有文字（`SKILL.md` 文件、文档、`README.md`、`CHANGELOG.md`、ADR、changeset、代码注释）里都不使用破折号类标点：英文的长破折号和短破折号、中文的破折号，一律不用。当一个句子想用破折号时，改写这个句子，按句子真正需要的，换成逗号、冒号、句号、括号或连词；绝不做机械的字符替换。

## Agent skills

### Triage labels

使用标准名称，不做改动。见 `docs/agents/triage-labels.md`。issue 依据 [`SCOPE.md`](./SCOPE.md) 来判断。
