# Standards menu index

Filter by the "Applies when" column against the step 1 inventory. Anything that doesn't meet its condition is not applicable; write a one-sentence reason.

| # | Standard | Template | Applies when |
|---|---|---|---|
| 1 | Coding style and naming | [coding-style.md](coding-style.md) | Any project with source code |
| 2 | Directory structure and layering | [architecture.md](architecture.md) | Projects with two or more modules / layers |
| 3 | Error handling and logging | [errors-logging.md](errors-logging.md) | Any service / app that runs |
| 4 | API / interface design | [api-design.md](api-design.md) | Has an external HTTP / RPC / GraphQL interface |
| 5 | Data and migrations | [data-migrations.md](data-migrations.md) | Has a database schema or migrations directory (`migrations/`, `alembic/`, `prisma/`) |
| 6 | Testing | [testing.md](testing.md) | Projects with tests, or that plan to write them |
| 7 | Git and commits | [git-commits.md](git-commits.md) | Any git repo |
| 8 | Code review | [code-review.md](code-review.md) | Repos with multiple contributors or required review |
| 9 | Dependency management | [dependencies.md](dependencies.md) | Projects with a package manager |
| 10 | Security baseline | [security-baseline.md](security-baseline.md) | Any project that handles user input, auth, or secrets |
| 11 | Config and environments | [config-env.md](config-env.md) | Projects with multiple environments or environment variables |
| 12 | Docs and ADRs | [docs-adr.md](docs-adr.md) | Projects delivered externally or maintained by several people |
| 13 | Performance and observability | [performance-observability.md](performance-observability.md) | Backend services, or projects with an SLA or performance requirements |
| 14 | Definition of Done | [definition-of-done.md](definition-of-done.md) | All projects |
| 15 | Money / time / time zones | [money-time.md](money-time.md) | Involves money, prices, taxes, reports, or times across time zones (POS, payments, e-commerce, SaaS billing) |
| 16 | Internationalization / localization | [i18n.md](i18n.md) | Has a multilingual UI or serves users in multiple regions |
| 17 | Concurrency and async | [concurrency.md](concurrency.md) | Has async IO, background jobs, queues, multithreading, or offline sync |
| 18 | Type safety | [type-safety.md](type-safety.md) | TypeScript, Python with type checking, and the like |
| 19 | Frontend | [frontend.md](frontend.md) | Has a web / mobile UI |
| 20 | Database access | [database-access.md](database-access.md) | Services that read and write a database |
| 21 | Caching | [caching.md](caching.md) | Uses Redis / Memcached / in-memory cache / CDN |
| 22 | Versioning and release | [versioning-release.md](versioning-release.md) | Libraries or apps released externally, or services with a formal release process |
| 23 | CI/CD | [ci-cd.md](ci-cd.md) | Has a CI pipeline or deployment process |
| 24 | Code ownership | [code-ownership.md](code-ownership.md) | Repos where several people or teams contribute |
| 25 | Privacy and data retention | [privacy-retention.md](privacy-retention.md) | Handles personal data (names, phone numbers, emails, addresses, payment info) |
| 26 | License compliance | [license-compliance.md](license-compliance.md) | Closed-source commercial projects, or ones that vendor third-party code |
| 27 | Monorepo boundaries | [monorepo.md](monorepo.md) | Several packages / services in one repo (workspaces, `packages/`, `apps/`) |
| 28 | Language conventions | [language-glossary.md](language-glossary.md) | Mixed Chinese and English teams, or projects heavy in domain terms |
| 29 | Agent rules (Claude-specific) | [agent-rules.md](agent-rules.md) | All projects that use Claude Code |

Layer definitions are in step 4 of [../SKILL.md](../SKILL.md).
