# Git 与 commit

**适用条件：** 任何 git 仓库

**先探查：** `git branch -a`，最近 30 条 `git log --oneline` 的 commit 格式，是否存在 develop 分支

## 待定项

逐项拍板；本项目不需要的写「不适用」。每项都写成可检查的句子。

| 项 | 要定什么 | 例子 |
|---|---|---|
| 分支模型 | `main`+`develop` 双分支，还是只有主干 | 无 |
| 分支命名 | `feature/<module>`、`hotfix/<issue>`；小写加下划线 | `feature/cart_opt` |
| commit 格式 | Conventional Commits：`type(scope): description` | `fix(order): correct stacked discounts` |
| commit 粒度 | 一个 commit 只做一件事；格式化和逻辑改动分开提交 | 无 |
| PR 要求 | 描述中必须包含「验证」一节（实际运行过的命令及结果）；每个 PR 的规模上限 | 无 |
| 禁止 | 直接推送到 `main`；对共享分支 force push | 无 |

## 落点

- 第 1 层：在 `permissions.deny` 中加入 `Bash(git push --force:*)` 和 `Bash(git push origin main:*)`
- 第 2 层：commitlint / 分支保护规则（在托管平台上设置；在报告中提醒用户）
- 第 5 层：分支模型（只有主干，还是 main + develop）写进 CLAUDE.md「项目约定」；`commit-push-pr` 的分支保护逻辑以它为准
- 配套：没有 `.github/pull_request_template.md` 时生成一份

## 配套文件骨架

目标文件已存在时跳过，并在报告中说明。不要覆盖。

```markdown
## 改了什么

## 为什么

## 验证
<!-- 实际运行过的命令及结果；没有运行的，写「未验证」 -->

## 风险与回滚
```
