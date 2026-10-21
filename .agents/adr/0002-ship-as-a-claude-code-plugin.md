# 以原生 Claude Code plugin 的形式发布整套 skill；原生 Codex plugin 暂缓

这些 skill 一直都可以通过 [skills.sh](https://skills.sh/mattpocock/skills)（`npx skills add mattpocock/skills`）安装，它会把可编辑的 skill 文件复制到用户的项目里，支持 Claude Code、Codex 以及其他遵循 Agent Skills 标准的 harness。一个反复出现的需求是**即插即用**的分发方式：把这套 skill 当作一个只读、始终最新、不需要自己编辑的包来订阅，而不是一个归你所有的 fork。这正是原生 plugin 系统提供的东西。

我们发布原生的 **Claude Code plugin**，而原生的 **Codex plugin** 目前**暂缓**。之所以这样划分，是因为两个生态的 plugin 清单（manifest）选择 skill 的方式，和本仓库按分类目录（bucket）组织的布局之间存在冲突。

## 约束：分类目录中的 skill vs 单一路径选择

skill 放在 `skills/` 下的分类目录里：`engineering/` 和 `productivity/` 是**推广的**（会发布）；`misc/`、`personal/`、`in-progress/` 和 `deprecated/` **不是**。plugin 必须只暴露推广的那一组，而这一组横跨其中两个分类目录。

- **Claude Code**：`.claude-plugin/plugin.json` 接受 `skills` 作为一个**显式 skill 目录路径的数组**。我们逐个列出推广的 skill，毫无歧义地排除其他所有 skill，并添加 `.claude-plugin/marketplace.json`，让仓库自己就是一个只含单个 plugin 的 marketplace。已端到端验证：`claude plugin validate . --strict` 通过，`marketplace add` → `install` 能解析出所有推广的 skill。

- **Codex**：`.codex-plugin/plugin.json` 只接受**单个路径字符串**作为 `skills`（数组会被拒绝，报 `missing or invalid plugin.json`），Codex 会在这个路径下递归发现 `SKILL.md` 文件。用一个路径没办法同时指定两个分类目录，也没法挑选一个子集。我们测试并否决了两个变通办法：
  - 指向 `./skills/` 会把 `deprecated/`、`in-progress/`、`personal/` 和 `misc/` 也一起发布出去：这些是我们刻意不推广的已退役、草稿和个人 skill。
  - 用一个精心挑选的扁平目录，里面放指向各分类目录的**符号链接**，这种做法在安装后保不住：Codex 会把 plugin 目录树复制到它的缓存里，并且**丢弃符号链接**，结果 skill 到手是空的。

要给 Codex 提供一个只含推广 skill 的单一路径，可靠的办法只有两个：(a) **重构目录结构**，让 `skills/` 只包含推广的 skill（把非推广的分类目录移出去，影响范围很大，涉及 `CLAUDE.md`、`scripts/link-skills.sh`、各分类目录的 README，以及依赖 `in-progress/` 和 `personal/` 的本地开发流程）；或者 (b) **commit 推广 skill 的副本**到一个扁平目录里（带来同步负担，还多出第二个事实来源）。两者都是结构性决策，不应该和发布 Claude plugin 捆绑在一起。这很可能就是之前没有发布 plugin 的那个原始原因（只是大家记得不太清了）：清单格式没法干净地表达「从一个按分类目录组织的仓库里挑出一个子集」。

## 决定

- 现在就发布 **Claude Code plugin**（`.claude-plugin/plugin.json` + `.claude-plugin/marketplace.json`），只包含推广的那一组，作为 v1.2 的头号交付物。
- 保留 **skills.sh** 作为通用安装器：它今天已经在服务 Codex 和其他 harness，所以没有哪个 Codex 用户会找不到安装方式。
- 原生 Codex plugin **暂缓**，直到我们在「把 `skills/` 重构成只含推广 skill」和「commit 一份生成的扁平副本」之间做出选择。等 Codex 支持 `skills` 数组或包含列表，或者安装时保留符号链接，再重新评估。

## 由此产生的不变量

- 每个推广的 skill 都在 `.claude-plugin/plugin.json` 的 `skills` 数组里有一项（这本来就是 `CLAUDE.md` 里的一条规则；现在它还决定了 plugin 的内容）。
- `.claude-plugin/plugin.json` 的 `version` 跟随 `package.json` 的版本：发布时两者一起升级。Claude 用 plugin 的 `version` 来决定已安装的用户何时能看到更新。

## 更新，2026-08-05

`mattpocock-skills` 已被收录进 **Claude Code 的官方 marketplace**（配置名 `claude-plugins-official`，源仓库 `anthropics/claude-plugins-official`），每个 Claude Code 安装默认都带有它。`claude plugins install mattpocock-skills` 现在是文档推荐的方式，上面的 `marketplace add` → `install` 路径已被取代。安装措辞放在 [.agents/install-block.md](../install-block.md) 里。

官方收录指向本仓库的 git URL，并直接读取 `.claude-plugin/plugin.json`，所以它不依赖 `.claude-plugin/marketplace.json`。保留那个文件只是为了直接从仓库安装时作为后备（比如一个尚未发布的 commit，或者一个 fork）。

2026-08-05 在 Claude Code 2.1.222 上针对线上收录验证过：

- `claude plugins install mattpocock-skills` 无需事先添加 marketplace 就能解析，并报告 `mattpocock-skills@claude-plugins-official`。
- 接着 `claude plugin details mattpocock-skills` 报告版本 1.2.0，并加载了推广的 skill。
- 收录的 `source` 是 `{"source": "url", "url": "https://github.com/mattpocock/skills.git", "sha": …}`：**sha 是固定的**，所以新版本要等这个固定值移动后才会到达已安装的用户，而不是我们一打 tag 就到。撰写本文时，这个固定值落后 `main` 两个 commit，这就是为什么它列出 22 个 skill，而不是 `plugin.json` 里的 24 个。
- 会话内的 `/plugin install mattpocock-skills` **没有**实际测试过：`/plugin` 在无头（`claude -p`）会话中不可用。它和 CLI 运行的是同一个解析器，文档里给出的示例写法是 `/plugin install <name>@claude-plugins-official`。

## 更新，2026-10-07

上面关于 Codex 的约束不再成立。Codex `main` 已经接受 `skills` 字符串数组，并且在没有 `.codex-plugin/` 时回退到 `.claude-plugin/`（[manifest.rs](https://github.com/openai/codex/blob/main/codex-rs/core-plugins/src/manifest.rs)）。Codex 仍然会丢弃符号链接。

在 Codex 0.161.0 上，从 `@mattpocock` marketplace 安装会加载推广的模型自动调用 skill，`misc/` 和 `in-progress/` 里的一个都不会加载。Copilot CLI 读取同样的清单，并报告「Installed 27 skills」。

## 更新，2026-10-08：优先推荐托管安装

`@mattpocock` 现在是 Codex、Copilot 和 VS Code 上的首推路线，代价是在 Copilot 上需要一次性开启。Claude Code 继续用 `claude-plugins-official`（与 2026-08-05 的更新一致），因为它默认自动更新，而且不需要 `marketplace add`。

上面的版本不变量现在适用于每一条托管路线。`npm run version` 通过运行 `scripts/sync-plugin-version.mjs` 已经在维持它。`marketplace.json` 没有 `version` 字段，所以不会出现版本漂移。
