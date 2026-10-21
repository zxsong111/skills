---
"mattpocock-skills": patch
---

`wizard` 模板修复：`_existing` 会解码带双引号的 `.env` 值，所以按回车保留当前值时不再把引号也存进去（#1220）；各阶段在 `run_wizard` 内部运行，所以运行中途编辑脚本不会让它崩掉（#1142）；`tput clear` 失败时 `_clear` 会回退到 ANSI（#1081）；`write_env` 也会设置 shell 变量（#1041）；删掉了未使用的 `RED`（#1003）。
