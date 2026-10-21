# Domain Docs

engineering 类 skill 在探索代码库时应该如何使用本 repo 的领域文档。

## 探索之前，先读这些

- repo 根目录下的 **`GLOSSARY.md`**，或者
- repo 根目录下的 **`GLOSSARY-MAP.md`**（如果存在）：它指向每个上下文各自的一个 `GLOSSARY.md`。阅读与主题相关的每一个。
- **`docs/adr/`**：阅读涉及你即将工作的区域的 ADR。在多上下文 repo 中，还要检查 `src/<context>/docs/adr/` 里限定于该上下文的决策。

如果这些文件中有任何一个不存在，**静默继续**。不要指出它们缺失；不要建议预先创建它们。`/domain-modeling` skill（通过 `/grill-with-docs` 和 `/improve-codebase-architecture` 触达）会在术语或决策真正被确定时按需创建它们。

## 文件结构

单上下文 repo（大多数 repo）：

```
/
├── GLOSSARY.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

多上下文 repo（根目录存在 `GLOSSARY-MAP.md`）：

```
/
├── GLOSSARY-MAP.md
├── docs/adr/                          ← 系统级决策
└── src/
    ├── ordering/
    │   ├── GLOSSARY.md
    │   └── docs/adr/                  ← 特定于上下文的决策
    └── billing/
        ├── GLOSSARY.md
        └── docs/adr/
```

## 使用术语表的词汇

当你的输出要说出一个领域概念时（在 issue 标题、重构提案、假设、测试名里），使用 `GLOSSARY.md` 中定义的术语。不要漂移到术语表明确避免使用的同义词上。

如果你需要的概念还不在术语表(glossary)里，这就是一个信号：要么你在发明项目并不使用的说法（重新考虑），要么确实存在空缺（记下来留给 `/domain-modeling`）。

## 指出与 ADR 的冲突

如果你的输出与某个现有 ADR 相矛盾，要明确指出来，而不是悄悄推翻它：

> _与 ADR-0007（事件溯源的订单）相矛盾，但值得重新讨论，因为……_
