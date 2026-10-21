# 许可证合规

**适用条件：** 闭源商业项目，或 vendor 了第三方代码的项目

**先探查：** 依赖许可证扫描结果；仓库中的 vendor 目录

## 待定项

逐项拍板；本项目不需要的写「不适用」。每项都写成可检查的句子。

| 项 | 要定什么 | 例子 |
|---|---|---|
| 允许 | MIT、BSD、Apache-2.0 等 | 无 |
| 禁止 / 需审批 | GPL、AGPL、SSPL 等 | 无 |
| vendor 代码 | 拷贝进来的第三方代码保留原始 LICENSE 和来源 commit | 无 |

## 落点

- 第 2 层：许可证扫描放进 CI（license-checker、pip-licenses）
- 第 5 层：写进 CLAUDE.md；agent 规则写明「加依赖之前先检查许可证」
