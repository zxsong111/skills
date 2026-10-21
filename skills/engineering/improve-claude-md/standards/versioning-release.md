# 版本与发布

**适用条件：** 对外发布的库或应用，或有正式发布流程的服务

**先探查：** tag 历史、CHANGELOG、发布脚本 / workflow

## 待定项

逐项拍板；本项目不需要的写「不适用」。每项都写成可检查的句子。

| 项 | 要定什么 | 例子 |
|---|---|---|
| 版本号 | SemVer；什么时候升 major / minor / patch | 无 |
| CHANGELOG | 每个用户可见的变更一条，按版本分组 | Keep a Changelog 格式 |
| 发布流程 | 从哪个分支发、谁来触发、发布前检查 | 无 |
| Hotfix | 从 `main` 拉分支，修好后同时合回 `main` 和 `develop` | 无 |
| 废弃 | 废弃的接口至少保留一个 minor 版本，并提供迁移说明 | 无 |

## 落点

- 第 2 层：发布 workflow 自动校验版本号和 CHANGELOG
- 第 5 层：写进 CLAUDE.md；配套：没有 `CHANGELOG.md` 时生成一份骨架

## 配套文件骨架

目标文件已存在时跳过，并在报告中说明。不要覆盖。

```markdown
# Changelog

## [Unreleased]

### Added
### Changed
### Fixed
### Removed
```
