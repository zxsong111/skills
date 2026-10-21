# 类型安全

**适用条件：** TypeScript、带类型检查的 Python 等

**先探查：** `tsconfig.json` 中的 strict、mypy / pyright 配置、当前 `any` / `type: ignore` 的数量

## 待定项

逐项拍板；本项目不需要的写「不适用」。每项都写成可检查的句子。

| 项 | 要定什么 | 例子 |
|---|---|---|
| strict | 打开 strict；已有项目给出逐步收紧的路径 | 无 |
| 不留逃生口 | `any`、`as unknown as`、`# type: ignore` 必须带注释说明原因 | `# type: ignore[attr-defined]  # 第三方库没有类型存根` |
| 公共接口 | 导出函数 / 公共方法必须标注参数和返回类型 | 无 |
| 运行时边界 | 外部数据进入系统时做运行时校验；不能只靠类型断言 | 无 |

## 落点

- 第 2 层：全部写进 tsconfig / mypy / pyright / eslint 配置，并作为「类型检查」门禁写进门禁表
- 第 5 层：CLAUDE.md 只写一句：「类型检查必须通过；任何逃生口都必须写明原因」
