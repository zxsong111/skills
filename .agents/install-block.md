# 标准安装块

一套安装说法，一种措辞。`README.md`、`.changeset/*` 以及 `docs/` 下的每个页面都必须这么写，不能有别的说法。要改先改这里，再同步到各处。

## 优先推荐托管安装

先列会自动更新的安装方式。只有某个 agent 没有这种安装方式时，才退回到 skills.sh，并标注「手动更新」。只有不需要用户运行任何命令就能更新的路线，才叫托管安装。任何一次性的开启操作，都写在对应安装命令的旁边。永远不要承诺「即时」。

Claude Code 从它的官方 marketplace `claude-plugins-official` 安装。其他所有托管路线都从本仓库自己的 marketplace 安装，也就是 `.claude-plugin/marketplace.json` 和 `plugin.json`。这些路线只在 `plugin.json` 里的 `version` 变化时才重新安装。Release 工作流会运行 `npm run version`，把这个字段从 `package.json` 复制过去，所以「chore: version skills」这个 PR 合并后，用户就会收到新版本。

| Agent         | 路线                             | 自动更新？                                                       |
| ------------- | -------------------------------- | ---------------------------------------------------------------- |
| Claude Code   | `@claude-plugins-official`       | 是，默认开启                                                     |
| Codex         | `@mattpocock` marketplace        | 是，启动时更新，默认开启                                         |
| Copilot CLI   | `@mattpocock` marketplace        | 是，需要一次性设置 `autoUpdate: true`                            |
| VS Code       | Chat: Install Plugin From Source | 是，每天更新，默认开启                                           |
| Gemini CLI    | `gemini skills install`（复制）  | 否。Gemini 扩展需要扁平的 `skills/<name>/` 目录结构              |
| 其他所有 agent | skills.sh                        | 否。运行 `npx skills update`，新 skill 要重新运行 `add`          |

来源（2026-10-08）：Codex `core-plugins/src/manager.rs`；Copilot [cli-config-dir-reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-config-dir-reference)；VS Code `pluginAutoUpdate.ts`；Gemini `skillLoader.ts`。

还没有人在本仓库上跑过 Auggie、Droid、Qwen 或 Goose，所以在有人验证之前，它们继续走 skills.sh。

## Claude Code

<canonical-block name="claude-code">

```bash
claude plugin install mattpocock-skills@claude-plugins-official
```

默认自动更新。

</canonical-block>

## Codex

<canonical-block name="codex">

```bash
codex plugin marketplace add mattpocock/skills
codex plugin add mattpocock-skills@mattpocock
```

启动时自动更新。

</canonical-block>

## GitHub Copilot（CLI 和 VS Code）

用 marketplace，不要用 `copilot plugin install mattpocock/skills`。Copilot 已经弃用直接从仓库安装，而且这种方式不能自动更新。`extraKnownMarketplaces` 条目按文档里的 schema 写，但还没有人实际跑过。

<canonical-block name="copilot">

```bash
copilot plugin marketplace add mattpocock/skills
copilot plugin install mattpocock-skills@mattpocock
```

然后（只需一次）把下面内容加到 `~/.copilot/settings.json`：

```json
{
  "extraKnownMarketplaces": {
    "mattpocock": { "source": { "source": "github", "repo": "mattpocock/skills" }, "autoUpdate": true }
  }
}
```

在 VS Code 里运行 **Chat: Install Plugin From Source**，输入 `https://github.com/mattpocock/skills`。它每天自动更新。

</canonical-block>

## Gemini CLI

Gemini 不读 `.claude-plugin`，而 `--path` 只能接一个分类目录。每个推广分类各装一次，正好得到推广的那一整套（27 个 skill，2026-10-07 验证）。

<canonical-block name="gemini">

```bash
gemini skills install https://github.com/mattpocock/skills.git --path skills/engineering
gemini skills install https://github.com/mattpocock/skills.git --path skills/productivity
```

重新运行这两条命令即可更新。

</canonical-block>

## 其他所有 agent，或者想要可编辑的文件（skills.sh）

`-a` 用来预先选定 agent。注释里列出的每个 agent 都在 2026-10-07 实际跑过。优先用 skills.sh，而不是 agent 自带的仓库安装器（比如 `amp skill add` 或 `pi install git:…`），因为那些安装器会把 `misc/` 和 `in-progress/` 也一起拉进来。`npx skills update` 会跳过 `add` 之后上游新增的 skill，所以安装块会提醒用户重新运行 `add`。

<canonical-block name="other-agents">

```bash
npx skills@latest add mattpocock/skills -a <agent>  # cursor, opencode, devin, windsurf, amp, pi; omit -a to choose
```

安装器问你要装哪些 skill 时，记得勾上 `setup-matt-pocock-skills`。更新时运行 `npx skills@latest update`；要获取新 skill，重新运行 `add`。

</canonical-block>

凡是单独提到某一个 skill 的地方，都用单个 skill 的写法。`docs/` 页面不用这个安装块，因为 ai-hero 会在页面正文上方渲染安装组件。见 [writing-docs.md](./writing-docs.md)。

<canonical-block name="skills-sh-one-skill">

```bash
npx skills@latest add mattpocock/skills --skill=<name>
```

```bash
npx skills@latest update <name>
```

</canonical-block>

`skills@latest` 是所有地方统一使用的固定写法。

## 两条路线互斥

plugin 是你订阅的一个托管、只读的打包。skills.sh 写入的是归你所有、可以自己编辑的文件。两个都装，用户就会得到每个 skill 各两份：所以一定要说「二选一」。
