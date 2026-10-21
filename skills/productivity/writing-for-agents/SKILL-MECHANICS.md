# Skill 机制

这是 [`writing-for-agents`](SKILL.md) 中专属于 skill 的分支：当文档是一个 skill 时有什么不同（frontmatter、调用方式的选择，以及路由 skill）。关于怎么写它的其他一切，都在 `SKILL.md` 里的通用参考中。

## 调用方式

两种选择，在两种负担之间取舍：

- **模型自动调用(model-invoked)**的 skill 保留 `description`，这样 agent 能自主触发它，其他 skill 也能调用它。你仍然可以手动输入它的名字：模型自动调用总是_包含_用户可达；description 只会额外加上 agent 的发现能力，从不剥夺人的调用能力。description 是 skill 的顶层上下文指针，被迫始终保持加载：用永久的上下文负担换取可发现性。一个内容全是参考的模型自动调用 skill，也可以作为共享参考的一个归宿：别的 skill 可以调用它，所以多个 skill 都需要的参考就放在一处。机制：省略 `disable-model-invocation`，并写一份面向模型、带有触发分支的 description（`SKILL.md` 里写指针的规则全部适用）。
- **用户手动调用(user-invoked)**的 skill 让 description 脱离 agent 的可达范围：只有人手动输入它的名字才能调用它，任何其他 skill 都不能。上下文负担为零，但要花认知负担：你就是那个必须记得它存在的索引。机制：设置 `disable-model-invocation: true`；`description` 变成面向人的：一行摘要，去掉触发词列表。

只有当 agent 必须自己找到这个 skill，或者另一个 skill 必须调用它时，才选模型自动调用。如果它只会被手动触发，就做成用户手动调用，不付任何上下文负担。

两个用户手动调用的 skill 都需要的共享参考，放在哪一个里都不行：没有 description，谁也触发不了谁。把它推到 skill 体系之外的一个普通文件里：成为任何 skill 都能指向的外部参考。

## 按调用方式拆分

拆分中按调用方式的那一刀（按顺序的那一刀在 `SKILL.md` 里）：当你有一个应该单独触发它的独特引导词（一个你在 prompt 里真的会用的触发词），或者另一个 skill 必须调用它时，就拆出一个模型自动调用的 skill。新的始终加载的 description 要付上下文负担，所以这份独立的可达性必须值得。

## 路由 skill

当用户手动调用的 skill 多到你记不住时，这份堆积起来的认知负担要靠一个**路由 skill(router skill)**来治：一个用户手动调用的 skill，点名其他 skill 以及各自什么时候用，这样人只需要记住一个 skill，而不是一大堆。它只能提示，永远不能触发它们：用户手动调用的 skill 没有 description，所以除了人之外，谁也调用不了它们。
