# Matt Pocock Skills

一组由 Claude Code 加载的 agent skill（slash command 和行为）。skill 按分类目录组织，由 `/setup-matt-pocock-skills` 生成的按仓库配置来使用。

## 语言

**Issue tracker**（issue 跟踪工具）：
托管一个仓库 issue 的工具：GitHub Issues、Linear、本地 `.scratch/` markdown 约定，或者类似的东西。`to-tickets`、`to-spec`、`triage` 这类 skill 会读写它。
_避免使用_：backlog manager、backlog backend、issue host

**Issue**（issue）：
**Issue tracker** 里一个被跟踪的工作单元：一个 bug、任务、spec，或者 `to-tickets` 产出的一个切片。
_避免使用_：ticket（只在引用把它们叫作 ticket 的外部系统时使用，或者用于 **Decision ticket**，见下文）

**Decision ticket**（决策 ticket）：
`wayfinder` 的工作单元：一个 `wayfinder:map` 的子 **Issue**，承载一个*问题*，它的解决结果是一个决策，而不是一段要执行的构建切片。**决策**这个限定词让它有别于实现类 ticket；`wayfinder` 先引入这个术语，之后就只说「ticket」。

**Triage role**（分诊角色）：
在分诊过程中贴到 **Issue** 上的一个标准状态机标签（例如 `needs-triage`、`ready-for-afk`）。每个角色都通过 `docs/agents/triage-labels.md` 映射到 **Issue tracker** 里一个真实的标签字符串。

## 关系

- 一个 **Issue tracker** 包含多个 **Issue**
- 一个 **Issue** 同一时间只带一个 **Triage role**
- 一个 **Decision ticket** 就是一个 **Issue**（一个 `wayfinder:map` 的子 issue）

## 已标记的歧义

- 「backlog」以前既用来指托管 issue 的*工具*，也用来指其中的*工作内容*。已解决：工具叫 **Issue tracker**；「backlog」不再作为领域术语使用。
- 「backlog backend」/「backlog manager」。已解决：合并为 **Issue tracker**。
