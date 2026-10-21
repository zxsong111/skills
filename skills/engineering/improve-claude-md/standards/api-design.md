# API / 接口设计

**适用条件：** 有对外的 HTTP / RPC / GraphQL 接口

**先探查：** 路由定义、OpenAPI / proto 文件、现有接口如何处理命名和分页

## 待定项

逐项拍板；本项目不需要的写「不适用」。每项都写成可检查的句子。

| 项 | 要定什么 | 例子 |
|---|---|---|
| 资源命名 | 复数名词，kebab-case 路径；RPC 用动宾结构 | `GET /orders/{id}` |
| 版本 | URL 前缀还是 header；什么时候升主版本 | `/v1/` |
| 分页 / 过滤 / 排序 | 统一的参数名和响应结构 | `?cursor=&limit=`，返回 `next_cursor` |
| 幂等 | 写操作支持 `Idempotency-Key`；PUT/DELETE 天然幂等 | 无 |
| 向后兼容 | 只增不删；字段先废弃一个版本周期再删除 | 无 |
| 契约优先 | 先改 OpenAPI / proto，再改实现 | 无 |

## 落点

- 第 2 层：有 OpenAPI / proto 的，在 CI 里加 lint（spectral、buf lint）和破坏性变更检查（buf breaking、oasdiff）
- 第 3 层：`.claude/rules/api.md`，`paths:` 限定在路由 / handler 目录
