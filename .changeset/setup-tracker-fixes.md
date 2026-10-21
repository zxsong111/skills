---
"mattpocock-skills": patch
---

`setup-matt-pocock-skills` 现在会在 GitHub/GitLab 上创建缺失的分诊（triage）标签（#616），修复了 GitLab 模板中的 `glab` 命令（#635），用 `--json` 读取 GitHub issue，以便拿到标签和正文（#733），并在 `triage-labels.md` 中为「Label in our tracker」这一列命名（#801）。重新运行 `/setup-matt-pocock-skills` 以刷新 `docs/agents/`。
