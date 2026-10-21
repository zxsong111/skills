## 它做什么

`security-and-hardening` 是一份针对眼前改动触发的安全加固检查清单。当一个改动涉及认证、会话、支付、个人数据、文件上传、webhook、不可信的外部输入或新依赖时，它会先让你**画出信任边界**（不可信数据从哪里进入系统，哪些资产值得被偷，并对每条边界做一遍 STRIDE 分析），然后对照 OWASP 逐项加固。它的立场是：如果你说不出一个功能的信任边界在哪里，你就还没准备好去保护它。

它把规则分成三档：

- **总是要做**：参数化查询、输出编码、HTTPS、密码哈希、安全响应头、依赖审计。
- **先问再做**：新的认证流程、新类别的敏感数据、CORS、上传、权限提升。
- **绝对不做**：commit 密钥、在日志里记录敏感数据、信任客户端校验、把 LLM 输出直接传给 eval 或 SQL。

## 什么时候用

输入 `/security-and-hardening`，或者在任务匹配时由 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 自动调用：也就是改动涉及上面某个领域的时候。其余时间它不会占用[上下文窗口](https://www.aihero.dev/ai-coding-dictionary/context-window)。

| 情况 | 它给你什么 |
| --- | --- |
| 添加登录，修改权限或会话 | 密码哈希、cookie 属性、「每个请求都要检查授权」这条规则 |
| 接收表单、上传、webhook 或用户提供的 URL | 在边界处做 schema 校验、magic-byte 检查、防 SSRF 的 DNS 解析检查 |
| 添加依赖，运行审计 | 一张包管理器对照表、对安装脚本的把关、按可达性做分诊 |
| 处理 PII | 字段分级、最少收集、保留期限、删除路径 |
| 接入 LLM | 把模型输出当作不可信输入、prompt 注入、租户隔离 |

具体的代码模式放在 skill 目录下的 `references/hardening-patterns.md` 里，skill 碰到相应代码时会打开对应的小节。签收之前，它会逐项走一遍 `references/security-checklist.md`。

## 它在等的那些借口

这个 skill 带着一张自我合理化借口的表：内部工具不需要安全，原型可以以后再加，框架会处理的，审计通过了所以依赖没问题，先把数据收集起来以防以后有用。每一条都配上了实际情况。这张表的存在，就是为了在你想跳过某一步的那一刻被读到。

## 常见问题

**它会自己改代码吗？**
会，在你授权的范围内。对于「先问再做」那一档的改动（新的认证流程、新的敏感数据、CORS、上传、权限提升），它会停下来先问。

**它和 `code-review` 是什么关系？**
这个 skill 用于实现阶段；[code-review](https://aihero.dev/skills-code-review) 在之后做审查。把项目的安全基线写进 `CODING_STANDARDS.md`，两者就读的是同一套规则。

**我的项目没有 Web 界面。**
那大部分小节都不适用，这个 skill 也不会触发。关于处理密钥、对文件系统的破坏性操作、以及由外部进程传入的路径的那几节，适用于任何程序。

## 起作用的标志

- 当你添加一个接收外部输入的端点时，回复会在写任何代码之前先列出信任边界和资产。
- 任何 diff 里都不会出现密码、token 或 `.env` 的内容。
- 上传、SSRF 和限流相关的代码遵循 skill 提供的模式，而不是临场即兴发挥。
- 引入新依赖时，审计结果和对其安装脚本的处理方式会被明确报告出来。

## 在体系中的位置

`security-and-hardening` 是一个**随时可用的独立工具**，不是主链路上的一步。当实现阶段由 [tdd](https://aihero.dev/skills-tdd) 驱动的代码进入安全敏感区域时，它会被拉进来。当一个安全事件需要先找出根因时，请用 [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs)。[ask-matt](https://aihero.dev/skills-ask-matt) 有整套 skill 的地图。
