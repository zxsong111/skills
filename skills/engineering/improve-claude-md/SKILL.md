---
name: improve-claude-md
description: >
  审计并改进项目的 CLAUDE.md / AGENTS.md / .claude/rules/，并为项目生成开发规范（代码风格、分层、错误处理、
  API、测试、Git、依赖、安全、金额与时区、agent 规则等）。
  当用户说「优化 CLAUDE.md」「整理 AGENTS.md」「生成规则」「定规范」「定约定」「代码风格」「目录怎么分」，
  或 "optimize CLAUDE.md"、"clean up AGENTS.md"、"generate rules"、"set standards"、"set conventions"、
  "coding style"、"how should the directories be split" 时使用。老项目的 CLAUDE.md 长期无人维护、新项目刚接入这套
  skill、或架构设计已获批准但还没写第一行代码时，也使用。
  没有外部接口、没有持久化的单入口小脚本不需要它，不要触发。
argument-hint: "[可选：只做其中几项，例如 审计 / 命名 / 错误处理 / agent 规则]"
allowed-tools: Bash(git:*), Bash(ls:*), Bash(find:*), Bash(python3 -m json.tool:*), Read, Grep, Glob, Edit, Write, Bash(echo:*), Bash(grep:*), Bash(head:*), Bash(tr:*), Bash(wc:*)
---

# 改进 CLAUDE.md 与开发规范

## 0. 预取的上下文

### 仓库状态（预取）

- 已跟踪文件数：!`git ls-files 2>/dev/null | wc -l | tr -d ' ' || true`
- 顶层布局：!`ls -1 2>/dev/null | head -25 || true`
- 记忆文件：!`ls -1d CLAUDE.md CLAUDE.local.md AGENTS.md CODING_STANDARDS.md .claude/settings.json .claude/rules 2>/dev/null || echo "(none)"`
- 子目录 CLAUDE.md 文件：!`git ls-files '*/CLAUDE.md' 2>/dev/null | head -10 || true`
- CLAUDE.md 行数：!`wc -l < CLAUDE.md 2>/dev/null || echo 0`
- 技术栈与包管理器：!`ls -1 package.json pnpm-lock.yaml package-lock.json yarn.lock pyproject.toml uv.lock go.mod Cargo.toml pom.xml build.gradle Makefile 2>/dev/null || echo "(none)"`
- 已有的自动检查配置：!`ls -1 .eslintrc* eslint.config.* .prettierrc* biome.json ruff.toml .editorconfig tsconfig.json mypy.ini pyrightconfig.json 2>/dev/null || echo "(none)"`
- CI 与协作：!`ls -1 .github/workflows .gitlab-ci.yml .github/CODEOWNERS .github/pull_request_template.md 2>/dev/null || echo "(none)"`
- 领域文档与 tracker 配置：!`ls -1 GLOSSARY.md docs/adr docs/agents 2>/dev/null || echo "(none; consider running /setup-matt-pocock-skills first)"`

### 关注点

$ARGUMENTS

> 以上内容都在这个 skill 加载时自动获取（无论是用户用 `/improve-claude-md` 手动调用，还是模型自动触发，都一样）。正文后面再出现同类命令时，**直接用上面的结果，不要重跑**。

项目级 `CLAUDE.md` 是 Claude 每次会话都会读的唯一常驻上下文，`.claude/rules/` 则是按路径加载的
补充。写得好，同一个错误不会犯第二次；写得差，每次会话都在花 token 读噪音。

这个 skill 做三件事：**审计**已有的记忆文件，按下面的「目标结构」**补全**它们，
并**生成**项目真正会用到的开发规范，把每条规范放进约束力最强的那一层。

**全程先报告(report-first)：先报告，等批准，再写入。报告期间绝不改文件。**

## 0. 与其他 skill 的边界

| | 负责 |
|---|---|
| `setup-matt-pocock-skills`（由用户手动运行） | issue tracker、triage 标签和领域文档布局，写入 `docs/agents/*.md`。本 skill 不碰这些文件 |
| `domain-modeling` | 领域语言：`GLOSSARY.md` 和 ADR。本 skill 不写任何术语，只在 CLAUDE.md 里留指向它们的导航指针 |
| `retro` | 在对**单次会话**复盘后提出环境改进建议。本 skill 审计的是**整个仓库**的记忆文件。两者的产出落在同一组文件里 |
| `code-review` | 读取 `CODING_STANDARDS.md` 作为 Standards 维度的依据。本 skill 生成的判断性规范放在那里，供它对照审查 |
| 本 skill | **怎么写、怎么验证**：目录、命名、错误的**具体形式**、门禁命令、agent 的行为边界 |

## 1. 盘点（只读）

逐项检查。**不要凭记忆**：

```bash
ls -1 CLAUDE.md CLAUDE.local.md AGENTS.md CODING_STANDARDS.md .claude/settings.json .claude/rules/ 2>/dev/null
find . -name CLAUDE.md -not -path './node_modules/*' -not -path './.git/*'   # 子目录 CLAUDE.md 文件
git ls-files | head -80                                                       # 实际结构
ls -1 package.json pnpm-lock.yaml package-lock.json yarn.lock pyproject.toml uv.lock \
      go.mod Cargo.toml pom.xml build.gradle* Makefile 2>/dev/null           # 技术栈与包管理器
ls -1 .eslintrc* eslint.config.* .prettierrc* biome.json* ruff.toml .editorconfig \
      tsconfig*.json mypy.ini pyrightconfig.json 2>/dev/null                 # 已有的自动检查配置
ls -1 .github/workflows/ .gitlab-ci.yml .github/CODEOWNERS \
      .github/pull_request_template.md 2>/dev/null                           # CI 与协作
ls -1 GLOSSARY.md docs/adr docs/agents 2>/dev/null                           # 领域文档与 tracker 配置
```

读 `package.json` 里的 `scripts`、`pyproject.toml` 的工具配置段，以及 CI 配置实际运行的命令。
**抽样 8 到 12 个有代表性的源文件**，记下它们实际如何处理命名、错误处理、日志和返回格式。

## 2. 审计已有的记忆文件

### 目标结构

根目录的 `CLAUDE.md`（或 `AGENTS.md`）应包含以下章节，按此顺序。缺的章节不一定都要补，但每个章节要么有实在内容，要么就不存在：

| 章节 | 内容 |
|---|---|
| 项目简介 | 一两句话：这是什么、给谁用 |
| 技术栈 | 语言 / 框架 / 包管理器，从 lockfile 读取，带版本号 |
| 验证命令 | 安装、类型检查、构建、测试、本地启动。**每条后面附一段正常输出样例**（最后一行长什么样、退出码是多少）。跑不通的就不写 |
| 项目结构 | 只写目录名看不出来的东西：入口在哪、不能手改的生成代码、`GLOSSARY.md` 和 ADR 放在哪 |
| 项目约定 | 本项目特有的约定。只对部分路径成立的，放进 `.claude/rules/<topic>.md` |
| 禁止事项 / 非目标 | 不要碰的文件、不要加的依赖、明确的非目标 |
| 已知坑 / Claude 犯过的错 | 日期 / 现象 / 正确做法三列表格，只追加 |
| 质量门禁 | 门禁 / 命令 / 严重程度（阻断或警告）。门禁为空的行直接删掉 |
| 强制流程 | 条件 → 必须使用哪个 skill（需求模糊 → grill-with-docs；写功能 → tdd；遇到 bug → diagnosing-bugs；说「完成」之前 → 先跑验证命令；收尾 → code-review；构建结束后 → retro） |

### 逐项检查的问题

| 问题 | 例子 | 修法 |
|---|---|---|
| 缺章节 | 没有「验证命令」 | 根据探查结果补上 |
| 命令与仓库不符 | 写的是 `npm test`，但 lockfile 是 pnpm | 改成真实命令，并**实际运行一遍**确认 |
| 验证命令没有正常输出样例 | 只写了 `pnpm test`，没说通过时最后一行长什么样 | 跑一遍，把最后一行 / 退出码写成 `# healthy: …` |
| 空门禁 | 门禁表里某条命令是空的 | 整行删掉。空门禁比没有门禁更糟 |
| 泛泛的套话 | 「写清晰的代码」「注意安全」 | 删掉，或改写成可检查的句子 |
| 工具能强制的文字规则 | 「import 要排序」 | 挪进 linter 配置，删掉这段文字 |
| 判断性规则写在 CLAUDE.md 里 | 「各文件的错误处理风格保持一致」 | 挪到 `CODING_STANDARDS.md`，由 `code-review` 检查。在 CLAUDE.md 里留一行指针 |
| 只对部分路径成立 | 根 CLAUDE.md 里写着「迁移必须可回滚」 | 拆到 `.claude/rules/<topic>.md`，加 `paths:` |
| 重复 / 矛盾 | CLAUDE.md 和 AGENTS.md 各有一份，且内容不一致 | 合并成单一来源（见第 5 步） |
| 太长 | 根 CLAUDE.md 超过约 200 行 | 把细节下沉到 rules 或 CODING_STANDARDS.md。根文件只留全局条目和导航指针 |
| 过时 | 提到已删除的目录 / 脚本 | 删掉或改正 |
| 无效指令 | 读了也不会改变 agent 行为的句子 | 删掉 |

## 3. 规范菜单

读 [standards/INDEX.md](standards/INDEX.md)，拿每条的 **适用条件** 去对照盘点结果。
列出适用于本项目的规范。**不适用的写「不适用」并附一句理由。不要凑数。**

让用户勾选要生成哪些。每勾一项，就读对应的 `standards/<topic>.md` 模板，逐项填写：

- **在非空仓库里，规范是总结出来的，不是发明出来的。** 先用第 1 步的抽样推出「现行约定」。
  凡是偏离现行约定、而你认为应该改的地方，**单独列出来**，让用户逐条选择「以代码为准」还是「以新规范为准」。
  不要把它混进现行约定里当作事实
- **只有在空仓库里**，才给出该技术栈的主流默认做法：成熟、示例多的生态能让写出来的代码更可靠
- 每条都写成**可检查的句子**：「函数名使用 snake_case」，而不是「命名要清晰」

## 4. 落点分层

**给每条规范标上它落在哪一层。能放进更高层的，就不要在低层写成文字。**

| 约束力 | 机制 | 放什么 |
|---|---|---|
| 1 硬拦截 | `.claude/settings.json` 里的 `permissions.deny` / `ask`，PreToolUse hook | 禁区文件（`Edit(<dir>/**)`；`Write(...)` 规则不生效）、密钥（`Read(./.env)` 同时也会拦住 Edit / Grep）、危险命令。推送到主分支和合并走 `ask` |
| 2 工具强制 | linter / formatter / 类型检查器配置，CI 必过检查 | 命名、import 顺序、类型等机器可检查的条目 |
| 3 按路径生效 | `.claude/rules/<topic>.md` + `paths:` | 只对特定目录 / 文件类型成立的规则 |
| 4 目录级 | 子目录 `CLAUDE.md` | monorepo 中每个包自己的约定 |
| 5 全局文字 | 根 `CLAUDE.md`（或通过 `@AGENTS.md` 引入）**以及** `CODING_STANDARDS.md` | 全项目通用、但无法机器检查的条目。两个文件分工：根 CLAUDE.md 每次会话都会读，所以只放导航指针、验证命令、门禁、强制流程和已知坑。**判断性**规则（跨文件一致性、「与周边风格一致」）放进 `CODING_STANDARDS.md`，由 `code-review` 的 Standards 维度在审查时读取，因此实现阶段不占上下文 |
| 6 个人，不提交 | `CLAUDE.local.md`、`~/.claude/rules/` | 个人偏好，不进团队配置 |

机械性的规则（固定语法、禁用的 API、文件位置）一律落到第 1 层或第 2 层，绝不写成文字。这与 `retro` 的分类规则一致。

`.claude/rules/` 文件格式：

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/server/**/*.ts"
---

# API 规范

- 每个对外接口都返回 `{ data, error }`，其中 `error` 为 `{ code, message }`
- ...
```

不带 `paths:` 的 rules 文件对整个项目生效，等同于写在根 CLAUDE.md 里。这种情况就直接写进 CLAUDE.md；
不要为了结构看起来整齐而拆文件。

## 5. CLAUDE.md 与 AGENTS.md

这两个文件**必须是单一来源**。问用户：项目是否还在用 Codex 或其他读取 AGENTS.md 的工具：

- **两者都用**：正文放在 `AGENTS.md`。`CLAUDE.md` 只保留一行 `@AGENTS.md`，外加 Claude 专属的章节
  （强制流程，以及 agent 规则中只适用于 Claude 的部分）
- **只用 Claude**：正文放在 `CLAUDE.md`。把已有的 `AGENTS.md` 内容合并进来之后，
  问用户是删掉它，还是缩成一行指向 CLAUDE.md 的说明

合并时去重。有冲突的条目列出来让用户决定，不要自己挑。

## 6. 报告（到此为止，等待批准）

```
## 项目记忆审计与规范提案

### A. 已有文件中的问题（按影响排序）
| 文件:行 | 问题 | 建议 |

### B. 适用的规范（勾选要生成的）
- [ ] 代码风格与命名。理由：<盘点中的证据>
- [ ] ...
不适用：API / 接口设计（没有对外接口）；缓存（未使用缓存）

### C. 要新建 / 修改的文件
| 文件 | 操作 | 层 | 摘要 |
| CLAUDE.md | 修改 | 5 | 新增「验证命令」，删掉 3 行套话 |
| CODING_STANDARDS.md | 新建 | 5 | 4 条错误处理与日志规则，审查时读取 |
| .claude/rules/migrations.md | 新建 | 3 | paths: migrations/** |
| .claude/settings.json | 修改 | 1 | 在 permissions.deny 中新增 4 条 |

### D. 与现有代码不一致、需要你拍板的地方
- <现状> → <提议>，理由：<原因>

### E. AGENTS.md 的处理方式：<提议>

确认后，我会写入表 C 中的全部内容。如果想改其中某一行，现在就说。
```

**用户批准之前不写任何文件。**

## 7. 写入

- **不要覆盖用户写的内容**：修改已有章节时，替换占位注释、改正错误条目，其余保持原样。
  已存在的 `.editorconfig`、PR 模板、`CODEOWNERS` 等**跳过并在报告中说明**，不覆盖
- 「已知坑 / Claude 犯过的错」章节**只追加，绝不删除**
- `.claude/settings.json`：合并，不覆盖。`allow` 里不放任何写操作（`git push`、`git reset --hard`、
  `gh pr merge`）；`deny` 里只放用户批准过的条目。写完用 `python3 -m json.tool` 校验
- 不要写依赖特定机器的工具或路径：这份配置必须在一台全新的机器上也能用
- 门禁表里的每条命令都要先**实际运行**。失败的就不写，并在报告里说明
- `docs/agents/*.md`、`GLOSSARY.md`、`docs/adr/` 一个字都不要动。它们归 `setup-matt-pocock-skills` 和 `domain-modeling` 管
- 只写最终决定的内容，不写讨论过程和被否决的方案

## 收尾

说明改了哪些文件、每条规范落在哪一层、哪些被判定为不适用、哪些因为已存在而跳过、
哪些门禁命令失败而没有写入。

再提醒一句：**规范必须随项目演进。** 规范变了代码没变，或者代码变了规范没变，
都比没有规范更糟，因为大家会以为它仍然成立。Claude 在这个项目里犯了新错误时，往「已知坑 / Claude 犯过的错」加一行。构建结束后运行 `/retro`，它会系统地把这些发现找出来。
