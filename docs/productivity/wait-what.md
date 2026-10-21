## 它做什么

你在没看懂一条消息时输入 `wait-what`。然后 [agent](https://www.aihero.dev/ai-coding-dictionary/agent) 会把它刚才说的话重新讲一遍：补上你缺的上下文，用大白话写，并使用你项目 `GLOSSARY.md` 里的词汇。

这个 skill 只有三行。这是设计，不是没写完的草稿。对抗啰嗦的 skill 通常失败在它们自己长得太长。一个四百行的简洁 skill 还是会让[模型](https://www.aihero.dev/ai-coding-dictionary/model)啰嗦，因为模型模仿的是 skill 的长度，不是它的要求。这个 skill 只有一个精确的核心词，别的什么都没有。

## 什么时候用

输入 `/wait-what` 调用它，agent 不会自己去用它，也不应该。只有你知道自己是从哪里开始跟不上的。

一发现自己开始扫读就用它。比如，agent 开始用它自造的行话了，一句话里塞了五个缩写，或者解释了一个你从没见过前提的决策。它修复的是你已经身在其中的对话。要让行话根本不出现，用 [grill-with-docs](https://aihero.dev/skills-grill-with-docs)，它会在一开始就把共享语言建起来。

## 名字本身就是机制

核心词是 **wait**（等一下）。「Be concise」是一条关于 agent 输出的指令，模型服从它的方式是砍词，然后让你更迷路。**wait** 说的是*你*的状态。它说的是：你在这里跟丢了。听到「说简短点」的 agent 写出干巴巴的碎片。听到「等一下，你把我讲丢了」的 agent 会退回去解释。

这个差别就是这个 skill 的全部。流行的对抗啰嗦的办法都在给*输出*命名：`/tldr`、`/no-fluff`、`/talk-normal`。模型于是矫枉过正，写出更短却一样不清的碎片。给*听者*命名，一次要的是两半：更少的词，**加上**你缺的上下文。

这个 skill 说的是重讲**那个东西**，而不是「最后那条消息」。让你跟丢的通常不止一段话，所以退多远由 agent 自己判断。

## 它接入你已有的语言

正文复用你全局 `CLAUDE.md` 和项目 `GLOSSARY.md` 里已有的核心词。ASD-STE100 Simplified Technical English 定语域。通用语言提供名词。这个 skill、`CLAUDE.md` 和 `GLOSSARY.md` 用的是同一批 [token](https://www.aihero.dev/ai-coding-dictionary/token)，所以调用它不是一条新指令，而是对一条 agent 已经同意过的指令的重申。

如果你没有 `GLOSSARY.md`（也没有一个指向当前上下文所用语表的 `GLOSSARY-MAP.md`），这个 skill 照样能用。你只损失领域词汇那一半。

## 起作用的标志

- 重讲**更短也更清楚**，而不是更短也更生硬。
- 它补上了你缺的前提，而不是只删词。
- 项目里的名词替换了自造的名词。你 `GLOSSARY.md` 里的术语回来了。
- 你可以连用两次，它不会退化成电报腔。

## 在体系中的位置

你可以在任何对话里、任何时刻、任何其他 skill 内部使用 `wait-what`。它修复的是已经发生的一条消息。真正的修复是事先商定一套共享语言，那正是 [grill-with-docs](https://aihero.dev/skills-grill-with-docs) 做的事：一次[盘问](https://www.aihero.dev/ai-coding-dictionary/grilling)会话，边问边运行 [domain-modeling](https://aihero.dev/skills-domain-modeling)，把你们俩都在用的词记进你的 `GLOSSARY.md`。拿不准此刻哪个 skill 合适时，[ask-matt](https://aihero.dev/skills-ask-matt) 会给你指路。
