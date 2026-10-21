---
name: claude-handoff
description: >
  把当前对话交接给一个全新的后台 agent，让它立即接手工作。
argument-hint: "下一个会话要用来做什么？"
disable-model-invocation: true
---

为当前对话写一份交接摘要，让一个全新的 agent 能够接着做。把它保存到用户操作系统的临时目录，然后启动一个以它作为 prompt 的后台 agent：`claude --bg --name "<descriptive name>" -- "$(cat <summary file>)"`。通过文件传递，可以防止 shell 执行摘要里的反引号或展开其中的 `$`。它会在当前工作目录启动并立即返回；用户通过 `claude agents` 管理它。

始终传入 `-n`/`--name` 并给出描述性的名称（例如 `--name "Fix login bug"`）；它决定了任务列表、会话选择器和终端标题中显示的名称。

在摘要中加入一个「建议使用的 skill」小节，列出下一个 agent 应该通过 Skill 工具调用哪些 skill。

不要重复其他产物（spec、计划、ADR、issue、commit、diff）中已有的内容，改为通过路径或 URL 引用它们。

删去所有敏感信息，比如 API 密钥、密码或个人身份信息，因为摘要会成为该 agent 的 prompt。

如果用户传入了参数，把它们视为对下一个会话重点的描述，并据此调整摘要。
