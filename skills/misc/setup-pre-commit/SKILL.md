---
name: setup-pre-commit
description: >
  在当前仓库中配置 Husky pre-commit hook，集成 lint-staged（Prettier）、类型检查和测试。当用户想添加 pre-commit hook、配置 Husky、配置 lint-staged，或在提交时自动格式化/类型检查/测试时使用。触发短语：「添加 pre-commit」「配置 Husky」「提交前自动检查」，以及 "pre-commit hook"、"setup husky"、"lint-staged"。
---

# 配置 Pre-Commit Hook

## 会配置哪些东西

- **Husky** pre-commit hook
- **lint-staged**，对所有暂存文件运行 Prettier
- **Prettier** 配置（如果缺失）
- pre-commit hook 中的 **typecheck** 和 **test** 脚本

## 步骤

### 1. 探测包管理器

检查是否存在 `package-lock.json`（npm）、`pnpm-lock.yaml`（pnpm）、`yarn.lock`（yarn）、`bun.lockb`（bun）。哪个存在就用哪个。不确定时默认用 npm。

### 2. 安装依赖

安装为 devDependencies：

```
husky lint-staged prettier
```

### 3. 初始化 Husky

```bash
npx husky init
```

这会创建 `.husky/` 目录，并在 package.json 中添加 `prepare: "husky"`。

### 4. 创建 `.husky/pre-commit`

写入这个文件（Husky v9+ 不需要 shebang）：

```
npx lint-staged
npm run typecheck
npm run test
```

**调整**：把 `npm` 替换为探测到的包管理器。如果仓库的 package.json 中没有 `typecheck` 或 `test` 脚本，就省略对应的行，并告诉用户。

### 5. 创建 `.lintstagedrc`

```json
{
  "*": "prettier --ignore-unknown --write"
}
```

### 6. 创建 `.prettierrc`（如果缺失）

只有在不存在任何 Prettier 配置时才创建。使用以下默认值：

```json
{
  "useTabs": false,
  "tabWidth": 2,
  "printWidth": 80,
  "singleQuote": false,
  "trailingComma": "es5",
  "semi": true,
  "arrowParens": "always"
}
```

### 7. 验证

- [ ] `.husky/pre-commit` 存在且可执行
- [ ] `.lintstagedrc` 存在
- [ ] package.json 中的 `prepare` 脚本是 `"husky"`
- [ ] `prettier` 配置存在
- [ ] 运行 `npx lint-staged`，确认它能正常工作

### 8. 提交

暂存所有修改/新建的文件，并用这条消息提交：`Add pre-commit hooks (husky + lint-staged + prettier)`

这次提交会经过新的 pre-commit hook：正好是一次检验一切是否正常的冒烟测试。

## 备注

- Husky v9+ 的 hook 文件不需要 shebang
- `prettier --ignore-unknown` 会跳过 Prettier 无法解析的文件（图片等）
- pre-commit 先运行 lint-staged（快，只处理暂存文件），再运行完整的类型检查和测试
