---
name: security-and-hardening
description: >
  加固代码，防范漏洞。当改动涉及认证 / 授权、会话管理、支付、个人数据（PII、GDPR、CCPA）、文件上传、
  webhook / 回调，或接收不可信外部数据的接口时使用；审计依赖漏洞、分诊审计结果、评估新依赖的供应链风险时使用；
  用户要求对照 OWASP Top Ten 做安全审查时也使用。触发短语：「安全审查」「加固一下」「查一下依赖漏洞」
  「这个接口安全吗」「security review」「harden this」「OWASP」。
---

# 安全与加固

## 概述

面向 Web 应用的安全优先开发实践。把每一个外部输入都当作敌意输入，把每一个密钥都当作不可外泄之物，把每一次授权检查都当作必须执行。安全不是一个阶段，而是对每一行触及用户数据、认证或外部系统的代码的约束。

## 何时使用

- 构建任何接收用户输入的功能
- 实现认证或授权
- 存储或传输敏感数据
- 集成外部 API 或服务
- 新增文件上传、webhook 或回调
- 处理支付或 PII 数据

## 流程：先做威胁建模

没有威胁模型就硬加上去的控制措施只是猜测。加固之前，先花五分钟像攻击者一样思考：

1. **画出信任边界。** 不可信数据从哪里进入你的系统？HTTP 请求、表单字段、文件上传、webhook、第三方 API、消息队列，以及 **LLM 输出**；还有那些因为是操作系统交给你的、所以看起来像内部数据的本地值（另一个进程的命令行或环境变量、共享卷上的文件名、任务载荷中的路径）。信任取决于是谁*写下*了这个值，而不是它经由哪个渠道送达。每一条边界都是攻击面。
2. **列出资产。** 什么值得偷、什么值得破坏？凭据、PII、支付数据、管理员操作、资金流转。
3. **对每条边界过一遍 STRIDE**（一个快速的视角，不是一套仪式）：

| 威胁 | 问自己 | 典型缓解措施 |
|---|---|---|
| **S**poofing（伪装） | 有人能冒充某个用户 / 服务吗？ | 认证、签名校验 |
| **T**ampering（篡改） | 数据在传输或存储时能被改动吗？ | 完整性校验、参数化查询、HTTPS |
| **R**epudiation（抵赖） | 某个操作事后能被否认吗？ | 对安全事件做审计日志 |
| **I**nformation disclosure（信息泄露） | 数据会泄露吗？ | 加密、字段白名单、通用错误信息 |
| **D**enial of service（拒绝服务） | 它会被压垮吗？ | 限流、输入大小上限、超时 |
| **E**levation of privilege（权限提升） | 用户能获得本不该有的权限吗？ | 授权检查、最小权限 |

4. **在用例旁边写下滥用用例。** 对每个功能都问一句「我会怎么滥用它？」，然后把它写成你的第一个测试。

如果说不出一个功能的信任边界，你就还没准备好去保护它。这就是 OWASP **A04: Insecure Design**：大多数安全事件始于设计，而不是代码。

## 三级边界体系

### 始终要做（没有例外）

- 在系统边界（API 路由、表单处理器）**校验所有外部输入**
- **所有数据库查询都参数化**：绝不把用户输入拼接进 SQL
- **对输出编码**以防 XSS（使用框架的自动转义，不要绕过它）
- 所有外部通信**使用 HTTPS**
- 用 bcrypt/scrypt/argon2 **哈希密码**（绝不存明文）
- **设置安全响应头**（CSP、HSTS、X-Frame-Options、X-Content-Type-Options）
- 会话**使用 httpOnly、secure、sameSite 的 cookie**
- 每次发布前，用检测到的包管理器自带的审计命令**对已提交的 lockfile 做审计**

### 先问再做（需要人工批准）

- 新增认证流程或修改认证逻辑
- 存储新类别的敏感数据（PII、支付信息）
- 新增外部服务集成
- 修改 CORS 配置
- 新增文件上传处理器
- 修改限流或节流设置
- 授予更高的权限或角色

### 绝不要做

- **绝不把密钥提交**到版本控制（API key、密码、token）
- **绝不记录敏感数据**（密码、token、完整信用卡号）
- **绝不把客户端校验**当作安全边界
- **绝不为了方便禁用安全响应头**
- **绝不对用户提供的数据使用 `eval()` 或 `innerHTML`**
- **绝不把会话存放在客户端可访问的存储里**（用 localStorage 存认证 token）
- **绝不向用户暴露堆栈信息**或内部错误细节

## 加固控制措施

下面的规则是工作流程；每条规则的具体实现见 [references/hardening-patterns.md](references/hardening-patterns.md)。写到那部分代码时再打开对应章节，不要提前读。

### 注入、XSS 与访问控制

- 每个查询都参数化。绝不用输入字符串拼出 SQL、NoSQL 或 shell 命令。
- 通过框架的自动转义对输出编码。如果确实无法避免原始 HTML，先用白名单型的 sanitizer 清理。
- 每个请求都检查**授权**，而不仅仅是认证：已认证用户必须拥有该具体资源，或对它有权限（A01，IDOR）。

模式：[注入](references/hardening-patterns.md#injection)、[XSS](references/hardening-patterns.md#cross-site-scripting-xss)、[访问控制](references/hardening-patterns.md#broken-access-control)。

### 认证与会话

- 用 bcrypt（≥12 轮）、scrypt 或 argon2 哈希密码。会话密钥来自环境变量，绝不写在代码里。
- 会话 cookie 设为 `httpOnly`、`secure`，以及 `sameSite: 'lax'` 或 `'strict'`（这是 CSRF 防御；`'none'` 会在跨站请求中带上 cookie），并设置有上限的 `maxAge`。

模式：[认证](references/hardening-patterns.md#broken-authentication)。

### 响应头、CORS 与响应体

- 每个响应都带安全响应头（helmet 或框架中的等价物）；CSP 从 `default-src 'self'` 起步，只收紧，不放宽。
- CORS 限定为来自配置的明确 origin 列表。带凭据时绝不用 `*`。
- 任何响应之前都剔除敏感字段（`passwordHash`、重置 token）。错误响应体保持通用；内部细节只进服务端日志。

模式：[错误配置](references/hardening-patterns.md#security-misconfiguration)、[敏感数据暴露](references/hardening-patterns.md#sensitive-data-exposure)。

### 输入校验与上传

- 在边界用 schema 校验：白名单式的结构、长度、枚举、格式。校验失败返回 422 和结构化的详情；下游代码只使用解析后、带类型的值。
- 上传：MIME 类型用白名单，限制大小，必要时校验内容（magic bytes）。扩展名证明不了任何事。

模式：[Schema 校验](references/hardening-patterns.md#schema-validation-at-boundaries)、[文件上传](references/hardening-patterns.md#file-upload-safety)。

### 服务端请求（SSRF）

任何受用户影响的 URL（webhook、从 URL 导入、图片代理、链接预览）都可能被指向内部服务。对 scheme 和 host 做白名单，解析**全部** DNS 记录，拒绝任何私有或保留地址（loopback、link-local `169.254.169.254`、私有地址、unique-local，IPv4 和 IPv6 都要覆盖），并禁止重定向。这个检查仍然存在 DNS 重绑定的 TOCTOU 漏洞：对高风险的入口，固定解析出的 IP，或者在前面加一个过滤代理。

模式：[SSRF](references/hardening-patterns.md#server-side-request-forgery-ssrf)。

### 对派生路径的破坏性操作

删除、移动或覆盖操作的安全程度，取决于指明其目标的那个值；而信任取决于是谁*写下*了这个值，不是它经由哪个渠道送达：另一个进程的命令行和表单字段一样受攻击者控制。形状检查只能证明格式正确，不能证明有权操作。调用之前，三项缺一不可：解析后的目标（已解析 symlink）位于一个**白名单根目录**之下；它至少比该根目录**低一级**；并且它带有**在操作之前读取的归属证据**。拒绝时，记录被拒绝的目标并停止；绝不回退到一个范围更大的默认路径。

为什么这个检查实际上比读起来弱（标记文件是自我证明、检查与使用之间存在竞态）：[破坏性路径](references/hardening-patterns.md#destructive-operations-on-derived-paths)。完整代码：[references/security-checklist.md](references/security-checklist.md)。

### 限流

对 API 做常规限流，对认证接口做严格限流（大约每 15 分钟 10 次尝试）。一旦有不止一个进程在处理流量，内存中的计数器就会悄悄变成 `max × instances`，在 serverless 上则根本不会触发：用共享存储来支撑限流器。

模式：[限流](references/hardening-patterns.md#rate-limiting)。

### 密钥

密钥来自环境变量。`.env.example` 带占位值提交；真实的 `.env*` 文件和密钥材料加入 gitignore；commit 之前 grep 一遍暂存区的 diff。**密钥一旦到达远端，就在落地那一刻泄露了：先轮换，再清理历史。**

模式：[密钥管理](references/hardening-patterns.md#secrets-management)。

### 依赖与供应链

1. **找到安装边界和包管理器。** 使用拥有 lockfile 的 workspace 根目录；只有当嵌套项目位于该 workspace 之外时，才把它当作独立项目。相互印证 `packageManager`（如果有）、lockfile 和 CI；三者不一致或存在相互竞争的 lockfile 时停下来。固定包管理器的版本。
2. **在首次执行之前拦住依赖脚本。** 以禁用脚本的方式或按一份有文档的 fail-closed 策略完成初次安装，检查待执行脚本的源码，只批准最小必要的部分，提交该策略，然后用一次干净的 frozen/immutable 安装验证。绝不一揽子批准。
3. **每次发布前，用包管理器自带的审计命令对已提交的 lockfile 做审计。** 按**可达性**（运行时、构建、测试、部署路径）和是否有修复版本来分诊(triage) critical/high。绝不自动执行强制修复（`npm audit fix --force` 或等价命令），因为强制修复可能越过声明的依赖版本范围；先预览，读 changelog，逐个测试每次升级。每次推迟修复都要写明理由和复查日期。
4. **审计只能匹配已知的安全公告。** 它们抓不到新出现的恶意包或仿冒包（`cross-env` 与 `crossenv`）。把新依赖、lockfile diff 和脚本策略的变更放在一起审查：归属、维护状况、发布时长、来源证明、传递依赖图。在支持的地方校验 registry 签名（`npm audit signatures`、`pnpm audit signatures`），签名缺失是需要调查的信号，而不是被攻破的确凿证据（A06，LLM03）。

分诊决策树：[依赖审计分诊](references/hardening-patterns.md#dependency-audit-triage)。包管理器矩阵和安装脚本闸门：[references/security-checklist.md](references/security-checklist.md)。

### 个人数据与隐私

加固问的是「攻击者能读到吗？」隐私问的是「*我们*到底该不该持有它，持有多久？」最便宜的数据，无论是保护、泄露还是合规，都是你从未收集过的数据；把个人数据当作需要尽量减少的负债。

- **新增字段时就做分类**（非个人、PII、敏感），并按类别处理。找不到的数据，你既保护不了，也无法响应针对它的删除请求。
- **只为明确的用途收集。** 「以后可能有用」是潜在的泄露范围，不是用途。让 PII 远离遥测数据：日志、指标、链路追踪和错误报告也都是数据存储。
- **事先设定保留期限，然后真的去删。** 每个个人数据存储都需要 TTL 和可用的删除路径，包括备份、缓存、搜索索引和分析副本。
- **支持你所在司法辖区要求的数据主体权利**（GDPR、CCPA 及同类法规）：导出、更正、删除。schema 的设计要让一个用户的数据可查找、可擦除，而不是不可逆地散落在各个系统里。
- **同意是收集和向第三方共享的前提，并且可审计。** 把 PII 发送给分析、广告或 LLM 供应商就是共享；供应商需要签数据处理协议。把地区做成可配置的策略，而不是硬编码的假设。

分类表：[数据分类](references/hardening-patterns.md#data-classification)。隐私事件会启动泄露通知的倒计时；先定位根因：打补丁之前，调用 Skill 工具，参数为 "diagnosing-bugs"。

### AI / LLM 功能

调用 LLM（聊天机器人、摘要器、agent、RAG）会带来新的攻击面；把它对照 [OWASP Top 10 for LLM Applications (2025)](https://genai.owasp.org/llm-top-10/)：

- **模型输出是不可信输入**（LLM05）。绝不送进 `eval`、SQL、shell、`innerHTML` 或文件路径；防御式解析，按 schema 校验，再编码。
- **prompt 可能被劫持**（LLM01）。上下文中的不可信文本（用户消息、抓取的网页、PDF）可能携带指令。system prompt 不是安全边界；在代码里强制执行权限。
- **让密钥、其他租户的数据和完整的 system prompt 远离上下文窗口**（LLM02、LLM07）；限定工具权限，校验每一个工具参数，破坏性操作要确认（LLM06）；限制 token、请求速率和递归深度（LLM10）；RAG 的 embedding 按租户隔离，文档在建索引之前先校验（LLM08）。

模式：[LLM 输出处理](references/hardening-patterns.md#llm-output-handling)。

## 审查清单

签字确认之前，过一遍 [references/security-checklist.md](references/security-checklist.md)：它涵盖认证、授权、输入、数据保护与隐私、响应头与 CORS、依赖与供应链、AI/LLM 和错误处理，外加 OWASP 速查表。

## 常见的自我开脱

| 借口 | 实际情况 |
|---|---|
| 「这是内部工具，安全无所谓」 | 内部工具也会被攻破。攻击者专挑最薄弱的环节。 |
| 「安全以后再加」 | 事后补安全比一开始就做进去难 10 倍。现在就加。 |
| 「没人会去利用这个」 | 自动化扫描器会找到它。靠隐蔽来保证安全不是安全。 |
| 「框架会处理安全」 | 框架提供的是工具，不是保证。你仍然需要正确地使用它们。 |
| 「这只是个原型」 | 原型会变成生产代码。安全习惯从第一天开始。 |
| 「这里做威胁建模太小题大做了」 | 花五分钟想想「我会怎么攻击它？」，就能避免事后任何控制措施都补不上的设计缺陷。 |
| 「这只是 LLM 输出，就是一段文本」 | 这段「文本」可能是一条 SQL 语句、一个 script 标签或一条 shell 命令。像对待任何不可信输入一样对待它。 |
| 「审计通过了，所以这个依赖是安全的」 | 审计只匹配已知的安全公告。它们检测不到新出现的恶意包，也不能让未经审查的安装脚本变得可以安全执行。 |
| 「先收集了再说，以后可能用得上」 | 你没持有的数据不会被泄露、被传唤，也不会被误删。「可能用得上」是泄露范围，不是用途。 |
| 「删除请求我们手动处理」 | 手动擦除会漏掉备份、缓存和分析副本。如果 schema 找不到一个用户的数据，你就无法响应请求，所以要为此做设计。 |
| 「合规是法务的事，不是我们的」 | 导出、删除、保留期限和同意都是 schema 和代码。等你把 PII 散落到十个系统里之后，法务没法再把它们补上。 |

## 危险信号

- 用户输入直接传给数据库查询、shell 命令或 HTML 渲染
- 删除、移动或覆盖操作的目标来自载荷、配置值或另一个进程的命令行，而唯一的防护只是对路径做形状检查
- 源代码或 commit 历史中有密钥
- API 接口没有认证或授权检查
- 缺少 CORS 配置，或使用通配符（`*`）origin
- 认证接口没有限流，或在多个实例前面使用内存限流器
- 向用户暴露堆栈信息或内部错误
- 依赖存在已知的 critical 漏洞、同一安装边界下有相互竞争的 lockfile、安装不可复现，或脚本被一揽子批准
- 服务端在没有白名单的情况下请求用户提供的 URL（SSRF）
- LLM/模型输出被传入查询、DOM、shell 或 `eval`
- 密钥、PII 或完整的 system prompt 被放进 LLM 的上下文窗口
- 收集个人数据却没有明确用途、保留期限或删除路径
- 在没有同意或数据处理协议的情况下把 PII 发给分析/广告/LLM 供应商
- 「删除我的账户」只是翻转一个标记位，而个人数据仍然残留在各个存储和备份中

## 验证

实现与安全相关的代码之后：

- [ ] 包管理器自带的审计没有未缓解的、可达的 critical/high 发现；CI 保留权威 lockfile，并拦住未经审查的依赖脚本
- [ ] 源代码和 git 历史中没有密钥
- [ ] 所有用户输入都在系统边界处校验
- [ ] 破坏性的文件系统操作先解析 symlink，再在执行前校验白名单根目录、最小深度和归属
- [ ] 每个受保护接口都检查了认证和授权
- [ ] 响应中带有安全响应头（用浏览器 DevTools 检查）
- [ ] 错误响应不暴露内部细节
- [ ] 认证接口启用了限流，并且在多个实例处理流量时由共享存储支撑
- [ ] 服务端 URL 请求经过白名单校验（无 SSRF）
- [ ] LLM/模型输出在使用前经过校验和编码（如果有 AI 功能）
- [ ] 个人数据已分类、按明确用途做了最小化，并设有保留期限
- [ ] 删除和导出请求端到端可用（包括备份、缓存和分析副本）
