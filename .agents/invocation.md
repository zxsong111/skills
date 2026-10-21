# 模型自动调用 vs 用户手动调用

本仓库里的每个 `SKILL.md` 都是一个 skill。把它们分开的唯一维度是**调用方式**，也就是谁能触发它：

- **用户手动调用**（user-invoked）：**只有人输入它的名字**才能触发。在 frontmatter 里设置 `disable-model-invocation: true`（Claude Code），并在 `agents/openai.yaml` 里设置 `policy.allow_implicit_invocation: false`（Codex）。`description` 是**写给人看的**：一行摘要，给浏览 slash command 的人读。去掉触发词列表（「Use when the user says…」这类）。
- **模型自动调用**（model-invoked）：**模型或用户**都能触发。这是默认情况：省略 `disable-model-invocation`，`agents/openai.yaml` 里也不写 `policy` 块。`description` 是**写给模型看的**，保留丰富的触发短语（「Use when the user wants…, mentions…, asks for…」这类），好让自动调用生效。判断一个 skill 是否该保持模型自动调用的标准是：_模型自主地去用它，是否真的有用？_（可复用是把它抽成 skill 的理由，而不是这个判断标准。）

每个 harness 都用自己的方式把用户手动调用的 skill 挡在模型够不着的地方，所以除了人，谁都无法触发它：其他 skill 也不行。用户手动调用的 skill 可以调用模型自动调用的 skill，但永远不能调用另一个用户手动调用的 skill。

每个 skill 的 `SKILL.md` 旁边还有一个 `agents/openai.yaml`。它存放 Codex 的 UI 元数据：供 skill 选择器使用的 `interface.display_name` 和 `interface.short_description`；对于用户手动调用的 skill，还有与 `disable-model-invocation` 配对的 `policy.allow_implicit_invocation: false`。两者要保持同步：一个 skill 要么在两个 harness 里都是用户手动调用，要么都不是。

各分类目录（bucket）的 `README.md` 和顶层 `README.md` 都把条目分成**用户手动调用**和**模型自动调用**两组。

## 它们之间的依赖

依赖关系用一条明确的指令来表达：**调用 Skill 工具**并指定 skill 名（`Call the Skill tool with "grilling"`），而不是深层的 `../other-skill/FILE.md` 交叉引用，也不是丢一个 `/skill` 形式的提及让模型自己去理解。点明工具名才能让它真正触发：大多数 harness 都把 skill 调用暴露为模型可调用的一个工具，明确写出来，命中率比在正文里塞一个 `/name`、指望模型把它当成命令要高。去掉开头的 `/` 也让写法更加不依赖具体 harness：单独一个 skill 名，不预设它属于哪个 harness 的触发语法。共享的参考文档放在拥有它的那个 skill 里面；其他 skill 要用这些材料，就用 Skill 工具调用那个 skill，而不是跨目录链接过去。

这里说的是**操作性**指令：skill 自己的步骤让 agent 马上去运行另一个 skill。路由性质的文字（`ask-matt`、分类目录的 `README.md`）只是列出 skill 名让人挑选，并没有调用任何东西，所以继续把 `/skill` 形式的名字当普通标签用。

Skill 工具每次调用只接受一个 skill。需要两个 skill 的步骤就是两次调用，而不是一次调用带两个名字：要明确写出来（`Call the Skill tool twice, for "grilling" and "domain-modeling"`），而不是写「call it with X and Y」，那读起来像是一次调用同时接收两个。

这整套约定只在被点名的 skill 是**模型自动调用**时才成立。用户手动调用的 skill 永远无法通过这种方式触发，没有例外：按照上面的不变量，其他 skill 都不能调用它，包括把它的名字交给 Skill 工具。当某一步的前置条件是一个用户手动调用的 skill（例如 `setup-matt-pocock-skills`），要把它写成让人去执行的指令：「告诉用户运行 `/setup-matt-pocock-skills`」，绝不写成一次 Skill 工具调用。

## 被动与主动的领域工作

只是为了词汇去_读_ `GLOSSARY.md`，用一行文字指针即可，不需要 `domain-modeling` skill。只有主动构建和打磨的那套方法纪律（质疑术语、边界场景、写 ADR、随手更新 `GLOSSARY.md`）才是 `domain-modeling`。
