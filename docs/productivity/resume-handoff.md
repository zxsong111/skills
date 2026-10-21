## 它做什么

`resume-handoff` 是 [handoff](https://aihero.dev/skills-handoff) 的另一半。在一个新[会话](https://www.aihero.dev/ai-coding-dictionary/session)里，它自己找到交接文档，对照它检查工作状态，然后从「下一步」继续。**它从不问你文档在哪；它自己去找。**找不到时，它也不会编造进度：它会直说什么都没找到，然后向你要一个路径。

查找顺序是固定的：

1. 仓库根目录的 `tasks/handoff.md`。
2. 仓库其他 worktree 里的同一个文件。
3. 系统临时目录里最近 7 天的交接文档，上游 `handoff` 默认写在那里。

如果找到好几份，它用最新的，并告诉你其余的在哪里。

## 什么时候用

输入 `/resume-handoff` 调用它，[agent](https://www.aihero.dev/ai-coding-dictionary/agent) 不会自己去用它。它不接受参数。

| 情况 | 它做什么 |
| --- | --- |
| 上一个会话运行过 `/handoff` | 找到文档，检查 branch 和工作区，重申目标和下一步，然后开工 |
| branch 或改动与文档对不上 | 停下来，告诉你差在哪里，先问再继续 |
| 没有交接文档 | 去 issue tracker 查有没有进行中的 ticket；也没有的话，直说并停止 |
| 文档列了「待用户决定」 | 先问，再动手 |

## 检查工作状态，而不是检查文档

交接文档里被当作事实陈述却没有证据的说法（「X 做完了」「Y 不存在」）会被当作待验证的东西。「已排除」里列出的做法不会被再次尝试，除非出现了新的证据。任务完成、验证也拿出了证据之后，skill 会删掉交接文档，这样下一次运行就不会捡起一份已经完结的交接。

## 常见问题

**上游 `handoff` 写到临时目录。它能找到那里吗？**
能。它的第三步会在 `$TMPDIR`（未设置时是 `/tmp`）里找最近 7 天文件名带 handoff 的 markdown 文件。超过 7 天的文件，或者系统清空临时目录时丢掉的文件，它找不到，转而向你要路径。

**它和 `/compact` 有什么区别？**
`/compact` 压缩[上下文](https://www.aihero.dev/ai-coding-dictionary/context)，在同一个会话里继续；`resume-handoff` 在一个全新的会话里从文件恢复。前者保住你的意图。后者只有写到磁盘上的那些东西。

## 起作用的标志

- 运行 `/resume-handoff` 之后，回复的头两三行是目标、当前状态和下一步。
- 它跑了 `git status` 和 `git branch` 来核对，而不是听信文档的一面之词。
- 文档「已排除」下的做法没有被再次尝试。
- 任务做完后，交接文档被删掉了。

## 在体系中的位置

`resume-handoff` 是一个**随时可用的独立工具**，工作在阶段边界上：`/handoff` 写，`/resume-handoff` 读。它唯一的邻居是 [handoff](https://aihero.dev/skills-handoff)，因为那个写下的文档正是这个 skill 要读的。要在阶段边界上的五个选项里做选择，见 [ask-matt](https://aihero.dev/skills-ask-matt)。
