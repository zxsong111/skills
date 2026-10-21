---
"mattpocock-skills": minor
---

新增 **`improve-claude-md`**（Engineering；模型自动调用，model-invoked）：审查并改进项目的 `CLAUDE.md`、`AGENTS.md` 和 `.claude/rules/`（包括老项目），并从一份 29 个类别的菜单（`standards/`）中生成这个项目可用的开发规范，为每条标注它落在哪一层。判断性的规则写入 `CODING_STANDARDS.md`，供 `code-review` 读取。它先报告，获得批准后才写入。来自 zxsong111/claude-config，去掉了 OpenSpec 相关小节。
