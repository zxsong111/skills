---
name: handoff
description: >
  把当前对话压缩成一份交接文档，供另一个 agent 接手。
argument-hint: "下一个会话要用来做什么？"
disable-model-invocation: true
---

写一份交接文档(handoff document)总结当前对话，让一个全新的 agent 能接着干。保存到用户操作系统的临时目录（`$TMPDIR`，没有则用 `/tmp`；Windows 上用 `%TEMP%`），不要放在当前工作区。

在文档里加一个「建议调用的 skill」小节，写明下一个 agent 应该用 Skill 工具调用哪些 skill。

不要重复其他产物（spec、计划、ADR、issue、commit、diff）里已经记录的内容，改为用路径或 URL 引用它们。

抹掉所有敏感信息，比如 API key、密码或个人身份信息。

如果用户传了参数，就把它当作下一个会话关注点的说明，据此调整文档内容。
