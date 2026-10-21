# Agent 规则（Claude 专属）

**适用条件：** 所有使用 Claude Code 的项目

**先探查：** 已有 `.claude/settings.json` 中的权限配置；用户口头反复强调过的禁令；「已知坑 / Claude 犯过的错」表格

## 待定项

逐项拍板；本项目不需要的写「不适用」。每项都写成可检查的句子。

| 项 | 要定什么 | 例子 |
|---|---|---|
| 自主边界 | 哪些事必须先问：删除文件、改 schema / 迁移、加依赖、改 CI、向外部推送、发消息 | 无 |
| 禁区 | 不许读、不许改的文件和目录 | 生成代码、`.env*`、`vendor/`、已发布的迁移 |
| 上下文卫生 | 遇到大目录先派一个 Explore subagent 探路；哪些文件是事实来源 | `openapi.yaml` 优先于代码注释 |
| 输出约定 | 回复语言、commit 署名、PR 描述格式 | 无 |
| 失败处理 | 同一个修复尝试失败 2 次就停下来报告；绝不为了让测试通过去改测试 / 断言；绝不使用 `--no-verify` | 无 |
| 完成标准 | 说「完成」之前，必须有命令输出作为证据 | 无 |

## 落点

- 第 1 层：禁区路径和危险命令放进 `.claude/settings.json` 的 `permissions.deny`（需用户批准）
- 第 5 层：自主边界和失败处理写进 CLAUDE.md「禁止事项 / 非目标」
- 第 6 层：回复语言等个人偏好写进 `CLAUDE.local.md`

## 配套文件骨架

目标文件已存在时跳过，并在报告中说明。不要覆盖。

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Edit(src/gen/**)",
      "Bash(git push --force:*)",
      "Bash(git commit --no-verify:*)"
    ]
  }
}
```
