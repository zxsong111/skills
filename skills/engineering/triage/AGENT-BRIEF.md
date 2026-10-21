# 编写 Agent 简报

agent 简报是一条结构化的评论，在 GitHub issue 或 PR 转为 `ready-for-agent` 时发布在上面。它是 AFK agent 据以工作的权威规格说明。原始正文和讨论只是上下文：agent 简报才是契约。

简报说明 **agent 应该做什么**，这一点适用于两种对象：对于 issue，就是从零开始实现这个改动；对于 PR，就是*在现有 diff 上*还剩什么要做：把它完成、补上缺口、处理审查意见。两者原则相同；下面的 PR 示例展示了区别。

## 原则

### 持久胜过精确

issue 可能会在 `ready-for-agent` 里放上几天甚至几周。在此期间代码库会变化。写简报时要让它在文件被重命名、移动或重构之后依然有用。

- **要**描述接口、类型和行为契约
- **要**点名 agent 应该查找或修改的具体类型、函数签名或配置结构
- **不要**引用文件路径：它们会过时
- **不要**引用行号
- **不要**假设当前的实现结构会保持不变

### 描述行为，而不是步骤

描述系统**应该做什么**，而不是**怎么实现**。agent 会重新探索代码库，自己做实现决策。

- **好：**「`SkillConfig` 类型应该接受一个可选的 `schedule` 字段，类型为 `CronExpression`」
- **差：**「打开 src/types/skill.ts，在第 42 行加一个 schedule 字段」
- **好：**「当用户不带参数运行 `/triage` 时，应该看到一份需要关注的 issue 摘要」
- **差：**「在主处理函数里加一个 switch 语句」

### 完整的验收标准

agent 需要知道什么时候算完成。每份 agent 简报都必须有具体、可测试的验收标准。每条标准都应该能独立验证。

- **好：**「运行 `gh issue list --label needs-triage` 返回已经过初步分类的 issue」
- **差：**「分诊应该正常工作」

### 明确的范围边界

说明哪些在范围之外。这能防止 agent 画蛇添足，或对相邻功能做出假设。

## 模板

```markdown
## Agent Brief

**Category:** bug / enhancement
**Summary:** 一句话描述需要发生什么

**Current behavior:**
描述现在发生什么。对于 bug，这是出错的行为。
对于 enhancement，这是新功能所依托的现状。

**Desired behavior:**
描述 agent 的工作完成后应该发生什么。
具体说明边界情况和错误条件。

**Key interfaces:**
- `TypeName`：需要改什么、为什么改
- `functionName()` 的返回类型：它现在返回什么，以及应该返回什么
- 配置结构：需要的任何新配置项

**Acceptance criteria:**
- [ ] 具体、可测试的标准 1
- [ ] 具体、可测试的标准 2
- [ ] 具体、可测试的标准 3

**Out of scope:**
- 在这个 issue 中**不应**改动或处理的事项
- 看似相关、实则独立的相邻功能
```

## 示例

### 好的 agent 简报（bug）

```markdown
## Agent Brief

**Category:** bug
**Summary:** skill description 截断时会在单词中间截断，产生残缺的输出

**Current behavior:**
当 skill description 超过 1024 个字符时，会不顾单词边界、恰好在
第 1024 个字符处截断。这会产生在单词中间结束的 description
（例如 "Use when the user wants to confi"）。

**Desired behavior:**
截断应该在 1024 个字符之前的最后一个单词边界处断开，
并追加 "..." 表示已截断。

**Key interfaces:**
- `SkillMetadata` 类型的 `description` 字段：类型不需要改，
  但填充它的校验/处理逻辑需要尊重单词边界
- 任何读取 SKILL.md frontmatter 并提取 description 的函数

**Acceptance criteria:**
- [ ] 不足 1024 个字符的 description 保持不变
- [ ] 超过 1024 个字符的 description 在 1024 个字符之前的
      最后一个单词边界处截断
- [ ] 截断后的 description 以 "..." 结尾
- [ ] 包括 "..." 在内的总长度不超过 1024 个字符

**Out of scope:**
- 修改 1024 字符这个上限本身
- 支持多行 description
```

### 好的 agent 简报（enhancement）

```markdown
## Agent Brief

**Category:** enhancement
**Summary:** 新增 `.out-of-scope/` 目录支持，用于记录被拒绝的功能请求

**Current behavior:**
功能请求被拒绝时，issue 会带着 `wontfix` 标签和一条评论被关闭。
没有关于这个决定或其理由的持久记录。以后出现类似请求时，
维护者需要回忆或搜索之前的讨论。

**Desired behavior:**
被拒绝的功能请求应该记录在 `.out-of-scope/<concept>.md` 文件中，
记下决定、理由，以及所有请求过这个功能的 issue 的链接。
分诊新 issue 时，应该检查这些文件是否有匹配。

**Key interfaces:**
- `.out-of-scope/` 中的 Markdown 文件格式：每个文件应该有一个
  `# Concept Name` 标题、一行 `**Decision:**`、一行 `**Reason:**`，
  以及一个带 issue 链接的 `**Prior requests:**` 列表
- 分诊流程应该尽早读取所有 `.out-of-scope/*.md` 文件，
  并按概念相似度把新进的 issue 与它们匹配

**Acceptance criteria:**
- [ ] 以 wontfix 关闭一个功能时，会在 `.out-of-scope/` 中创建或更新一个文件
- [ ] 文件包含决定、理由，以及被关闭 issue 的链接
- [ ] 如果已存在匹配的 `.out-of-scope/` 文件，新 issue 会被追加到
      它的 "Prior requests" 列表中，而不是新建一个重复文件
- [ ] 分诊期间会检查已有的 `.out-of-scope/` 文件，
      当新 issue 与先前的拒绝匹配时把它找出来

**Out of scope:**
- 自动匹配（由人来确认匹配）
- 重新开启之前被拒绝的功能
- bug 报告（只有被拒绝的 enhancement 才进 `.out-of-scope/`）
```

### 好的 agent 简报（PR）

对于 PR，"Current behavior" 描述的是 diff 的状态，简报要求 agent 把它完成或修好，而不是从零开始实现。

```markdown
## Agent Brief

**Category:** enhancement
**Summary:** 完成贡献者为 `triage list` 添加的 `--json` 输出参数

**Current behavior:**
这个 PR 添加了一个 `--json` 参数，把 issue 列表序列化为 JSON。正常路径
能跑通，diff 也符合项目的命令结构。还剩两个缺口：错误仍然以人类可读
文本（而不是 JSON）输出，以及这个新参数没有测试覆盖。

**Desired behavior:**
使用 `--json` 时，所有输出（包括错误）都是 stdout 上格式良好的 JSON，
命令的退出码保持不变。不带这个参数时，现有的人类可读输出不受影响。

**Key interfaces:**
- 在 `--json` 下，命令的错误路径应该输出 `{ "error": string }`，
  而不是纯文本错误
- 复用 PR 已经添加的那个序列化器；不要再引入第二个

**Acceptance criteria:**
- [ ] `triage list --json` 在成功和出错两种情况下都输出合法的 JSON
- [ ] 退出码与非 JSON 命令一致
- [ ] 有一个测试覆盖 `--json` 的成功输出和一个出错情况
- [ ] 默认（非 JSON）输出逐字节保持不变

**Out of scope:**
- 给其他任何命令添加 `--json`
- 修改 PR 已经定义好的成功载荷的 JSON 结构
```

### 差的 agent 简报

```markdown
## Agent Brief

**Summary:** 修一下分诊的 bug

**What to do:**
分诊那玩意儿坏了。看看主文件把它修好。
第 150 行附近那个函数有问题。

**Files to change:**
- src/triage/handler.ts (line 150)
- src/types.ts (line 42)
```

它差在：
- 没有类别
- 描述含糊（「分诊那玩意儿坏了」）
- 引用了会过时的文件路径和行号
- 没有验收标准
- 没有范围边界
- 没有描述当前行为与期望行为
