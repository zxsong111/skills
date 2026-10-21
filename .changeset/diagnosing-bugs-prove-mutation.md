---
"mattpocock-skills": patch
---

`diagnosing-bugs` 的第 5 阶段现在要求 agent 在相信「红」之前，先把强制引入的变异与一份原始副本做 `diff`，这样一处悄悄什么都没改的编辑就无法冒充失败的测试（#955）。
