# Issue tracker: GitLab

本 repo 的 issue 和 spec 以 GitLab issue 的形式存在。所有操作都使用 [`glab`](https://gitlab.com/gitlab-org/cli) CLI。

## 约定

- **创建 issue**：`glab issue create --title "..." --description "..."`。多行描述用 heredoc。传 `--description -` 可以打开编辑器。
- **读取 issue**：`glab issue view <number> --comments`。用 `-F json` 获得机器可读的输出。
- **列出 issue**：`glab issue list -O json`，配合合适的 `--label` 过滤条件。
- **在 issue 上评论**：`glab issue note <number> --message "..."`。GitLab 把评论叫作 "notes"。
- **添加 / 移除标签**：`glab issue update <number> --label "..."` / `--unlabel "..."`。多个标签可以用逗号分隔，也可以重复这个参数。
- **关闭**：`glab issue close <number>`。`glab issue close` 不接受关闭评论，所以先用 `glab issue note <number> --message "..."` 发出说明，再关闭。
- **Merge request**：GitLab 把 PR 叫作 "merge requests"。使用 `glab mr create`、`glab mr view`、`glab mr note` 等，形式与 `gh pr ...` 相同，只是用 `mr` 代替 `pr`，用 `note`/`--message` 代替 `comment`/`--body`。

从 `git remote -v` 推断 repo；在克隆的仓库里运行时 `glab` 会自动做这件事。

## 把 merge request 作为分诊对象

**MRs as a request surface: no.** _（如果本 repo 把外部 merge request 当作功能请求，就设为 `yes`；`/triage` 会读取这个标志。）_

设为 `yes` 时，MR 走与 issue 相同的标签和状态，使用对应的 `glab mr` 命令：

- **读取 MR**：`glab mr view <number> --comments`，diff 用 `glab mr diff <number>`。
- **列出待分诊的外部 MR**：`glab mr list -F json`，然后只保留作者不是项目成员/所有者的 MR（贡献者的 MR，而不是维护者进行中的工作）。
- **评论 / 打标签 / 关闭**：`glab mr note`、`glab mr update --label`/`--unlabel`、`glab mr close`。

与 GitHub 不同，GitLab 的 issue 和 MR 分开编号，所以只要知道维护者指的是哪一类，`#42` 就没有歧义。

## 当 skill 说 "publish to the issue tracker"（发布到 issue tracker）时

创建一个 GitLab issue。

## 当 skill 说 "fetch the relevant ticket"（拉取相关 ticket）时

运行 `glab issue view <number> --comments`。

## Wayfinding operations

供 `/wayfinder` 使用。**地图(map)**是单个 issue，**子** issue 就是各个 ticket。

- **Map**：单个打了 `wayfinder:map` 标签的 issue，正文包含 Notes / Decisions-so-far / Fog。`glab issue create --label wayfinder:map`。（在有原生 epic 的 GitLab 版本上，也可以用 epic 来承载地图；打标签的 issue 则在哪里都能用。）
- **Child ticket**：一个在描述顶部写有 `Part of #<map>`、带 `wayfinder:<type>` 标签（`research`/`prototype`/`grilling`/`task`）的 issue。一旦被认领，ticket 就指派给主导的开发者。
- **Blocking**：GitLab 的**原生阻塞链接**，这是规范的、在 UI 上可见的表示方式。用 `/blocked_by #<n>` 快捷操作添加，以 note 的形式发出（`glab issue note <child> --message "/blocked_by #<blocker>"`）。原生阻塞链接是 Premium/Ultimate 功能；在免费版上（或不可用时）回退为在描述顶部写一行 `Blocked by: #<n>, #<n>`。当所有阻塞方都关闭时，ticket 就解除阻塞了。
- **Frontier query**：`glab issue list -O json`，限定在地图的子 issue 范围内，去掉任何还有未关闭阻塞方的：指向未关闭 issue 的原生 `blocked_by` 链接（`glab api projects/:id/issues/<child-iid>/links`），或 `Blocked by` 行里有未关闭的 issue，或已有指派人；按地图顺序排第一的优先。
- **Claim**：`glab issue update <n> --assignee @me`，这是会话中的第一次写操作。
- **Resolve**：`glab issue note <n> --message "<answer>"`，然后 `glab issue close <n>`，再在地图的 Decisions-so-far 中追加一个上下文指针(context pointer)（要点 + 链接）。
