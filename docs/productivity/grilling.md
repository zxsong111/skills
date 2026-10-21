## 它做什么

`grilling` 是一个访谈循环，在任何人动手之前，对一个计划、一个决策或一个想法做压力测试。它把主题画成一棵**决策树**（design tree）：每个决策都分叉出挂在它下面的决策，然后逐个分支地访谈你，直到没有任何假设是未说明的。

它不会一次只问一个问题，也不会一次把所有问题都问完。每一**轮**问的是整个**前沿**（frontier）：所有前提条件都已定下来的决策，仅此而已。如果一个问题依赖另一个，这两个问题绝不会出现在同一轮；一个取决于尚未确定的答案的问题，属于后面的轮次。你的回答定下了决策，前沿向外推进，下一轮就问那些刚被解锁的问题。十三个问题通常大约三轮就问完，而不是十三轮。

## 什么时候用

输入 `/grilling`，或者在任务匹配时由 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 自动调用。它是盘问家族里唯一一个模型自动调用的 [skill](https://www.aihero.dev/ai-coding-dictionary/skill)，所以你很少需要输入它。通常是你*确实*输入了的某个 skill 替你运行它。

直接输入 `/grilling`，得到的就是单纯的访谈，别无其他。如果你想要的不止于此：

| 你手上有什么 | 该用什么 |
| --- | --- |
| 你不在一个工作目录里 | [grill-me](https://aihero.dev/skills-grill-me)：同样的[会话](https://www.aihero.dev/ai-coding-dictionary/session)，换了一个 agent 永远不会自己触发的名字 |
| 你在一个工作目录里 | [grill-with-docs](https://aihero.dev/skills-grill-with-docs)：同样的会话，并且会边聊边写 `GLOSSARY.md` 和 ADR |
| 一项大到一次会话装不下的工作 | [wayfinder](https://aihero.dev/skills-wayfinder)：它画出一张地图，并在决策 ticket 里运行盘问 |
| 一个靠聊天解决不了的问题：某样东西应该长什么样、是什么感觉 | [prototype](https://aihero.dev/skills-prototype)：先做出一次性的版本，然后再回来 |
| 你自己写的、需要访谈的 skill | 在里面调用 `/grilling`，而不是再写一套访谈 |

## 轮次、前沿，以及谁来决定

这个 skill 建立在三个概念之上。

**决策树**是主题的模型：决策下面挂着决策。**前沿**是所有前提条件都已定下来的决策集合：也就是 agent 当前唯一能问的问题。**一轮**就是一个前沿，完整地问出，完整地回答。

在一轮里，每个问题都有固定格式：编号和标题跟在 `❓` 后面，然后是正文，然后是 agent 的推荐答案，单独占一行，以 `➡️` 开头。这种格式让你可以按编号回答一整轮（「1 是，2 选第二个，3 不，原因如下」），而不用把问题引用回去。这个格式有一个已知问题。推荐答案有时会*反对*问题本身的措辞，于是同意推荐答案就意味着对问题回答「否」。遇到这种情况，就针对推荐答案作答，并说明这一点。

设计的另一半是事实与决策的划分。事实是 skill 自己的事。当某个前沿问题需要的东西可以由[环境](https://www.aihero.dev/ai-coding-dictionary/environment)确定时，agent 会派出一个[子 agent](https://www.aihero.dev/ai-coding-dictionary/subagent) 去查明，而不是问你。这一轮不会等这项调研；只有依赖它的问题才会等。决策归你，agent 必须等你做出决策。一个运行 `grilling` 却自己回答自己决策问题的 agent，就是把这个 skill 用坏了。前沿清空时会话结束。然后 agent 会等你确认双方理解一致，才会按你们商定的去行动。

前沿有一个局限。agent 是凭判断选出前沿的，而不是从一张图里算出来的。所以它可能把两个问题放进同一轮，事后才发现其中一个的答案本该改变另一个。唯一的防护就是告诉它。这样受影响的分支会在下一轮重新打开。

## 这里讲什么，包装 skill 里讲什么

本页讲的是机制。包装 skill 的页面回答人们最常问的问题。

| 问题 | 在哪里回答 |
| --- | --- |
| 决策树、前沿、轮次、问题格式、事实与决策 | 本页 |
| 一次会话该持续多久，碰到靠聊天答不出来的问题怎么办，怎样避免一路点头 | [grill-me](https://aihero.dev/skills-grill-me) |
| 什么会被写进 `GLOSSARY.md`，什么会变成 ADR | [grill-with-docs](https://aihero.dev/skills-grill-with-docs) |

## 常见问题

**我能改回一次只问一个问题吗？**
可以，而且相当一部分用户就是这么做的。把这一行加到你的全局 `CLAUDE.md`：

```
盘问时，一次只问一个问题。
```

不是每个人都喜欢默认的按轮提问。阅读较慢的用户、用第二语言工作的用户，或者借助逐个提问来帮自己集中注意力的用户，都反馈一次一个问题对他们更好用。这个退出选项是受支持的设置，而不是变通办法。

**`/batch-grill-me` 去哪了？**
并进了这个 skill。按轮提问曾短暂地作为一个独立 skill 发布，后来移进了 `grilling` 本身，这样所有建立在这个基础组件上的东西（`grill-me`、`grill-with-docs`、`triage`、`wayfinder`）一下子都有了它。没有 `batch-grill-me` 可以安装，也没有单独的逐个提问 skill；上面那行 `CLAUDE.md` 就是改回一次一个的方法。

**一次问完一整轮，肯定会漏掉我前面的回答本来会引出的问题吧？**
这是对按轮提问最常见的反对意见，而前沿回答了它。一轮里只包含互不依赖的问题，所以一轮里的任何回答都不可能让同一轮的另一个问题失效。你的回答仍然会改变后面的内容，因为 agent 每一轮都会从头推算下一轮。你确实会损失一些东西，但比「一次问完所有问题」听起来要少。见上文前沿的局限。

**它问完了问题，就开始动手构建了。**
确认关卡就是为此而设的。skill 的结束点是你说双方理解一致的时候，而不是前沿清空的时候。较弱、较快的[模型](https://www.aihero.dev/ai-coding-dictionary/model)仍然会跳过这道关卡。用户反馈这种情况最常出现在低推理强度或非前沿模型上，它们会把「访谈直到理解一致」压缩成几个问题加一份大纲。如果你的模型这么做，可靠的解决办法是在你自己的 `AGENTS.md` 或 `CLAUDE.md` 里加一行，告诉 agent 未经许可不要动手实现。

**它自己回答了自己的问题，而不是问我。**
这是这次运行的 bug，也正是 skill 文本把事实和决策分开的原因。最常发生在另一个 skill 运行 `grilling` 来解决某个 ticket 时，agent 把这个任务当成了继续往前推进的许可。同样的约束也是没有异步模式的原因。有人要过一种变体：读取一个 GitHub issue，然后发布一份汇总的决策备忘录。那是另一个 skill，因为一次没人回答的盘问会话，产出的是 agent 的意见，而不是你的。

**我能给问题数量设个上限吗？**
不能，而且上限是有意排除在范围之外的。有的计划需要三个问题，有的需要五十个；固定的上限要么截断困难的情况，要么在简单的情况下显得武断。预期的控制方式是直接说话。告诉它收尾，或者停下来，接受计划当前的样子。如果一次会话跑得特别长，原因通常是范围太大；把工作拆开，逐块盘问。

**我单独安装了 `grill-me`，结果什么都没发生。**
`grill-me` 是一个只有一行的 skill，它的全部正文就是「运行一次 `/grilling` 会话」，所以它需要同时安装这个 skill。`grill-with-docs` 也一样，而且它还需要 [domain-modeling](https://aihero.dev/skills-domain-modeling)。安装整套就能避免这个问题；有选择地安装，就意味着也要装上这些基础组件。

**`grill-with-docs` 跑了，但它从来没有加载 `grilling`。**
这是一个真实存在、尚未修复的 bug，用户在各种 [harness](https://www.aihero.dev/ai-coding-dictionary/harness) 和模型上都报告过。一个 skill 点名另一个 skill，并不能可靠地让那个 skill 被加载，而 `grill-with-docs` 点名了两个。征兆是一次会话把所有问题一次问完，而且没有推荐答案。这说明模型在即兴发挥一场访谈，而不是在运行这一套。直接问 agent 它有没有加载 `grilling` 和 `domain-modeling`，通常就能恢复。

## 起作用的标志

- 一轮以编号列表的形式到来，每个问题的推荐答案单独占一行 `➡️`，你可以按编号回答整轮。
- 一轮里没有任何问题需要先回答同一轮的另一个问题。
- 后面的轮次问到了第一轮不可能问出的东西。
- 它会自己去查事实（读文件、派出子 agent），而不是问你一些它本可以自己查到的东西。
- 后台运行的调研不会拖住这一轮；只有依赖它的问题才会等。
- 它在结束时停下来，请你确认双方理解一致，而不是直接开工。
- 问题数量多，轮次数量少。

## 在体系中的位置

`grilling` 是一个**基础组件**，而不是你要安排的一个步骤：它是访谈技巧唯一的事实来源，集中放在一处，让每个需要访谈的 skill 都来用它，而不是自己发明一套。[grill-me](https://aihero.dev/skills-grill-me) 和 [grill-with-docs](https://aihero.dev/skills-grill-with-docs) 是它的两个用户手动调用的入口，而 `grill-with-docs` 是主构建链路的起点，位于 [to-spec](https://aihero.dev/skills-to-spec) 之前。[wayfinder](https://aihero.dev/skills-wayfinder) 运行它来解决决策 ticket，[triage](https://aihero.dev/skills-triage) 用它把一份模糊的报告盘问成可操作的报告，[improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) 则在你选定一个要加深的候选项后，用它来走一遍决策树。拿不准哪个入口合适时，[ask-matt](https://aihero.dev/skills-ask-matt) 会给你指路。
