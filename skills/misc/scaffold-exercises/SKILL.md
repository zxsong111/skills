---
name: scaffold-exercises
description: >
  创建能通过 lint 的练习目录结构，包含章节、题目、答案和讲解。当用户想搭建练习脚手架、创建练习占位，或新建一个课程章节时使用。触发短语：「搭建练习」「创建练习占位」「新建课程章节」，以及 "scaffold exercises"、"stub exercises"。
---

# 搭建练习脚手架

创建能通过 `pnpm ai-hero-cli internal lint` 的练习目录结构，然后用 `git commit` 提交。

## 目录命名

- **章节**：`exercises/` 下的 `XX-section-name/`（例如 `01-retrieval-skill-building`）
- **练习**：章节下的 `XX.YY-exercise-name/`（例如 `01.03-retrieval-with-bm25`）
- 章节编号 = `XX`，练习编号 = `XX.YY`
- 名称使用 dash-case（小写，用连字符连接）

## 练习变体

每个练习至少需要以下子目录之一：

- `problem/`：学生的工作区，带 TODO
- `solution/`：参考实现
- `explainer/`：概念讲解材料，不带 TODO

创建占位时，除非计划另有说明，默认使用 `explainer/`。

## 必需文件

每个子目录（`problem/`、`solution/`、`explainer/`）都需要一个 `readme.md`，它要满足：

- **不为空**（必须有实际内容，哪怕只有一行标题也行）
- 没有失效链接

创建占位时，写一个只含标题和描述的最小 readme：

```md
# 练习标题

在这里写描述
```

如果子目录里有代码，还需要一个 `main.ts`（多于 1 行）。但对于占位来说，只有 readme 的练习也没问题。

## 工作流程

1. **解析计划**：提取章节名称、练习名称和变体类型
2. **创建目录**：对每个路径执行 `mkdir -p`
3. **创建占位 readme**：每个变体目录一个带标题的 `readme.md`
4. **运行 lint**：用 `pnpm ai-hero-cli internal lint` 进行校验
5. **修复所有错误**：反复迭代，直到 lint 通过

## Lint 规则摘要

linter（`pnpm ai-hero-cli internal lint`）会检查：

- 每个练习都有子目录（`problem/`、`solution/`、`explainer/`）
- `problem/`、`explainer/` 或 `explainer.1/` 中至少存在一个
- 主子目录中存在 `readme.md` 且不为空
- 没有 `.gitkeep` 文件
- 没有 `speaker-notes.md` 文件
- readme 中没有失效链接
- readme 中没有 `pnpm run exercise` 命令
- 每个子目录都需要 `main.ts`，除非它只有 readme

## 移动/重命名练习

重新编号或移动练习时：

1. 用 `git mv`（而不是 `mv`）重命名目录，以保留 git 历史
2. 更新数字前缀以保持顺序
3. 移动之后重新运行 lint

示例：

```bash
git mv exercises/01-retrieval/01.03-embeddings exercises/01-retrieval/01.04-embeddings
```

## 示例：根据计划创建占位

给定这样一份计划：

```
Section 05: Memory Skill Building
- 05.01 Introduction to Memory
- 05.02 Short-term Memory (explainer + problem + solution)
- 05.03 Long-term Memory
```

创建：

```bash
mkdir -p exercises/05-memory-skill-building/05.01-introduction-to-memory/explainer
mkdir -p exercises/05-memory-skill-building/05.02-short-term-memory/{explainer,problem,solution}
mkdir -p exercises/05-memory-skill-building/05.03-long-term-memory/explainer
```

然后创建占位 readme：

```
exercises/05-memory-skill-building/05.01-introduction-to-memory/explainer/readme.md -> "# Introduction to Memory"
exercises/05-memory-skill-building/05.02-short-term-memory/explainer/readme.md -> "# Short-term Memory"
exercises/05-memory-skill-building/05.02-short-term-memory/problem/readme.md -> "# Short-term Memory"
exercises/05-memory-skill-building/05.02-short-term-memory/solution/readme.md -> "# Short-term Memory"
exercises/05-memory-skill-building/05.03-long-term-memory/explainer/readme.md -> "# Long-term Memory"
```
