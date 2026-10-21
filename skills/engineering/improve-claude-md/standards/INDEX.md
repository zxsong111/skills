# 规范菜单索引

用「适用条件」列对照第 1 步的盘点结果筛选。不满足条件的就是不适用，写一句理由。

| # | 规范 | 模板 | 适用条件 |
|---|---|---|---|
| 1 | 代码风格与命名 | [coding-style.md](coding-style.md) | 任何有源代码的项目 |
| 2 | 目录结构与分层 | [architecture.md](architecture.md) | 有两个及以上模块 / 层的项目 |
| 3 | 错误处理与日志 | [errors-logging.md](errors-logging.md) | 任何要运行的服务 / 应用 |
| 4 | API / 接口设计 | [api-design.md](api-design.md) | 有对外的 HTTP / RPC / GraphQL 接口 |
| 5 | 数据与迁移 | [data-migrations.md](data-migrations.md) | 有数据库 schema 或迁移目录（`migrations/`、`alembic/`、`prisma/`） |
| 6 | 测试 | [testing.md](testing.md) | 有测试或打算写测试的项目 |
| 7 | Git 与 commit | [git-commits.md](git-commits.md) | 任何 git 仓库 |
| 8 | 代码审查 | [code-review.md](code-review.md) | 有多名贡献者或要求审查的仓库 |
| 9 | 依赖管理 | [dependencies.md](dependencies.md) | 有包管理器的项目 |
| 10 | 安全基线 | [security-baseline.md](security-baseline.md) | 任何处理用户输入、认证或密钥的项目 |
| 11 | 配置与环境 | [config-env.md](config-env.md) | 有多套环境或环境变量的项目 |
| 12 | 文档与 ADR | [docs-adr.md](docs-adr.md) | 对外交付或由多人维护的项目 |
| 13 | 性能与可观测性 | [performance-observability.md](performance-observability.md) | 后端服务，或有 SLA / 性能要求的项目 |
| 14 | 完成定义（Definition of Done） | [definition-of-done.md](definition-of-done.md) | 所有项目 |
| 15 | 金额 / 时间 / 时区 | [money-time.md](money-time.md) | 涉及金额、价格、税、报表或跨时区时间（POS、支付、电商、SaaS 计费） |
| 16 | 国际化 / 本地化 | [i18n.md](i18n.md) | 有多语言 UI 或服务多个地区的用户 |
| 17 | 并发与异步 | [concurrency.md](concurrency.md) | 有异步 IO、后台任务、队列、多线程或离线同步 |
| 18 | 类型安全 | [type-safety.md](type-safety.md) | TypeScript、带类型检查的 Python 等 |
| 19 | 前端 | [frontend.md](frontend.md) | 有 Web / 移动端 UI |
| 20 | 数据库访问 | [database-access.md](database-access.md) | 读写数据库的服务 |
| 21 | 缓存 | [caching.md](caching.md) | 使用 Redis / Memcached / 内存缓存 / CDN |
| 22 | 版本与发布 | [versioning-release.md](versioning-release.md) | 对外发布的库或应用，或有正式发布流程的服务 |
| 23 | CI/CD | [ci-cd.md](ci-cd.md) | 有 CI 流水线或部署流程 |
| 24 | 代码归属 | [code-ownership.md](code-ownership.md) | 多人或多个团队共同贡献的仓库 |
| 25 | 隐私与数据保留 | [privacy-retention.md](privacy-retention.md) | 处理个人数据（姓名、电话、邮箱、地址、支付信息） |
| 26 | 许可证合规 | [license-compliance.md](license-compliance.md) | 闭源商业项目，或 vendor 了第三方代码的项目 |
| 27 | Monorepo 边界 | [monorepo.md](monorepo.md) | 一个仓库里有多个包 / 服务（workspaces、`packages/`、`apps/`） |
| 28 | 语言约定 | [language-glossary.md](language-glossary.md) | 中英文混合的团队，或领域术语很多的项目 |
| 29 | Agent 规则（Claude 专属） | [agent-rules.md](agent-rules.md) | 所有使用 Claude Code 的项目 |

各层的定义见 [../SKILL.md](../SKILL.md) 第 4 步。
