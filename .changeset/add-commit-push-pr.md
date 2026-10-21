---
"mattpocock-skills": minor
---

新增 **`commit-push-pr`**（Engineering；模型自动调用，model-invoked）：按 Git 约定提交当前改动，然后推送并创建 PR。在主干（`main` 或 `master`）上它会停下来给出选项，而不是直接提交；commit message 遵循 `type(scope): short description`；改动超过 13 个文件或涉及 3 类问题时，会先建议拆分；推送前会先询问；PR 正文来自 `pr`，并附带一个验证小节，列出真正运行过的命令。改编自 zxsong111/claude-config 中的同名 skill，去掉了其中 main/develop/release 的企业分支模型。
