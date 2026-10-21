---
name: domain-modeling
description: >
  构建并打磨项目的领域模型。当讨论代码库术语、编写或修改 GLOSSARY.md、记录或修改 ADR 时使用。触发短语：「这个词到底指什么」「更新术语表」「记一条 ADR」「domain model」「update the glossary」「record an ADR」。
---

# 领域建模（Domain Modeling）

在设计过程中主动构建并打磨项目的领域模型（domain model）。这是一门*主动*的功夫：质疑术语、编造边界情况的场景，并在术语表（glossary）和决定一成形时就立刻写下来。（仅仅为了获取词汇而*读一下* `GLOSSARY.md` 不属于这个 skill：那是任何 skill 都能做的一行习惯。这个 skill 用于你要修改模型、而不只是消费模型的时候。）

## 文件结构

大多数仓库只有一个上下文（context）：

```
/
├── GLOSSARY.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

如果根目录下有 `GLOSSARY-MAP.md`，说明这个仓库有多个上下文。这张地图指明每个上下文所在的位置：

```
/
├── GLOSSARY-MAP.md
├── docs/
│   └── adr/                          ← 全系统范围的决定
├── src/
│   ├── ordering/
│   │   ├── GLOSSARY.md
│   │   └── docs/adr/                 ← 特定上下文的决定
│   └── billing/
│       ├── GLOSSARY.md
│       └── docs/adr/
```

文件用到时再创建：只有在有东西要写时才创建。如果没有 `GLOSSARY.md`，在第一个术语确定下来时创建。如果没有 `docs/adr/`，在需要第一条 ADR 时创建。

## 会话过程中

### 对照术语表提出质疑

当用户使用的某个术语与 `GLOSSARY.md` 中已有的语言冲突时，立即指出来。「你的术语表把 'cancellation' 定义为 X，但你似乎指的是 Y。到底是哪个？」

### 把模糊的语言说精确

当用户使用含糊或一词多义的术语时，提出一个精确的规范术语。「你说的是 'account'：你指的是 Customer 还是 User？这是两样不同的东西。」

### 讨论具体场景

讨论领域关系时，用具体场景对它们做压力测试。编造能探查边界情况的场景，迫使用户把概念之间的边界说精确。

### 与代码交叉核对

当用户陈述某个东西如何运作时，检查代码是否与之一致。如果发现矛盾，就提出来：「你的代码会取消整个 Order，但你刚才说可以部分取消。哪个是对的？」

### 当场更新 GLOSSARY.md

一个术语确定下来，就当场更新 `GLOSSARY.md`。不要攒起来批量处理：发生时就记下来。使用 [GLOSSARY-FORMAT.md](./GLOSSARY-FORMAT.md) 中的格式。

`GLOSSARY.md` 中应完全不含实现细节。不要把 `GLOSSARY.md` 当作 spec、草稿本或存放实现决定的地方。它就是一份术语表，别无其他。

### 谨慎地提议 ADR

只有当以下三条全部成立时，才提议创建 ADR：

1. **难以逆转**：以后改主意的代价不小
2. **没有上下文就会令人意外**：未来的读者会疑惑「他们为什么这么做？」
3. **是真实权衡的结果**：当时确实有别的选项，而你出于具体理由选了其中一个

三条中缺任何一条，就不写 ADR。使用 [ADR-FORMAT.md](./ADR-FORMAT.md) 中的格式。
