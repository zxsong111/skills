# Coding style and naming

**Applies when:** Any project with source code

**Probe first:** Existing linter/formatter config (eslint, biome, prettier, ruff, golangci-lint, .editorconfig); the naming actually used in sampled files

## Items to decide

Decide each item; write "not applicable" for any this project doesn't need. Phrase each one as a checkable sentence.

| Item | What to decide | Example |
|---|---|---|
| File naming | kebab-case / snake_case / PascalCase, following the language's convention | `order-service.ts`, `order_service.py` |
| Types / classes | PascalCase | `OrderTotal` |
| Functions / variables | camelCase or snake_case, matching the language; booleans start with is/has/can | `isPaid`, `has_discount` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY` |
| Import order | Standard library → third party → this project, blank line between groups; leave it to tooling | ruff `I`, eslint `import/order` |
| File length | Past about 400 lines, consider splitting first | none |
| Comments | Explain "why", not "what"; never leave commented-out code blocks | none |

## Where it lands

- Layer 2: everything a formatter / linter can handle (indentation, quotes, import order, line width) goes in config, not in text
- Layer 5: naming semantics the linter can't reach (boolean prefixes, domain terms) go in CLAUDE.md "Project conventions"
- Companion: with no `.editorconfig`, generate one (indentation, line endings, final newline, charset)

## Companion file skeleton

If the target file already exists, skip it and say so in the report. Don't overwrite it.

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
