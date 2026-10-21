---
"mattpocock-skills": patch
---

`handoff` 现在会写明操作系统临时目录在哪里（`$TMPDIR`，否则 `/tmp`；Windows 上为 `%TEMP%`），agent 不用再去猜（#272）。
