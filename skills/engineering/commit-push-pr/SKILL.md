---
name: commit-push-pr
description: >
  按 Git 规范 commit 当前改动，用户同意后再 push 并开 PR。带 branch 守卫：拒绝直接在主干（main / master）上 commit。
  commit message 使用 type(scope): short description 格式；改动超过 13 个文件或超过 3 个独立关注点时，先给出拆分建议。
  当用户说 "commit"、"commit this"、"open a PR"、"push it"、"merge it for me"、「提交一下」「开个 PR」「推上去」「帮我合并」，或运行 /commit-push-pr 时使用。
argument-hint: "[可选：用一句话概括这次改动]"
allowed-tools: Bash(git:*), Bash(gh:*), Read, Grep, Glob, Bash(tail:*)
---

# Commit、push、开 PR

## 0. 预取的上下文

### 当前仓库状态（已获取，不要重复运行这些命令）

- 当前 branch：!`git branch --show-current || true`
- 工作区：!`git status --short || true`
- diff 统计：!`git diff HEAD --stat | tail -20 || true`
- 最近的 commit：!`git log --oneline -5 || true`
- 远端主干：!`git branch -r --list 'origin/main' 'origin/master' 2>/dev/null || true`

### 本次改动的说明

$ARGUMENTS

> 以上内容在本 skill 加载时自动获取（无论是手动运行 `/commit-push-pr` 还是由模型触发，都一样）。正文后面再遇到同类命令时，**直接用上面的结果，不要重新运行**。

下面每一条都是硬性要求，并且自成一体；你不需要读任何外部文件。
如果项目根目录的 `CLAUDE.md` 规定了不同的 branch 策略，以项目为准。

### 1. Branch 守卫（先于一切）

**守卫保护的是仓库的主干，而不是字面上的 `main`。**`git init` 默认创建的是 `master`：名字不同，角色相同，同样要拦。
如果仓库用的是别的主干名（`trunk`、`dev` 之类），同理：关键在于它是不是这个仓库的主干，而不在于它叫什么。

如果当前 branch 是主干，**停下**，不要 commit。

「停下」的意思是：这一轮你**不运行** `git commit`，也**不运行** `git checkout -b` / `git switch -c` / `git branch -m`。
开哪个 branch、叫什么名字，由用户决定。把当前状态和可选方案摆出来，然后**结束这一轮，等用户回答**。
「至少不是 commit 到主干」不是开 branch 的理由：你自作主张选的 branch 名和基点，用户事后还得去改。

给用户看的选项：

```bash
# 从主干开一个功能 branch，再通过 PR 合回主干
git checkout -b feature/<module-name>

# 或者用户明确说「直接 commit 到主干就行」（在个人、单人维护的仓库里很常见）
```

如果用户选了「直接 commit 到主干」，就照做，并把这一点记到项目 `CLAUDE.md` 的「项目约定」下，免得每次都再问一遍。

### 例外：没有任何 commit 的仓库里的第一个 commit

守卫是用来阻止直接 commit 到**已有历史的主干**的。仓库还没有任何 commit 时，第一个 commit 总得落在某个地方，主干就是它正常的位置，所以**不要拦**：

```bash
git log --oneline -1 2>/dev/null   # 没有输出 = 没有任何 commit 的仓库，放行第一个 commit
```

放行之后，在收尾报告里提一句该定一下 branch 策略了，但不要卡住流程。

### 2. 先读改动，再写 message

工作区是干净的 → 说「没有可 commit 的内容」，然后停下。

否则读 `git diff`，看实际改了什么。**不要只凭文件名猜。**

### 3. 单个 commit 自查

- 改动文件超过 13 个，或独立关注点超过 3 个 → **先建议拆分**，给出怎么拆，等用户决定
- 一个 commit 只做一件事。混在一起的改动拆成多个 commit
- 对 spec、ticket、ADR 之类文档的修改**和实现放在同一个 commit 里**；文档和代码分开落地，它们又会慢慢对不上
- commit 之前，检查暂存区里有没有凭据（API key、token、私钥、`.env` 内容）：`git diff --cached | grep -niE 'api[_-]?key|secret|token|password|BEGIN .*PRIVATE KEY|AKIA[0-9A-Z]{16}'`。
  命中就停下，把位置指给用户看；改成读取环境变量或用占位符。凭据一旦进入历史就没法彻底清除，所以这一步没有「先 commit，回头再处理」一说

### 4. Commit message

格式 `type(scope): short description`：

- `type` 必填，取 `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore` 之一
- `scope` 可选：模块名
- 描述用祈使语气，简洁，**结尾不加句号**
- 不向后兼容 → 在 `type` 后面加 `!`，并在正文里写 `BREAKING CHANGE: <说明>`

最后加一行 `Co-Authored-By`，写**当前实际在运行的模型**（使用 system prompt 里给出的那一行，原样照用；不要硬编码旧名字）：

```
Co-Authored-By: <current model name> <noreply@anthropic.com>
```

### 5. Push：先征得同意

commit 完成后，**停下**，把 commit message 给用户看，并明确询问是否 push。
push 共享 branch 是别人看得见的，所以每次都要确认。**没得到同意之前不要 `git push`。**

### 6. 开 PR

push 获准后，运行 `git push -u origin <current-branch>`，然后以仓库主干为 base 开 PR：

```bash
gh pr create --base <trunk> --head <current-branch> --title "<与 commit 标题相同>" --body "<描述>"
```

PR 正文的结构交给 `pr` skill：用 Skill 工具调用 "pr"。它负责提供最精简的可视化摘要、改动前 / 改动后的证据，以及单向门还是双向门的判断。
在此之上，**必须有一个「验证」小节**，写明实际运行了什么、真实结果是什么：

```markdown
## 验证

| 检查项 | 命令 | 结果 |
|---|---|---|
| 构建 | pnpm build | 通过 |
| 测试 | pnpm test | 42/42 通过 |

未验证：<跳过了什么，以及原因>
```

- 内容来自**真正运行过的命令**
- **如果什么都没运行，就写「未验证：什么都没运行」**；不要编一张从头到尾都写着「通过」的表
- 跳过的检查必须明说。漏写比写「已跳过」更糟：后来的人会以为它验证过了

这一节是这次改动唯一能留存下来的证据：会话会结束，PR 不会。

在 PR 描述末尾追加：

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

如果仓库里有 `.github/PULL_REQUEST_TEMPLATE` 或 `pull_request_template.md`，正文按模板的结构来写。

### 7. 收尾

报告：commit 了什么、是否已 push、PR 链接。不要说「应该没问题」这类未经验证的话。
