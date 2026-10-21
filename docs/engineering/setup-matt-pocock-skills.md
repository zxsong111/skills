## 它做什么

`setup-matt-pocock-skills` 回答关于一个仓库的三个问题：issue 放在哪里，分诊(triage)标签叫什么，领域文档在哪里。它把答案记录成 `docs/agents/` 下的 markdown 文件。

这些文件是不同仓库之间唯一会变的东西。skill 本身在哪里都一样。它们在运行时读取 `docs/agents/issue-tracker.md`，照它说的去做。这就是为什么这套 skill 不绑定 GitHub，也是为什么你永远不需要为了换一个 tracker 去改 skill 文件。用「把这些 skill 连接到一个自定义 issue tracker」来调用它，任何你能以编程方式接入的东西都可以，skill 本身无需改动。

它是一个由 prompt 驱动的 skill，不是确定性的脚本。它读取你的 `git remote`、`CLAUDE.md` 和 `GLOSSARY.md`，把发现的东西提出来，等你确认后才写入任何内容。

## 什么时候用

输入 `/setup-matt-pocock-skills` 调用它，[agent](https://www.aihero.dev/ai-coding-dictionary/agent) 不会自己去用它。它的元数据特意把它标为不可被调用，所以其他任何 skill 都没法替你触发它。

每个仓库用一次，在第一次使用任何其他工程类 skill 之前。如果 [triage](https://aihero.dev/skills-triage)、[to-spec](https://aihero.dev/skills-to-spec)、[to-tickets](https://aihero.dev/skills-to-tickets) 或 [wayfinder](https://aihero.dev/skills-wayfinder) 开始猜你的 issue 该放哪里，或者打上你的 tracker 里没有的标签，说明这个仓库还没设置。你可以在项目进行到一半的仓库里运行它。skill 会读取已有的内容，所以之前的工作不会丢失。

## 前置条件

它会写入你运行它的那个仓库：

| 它写入 | 位置 |
| --- | --- |
| `issue-tracker.md` | `docs/agents/` |
| `domain.md` | `docs/agents/` |
| `triage-labels.md` | `docs/agents/`，仅在安装了 `triage` skill 时 |
| 一个 `## Agent skills` 块 | `CLAUDE.md` 或 `AGENTS.md` 中已经存在的那个 |

这些全都以 markdown 的形式 commit。没有用户级或全局模式。配置住在仓库里，所以每个仓库都有自己的一份。

## 三个决定

每一节它都先给出推荐答案，并跳过探索阶段已经回答了的问题。大多数运行只需要确认两次。

| 决定 | 它提议什么 | 什么时候问 |
| --- | --- | --- |
| **issue tracker** | 与你的 `git remote` 匹配的那个 | 总是会问，因为这是唯一真正的选择 |
| **分诊标签** | 保留五个规范名称（`needs-triage`、`needs-info`、`ready-for-agent`、`ready-for-human`、`wontfix`） | 仅在安装了 `triage` skill 时 |
| **领域文档** | 单上下文：根目录下一个 `GLOSSARY.md` 加 `docs/adr/` | 仅在发现 monorepo 迹象时，这时它会提供多上下文的 `GLOSSARY-MAP.md` |

tracker 的选项：

| 选项 | issue 放在哪里 | 需要 |
| --- | --- | --- |
| **GitHub** | 仓库的 GitHub Issues | `gh` CLI |
| **GitLab** | 仓库的 GitLab Issues | `glab` CLI |
| **本地 markdown** | 本仓库 `.scratch/<feature>/` 下的文件 | 什么都不需要，连 remote 都不用 |
| **其他** | 你说放哪就放哪 | 由你写一段话描述工作流程 |

前三个作为模板随 skill 一起提供，开箱即用。本地 markdown 是一个完整的选项，不是退而求其次。这个 skill 支持没有 remote 的个人项目。有一点要注意：如果你用 GitHub，就不要用本地 markdown。它们是二选一的，挑一个。

「其他」也是一个完整的选项。Jira、Linear、Azure DevOps 和 Beads 都是这样接入的。你描述工作流程，skill 把你的文字记录到 `docs/agents/issue-tracker.md`，下游 skill 照着这段文字去做。已经有用户做出来了：一个通过 [MCP](https://www.aihero.dev/ai-coding-dictionary/mcp) 接 Jira 的变体，一个仿照 `gh` 设计的 Gitea CLI，一个手搭的本地看板。

## 常见问题

**我必须用 GitHub 吗？**

不必。GitHub、GitLab 和 `.scratch/` 下的本地 markdown 都作为现成模板提供，其他任何东西都可以走「其他」这条路。这是被问得最多的问题，大致是这些说法：*「被死死锁定在 github 上」*、*「我能用 GitLab / Jira 吗」*、*「那 Azure DevOps 呢」*。答案始终一样：选择 tracker 的是设置，不是 skill。

**更新 skill 之后需要重新运行它吗？**

v1.1 之后的直接回答是需要。skill 自己的结束语则温和一些，它只让你在切换 tracker 或从头开始时重新运行。两种说法都站得住。种子模板在版本之间会变，所以旧版本生成的 `docs/agents/issue-tracker.md` 可能已经跟不上现在读取它的 skill 了。如果某个下游 skill 的行为和文档描述的不一样，就重新运行设置。代价很小。

**它写进了 `CLAUDE.md`，但我用的是 Codex。**

这是一个已知的缺口，至今仍未解决。选择文件的规则是「`CLAUDE.md` 存在就改它，否则改 `AGENTS.md`」。它检查的是哪个文件存在，而不是正在运行的是哪个 [harness](https://www.aihero.dev/ai-coding-dictionary/harness)。在一个留有 Claude Code 时期 `CLAUDE.md` 的仓库里，skill 会把它的 `## Agent skills` 块写进一个 Codex 从来不读的文件。用户有两种变通办法：手动把这个块挪到 `AGENTS.md`，或者以 `AGENTS.md` 为准，把 `CLAUDE.md` 改成一行指向它的指针。如果两个文件都不存在，skill 会问你创建哪一个，而不是自己挑一个。这让一些期望它自己做决定的人感到困惑。

**它没有创建我的分诊标签。**

它不会创建。`docs/agents/triage-labels.md` 是一张*映射表*：它告诉 `/triage` 你的 tracker 里哪些字符串对应五个规范角色。它不会运行 `gh label create`。在一个全新的 GitHub 仓库里，这些标签还不存在，用户不止一次把这个当作 bug 提交过。由此有两个结果：

- 如果你的 tracker 已经在用规范名称，映射表就是一张恒等表，没什么要配置的。这是预期中的常见情况，不是漏掉了某一步。
- 这个 skill 也不会创建 [wayfinder](https://aihero.dev/skills-wayfinder) 的 `wayfinder:map` 和 `wayfinder:<type>` 标签，而 `gh issue create --label <missing>` 会直接失败，不会帮你创建标签。在 GitHub 仓库上第一次运行 wayfinder 之前，先手动创建它们。

**我能在这里配置其他 skill 的行为吗（[盘问](https://www.aihero.dev/ai-coding-dictionary/grilling)节奏、提问格式、语气）？**

不能。它配置三样东西：tracker、标签、文档布局。有用户希望把它做成存放个人偏好的地方。答案是 skill 保持有主见，不接受按用户的配置。偏好应该作为普通指令写进你的 `CLAUDE.md`，每个 skill 本来就会读它。

**我能把配置放在 `~/.claude` 里，而不是 commit 到每个仓库吗？**

目前不能。有位在很多仓库里使用这套 skill 的用户提了这个请求，至今未关闭，但用户级模式并不存在。每个仓库都带着自己的 `docs/agents/`。

**用一个 skill 去配置其他 skill，不觉得奇怪吗？**

一条由来已久的抱怨说是的，原话是：*「用一个 skill 去设置其他 skill，我觉得不对劲：这意味着 LLM 在配置它自己的 skill。」* 这个取舍是真实存在的。没有设置这一步，每个涉及 issue 的 skill 都得各自带一份 tracker 说明。产出是你能读、能改的 markdown，这限制了风险。它写的每个文件你都能读，也能手动修改。日常的改动就这样手动做，而不是再运行一次。

## 起作用的标志

- `docs/agents/issue-tracker.md` 和 `docs/agents/domain.md` 存在，如果安装了 `triage`，还有 `triage-labels.md`。
- 你的 harness 读取的指令文件里出现了一个 `## Agent skills` 小节，为上面每个文件各写了一行摘要并指向它。
- 它提议的 tracker 与你使用的 remote 匹配，标签字符串与你 tracker 里实际存在的标签匹配。
- 之后，`/to-tickets` 发布时不再问你 issue 放在哪里，`/triage` 会打上已有的标签而不是自己编造标签。
- skill 文件本身没有任何变化。如果设置改动了某个 `SKILL.md`，那就是出问题了。

## 在体系中的位置

`setup-matt-pocock-skills` 是工程流程的**一次性设置**，是其他一切默认已经具备的前提，而不是链路中的一步。它的邻居就是它的读者：[triage](https://aihero.dev/skills-triage)，使用这里写下的标签词汇；[to-spec](https://aihero.dev/skills-to-spec) 和 [to-tickets](https://aihero.dev/skills-to-tickets)，发布到这里指定的 tracker；以及 [wayfinder](https://aihero.dev/skills-wayfinder)，读取同一个 tracker 文件里的 "Wayfinding operations" 小节，了解如何存放地图和子 [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket)。[domain-modeling](https://aihero.dev/skills-domain-modeling) 之后会补全设置记录下的领域文档布局。它只在你确定一个术语或决策时才创建 `GLOSSARY.md` 和 ADR，所以设置之后仓库里没有领域文档是正常的。下一步该用哪个 skill，[ask-matt](https://aihero.dev/skills-ask-matt) 会在整套 skill 上为你指路。
