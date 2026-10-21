# Issue tracker: GitHub

本 repo 的 issue 和 spec 以 GitHub issue 的形式存在。所有操作都使用 `gh` CLI。

## 约定

- **创建 issue**：`gh issue create --title "..." --body "..."`。多行正文用 heredoc。
- **读取 issue**：`gh issue view <number> --json number,title,body,labels,comments`。
- **列出 issue**：`gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`，配合合适的 `--label` 和 `--state` 过滤条件。
- **把 issue 设为某个父 issue 的子 issue**：`gh issue create --parent <parent> ...`，或者事后用 `gh issue edit <parent> --add-sub-issue <child>`（`gh` 2.94+）。较旧的 `gh`：`gh api --method POST repos/<owner>/<repo>/issues/<parent>/sub_issues -F sub_issue_id=<child-db-id>`（数据库 id，与下文 **Blocking** 中相同）。没有子 issue 功能时，在子 issue 正文顶部写上 `Part of #<parent>`。
- **在 issue 上评论**：`gh issue comment <number> --body "..."`
- **添加 / 移除标签**：`gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **关闭**：`gh issue close <number> --comment "..."`

从 `git remote -v` 推断 repo；在克隆的仓库里运行时 `gh` 会自动做这件事。

## 把 pull request 作为分诊对象

**PRs as a request surface: no.** _（如果本 repo 把外部 PR 当作功能请求，就设为 `yes`；`/triage` 会读取这个标志。）_

设为 `yes` 时，PR 走与 issue 相同的标签和状态，使用对应的 `gh pr` 命令：

- **读取 PR**：`gh pr view <number> --comments`，diff 用 `gh pr diff <number>`。
- **列出待分诊的外部 PR**：`gh api --paginate 'repos/{owner}/{repo}/pulls?state=open' --jq '.[] | select(.author_association | IN("OWNER","MEMBER","COLLABORATOR") | not) | {number, title, author: .user.login, author_association, labels: [.labels[].name]}'`。
- **评论 / 打标签 / 关闭**：`gh pr comment`、`gh pr edit --add-label`/`--remove-label`、`gh pr close`。

GitHub 的 issue 和 PR 共用一个编号空间，所以一个光秃秃的 `#42` 可能是其中任一种：先用 `gh pr view 42` 解析，失败再回退到 `gh issue view 42`。

## 当 skill 说 "publish to the issue tracker"（发布到 issue tracker）时

创建一个 GitHub issue。

## 当 skill 说 "fetch the relevant ticket"（拉取相关 ticket）时

按上文 **读取 issue** 的方式读取。

## Wayfinding operations

供 `/wayfinder` 使用。**地图(map)**是单个 issue，**子** issue 就是各个 ticket。

- **Map**：单个打了 `wayfinder:map` 标签的 issue，正文包含 Notes / Decisions-so-far / Fog。`gh issue create --label wayfinder:map`。
- **Child ticket**：以 GitHub 子 issue 形式关联到地图的 issue（见 **把 issue 设为某个父 issue 的子 issue**）。未启用子 issue 时，把子 issue 加到地图正文的任务列表里，并在子 issue 正文顶部写上 `Part of #<map>`。标签：`wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）。一旦被认领，ticket 就指派给主导的开发者。
- **Blocking**：GitHub 的**原生 issue 依赖**，这是规范的、在 UI 上可见的表示方式。用 `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>` 添加一条边，其中 `<blocker-db-id>` 是阻塞方的数字**数据库 id**（`gh api repos/<owner>/<repo>/issues/<n> --jq .id`，_不是_ `#number` 或 `node_id`）。GitHub 会报告 `issue_dependencies_summary.blocked_by`（只统计未关闭的阻塞方，即实时的关卡）。不支持依赖功能时，回退为在子 issue 正文顶部写一行 `Blocked by: #<n>, #<n>`。当所有阻塞方都关闭时，ticket 就解除阻塞了。
- **Frontier query**：列出地图下未关闭的子 issue（`gh issue list --state open`，限定在地图的子 issue / 任务列表范围内），去掉任何还有未关闭阻塞方的（`issue_dependencies_summary.blocked_by > 0`，或 `Blocked by` 行里有未关闭的 issue）或已有指派人的；按地图顺序排第一的优先。
- **Claim**：`gh issue edit <n> --add-assignee @me`，这是会话中的第一次写操作。
- **Resolve**：`gh issue comment <n> --body "<answer>"`，然后 `gh issue close <n>`，再在地图的 Decisions-so-far 中追加一个上下文指针(context pointer)（要点 + 链接）。
