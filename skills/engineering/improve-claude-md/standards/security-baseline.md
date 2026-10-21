# 安全基线

**适用条件：** 任何处理用户输入、认证或密钥的项目

**先探查：** `.gitignore` 是否忽略了 `.env`；密钥如何加载；认证中间件在哪

## 待定项

逐项拍板；本项目不需要的写「不适用」。每项都写成可检查的句子。

| 项 | 要定什么 | 例子 |
|---|---|---|
| 密钥 | 只从环境变量 / 密钥管理服务读取；`.env` 绝不提交 | 无 |
| 输入校验 | 在边界层用 schema 校验；内部代码信任已校验的数据 | zod、pydantic |
| 认证放在哪 | 哪一层做认证和授权检查；绝不散落在业务代码里 | 无 |
| 输出编码 | HTML 转义、参数化 SQL；绝不用字符串拼接查询 | 无 |
| 敏感操作 | 删除、权限变更和资金操作必须写审计日志 | 无 |

## 落点

- 第 1 层：在 `permissions.deny` 中加入 `Read(./.env)`、`Read(./.env.*)`、`Read(**/secrets/**)`
- 第 2 层：密钥扫描（gitleaks）和 SAST 放进 CI
- 第 5 层：要点写进 CLAUDE.md，细节引用本 plugin 的 `references/security-checklist.md`；深度审计走 `security-and-hardening`
