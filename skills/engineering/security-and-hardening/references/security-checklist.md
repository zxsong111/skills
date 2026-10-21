# 安全清单

Web 应用安全速查。配合 `security-and-hardening` skill 使用。

## 目录

- [威胁建模（从这里开始）](#threat-modeling-start-here)
- [提交前检查](#pre-commit-checks)
- [认证](#authentication)
- [授权](#authorization)
- [输入校验](#input-validation)
- [安全响应头](#security-headers)
- [CORS 配置](#cors-configuration)
- [数据保护](#data-protection)
- [依赖安全](#dependency-security)
- [AI / LLM 安全](#ai--llm-security)
- [错误处理](#error-handling)
- [OWASP Top 10 速查](#owasp-top-10-quick-reference)
- [OWASP LLM Top 10 速查](#owasp-top-10-for-llms-quick-reference)

## Threat Modeling (Start Here)

在动手加控制措施之前，先花五分钟像攻击者一样思考：

- [ ] 画出了信任边界（请求、上传、webhook、第三方 API、LLM 输出，以及由你无法控制的进程写下的本地值）
- [ ] 列出了资产（凭据、PII、支付数据、管理员操作、资金流转）
- [ ] 对每条边界过了一遍 STRIDE（Spoofing、Tampering、Repudiation、Info disclosure、DoS、Elevation）
- [ ] 在用例旁边写下了滥用用例（「我会怎么滥用它？」）

## Pre-Commit Checks

- [ ] 代码中没有密钥（`git diff --cached | grep -i "password\|secret\|api_key\|token"`）
- [ ] `.gitignore` 覆盖了：`.env`、`.env.local`、`*.pem`、`*.key`
- [ ] `.env.example` 使用占位值（不是真实密钥）

## Authentication

- [ ] 密码用 bcrypt（≥12 轮）、scrypt 或 argon2 哈希
- [ ] 会话 cookie：`httpOnly`、`secure`、`sameSite: 'lax'`
- [ ] 配置了会话过期（合理的 max-age）
- [ ] 登录接口有限流（每 15 分钟 ≤10 次尝试）
- [ ] 密码重置 token：有时效（≤1 小时）、一次性
- [ ] 多次失败后锁定账户（可选，需附带通知）
- [ ] 敏感操作支持 MFA（可选，但推荐）

## Authorization

- [ ] 每个受保护接口都检查认证
- [ ] 每次资源访问都检查归属/角色（防止 IDOR）
- [ ] 管理员接口要求验证管理员角色
- [ ] API key 的权限限定在最小必要范围
- [ ] JWT token 经过校验（签名、过期时间、签发者）

## Input Validation

- [ ] 所有用户输入都在系统边界处校验（API 路由、表单处理器）
- [ ] 校验使用白名单（而不是黑名单）
- [ ] 字符串长度有约束（最小/最大）
- [ ] 数值范围经过校验
- [ ] 邮箱、URL 和日期格式用合适的库校验
- [ ] 文件上传：限制类型、限制大小、校验内容
- [ ] SQL 查询参数化（不做字符串拼接）
- [ ] HTML 输出经过编码（使用框架的自动转义）
- [ ] 重定向前校验 URL（防止开放重定向）
- [ ] 服务端 URL 请求使用白名单；拦截私有/保留 IP（防止 SSRF）
- [ ] 破坏性路径操作（删除/移动/覆盖）：已解析 symlink、白名单根目录、最小深度、调用前读取归属证据

### Destructive Path Operations

对由数据指定的目标做隔离限定。先解析，再判断，并把结果当作候选，而不是授权：

```typescript
import { realpath, readFile } from 'node:fs/promises';
import { resolve, relative, isAbsolute, join, sep } from 'node:path';

const ALLOWED_ROOTS = ['/var/lib/myapp/sessions']; // 一个白名单，不是一个匹配模式
const MIN_DEPTH = 1;                               // 让根目录永远不会成为目标

async function resolveDeletable(candidate: string, expectedOwner: string) {
  const target = await realpath(resolve(candidate)); // 在检查之前解析 symlink
  const inRoot = ALLOWED_ROOTS.some((root) => {
    const rel = relative(root, target);
    // 只拒绝 `rel === '..'` / `'../'`：单纯的 `startsWith('..')` 也会
    // 拒绝一个名为 `..cache` 的合法子目录。
    if (rel === '' || rel === '..' || rel.startsWith(`..${sep}`) || isAbsolute(rel)) return false;
    return rel.split(sep).length >= MIN_DEPTH;
  });
  if (!inRoot) throw new Error(`refusing: outside allowed roots (${target})`);

  const owner = await readFile(join(target, '.owner'), 'utf8').catch(() => null);
  if (owner?.trim() !== expectedOwner) throw new Error(`refusing: unproven owner (${target})`);
  return target;
}
```

它做不到的事，必须在复制这段代码的地方写明：

- **标记文件是自我证明。** 任何能在根目录内写东西的人都能写
  `.owner`。`expectedOwner` 必须来自经过认证的状态，而且标记文件需要
  完整性保护（严格的文件归属，或 MAC），它才算是授权，
  而不只是针对错误推导出的目标做的一致性检查。
- **返回一个路径会留下检查与使用之间的竞态。** 在不可信进程能于检查和调用之间替换
  某个上级目录的地方，要通过文件描述符操作，并使用 no-follow、
  限定在根目录之下的语义，或者保证目录层级在操作期间不可变。

## Security Headers

```
Content-Security-Policy: default-src 'self'; script-src 'self'
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 0  (已禁用，依靠 CSP)
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

## CORS Configuration

```typescript
// 严格限制（推荐）
cors({
  origin: ['https://yourdomain.com', 'https://app.yourdomain.com'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
})

// 生产环境中绝不要用：
cors({ origin: '*' })  // 允许任何 origin
```

## Data Protection

- [ ] API 响应中排除了敏感字段（`passwordHash`、`resetToken` 等）
- [ ] 不记录敏感数据（密码、token、完整信用卡号）
- [ ] PII 静态加密（如果法规要求）
- [ ] 所有外部通信使用 HTTPS
- [ ] 数据库备份已加密
- [ ] 个人数据已分类，按明确用途收集，并做了最小化
- [ ] 个人数据有保留期限和可用的删除路径（包括备份、缓存、索引）
- [ ] 在要求的地方支持导出/删除（数据主体）请求；向第三方共享有用户同意和数据处理协议

## Dependency Security

先定位**安装边界**。如果这个包被上级的 `workspaces` 声明匹配到，就使用那个 workspace 根目录；否则使用最近的、同时拥有自己的 manifest 和依赖图的项目根目录。在这个边界上，相互印证 `packageManager`（如果有）、lockfile 和 CI 命令。如果三者不一致，或者那里存在相互竞争的包管理器 lockfile，就停下来。只有当嵌套项目位于上级 workspace 之外时，它才是独立项目；独立的子项目可以合理地使用不同的包管理器。

| 包管理器/版本信号 | CI 中的 frozen/immutable 安装 | 已知安全公告审计 |
|---|---|---|
| npm（`package-lock.json` 或 `npm-shrinkwrap.json`） | `npm ci` | `npm audit` |
| pnpm | `pnpm install --frozen-lockfile` | `pnpm audit` |
| Yarn 2+ | `yarn install --immutable` | `yarn npm audit -A -R` |
| Yarn 1 | `yarn install --frozen-lockfile` | `yarn audit` |

对于未列出的包管理器或版本，查阅它的官方文档；不要套用另一个包管理器的命令或更新版本的默认值。

### 安装脚本闸门

绝不要在一个默认行为尚未核实的客户端上，靠先执行一次普通安装来发现依赖的生命周期脚本。

1. 以禁用依赖脚本的方式完成初次安装，或者使用一份有文档的默认拒绝策略并配合 fail-closed 的强制执行。
2. 批准之前，检查确切的脚本源码和包版本。
3. 在安装边界上记录范围最窄的原生 allow/deny 策略，并提交它。
4. 在该策略下做一次干净的 frozen/immutable 安装，确认需要构建的包仍然能构建。

**时间点快照：** 包管理器的默认行为和命令名变化很快。依赖这张矩阵之前，先对照所固定客户端版本当前的官方文档核实。

| 包管理器版本 | 原生策略 |
|---|---|
| 未经核实支持细粒度批准的 npm | 用 `npm ci --ignore-scripts` 完成初次安装，或者在确实要全项目拦截时持久化 `ignore-scripts=true`。在允许任何已审查的依赖脚本之前，保持脚本禁用，或者有意识地升级。 |
| npm 11.18.x（已在 11.18.0 上验证） | 未审查的依赖脚本默认会运行，只给出警告。在普通安装之前强制设置 `strict-allow-scripts=true`，然后在安装边界处使用不感知 workspace 的 `npm install-scripts ls`；批准要锁定版本，拒绝按包名整体生效。 |
| npm 12.x（已在 12.0.1 上验证） | 未审查的依赖脚本默认被跳过；`strict-allow-scripts=true` 会让安装在执行前因为存在这类脚本而失败。使用同样的 `npm install-scripts` 审查与批准流程。 |
| pnpm 11+ | 使用 `pnpm approve-builds` 并提交 `allowBuilds` 决定；`strictDepBuilds` 默认为 `true`，所以未审查的构建会失败。 |
| pnpm 10.26 至 10.x | 显式配置 `allowBuilds`，或者使用 `pnpm approve-builds` 配合旧版的 `onlyBuiltDependencies` / `ignoredBuiltDependencies` 列表。设置 `strictDepBuilds: true`；它在 v10 中的默认值是 `false`。 |
| pnpm 10.1 至 10.25 | `pnpm approve-builds` 记录旧版列表；在支持的版本（10.3+）上启用 `strictDepBuilds`。 |
| 更旧或未知版本的 pnpm | 用 `pnpm install --frozen-lockfile --ignore-scripts` 完成初次安装。除非所固定的版本文档中有可强制执行的策略，否则保持脚本禁用。 |
| Yarn 4.14+ | 依赖的 postinstall 默认禁用。只通过顶层的 `dependenciesMeta.<package>.built: true` 授予必要的例外。 |
| Yarn 2 至 4.13 | 在 `.yarnrc.yml` 中设置 `enableScripts: false`，然后只通过顶层的 `dependenciesMeta.<package>.built: true` 授予必要的例外；不要全局启用脚本。 |
| Yarn 1 | 用 `yarn install --ignore-scripts` 完成初次安装；除非每个必要的例外都按所固定客户端文档中的流程审查过，否则保持脚本禁用。 |

权威依据：[npm install-scripts](https://docs.npmjs.com/cli/v11/commands/npm-install-scripts/)、[安装策略](https://docs.npmjs.com/cli/v11/commands/npm-install/) 和 [CLI 发布记录](https://github.com/npm/cli/releases)；[pnpm approve-builds](https://pnpm.io/cli/approve-builds) 和 [构建设置](https://pnpm.io/settings#allowbuilds)；[Yarn 安全](https://yarnpkg.com/features/security) 和 [manifest](https://yarnpkg.com/configuration/manifest#dependenciesMeta)。

**供应链卫生**（安全公告审计抓不到新出现的恶意包）：
- [ ] 每个项目/workspace 根目录只提交一个权威 lockfile，CI 从不改写它
- [ ] critical/high 发现按可达性分诊(triage)；推迟修复的有理由和复查日期
- [ ] 强制审计修复（`npm audit fix --force` 或等价命令）绝不自动执行；修复产生的 diff 和 changelog 都经过审查
- [ ] 在包管理器支持的地方校验 registry 签名/来源证明
- [ ] 依赖的生命周期脚本在首次执行前被拦住，只通过所固定包管理器的原生策略批准
- [ ] 新依赖经过审查：归属、维护状况、发布时长、来源证明、传递依赖图，以及是否为仿冒包

## AI / LLM Security

对任何调用 LLM 的功能（聊天机器人、摘要器、agent、RAG）：

- [ ] 模型输出被视为不可信，绝不送进 `eval`/SQL/shell/`innerHTML`/文件路径
- [ ] 默认假设存在 prompt 注入；权限在代码中强制执行，而不是写在 system prompt 里
- [ ] 密钥、跨租户数据和完整的 system prompt 不进入上下文窗口
- [ ] 工具/agent 权限有范围限定；破坏性或不可逆的操作需要确认
- [ ] 设置了 token、速率和递归/循环次数上限（限制资源消耗）

## Error Handling

```typescript
// 生产环境：通用错误，不暴露内部细节
res.status(500).json({
  error: { code: 'INTERNAL_ERROR', message: 'Something went wrong' }
});

// 生产环境中绝不要这样：
res.status(500).json({
  error: err.message,
  stack: err.stack,         // 暴露内部细节
  query: err.sql,           // 暴露数据库细节
});
```

## OWASP Top 10 Quick Reference

| # | 漏洞 | 防范 |
|---|---|---|
| 1 | Broken Access Control | 每个接口都做权限检查，校验资源归属 |
| 2 | Cryptographic Failures | HTTPS、强哈希、代码中不放密钥 |
| 3 | Injection | 参数化查询、输入校验 |
| 4 | Insecure Design | 威胁建模、spec 驱动开发 |
| 5 | Security Misconfiguration | 安全响应头、最小权限、审计依赖 |
| 6 | Vulnerable Components | 所在生态的依赖审计（`npm audit`、`pip-audit` 等）、保持依赖更新、依赖尽量少 |
| 7 | Auth Failures | 强密码、限流、会话管理 |
| 8 | Data Integrity Failures | 校验更新/依赖、签名的制品 |
| 9 | Logging Failures | 记录安全事件，不记录密钥 |
| 10 | SSRF | 校验 URL / 使用白名单，限制出站请求 |

## OWASP Top 10 for LLMs Quick Reference

适用于带 LLM 功能的应用。参见 [OWASP GenAI Security Project](https://genai.owasp.org/llm-top-10/)。

| ID | 风险 | 防范 |
|---|---|---|
| LLM01 | Prompt Injection | 不要把 system prompt 当作边界；在代码中强制执行权限 |
| LLM02 | Sensitive Information Disclosure | 不把密钥/PII 放进 prompt；过滤输出 |
| LLM03 | Supply Chain | 像审查任何依赖一样审查模型、数据集和插件 |
| LLM04 | Data and Model Poisoning | 使用可信的模型来源并校验完整性；审查微调数据和 RAG 数据 |
| LLM05 | Improper Output Handling | 把模型输出当作不可信；校验、参数化、编码 |
| LLM06 | Excessive Agency | 限定工具权限；破坏性操作要确认 |
| LLM07 | System Prompt Leakage | 假定 system prompt 会泄露；不在里面放任何密钥 |
| LLM08 | Vector and Embedding Weaknesses | RAG 的 embedding 按租户隔离；文档在建索引之前先校验 |
| LLM09 | Misinformation | 用引用支撑回答；校验关键论断；保留人工把关 |
| LLM10 | Unbounded Consumption | 限制 token、请求速率和循环/递归深度 |
