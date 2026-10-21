---
name: setup-matt-pocock-skills
description: >
  为 engineering 类 skill 配置这个 repo：设置它的 issue tracker、分诊标签词汇表和领域文档布局。在首次使用其他 engineering skill 之前运行一次。
disable-model-invocation: true
---

# Setup Matt Pocock's Skills

搭建 engineering 类 skill 所假定的、每个 repo 各自的配置：

- **Issue tracker**：issue 存放在哪里（默认是 GitHub；本地 markdown 也开箱即用）
- **分诊标签**：五个规范分诊(triage)角色所使用的字符串
- **领域文档**：`GLOSSARY.md` 和 ADR 存放在哪里，以及读取它们的使用规则

这是一个由 prompt 驱动的 skill，而不是确定性的脚本。先探索，展示你的发现，和用户确认，然后再写入。

## 流程

### 1. 探索

查看当前 repo，了解它的初始状态。有什么就读什么；不要假设：

- `git remote -v` 和 `.git/config`：这是 GitHub repo 吗？是哪一个？
- repo 根目录下的 `AGENTS.md` 和 `CLAUDE.md`：两者有没有存在的？其中有没有已经包含 `## Agent skills` 一节的？
- repo 根目录下的 `GLOSSARY.md` 和 `GLOSSARY-MAP.md`
- `docs/adr/` 以及任何 `src/*/docs/adr/` 目录
- `docs/agents/`：这个 skill 之前的产出是否已经存在？
- `.scratch/`：这表明本地 markdown 形式的 issue tracker 约定已经在用了
- `triage` skill 装了吗？（与本 skill 并列的 `triage` skill 文件夹，或者你可用的 skill 里有 `triage`。）这决定了 B 部分是否需要执行。
- monorepo 信号：`pnpm-workspace.yaml`、`package.json` 里的 `workspaces` 字段，或者一个内容充实、各自带有 `src/` 的 `packages/*`。只有真正大型的多包 repo 才会有这些；没有它们就意味着单上下文，几乎所有 repo 都是这样。

### 2. 展示发现并提问

总结哪些已存在、哪些缺失。然后按顺序过各个部分。一个部分，一个回答，再下一个。

每个部分都以推荐答案开头，让用户一个字就能接受。只有当选择真的有分支时才给一行说明；如果探索已经有了定论，就整个跳过这一部分（`triage` 没装时跳过 B 部分，没有 monorepo 时跳过 C 部分）。

**A 部分：Issue tracker。**

> 说明：「issue tracker」是这个 repo 存放 issue 的地方。`to-tickets`、`triage`、`to-spec` 等 skill 会从中读取、向其写入。它们需要知道是该调用 `gh issue create`、在 `.scratch/` 下写一个 markdown 文件，还是遵循你描述的其他某种工作流。选你为这个 repo 实际跟踪工作的地方。

默认立场：这些 skill 是为 GitHub 设计的。如果有 `git remote` 指向 GitHub，就推荐 GitHub。如果有 `git remote` 指向 GitLab（`gitlab.com` 或自托管的主机），就推荐 GitLab。否则（或者用户另有偏好），提供这些选项：

- **GitHub**：issue 存放在 repo 的 GitHub Issues 中（使用 `gh` CLI）
- **GitLab**：issue 存放在 repo 的 GitLab Issues 中（使用 [`glab`](https://gitlab.com/gitlab-org/cli) CLI）
- **本地 markdown**：issue 以文件形式存放在这个 repo 的 `.scratch/<feature>/` 下（适合个人项目或没有远程仓库的 repo）
- **其他**（Jira、Linear 等）：请用户用一段话描述工作流；skill 会把它原样记录为自由格式的文字

把选择记录在 `docs/agents/issue-tracker.md` 中。GitHub 和 GitLab 模板带有一个 "PRs as a request surface" 标志，默认**关闭**。保持关闭，也不要提起它：想把外部 PR 纳入分诊队列的用户以后可以在文件里自己切换这个标志。

**B 部分：分诊标签词汇表。** 如果 `triage` skill 没有安装（探索已经告诉你了），就整个跳过这一部分，因为没安装的 skill 不需要标签。

如果已安装，只问一个问题：

> 要保留默认的分诊标签吗？（推荐：**是**）

默认值就是五个规范角色，每个标签字符串都等于它的名字：`needs-triage`、`needs-info`、`ready-for-agent`、`ready-for-human`、`wontfix`。回答**是**时，原样写入。只有当用户说不（通常是因为他们的 tracker 已经在用别的名字，例如用 `bug:triage` 表示 `needs-triage`）时，才收集这些覆盖值，让 `triage` 使用已有的标签而不是创建重复的标签。

**C 部分：领域文档。** 默认是**单上下文**（repo 根目录下一个 `GLOSSARY.md` + `docs/adr/`）。这适合几乎所有 repo；不用问，直接写。

只有当探索发现了 monorepo 信号时，才提供**多上下文**选项（根目录的 `GLOSSARY-MAP.md` 指向各个上下文的 `GLOSSARY.md` 文件）。然后确认他们想要哪种布局。

### 3. 确认并编辑

给用户看以下内容的草稿：

- 要加到 `CLAUDE.md` / `AGENTS.md` 中被编辑的那一个里的 `## Agent skills` 块（选择规则见第 4 步）
- `docs/agents/issue-tracker.md`、`docs/agents/domain.md` 和 `docs/agents/triage-labels.md` 的内容（最后一个仅在安装了 `triage` 时才有）

写入之前让他们先编辑。

### 4. 写入

**选择要编辑的文件：**

- 如果 `CLAUDE.md` 存在，编辑它。
- 否则如果 `AGENTS.md` 存在，编辑它。
- 如果两者都不存在，问用户要创建哪一个；不要替他们选。

当 `CLAUDE.md` 已经存在时，绝不要创建 `AGENTS.md`（反之亦然）；始终编辑已经存在的那个。

如果所选文件中已经有一个 `## Agent skills` 块，就原地更新它的内容，而不是再追加一个重复的。不要覆盖用户对周围各节的修改。

这个块：

```markdown
## Agent skills

### Issue tracker

[一句话概述 issue 在哪里跟踪]。见 `docs/agents/issue-tracker.md`。

### Triage labels

[一句话概述标签词汇表]。见 `docs/agents/triage-labels.md`。

### Domain docs

[一句话概述布局："single-context" 或 "multi-context"]。见 `docs/agents/domain.md`。
```

只有当安装了 `triage` 且执行了 B 部分时，才包含 `### Triage labels` 子块并写入 `docs/agents/triage-labels.md`。否则两者都省略。

当 B 部分在 GitHub 或 GitLab 上执行时，为 tracker 中缺少的每个已配置标签创建标签（`gh label create` / `glab label create`）。

然后以本 skill 文件夹中的种子模板为起点写入文档文件：

- [issue-tracker-github.md](./issue-tracker-github.md)：GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md)：GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md)：本地 markdown issue tracker
- [triage-labels.md](./triage-labels.md)：标签映射（仅在安装了 `triage` 时）
- [domain.md](./domain.md)：领域文档的使用规则 + 布局

对于「其他」类 issue tracker，根据用户的描述从零写出 `docs/agents/issue-tracker.md`。

### 5. 完成

告诉用户设置已完成，以及哪些 engineering skill 现在会读取这些文件。提一下他们以后可以直接编辑 `docs/agents/*.md`；只有想切换 issue tracker 或从头再来时，才需要重新运行这个 skill。
