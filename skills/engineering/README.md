# Engineering（工程）

我每天写代码时用的 skill。

## 用户手动调用

只有在你输入它们时才会触发（Claude Code：`disable-model-invocation: true`；Codex：`agents/openai.yaml` 里的 `policy.allow_implicit_invocation: false`）。

- **[ask-matt](./ask-matt/SKILL.md)**：问一问哪个 skill 或流程适合你当前的情况。它是本仓库所有用户手动调用 skill 的路由器。
- **[grill-with-docs](./grill-with-docs/SKILL.md)**：一次盘问会话，同时构建项目的领域模型，打磨术语，并随手更新 `GLOSSARY.md` 和 ADR。
- **[triage](./triage/SKILL.md)**：让 issue 在一个由分诊角色组成的状态机中流转。
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)**：扫描代码库寻找加深机会，以可视化 HTML 报告呈现，然后针对你选中的那个展开盘问。
- **[setup-matt-pocock-skills](./setup-matt-pocock-skills/SKILL.md)**：为工程类 skill 配置当前仓库（issue tracker、分诊标签、领域文档布局）。每个仓库运行一次。
- **[to-spec](./to-spec/SKILL.md)**：把当前对话整理成 spec 并发布到 issue tracker。
- **[to-tickets](./to-tickets/SKILL.md)**：把任何计划、spec 或对话拆成一组曳光弹 ticket，每个 ticket 声明自己的阻塞边，可以写成本地文件里的文本，也可以写成真实 tracker 上的原生阻塞链接。
- **[implement](./implement/SKILL.md)**：实现 spec 或一组 ticket 描述的工作，在事先约定的接缝处驱动 `/tdd`，并在 commit 之前用 `/code-review` 收尾。
- **[implement-spec](./implement-spec/SKILL.md)**：在一个集成分支上实现整个 spec。把 ticket 当作任务图来推进，在就绪的前沿上同时运行多个实现子 agent，尽可能提高并发，最后用 `/code-review` 收尾。
- **[wayfinder](./wayfinder/SKILL.md)**：规划一大块工作（一次 agent 会话装不下的那种），把它做成 issue tracker 上由决策 ticket 组成的共享地图，一次解决一个，直到通往目标的路变得清晰。
- **[retro](./retro/SKILL.md)**：在一次会话结束后，为编码 agent 的环境（导航、自动化检查、编码规范、引导文件、工具）提出改进建议，最严重的排在最前。

## 模型自动调用

模型和用户都能触发（描述里写了丰富的触发短语，方便模型自动调用）。

- **[prototype](./prototype/SKILL.md)**：构建一次性原型来回答一个设计问题：用于状态或逻辑问题的可分享单个 HTML 文件，或者几个可切换的 UI 变体。

- **[diagnosing-bugs](./diagnosing-bugs/SKILL.md)**：针对疑难 bug 和性能回退的有纪律的诊断循环：建立一个能在这个 bug 上变红的反馈回路 → 最小化 → 提出假设 → 埋点 → 修复 → 回归测试。
- **[research](./research/SKILL.md)**：对照高可信度的一手资料调查一个问题，并把结论整理成仓库里一个带引用的 Markdown 文件，以后台 agent 的方式运行。
- **[tdd](./tdd/SKILL.md)**：用红-绿-重构循环做测试驱动开发。一次一个垂直切片地构建功能或修复 bug。
- **[domain-modeling](./domain-modeling/SKILL.md)**：主动构建并打磨项目的领域模型：质疑术语，用场景做压力测试，并随手更新 `GLOSSARY.md` 和 ADR。
- **[codebase-design](./codebase-design/SKILL.md)**：设计深模块的共享方法纪律和词汇：小接口，干净的接缝，通过接口即可测试。
- **[code-review](./code-review/SKILL.md)**：对某个固定节点以来的 diff 做双维度审查：**Standards**（是否遵守仓库的编码规范，外加一套 Fowler 代码坏味道基线？）和 **Spec**（是否忠实实现了来源 issue 或 spec？），以并行子 agent 运行。
- **[pr](./pr/SKILL.md)**：PR 正文应有的结构：用能把改动讲清楚的最小可视化做摘要，给出改动前后能证明它有效的证据，并判断合并风险（单向门还是双向门，外加影响范围）。
- **[wizard](./wizard/SKILL.md)**：生成一个交互式 bash 向导，带人走完只有人能做的步骤：开通基础设施、配置凭据或 CI 密钥、在陌生的第三方控制台里操作，或者执行一次性的迁移或切换。
- **[commit-push-pr](./commit-push-pr/SKILL.md)**：按固定约定 commit、push 并开 PR，带主干保护（在 `main` / `master` 上会停下来询问，而不是直接 commit）。PR 正文交给 `pr` 来写。当你说「commit」或「push it」时，agent 会自动调用它。
- **[receiving-code-review](./receiving-code-review/SKILL.md)**：接收审查反馈（`code-review` 报告、PR 评论）时先验证再实现，不做表演式附和。反复出现的判断性规则会被沉淀进 `CODING_STANDARDS.md`。
- **[security-and-hardening](./security-and-hardening/SKILL.md)**：针对涉及认证、会话、支付、PII、文件上传、webhook、不可信外部输入或新依赖的改动的安全清单：先画出信任边界，再对照 OWASP 逐项加固。
- **[improve-claude-md](./improve-claude-md/SKILL.md)**：审计并改进项目的 `CLAUDE.md` / `AGENTS.md` / `.claude/rules/`（包括已有项目），然后从一份 29 项的菜单里生成这个项目真正需要的编码规范，每项都标明它应该放在哪一层。先报告，经批准后才写入。
