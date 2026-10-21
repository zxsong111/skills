# 数据与迁移

**适用条件：** 有数据库 schema 或迁移目录（`migrations/`、`alembic/`、`prisma/`）

**先探查：** 迁移工具和目录；现有的表 / 列命名

## 待定项

逐项拍板；本项目不需要的写「不适用」。每项都写成可检查的句子。

| 项 | 要定什么 | 例子 |
|---|---|---|
| 命名 | 表名用复数 / 单数，列名 snake_case，外键 `<table>_id`，索引 `idx_<table>_<cols>` | 无 |
| 可回滚 | 每个迁移都必须有 down / 可回滚；不可回滚的要写明原因并经人工批准 | 无 |
| 不含业务逻辑 | 迁移不调用应用代码；数据回填用单独的脚本 | 无 |
| 大表变更 | 加列带默认值、并发建索引、避免锁表 | `CREATE INDEX CONCURRENTLY` |
| 已发布的迁移 | 一旦合入主分支，迁移文件绝不能再改；只能新增 | 无 |

## 落点

- 第 1 层：已发布的迁移目录可以在 `permissions.deny` 中加 `Edit(migrations/**)`，同时保留新建文件的 `Write` 权限
- 第 3 层：`.claude/rules/migrations.md`，`paths: ["migrations/**"]`
