---
name: setup-ts-deep-modules
description: >
  在 TypeScript 仓库中接入 dependency-cruiser，让每个包都成为深模块：实现隐藏在子目录里，只能通过入口文件访问。用户手动调用。
disable-model-invocation: true
---

# Setup TS Deep Modules

让这个仓库里的每个包都成为**深模块（deep module）**：小接口背后承载大量行为。一个包的公开表面是它的**入口（entry point）**（位于包根目录的文件），子目录里的一切都是隐藏的。这个 skill 会安装 [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) 以及让入口成为唯一访问途径的规则，然后证明这些规则确实生效。

关于相关词汇（深模块、接口、接缝（seam）、深度），用「codebase-design」调用 Skill 工具，并在整个过程中使用它的语言。

## 要强制的结构

```
src/packages/
  <name>/
    index.ts        ← 一个入口（公开）。从外部导入这个文件。
    client.ts       ← 另一个入口。包可以暴露多个入口。
    lib/            ← 实现：对外隐藏，内部文件可以互相导入。
    tests/          ← 就近存放的测试和 fixture（是子目录，所以是私有的）。
```

公开表面是包的**根目录文件**，而不是某个指定的 `index.ts`。按照约定，实现放在 `lib/`，测试放在 `tests/`，让每个包都有相同的双目录结构。不过规则本身是通用的：*任何*子目录里的*任何*东西都是私有的，所以你永远不需要为了新增一个目录去扩展配置。

四条规则，级别都是 `error`：

1. **入口边界**：包外的代码（应用代码或其他包）只能导入该包的入口（它的根目录文件），绝不能导入其子目录里的任何东西。
2. **包内自由**：一个包自己的文件之间可以自由互相导入。
3. **测试通过入口进行**：`<pkg>/tests/` 下的文件可以导入任何包的入口以及自己 `tests/` 里的 fixture，但绝不能导入任何包（包括它自己的包）子目录里的内部实现。跨包的集成测试没问题；深层导入不行。
4. **禁止循环**：不允许依赖循环。

**用多个入口，而不是 barrel。** 因为公开表面是*每一个*根目录文件，一个包可以暴露几个小入口（`index.ts`、`client.ts`、`server.ts`），而不必把所有东西都塞进一个巨大的 `index.ts`。不鼓励使用重新导出整个子树的 barrel 文件；让入口保持小巧，把实现藏在子目录里。

分层（哪些包可以依赖哪些包）是*另一个*问题，在配置里留作一段注释掉的占位，由这个仓库自行填写。

## 步骤

### 1. 探测环境

- **包管理器**：`pnpm-lock.yaml` → pnpm，`yarn.lock` → yarn，`bun.lockb` → bun，否则 npm。下面每条命令都用它（`pnpm`/`yarn`/`npm run`/`bunx`）。
- **包根目录**：如果存在 `src/`，用 `src/packages`，否则用 `packages`。如果仓库已经有另一种明显的约定，先和用户确认这个选择。
- **已有配置**：检查是否存在 `.dependency-cruiser.*` 文件。如果存在，**不要**覆盖它：把四条规则和选项合并进去，并告诉用户你添加了什么。

**完成标志：** 包管理器、包根目录以及已有配置的情况都已明确。

### 2. 安装 dependency-cruiser

用探测到的包管理器把 `dependency-cruiser` 安装为 devDependency。

**完成标志：** `dependency-cruiser` 出现在 `devDependencies` 中。

### 3. 写入配置

把 [`dependency-cruiser.config.cjs`](./dependency-cruiser.config.cjs) 复制到仓库根目录，命名为 `.dependency-cruiser.cjs`。把 `PACKAGES_ROOT` 设为第 1 步探测到的根目录。这些规则基于路径深度，与文件扩展名无关，所以其他都不需要调整。

**完成标志：** `.dependency-cruiser.cjs` 已存在，`PACKAGES_ROOT` 正确，且四条 forbidden 规则都在。

### 4. 接入检查流程

- 添加一个 `lint:boundaries` 脚本：`depcruise <packages-root>`（或 `depcruise src`）。
- 把它并入仓库的总检查命令，也就是已经在跑类型检查的那个（例如 `check` / `ci` / `validate` 脚本）。**不要**改动 `tsconfig`，也不要添加路径别名。
- 如果没有总检查脚本，就添加 `lint:boundaries`，并告诉用户把它加进 CI。

**完成标志：** `lint:boundaries` 已存在，并且和类型检查在同一条命令中运行。

### 5. 搭建示例包

创建一个会被提交的 `<packages-root>/example/`，作为可复制的模板：

- `index.ts` 是一个入口。导出一个函数，委托给一个内部文件（这样这个包明显是*深*的，而不是简单的透传）。
- `lib/impl.ts`：位于**子目录**中的内部文件，由 `index.ts` 导入，外部无法访问。
- `tests/example.test.ts` **只**导入 `../index`（一个入口），并针对公开函数做断言。

告诉用户这是一个起步模板，可以复制也可以删除。

**完成标志：** 示例包已存在，通过根目录入口暴露行为，并把 `impl` 隐藏在子目录中。

### 6. 证明规则生效

这是整个 skill 的完成标准：一份在违规时不报错的配置毫无价值。

1. 运行 `lint:boundaries`。在干净的示例上它必须**通过**。
2. 临时在 `tests/example.test.ts` 中加入一个深层导入（例如 `import { thing } from "../lib/impl"`）。再次运行 `lint:boundaries`；它必须以 `tests-through-entrypoints` **失败**。
3. 撤销这个深层导入。再运行一次，它必须**通过**。

**完成标志：** 你已经观察到一次通过、一次因深层导入导致的失败、然后再次通过。如果第 2 步没有失败，说明规则没有正确接入，在结束前修好它。

### 7. 记录约定

在**包目录中**写一份 `README.md`（`<packages-root>/README.md`，就放在它所管辖的包旁边），内容包括：`src/packages/<name>/` 的布局（根目录放入口，`lib/` 放实现，`tests/` 放测试）、「只能通过包的入口（它的根目录文件）导入」，以及如何运行 `lint:boundaries`。明确地**不鼓励 barrel 文件**：暴露几个小入口，而不是通过一个 index 重新导出整个子树。内容只保留可复制的代码片段，外加四条规则，每条一段。

然后在仓库的 agent 指令文件（有 `CLAUDE.md` 就用它，否则用 `AGENTS.md`，两者都没有就创建 `AGENTS.md`）中加一条指向它的**上下文指针（context pointer）**。一行就够，例如 `Packages are deep modules: see [src/packages/README.md](./src/packages/README.md) before adding or importing one.`。正是这一行让 agent 能发现边界规则，而不是一头撞上它。

**完成标志：** `<packages-root>/README.md` 已存在并且不鼓励 barrel，仓库的 `CLAUDE.md`/`AGENTS.md` 链接到了它。

## 备注

- 配置中的 `$1` 反向引用（dependency-cruiser 的分组匹配）正是让包能访问自己的内部实现、而外部不能访问的关键。不要把它们拆平成按包单独编写的规则。
- 公开还是私有由**深度**决定：包的根目录文件是入口；子目录里的任何东西都是私有的。约定的子目录是 `lib/`（实现）和 `tests/`，但规则并没有把它们写死：任何子目录都是私有的，所以新增目录永远不需要改配置。新增一个入口只需新增一个根目录文件（不需要 barrel）。
- 包是**扁平的**：根目录下只有一层直接子目录。包的内部可以嵌套任意深度；但一个包不能包含另一个包。
- 使用 `.cjs`（而不是 `.js`），这样即使在 `"type": "module"` 的仓库里，配置中的 `module.exports` 也能正常工作。
