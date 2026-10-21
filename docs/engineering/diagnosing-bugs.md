## 它做什么

`diagnosing-bugs` 对一个棘手的 bug 或一次性能回退执行六个阶段的诊断：构建复现、最小化复现、给假设排序、加探针、带回归测试修复、清理。

在**紧凑的**反馈回路(feedback loop)建立之前，它不允许 agent 形成任何理论：要有一条具名命令，已经跑过一次，遇到*这个* bug 会变红，修好后会变绿。拿到 bug 报告时，编码 agent 默认会去读代码然后猜。这个 skill 就是要拦住这一点。如果没有能变红的命令，就没有第 2 阶段。这道关卡就是这个 skill 存在的意义。回路一旦建立，之后的一切（二分、验证假设、加探针）都是机械性的。

## 什么时候用

输入 `/diagnosing-bugs`，或者在任务匹配时由 agent 自动调用。它是模型自动调用(model-invoked)的，遇到「diagnose」「debug this」，或者报告某个东西坏了、抛异常、失败、变慢时就会触发。

把它用在难啃的问题上：一眼看不出的 bug、时有时无的 flaky 问题、在两个已知正常的状态之间引入的回退。它刻意做得又慢又彻底，所以如果你想一条消息就拿到答案，它是错误的工具。

| 你的情况 | 该去哪 |
| --- | --- |
| 一个能用症状描述的具体缺陷 | 这个 skill |
| 某个接口变慢，或者有已知前后对比的耗时回退 | 这个 skill。它有一条性能分支（先测基线，再二分） |
| 「这个代码库的瓶颈在哪？」，没有具体症状 | 不是这个 skill。它诊断一个已知的故障，不做审计 |
| 别人提来的原始 bug 报告，还没确认、也没整理成文 | 先用 [triage](https://aihero.dev/skills-triage) |
| 用一次性代码回答设计问题，而不是追查缺陷 | [prototype](https://aihero.dev/skills-prototype) |
| 以测试先行的方式实现一个计划中的行为 | [tdd](https://aihero.dev/skills-tdd) |
| bug 修好后，想问什么本可以预防它 | [retro](https://aihero.dev/skills-retro)，在同一个会话里运行 |
| 没有合适的接缝(seam)来锁住这个 bug | [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture)，由你自己启动 |

## 紧凑的回路就是这个 skill 的全部

第 1 阶段花的力气最多，因为它是唯一困难的阶段。skill 列出了构建回路的方法，大致按优先顺序排列：

1. 在能触及这个 bug 的任何接缝上写一个失败的测试。
2. 对运行中的开发服务器跑 curl 或 HTTP 脚本。
3. 用固定输入调用 CLI，与已知正确的快照做 diff。
4. 用无头浏览器脚本对 DOM、控制台或网络做断言。
5. 回放抓取的数据：把保存的请求、payload 或事件日志单独送进那条代码路径。
6. 一次性 harness：系统的最小子集，一次函数调用。
7. 属性测试或 fuzz 循环，针对「有时输出不对」。
8. 可以交给 `git bisect run` 的二分 harness。
9. 差分回路：相同输入，旧版本对比新版本。
10. [人在回路中](https://www.aihero.dev/ai-coding-dictionary/human-in-the-loop)的 bash 脚本，最后手段。skill 为此附带了 `scripts/hitl-loop.template.sh`：agent 运行脚本，你在终端里按提示操作，你的回答以可解析的输出返回。

目标不是*有*一个回路，而是**紧凑**：快（几秒）、确定（每次结论相同）、精准（断言的正是你的症状，而不是「没崩」），并且 agent 不用你在场就能运行。一个 30 秒、还不稳定的回路，比没有也强不了多少。对于只是偶尔出现的 bug，目标不是一个干净的复现，而是**更高的复现率**：循环触发、并行、加压、注入 sleep，直到 flaky 的频率高到可以拿来调试。

当 agent 构建不出回路时，skill 要求它停下并说明，列出尝试过的方法，然后向你申请[环境](https://www.aihero.dev/ai-coding-dictionary/environment)访问权限、一份抓取的工件，或者添加临时探针的许可。它不得照样往下去形成假设。

## 阶段之间的关卡

这些阶段是关卡，不是清单。某个条件成立之前，agent 不能进入下一阶段。

| 关卡 | 必须满足的条件 |
| --- | --- |
| 进入第 2 阶段 | 一条具名命令，已经运行过，命令和输出都贴出来了，而且它能因这个 bug 变红 |
| 进入第 3 阶段 | 复现已经重现*并且*最小化：剩下的每个元素都是复现 bug 所必需的 |
| 进入第 4 阶段 | 有 3 到 5 个排好序、可证伪的假设，每个都写明它的预测，并在测试任何一个之前给你看过 |
| 进入第 5 阶段 | 每个探针对应一个具体预测，一次只改一个变量，每条调试日志都带有类似 `[DEBUG-a4f2]` 的标签，这样一次 grep 就能把它们全部找出来清理掉 |
| 完成 | 原来的复现不再复现，探针已全部移除，commit message 写明了最终被证实的那个假设 |

第 5 阶段有一个例外。agent 在修复之前先写回归测试，但前提是存在一个**正确的接缝**：在那里，测试触发的是真实的 bug 模式，与它在调用点出现的方式一致。如果唯一可用的接缝太浅，skill 要求 agent 直说，而不是写一个给人虚假信心的测试。缺少接缝本身就是一项发现，agent 要把它记下来，而不是藏起来。

## 常见问题

**我只想要个直接回答的小问题，它也会触发。**
这是这个 skill 被报告最多的问题。尤其在 GPT-5.6-Sol 上，用户报告它会因为一句普通的问题描述就被触发：「the model triggers the rather formal diagnosing-bugs skill instead. It then goes on to construct a reproduction scenario (often building a mock scenario with limited value) before giving me a response or suggestion. This results in considerable reply delays.」有四个人分别在 [issue #578](https://github.com/mattpocock/skills/issues/578) 上报告了同样的问题。公认的修复方向是先用更轻量的方式处理，只在问题确实需要时才转入完整诊断，但这个改动还没发布。这个 skill 是按 Claude Code 的调用行为调校的，激活阈值更低的[模型](https://www.aihero.dev/ai-coding-dictionary/model)会过于频繁地触发它。在修复发布之前，绕过办法是直接说明你要什么（「直接回答，不要诊断」），或者在你的 [harness](https://www.aihero.dev/ai-coding-dictionary/harness) 里为它禁用模型自动调用。

**我能把它指向一个代码库，问它性能问题在哪吗？**
不能。它诊断的是一个你已经能说出来的故障。它的性能分支针对的是有症状的回退（先建立基线测量，再二分，先测量再修复），而不是主动排查。曾经有人[提议并关闭了](https://github.com/mattpocock/skills/issues/431)一个做主动排查的 skill；目前没有 skill 做这件事。

**它在写修复之前会停下来问我吗？**
不会。只有第 3 阶段有人工检查点：排好序的假设列表会在测试任何一个之前给你看，如果你不在，agent 会按自己的排序继续。加探针和修复之间没有关卡，所以 agent 可能在你认同它的根因之前就开始写代码。[Issue #124](https://github.com/mattpocock/skills/issues/124) 要求加上这道关卡，目前仍未关闭。如果你需要，调用时说一声。

**我已经对这个 bug 报告跑过 `/triage` 了，这是不是又做一遍同样的工作？**
部分是，而且两个 skill 都没说明这一点。正如一位读者所说：「Triage's step 3 is essentially a shallow, bounded instance of diagnosing-bugs Phase 1-2, but neither file mentions the other.」triage 做的是一次有边界的「这真的是 bug 吗，影响面有多大」检查；这个 skill 做的是彻底的版本。先跑 triage 并不浪费，因为它的验证往往能提供第 1 阶段的大部分原始材料。但要预期这个 skill 会把那些工作完整重做一遍，也别指望有交叉引用来提醒你。

**它贴出来的复现输出会泄露密钥吗？**
有可能。skill 要求 agent 贴出调用命令及其输出，并索取 HAR 文件、日志转储、core dump 之类的工件。没有任何指令要求 agent 对它们做脱敏。[Issue #674](https://github.com/mattpocock/skills/issues/674) 提的正是这个问题（凭据、token、cookie 和个人数据被复制进聊天、issue 或 PR），并提议加一道脱敏防护栏(guardrail)。它仍未关闭，也没有实现。目前把脱敏当作你自己的事，尤其是在输出要发到任何公开场合之前。

**我的安全扫描器把这个 skill 标为高风险。**
Snyk 会标记它，这是误报。它是整套里唯一附带可执行 shell 脚本（`hitl-loop.template.sh`）、同时还有运行它并 curl 开发服务器的指令的 skill。一个随附的 `.sh` 文件、运行它的指令、再加上对外的 HTTP 请求，凑在一起就足以触发静态扫描器。脚本本身大约 30 行，都是等待人工输入的 `read -r -p` 提示。扫描器评估的是这个 skill 可能做什么，而不是一个已被证实的漏洞。

**`/diagnose` 怎么了？**
v1.0.0 把它改名为 `/diagnosing-bugs`。旧名字已经不存在了。你那边任何串联了 `/diagnose` 的东西（包装 skill、保存的 prompt）都需要更新。

## 起作用的标志

- 在提出任何理论之前，它先给你看一条命令及其变红的输出。如果理论先出来，说明这个 skill 没在运行。
- 它复现的故障就是你报告的那个，而不是途中发现的某个相近故障。
- 它在开始猜测之前先缩小复现，并能说出剩下的每一部分为什么必需。
- 在测试任何假设之前，它给你看一份 3 到 5 个假设的排序列表，每个都带有一个你可以证伪的预测。
- 它加的每条调试日志都带有类似 `[DEBUG-a4f2]` 的标签，宣布完成时，对这个标签 grep 的结果为空。
- commit 或 PR message 写明了哪个假设是对的。
- 当它无法用测试锁住这个 bug 时，它会直说，而不是写一个浅层的测试。

## 在体系中的位置

`diagnosing-bugs` 是一个随时可用的独立工具。有东西坏了就启动它，修复和回归测试都到位后它就结束。它不保存状态，也不需要任何前置设置。[ask-matt](https://aihero.dev/skills-ask-matt) 会把「有东西坏了」路由到这里。

有两个邻居值得一提。[retro](https://aihero.dev/skills-retro) 在它之后：修复到位后，在同一个会话里运行它，问一问什么本可以预防这个 bug，此时会话掌握的信息比开始时多。`diagnosing-bugs` 从不自己调用 `retro`，因为 `retro` 是用户手动调用(user-invoked)的。[triage](https://aihero.dev/skills-triage) 在它之前，针对别人提来的原始报告形式的 bug，它做的是同样前两个阶段的浅层版本。
