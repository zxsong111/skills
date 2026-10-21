# 只对硬依赖显式指向 `/setup-matt-pocock-skills`

工程类 skill 依赖按仓库配置的设置（issue tracker、分诊标签词汇、领域文档布局），这些配置由 `/setup-matt-pocock-skills` 初始化。有些 skill 没有这些配置就无法正常工作：它们必须发布到某个特定的 issue tracker，或者打上某个特定的标签字符串。另一些 skill 只是用这些配置让输出更精准（词汇、对 ADR 的感知），没有它们也能优雅降级。

我们把它们分成**硬依赖**和**软依赖**两类 skill：

- **硬依赖**（`to-tickets`、`to-spec`、`triage`）：加上一句明确的话：_「……应该已经提供给你了；如果没有，运行 `/setup-matt-pocock-skills`。」_ 没有这份映射，输出就是错的，而不只是不够精准。
- **软依赖**（`diagnose`、`tdd`、`improve-codebase-architecture`）：只用模糊的文字提及「项目的领域术语表」和「你正在改动的区域里的 ADR」。如果这些文档不存在，skill 照样能用，只是输出没那么精准。

这样划分能让软依赖的 skill 保持 token 精简，也避免把 setup 指针生搬硬套到它并不起关键作用的地方。
