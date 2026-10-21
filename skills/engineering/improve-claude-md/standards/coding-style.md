# 代码风格与命名

**适用条件：** 任何有源代码的项目

**先探查：** 已有的 linter/formatter 配置（eslint、biome、prettier、ruff、golangci-lint、.editorconfig）；抽样文件中实际使用的命名

## 待定项

逐项拍板；本项目不需要的写「不适用」。每项都写成可检查的句子。

| 项 | 要定什么 | 例子 |
|---|---|---|
| 文件命名 | kebab-case / snake_case / PascalCase，遵循语言惯例 | `order-service.ts`、`order_service.py` |
| 类型 / 类 | PascalCase | `OrderTotal` |
| 函数 / 变量 | camelCase 或 snake_case，与语言一致；布尔值以 is/has/can 开头 | `isPaid`、`has_discount` |
| 常量 | UPPER_SNAKE_CASE | `MAX_RETRY` |
| import 顺序 | 标准库 → 第三方 → 本项目，组间空一行；交给工具处理 | ruff `I`、eslint `import/order` |
| 文件长度 | 超过约 400 行，先考虑拆分 | 无 |
| 注释 | 解释「为什么」，而不是「做了什么」；绝不留下被注释掉的代码块 | 无 |

## 落点

- 第 2 层：formatter / linter 能处理的（缩进、引号、import 顺序、行宽）都写进配置，不写成文字
- 第 5 层：linter 管不到的命名语义（布尔前缀、领域术语）写进 CLAUDE.md「项目约定」
- 配套：没有 `.editorconfig` 时生成一份（缩进、换行符、文件末尾换行、字符集）

## 配套文件骨架

目标文件已存在时跳过，并在报告中说明。不要覆盖。

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.py]
indent_size = 4

[Makefile]
indent_style = tab
```
