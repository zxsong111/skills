---
"mattpocock-skills": patch
---

`wizard` 模板修复：`ask` 使用 Readline，方向键可以移动光标（#741）；`write_env` 用单引号包裹值，使空格、`#`、`$` 和引号在 `source` 和 dotenv 中都能保留（#770）；当没有可用的浏览器打开程序时，`open_url` 会打印一条请自行打开的提示（#774）；`write_env` 会透过符号链接写入 `.env`，并保留已有文件的权限模式（#811）；`ask` 和 `ask_secret` 遇到 EOF 时会失败退出，而不是无限循环（#852）。
