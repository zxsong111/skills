## 它做什么

`pr` 定义 pull request 正文的结构：一段展示改动的 **Summary**（摘要），证明改动有效的 **Evidence**（证据），以及判断合入风险有多大的 **Merge Danger**（合并风险）。它是一份格式参考，不是工作流。它不 push branch，不开 PR，也不决定 PR 里放什么。它告诉 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 写正文时正文应该是什么样子。

摘要是一张图示，而不是一段文字。默认的 PR 正文会用文字描述 diff。这个 skill 则挑选能把要点讲清楚的**最小视图**（伪代码、调用树、组件树、文件树、Mermaid 图，或者经过整理的 diff），周围的文字保持简短。评审者手边已经开着 diff，所以正文要在他们阅读之前先让他们看到改动的形状。

## 什么时候用

输入 `/pr`，或者在任务匹配时由 agent 自动调用：只要它在写 PR 正文就会用上。

| 你的情况 | 该用 |
| --- | --- |
| branch 已就绪，需要一份评审者能快速扫读的正文 | `pr` |
| 代码写完了，但还没人评审过 | 先用 [code-review](https://aihero.dev/skills-code-review)，再用 `pr` |
| PR 已经开了，评审意见正陆续回来 | 这套 skill 里目前没有对应的；`pr` 只负责写正文 |

## 模板

三个部分，按此顺序：

- **Summary**：一张或几张小图示，每张都放在它所支撑的简短文字旁边。用一张，有时几张，很少全部都用。只保留评审者需要的调用、文件、props 和边界。
- **Evidence**：改动前与改动后。当改动是视觉上的、并且[环境](https://www.aihero.dev/ai-coding-dictionary/environment)能截图时，截图是最有力的证据。否则，用那个之前失败、现在通过的具体测试（写成伪代码），或者发生了变化的控制台输出。
- **Merge Danger**：这个改动是**单向门**还是**双向门**，以及它的**影响范围**(blast radius)。双向门撤回起来代价很低；单向门（破坏性的迁移、移除公共 API、难以撤回的决定）则不然。影响范围指的是改动一旦有错会弄坏什么：布局偏移、某个 API 的使用方、移动端适配。

门的判断是核心概念。它把「这能安全合入吗？」从一种直觉变成一条明确的论断，评审者可以表示不同意。它还告诉评审者把[人工评审](https://www.aihero.dev/ai-coding-dictionary/human-review)的精力花在哪里。影响范围小的双向门可以略读，单向门要慢慢读。

## 常见问题

**我能相信 agent 自己做的门的判断吗？**

不能盲信，而这正是要把它写出来的原因。写这个改动的 agent 就是给它打分的那个，所以当它说「双向门，影响范围小」时要最警惕。diff 也常常看不出一个改动能否撤回。正如一位用户所说：「rolling back a commit won't unsend a batch of emails」，而一次通过开关控制的灰度发布，只有在第一条新格式的数据写入之前才算双向门。skill 给 agent 的是一个定义（破坏性操作和难以撤回的决定是单向门），而不是一张清单，所以要最仔细地检查 Merge Danger 那一行。有两件事能帮上忙：确保 agent 手边有 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) 或 [spec](https://www.aihero.dev/ai-coding-dictionary/spec)，而不只是 diff；以及把你的仓库一向视为单向门的改动（schema 迁移、任何对外发出或删除东西的操作）写在 agent 做判断前会读到的地方。

**它会替我开 PR 吗？**

不会。`pr` 只负责正文。[implement](https://aihero.dev/skills-implement) 以 commit 到当前 branch 结束。要求增加一个开 PR 的 skill 或选项（一个 `/to-pr`，或者让 `implement` 开 PR 而不是 commit）的请求，目前仍是未关闭的提案。有位用户的绕过办法是给 `implement` 加一句本地覆盖，让它开 PR。[implement-spec](https://aihero.dev/skills-implement-spec) 是个例外：当你的 issue tracker 通过 PR 关闭工作，或者你要求时，它会开一个 draft PR。因为 `pr` 是模型自动调用(model-invoked)的，只要你让 agent 开 PR，它就会用这个结构来写正文。

**它不会又产出一大堆文字和图吗？**

skill 的设计就是为了防止这种情况，但它仍然可能发生。用户对 agent 写的 PR 正文的抱怨始终如一：「a long summary but all I need to know is what changed, how it was verified, what could break, and whether it's safe to merge.」skill 要求 agent 跳过开场白，文字从简，挑最小的视图，通常一张图示，很少全部都用。如果你还是收到一摞图，那是 agent 没听。如果正文巨长是因为 diff 巨大，问题出在 PR 的体量上，`pr` 不会替你拆分。

**我的仓库已经有 PR 模板了，听谁的？**

默认谁都不听。`pr` 有自己的模板，不会去找 `.github/pull_request_template.md` 之类的文件。好几位用户要求 skill 使用仓库的模板。如果你什么都不做，agent 对同一份文档就会有两条相互竞争的指令。在你仓库的 agent 文档里定下来，比如填写仓库模板，并把 Summary、Evidence 和 Merge Danger 放在它下面。

**输出是 HTML 吗？为什么 Mermaid 图渲染不出来？**

输出是一份 markdown 格式的 PR 正文，不是 HTML 页面。GitHub 和 GitLab 会渲染 PR 描述里的 Mermaid 代码块，但终端不会，所以 agent 还在本地给你看的时候，图看起来就是原始文本。使用 CLI harness 的用户用 ASCII Mermaid 渲染器来绕过，或者让 agent 给 PR 附上一个 HTML 版本。Mermaid 只是六种视图之一。调用树、文件树或经过整理的 diff 在哪里看都一样。

**它能帮我梳理回来的评审意见吗？**

不能。它写完正文就停下。用户不止一次要求有办法对其他开发者或评审机器人的意见做分诊(triage)（哪些值得处理，哪些不是问题）。这个 skill 不做这件事。

**PR 变化时，它会保持正文同步更新吗？**

不会。它在某个时间点写下正文，一个在评审中不断变化的 PR 会让那份正文过时。大改之后，让 agent 重写正文。agent 又一次在写 PR 正文，所以会用同样的结构。

**我的改动没有 UI，Evidence 里放什么？**

除了截图之外的一切。只有当改动是视觉上的，截图才是最有力的证据。对于迁移、后台任务或重构，证据是那个之前失败、现在通过的具体测试，或者发生了变化的控制台输出。单单一句「测试是绿的」只是一个论断，不是改动前与改动后。

**它能把正文标注为由 LLM 撰写吗？**

它自己不会。有位用户的做法是在仓库的 agent 文档里写一条长期指令，要求 agent 写的每个 issue、评论和 PR 都以一行声明结尾。这条规则应该放在仓库里，覆盖 agent 发出的所有内容，而不是放在针对某一类文档的模板里。

## 起作用的标志

- 打开 diff 之前，仅凭 Summary 的图示就能看出这个 PR 改了什么。
- 正文没有开场白：直接从 Summary 标题开始。
- Evidence 部分展示的是改动前和改动后，而不是一句「测试通过」的论断。
- 每个 PR 都写明了门的类型和影响范围，而你放慢速度细读的，正是那些单向门。

## 在体系中的位置

当构建以 pull request 的形式交付时，`pr` 位于评审和复盘之间：`to-spec → to-tickets → implement → code-review → pr → retro`。它是模型自动调用的，所以在这条链路之外，只要 agent 写 PR 正文，它也会自动触发。

- [code-review](https://aihero.dev/skills-code-review) 在它之前运行，因为 PR 正文应该描述一个已经评审过的 diff。
- [implement](https://aihero.dev/skills-implement) 产出正文所描述的 commit。

当你拿不准当前情况该用哪个 skill 时，[ask-matt](https://aihero.dev/skills-ask-matt) 会在整套 skill 中为你指路。
