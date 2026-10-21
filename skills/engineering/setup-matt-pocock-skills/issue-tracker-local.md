# Issue tracker: Local Markdown

本 repo 的 issue 和 spec 以 markdown 文件的形式存放在 `.scratch/` 中。

## 约定

- 每个功能一个目录：`.scratch/<feature-slug>/`
- spec 是 `.scratch/<feature-slug>/spec.md`
- 实现类 issue 每个 ticket 一个文件，路径为 `.scratch/<feature-slug>/issues/<NN>-<slug>.md`，从 `01` 开始编号，绝不合并成一个 tickets 文件
- 分诊状态记录在每个 issue 文件顶部附近的一行 `Status:` 中（角色字符串见 `triage-labels.md`）
- 评论和对话历史追加在文件底部的 `## Comments` 标题下

## 当 skill 说 "publish to the issue tracker"（发布到 issue tracker）时

在 `.scratch/<feature-slug>/` 下新建一个文件（如有需要先创建目录）。

## 当 skill 说 "fetch the relevant ticket"（拉取相关 ticket）时

读取所引用路径上的文件。用户通常会直接给出路径或 issue 编号。

## Wayfinding operations

供 `/wayfinder` 使用。**地图(map)**是一个文件，每个 ticket 对应一个**子**文件。

- **Map**：`.scratch/<effort>/map.md`（包含 Notes / Decisions-so-far / Fog 的正文）。
- **Child ticket**：`.scratch/<effort>/issues/NN-<slug>.md`，从 `01` 开始编号，问题写在正文里。一行 `Type:` 记录 ticket 类型（`research`/`prototype`/`grilling`/`task`）；一行 `Status:` 记录 `claimed`/`resolved`。
- **Blocking**：顶部附近的一行 `Blocked by: NN, NN`。当它列出的每个文件都是 `resolved` 时，这个 ticket 就解除阻塞了。
- **Frontier**：扫描 `.scratch/<effort>/issues/`，找出处于打开、未阻塞、未被认领状态的文件；编号最小的优先。
- **Claim**：在开始任何工作之前，设置 `Status: claimed` 并保存。
- **Resolve**：把答案追加到 `## Answer` 标题下，设置 `Status: resolved`，然后在 `map.md` 的 Decisions-so-far 中追加一个上下文指针(context pointer)（要点 + 链接）。
