# 测试

**适用条件：** 有测试或打算写测试的项目

**先探查：** 测试框架和配置、测试目录布局、CI 运行的测试命令、覆盖率配置

## 待定项

逐项拍板；本项目不需要的写「不适用」。每项都写成可检查的句子。

| 项 | 要定什么 | 例子 |
|---|---|---|
| 分层 | 单元 / 集成 / e2e 测试各覆盖什么，各放在哪 | `tests/unit/`、`tests/integration/` |
| 命名 | 测试文件和测试用例的命名；用例名描述行为 | `test_rejects_expired_coupon` |
| 覆盖率阈值 | 有的话写明数值并放进 CI；没有就不写 | `--cov-fail-under=80` |
| Mock | 真实实现 > fake > stub > mock；只在慢的 / 外部的边界上 mock | 无 |
| Bug 修复 | 必须附带一个先失败、后通过的复现测试 | 无 |
| 禁止 | 跳过 / 删除测试来让测试套件变绿；为了让测试通过去改断言 | 无 |

## 落点

- 第 2 层：覆盖率阈值和测试命令放进 CI，并写回 CLAUDE.md「质量门禁」表
- 第 3 层：`.claude/rules/testing.md`，`paths:` 限定在测试目录
- 相关：`test-driven-development` skill 及其 `writing-good-tests.md`
