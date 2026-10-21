# 加固模式

`security-and-hardening` skill 的代码模式和决策辅助。skill 负责陈述每条规则；本文件给出它的一种具体实现。写到那部分代码时再打开你需要的章节。本文件不需要从头读到尾。

共用的清单（威胁建模、提交前检查、安全响应头、CORS、包管理器矩阵、安装脚本闸门，以及 OWASP 速查表）在 [security-checklist.md](security-checklist.md) 里。

## OWASP Top 10 防范模式

这些是防范模式，不是排名。2021 版的排序见 [security-checklist.md](security-checklist.md#owasp-top-10-quick-reference) 中的速查表。

### Injection

```typescript
// 错误：字符串拼接导致 SQL 注入
const query = `SELECT * FROM users WHERE id = '${userId}'`;

// 正确：参数化查询
const user = await db.query('SELECT * FROM users WHERE id = $1', [userId]);

// 正确：ORM 配合参数化输入
const user = await prisma.user.findUnique({ where: { id: userId } });
```

### Broken Authentication

```typescript
// 密码哈希
import { hash, compare } from 'bcrypt';

const SALT_ROUNDS = 12;
const hashedPassword = await hash(plaintext, SALT_ROUNDS);
const isValid = await compare(plaintext, hashedPassword);

// 会话管理
app.use(session({
  secret: process.env.SESSION_SECRET,  // 来自环境变量，不写在代码里
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,     // JavaScript 无法访问
    secure: true,       // 仅限 HTTPS
    sameSite: 'lax',    // CSRF 防护
    maxAge: 24 * 60 * 60 * 1000,  // 24 小时
  },
}));
```

### Cross-Site Scripting (XSS)

```typescript
// 错误：把用户输入当作 HTML 渲染
element.innerHTML = userInput;

// 正确：使用框架的自动转义（React 默认就这样做）
return <div>{userInput}</div>;

// 如果必须渲染 HTML，先清理
import DOMPurify from 'dompurify';
const clean = DOMPurify.sanitize(userInput);
```

### Broken Access Control

```typescript
// 始终检查授权，而不仅仅是认证
app.patch('/api/tasks/:id', authenticate, async (req, res) => {
  const task = await taskService.findById(req.params.id);

  // 检查已认证用户是否拥有这个资源
  if (task.ownerId !== req.user.id) {
    return res.status(403).json({
      error: { code: 'FORBIDDEN', message: 'Not authorized to modify this task' }
    });
  }

  // 继续执行更新
  const updated = await taskService.update(req.params.id, req.body);
  return res.json(updated);
});
```

### Security Misconfiguration

```typescript
// 安全响应头（Express 用 helmet）
import helmet from 'helmet';
app.use(helmet());

// 内容安全策略（CSP）
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"],  // 能收紧就收紧
    imgSrc: ["'self'", 'data:', 'https:'],
    connectSrc: ["'self'"],
  },
}));

// CORS：限定为已知的 origin
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || 'http://localhost:3000',
  credentials: true,
}));
```

### Sensitive Data Exposure

```typescript
// 绝不在 API 响应中返回敏感字段
function sanitizeUser(user: UserRecord): PublicUser {
  const { passwordHash, resetToken, ...publicFields } = user;
  return publicFields;
}

// 密钥使用环境变量
const API_KEY = process.env.STRIPE_API_KEY;
if (!API_KEY) throw new Error('STRIPE_API_KEY not configured');
```

### Server-Side Request Forgery (SSRF)

只要服务端会请求一个受用户影响的 URL（webhook、「从 URL 导入」、图片代理、链接预览），攻击者就能把它指向内部服务（云元数据、`localhost`、私有 IP）。

```typescript
// 错误：用户给什么就请求什么
await fetch(req.body.webhookUrl);

// 正确：scheme + host 白名单；只要有任何一个解析出的 IP 是私有地址就拒绝；禁止重定向
import { lookup } from 'node:dns/promises';
import ipaddr from 'ipaddr.js';

const ALLOWED_HOSTS = new Set(['hooks.example.com']);

async function assertSafeUrl(raw: string): Promise<URL> {
  const url = new URL(raw);
  if (url.protocol !== 'https:') throw new Error('https only');
  if (!ALLOWED_HOSTS.has(url.hostname)) throw new Error('host not allowed');
  // 解析全部记录；只要有一个私有/保留地址，检查就不通过。
  const addrs = await lookup(url.hostname, { all: true });
  if (addrs.some((a) => ipaddr.parse(a.address).range() !== 'unicast')) {
    throw new Error('private/reserved IP');
  }
  return url;
}

await fetch(await assertSafeUrl(req.body.webhookUrl), { redirect: 'error' });
```

`range() !== 'unicast'` 这个检查覆盖了 IPv4 和 IPv6 中的 loopback、link-local `169.254.169.254`（云元数据，头号 SSRF 目标）、私有地址和 unique-local 范围。

**注意：这里仍然存在 TOCTOU 漏洞。** `fetch` 在检查之后会再解析一次 DNS，所以攻击者可以利用短 TTL 的记录，在校验和建立连接之间把域名重绑定到内部 IP。对高风险的入口，只解析一次并连接到固定的 IP，或者在前面加一个过滤代理（`request-filtering-agent` / `ssrf-req-filter`）。

## 输入校验模式

### Schema Validation at Boundaries

```typescript
import { z } from 'zod';

const CreateTaskSchema = z.object({
  title: z.string().max(200).trim().min(1),
  description: z.string().max(2000).optional(),
  priority: z.enum(['low', 'medium', 'high']).default('medium'),
  dueDate: z.string().datetime().optional(),
});

// 在路由处理器中校验
app.post('/api/tasks', async (req, res) => {
  const result = CreateTaskSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(422).json({
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid input',
        details: result.error.flatten(),
      },
    });
  }
  // result.data 现在已带类型并通过校验
  const task = await taskService.create(result.data);
  return res.status(201).json(task);
});
```

### File Upload Safety

```typescript
// 限制文件类型和大小
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
const MAX_SIZE = 5 * 1024 * 1024; // 5MB

function validateUpload(file: UploadedFile) {
  if (!ALLOWED_TYPES.includes(file.mimetype)) {
    throw new ValidationError('File type not allowed');
  }
  if (file.size > MAX_SIZE) {
    throw new ValidationError('File too large (max 5MB)');
  }
  // 不要相信文件扩展名，关键场景下检查 magic bytes
}
```

### Destructive Operations on Derived Paths

删除、移动或覆盖操作的安全程度，取决于指明其目标的那个值。从内核、任务载荷或兄弟服务读到这个值，只能证明它*从哪里来*，不能证明是谁*写下*了它：另一个进程的命令行和表单字段一样受攻击者控制。形状检查（「绝对路径，至少有一层目录」）只能证明格式正确，却常被误当成授权。清理例程就是这样删掉了根目录而不是叶子目录。

执行破坏性调用之前，三项缺一不可：解析后的目标位于一个**白名单根目录**之下（在解析 symlink 之后比较，绝不对原始字符串比较）；它至少比该根目录**低一级**，因此根目录本身永远不会成为目标；并且它带有**属于你的证据**，这个证据要在操作之前、在任何会删除它的拆除步骤之前读取，否则「不存在」和「不是我的」就无法区分。拒绝时，记录被拒绝的目标并停止：一个回退到范围更大的默认路径的清理例程，正是这个检查要防范的故障。完整示例见 [security-checklist.md](security-checklist.md#destructive-path-operations)。

有两个局限，因为这个检查读起来比实际更强。目录树内的标记文件是自我证明（任何能往里写东西的人都能写这个标记），所以预期的所有者必须来自经过认证的状态，而且标记文件需要完整性保护（严格的文件归属，或 MAC），才能算作授权。另外，先解析路径、再按*名字*操作，在任何不可信进程能替换某个上级目录的地方都存在检查与使用之间的竞态：在共享卷上，要通过文件描述符持有目标，使用 no-follow、限定在根目录之下的操作，或者确保目录层级在操作期间不会改变。

## Dependency Audit Triage

包管理器的审计报告的是已知的安全公告；它们既不能证明一个包值得信任，也不能证明有漏洞的代码是可达的。按这棵决策树处理：

```
包管理器自带的审计报告了一个漏洞
├── 严重程度：critical 或 high
│   ├── 有漏洞的代码在运行时、构建、测试或部署路径中可达吗？
│   │   ├── 是 --> 立即修复（升级、打补丁或替换该依赖）
│   │   └── 否（已确认在这些路径中都没有用到）--> 尽快修复，但不阻塞
│   └── 有修复版本吗？
│       ├── 有 --> 升级到已修补的版本
│       └── 没有 --> 寻找变通方案，考虑替换该依赖，或加入白名单并设定复查日期
├── 严重程度：moderate
│   ├── 在生产环境中可达？--> 在下一个发布周期修复
│   └── 仅开发依赖？--> 方便时修复，记入 backlog 跟踪
└── 严重程度：low
    └── 跟踪，在常规依赖更新时修复
```

**关键问题：**
- 有漏洞的函数真的在你的代码路径中被调用了吗？
- 这个依赖是运行时依赖还是仅开发依赖？
- 结合你的部署环境，这个漏洞可被利用吗（例如，一个只在客户端运行的应用里出现了服务端漏洞）？

推迟修复时，写明理由并设定复查日期。

## Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

// 常规 API 限流
app.use('/api/', rateLimit({
  windowMs: 15 * 60 * 1000, // 15 分钟
  max: 100,                   // 每个窗口 100 次请求
  standardHeaders: true,
  legacyHeaders: false,
}));

// 认证接口用更严格的限制
app.use('/api/auth/', rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,  // 每 15 分钟 10 次尝试
}));
```

**一旦有不止一个进程，就在共享存储里计数。** `express-rate-limit` 默认把计数器放在进程内存里。在负载均衡器后面，每个实例各自计数，于是实际限额变成 `max × instances`；在 serverless 或 edge 运行时上，每次新的调用都从零开始，所以上面的认证限流可能永远不会触发。传入一个共享的 `store`（通过 `rate-limit-redis` 使用 Redis），或者使用一个基于 HTTP 的限流器，它在无法维持长连接 TCP 的环境中也能工作（例如 `@upstash/ratelimit`）：

```typescript
import { Ratelimit } from '@upstash/ratelimit';
import { Redis } from '@upstash/redis';

const authLimiter = new Ratelimit({
  redis: Redis.fromEnv(),                       // UPSTASH_REDIS_REST_URL + _TOKEN
  limiter: Ratelimit.slidingWindow(10, '15 m'), // 每 15 分钟 10 次尝试，跨所有实例
});
const { success } = await authLimiter.limit(`login:${req.ip}`);
if (!success) return res.status(429).end();
```

## Secrets Management

```
.env 文件：
  ├── .env.example  → 提交（带占位值的模板）
  ├── .env          → 不提交（包含真实密钥）
  └── .env.local    → 不提交（本地覆盖配置）

.gitignore 必须包含：
  .env
  .env.local
  .env.*.local
  *.pem
  *.key
```

**提交前务必检查：**
```bash
# 检查是否不小心暂存了密钥
git diff --cached | grep -i "password\|secret\|api_key\|token"
```

**只要密钥曾被提交过，就轮换它。** 删掉那一行或改写历史都不够。从它到达远端的那一刻起，就假定它已经泄露。先吊销并重新签发密钥，再从历史中清除它。

## Data Classification

新增字段时就对个人数据分类，这样导出和删除请求以后才能找到它：

| 类别 | 例子 | 处理方式 |
|---|---|---|
| **非个人** | 聚合数据、匿名化计数 | 常规处理 |
| **个人（PII）** | 姓名、邮箱、IP、设备/用户 ID | 最小化、访问控制、纳入导出/删除范围 |
| **敏感** | 健康、财务、位置、生物特征、政府证件号、任何涉及未成年人的数据 | 收集需要额外的依据、更严格的访问控制，通常还要加密 + 审计日志 |

## LLM Output Handling

```typescript
// 错误：把模型输出当作命令或标记来信任
const sql = await llm.generate(`Write SQL for: ${userQuestion}`);
await db.query(sql);                                   // 任意查询执行
container.innerHTML = await llm.reply(userMessage);   // 经由模型的存储型 XSS

// 正确：模型输出是数据，所以先防御式解析，再校验，再编码
let intent;
try {
  intent = CommandSchema.parse(JSON.parse(await llm.replyJson(userMessage)));
} catch {
  throw new ValidationError('unexpected model output'); // JSON.parse 或 schema 校验失败
}
await runAllowlistedAction(intent.action, intent.params);
container.textContent = await llm.reply(userMessage);
```
