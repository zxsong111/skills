---
name: resume-handoff
description: >
  接手上一个会话没做完的任务。找到 /handoff 写的交接文档，对照它检查当前工作状态，然后从它的「下一步」继续。不接受参数。
disable-model-invocation: true
---

# 会话交接（读取端）

用户只输入了 skill 名。**不要问文档在哪儿，自己去找。**

## 1. 找到交接文档

按以下顺序查找，找到第一个就停：

```bash
root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
tmp=${TMPDIR:-/tmp}
found=$({
  # (1) 当前仓库根目录  (2) 同一仓库的其他 worktree（上一个会话可能在另一个 worktree 里）
  ls -1 "$root/tasks/handoff.md" 2>/dev/null
  git worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p' |
    while read -r w; do ls -1 "$w/tasks/handoff.md" 2>/dev/null; done
  # (3) 系统临时目录里最近 7 天的交接文档（/handoff 默认写到这里）
  find "$tmp" -maxdepth 2 -iname '*handoff*.md' -mtime -7 2>/dev/null
} | sort -u)
# 最新的排在最前；一个都没找到时什么也不输出（macOS 和 Linux 都适用）
[ -n "$found" ] && printf '%s\n' "$found" | tr '\n' '\0' | xargs -0 ls -t
```

- **找到一个** → 就用它
- **找到多个** → 用第一个（最新的），并告诉用户其他文档的路径，以及每份文档「时间」字段里记录的时间
- **一个都没找到** → 去 issue tracker 里找做了一半的 ticket：本地 tracker 就看 `.scratch/*/issues/*.md` 下 `Status:` 不是 done 的文件；真正的 tracker 就看分配给你、状态为进行中的 issue。
  如果有 → 列出来让用户挑一个，读完后继续；如果没有 → 告诉用户「没有找到交接文档，也没有进行中的 ticket」，请用户给出路径，然后停下。**不要编造进度报告**

如果交接文档在另一个 worktree 或另一个目录里，之后的所有工作都在**那个目录**里做，并且先告诉用户。

## 2. 检查工作状态

读完整份交接文档，然后对比：

```bash
git -C <包含交接文档的仓库根目录> branch --show-current
git -C <包含交接文档的仓库根目录> status --short
```

- branch 和交接文档记录的不一致、「改动中的文件」下列出的文件已经 commit 了或已经不在了，或者存在交接文档完全没提到的改动
  → 交接文档可能已经过时；**停下**，把差异告诉用户，等弄清楚之后再继续
- 文档里的「时间」已经是很久以前 → 同样先确认
- 交接文档当作事实陈述、但没有证据的说法（「X 已经做完了」「Y 不存在」）→ 视为仍待验证，不要直接相信

## 3. 继续

1. 用两三行向用户复述：「目标」、「当前状态」，以及接下来要做的那一步
2. 「待用户决定」不是「无」→ 先问
3. 从「下一步」开始。不要重试「已排除」里列出的做法，除非你有新的证据
4. 交接文档里有「建议调用的 skill」小节 → 调用它列出的 skill
5. 如果工作过程中状态发生了实质变化，会话又变长了 → 提醒用户再跑一次 `/handoff`

## 4. 收尾

任务完成、并且跑过验证命令拿到证据之后，**删除交接文档**（仓库里的 `tasks/handoff.md`，或临时目录里的那份），免得下一次 `/resume-handoff` 又捡起一份已经完成的交接。
