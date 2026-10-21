# 分诊标签

各个 skill 用五个规范的分诊角色(triage role)来表述状态。本文件把这些角色映射到本仓库 issue tracker 中实际使用的标签字符串。

| Label in mattpocock/skills | Label in our tracker | Meaning                                  |
| -------------------------- | -------------------- | ---------------------------------------- |
| `needs-triage`             | `needs-triage`       | 需要维护者评估这个 issue                 |
| `needs-info`               | `needs-info`         | 等待报告者补充更多信息                   |
| `ready-for-agent`          | `ready-for-agent`    | 已完整说明，可以交给 AFK agent           |
| `ready-for-human`          | `ready-for-human`    | 需要人来实现                             |
| `wontfix`                  | `wontfix`            | 不会处理                                 |

当某个 skill 提到一个角色（例如「打上 AFK-ready 的分诊标签」）时，使用本表中对应的标签字符串。

选定状态之前，先对照 [`SCOPE.md`](../../SCOPE.md) 评判每个 issue。被拒绝的 issue 以「not planned」关闭。
