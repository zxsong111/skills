## 它做什么

`improve-claude-md` 审计并改进项目的记忆文件（根目录的 `CLAUDE.md` 或 `AGENTS.md`、`.claude/rules/`，以及任何子目录下的 `CLAUDE.md`），然后逐项过一遍包含 29 个类别的规范菜单，生成这个项目真正会用的开发约定。它**自始至终先报告**(report-first)：先巡查仓库，报告问题和提案，等你批准，然后才写任何文件。老项目和新项目都适用。在老项目上，重点落在审计，它会查找：

- 缺失的章节
- 与仓库对不上的命令
- 空的质量门禁
- 泛泛而谈的套话
- 可以挪进 linter 的文字规则
- 写成全局、实际只对部分路径成立的规则
- 重复和矛盾
- 篇幅过长
- 过时的内容

每条约定都会标注它所落入的层：

| 约定 | 落在哪里 |
| --- | --- |
| 能用 `permissions.deny` 直接拦住 | 写在那里，绝不写成文字 |
| 能由 linter 强制 | linter 配置，而不是 `CLAUDE.md` |
| 属于判断性的 | `CODING_STANDARDS.md`，由 [code-review](https://aihero.dev/skills-code-review) 读取 |
| 每次[会话](https://www.aihero.dev/ai-coding-dictionary/session)都必须读到 | 根目录的 `CLAUDE.md`，它只保留这一类 |

## 什么时候用

输入 `/improve-claude-md`，或者在任务匹配时由 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 自动调用：比如你说「优化 CLAUDE.md」「清理 AGENTS.md」或「定规范」，或者问到代码风格、目录该怎么组织。你可以传一个参数来缩小范围，比如 `/improve-claude-md audit` 只做审计、不生成约定。

| 情况 | 用不用？ |
| --- | --- |
| 第一次把这套 skill 接入某个项目 | 用，在 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 之后 |
| 老项目的 `CLAUDE.md` 长达几百行，没人敢动 | 用，跑 `/improve-claude-md audit` |
| 架构设计已经批准，第一行代码还没写 | 用，先把约定定下来 |
| 一个单入口、没有对外接口的小脚本 | 不用，它也不会触发 |

它不碰 `docs/agents/*.md`、`GLOSSARY.md` 和 `docs/adr/`。那些归 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 和 [domain-modeling](https://aihero.dev/skills-domain-modeling) 管。

## 约定是总结出来的，不是编出来的

在非空仓库里，skill 会先抽样 8 到 12 个源文件，推断出已经在用的约定。它把建议改动的地方单独列出来，由你逐项在「以代码为准」和「以新约定为准」之间选择。只有空仓库才会拿到对应技术栈的主流默认值。每条约定都必须是一句可检查的话：「函数名使用 snake_case」，而不是「命名要清晰」。

## 常见问题

**它和 `retro` 有什么区别？**
[retro](https://aihero.dev/skills-retro) 回顾的是一次会话，从会话中发生的事推导出环境改进。`improve-claude-md` 审计的是整个仓库的记忆文件，不依赖任何会话。两者的产出落在同样的文件里，所以 `CLAUDE.md` 里的已知坑表格由两者共同维护。

**它会覆盖我手写的内容吗？**
不会。编辑已有章节时，它只替换占位注释、修正错误条目。已知坑只追加。已有的 `.editorconfig`、PR 模板或 `CODEOWNERS` 会被跳过并报告。

**29 个模板会全部加载吗？**
不会。它只读 `standards/INDEX.md` 来筛选，只有你勾选的模板才会被读进[上下文窗口](https://www.aihero.dev/ai-coding-dictionary/context-window)。

**我同时有 `CLAUDE.md` 和 `AGENTS.md`，怎么办？**
正文只能放在其中一个里。如果你也用 Codex，正文放在 `AGENTS.md`，`CLAUDE.md` 用 `@AGENTS.md` 引入它。如果只用 Claude，就全部合并进 `CLAUDE.md`。相互冲突的条目会列出来由你决定。

## 起作用的标志

- 第一轮回复是一张带 `file:line` 引用的问题表，外加一份待勾选的约定清单，工作区里没有任何文件被改动。
- 每条验证命令后面都跟着一段健康输出的样例，而且这段样例来自真实运行。
- 根目录的 `CLAUDE.md` 变短了，细节挪到了 `CODING_STANDARDS.md` 或 `.claude/rules/`。
- 写下的每条约定都能被检查：要么有命令支撑，要么是一句你能判断对错的话。

## 在体系中的位置

`improve-claude-md` 在这套 skill 进入项目时是一次**一次性设置**，之后是**定期维护**。它和 [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills) 一起构成地基。它的邻居是 [retro](https://aihero.dev/skills-retro)，因为它在会话层面做同一类工作；以及 [code-review](https://aihero.dev/skills-code-review)，因为它会读取这个 skill 写下的 `CODING_STANDARDS.md`。整套 skill 的地图在 [ask-matt](https://aihero.dev/skills-ask-matt) 里。
