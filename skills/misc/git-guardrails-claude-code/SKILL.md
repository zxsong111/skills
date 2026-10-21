---
name: git-guardrails-claude-code
description: >
  设置 Claude Code hook，在危险的 git 命令（push、reset --hard、clean、branch -D 等）执行前将其拦截。当用户想防止破坏性的 git 操作、添加 git 安全 hook，或在 Claude Code 中拦截 git push/reset 时使用。触发短语：「拦截 git push」「git 安全防护」「防止误删」，以及 "git guardrails"、"block git push"。
---

# 设置 Git 防护栏（guardrail）

设置一个 PreToolUse hook，在 Claude 执行危险的 git 命令之前将其拦截并阻止。

## 会被拦截的命令

- `git push`（所有变体，包括 `--force`）
- `git reset --hard`
- `git clean -f` / `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .`

被拦截时，Claude 会看到一条消息，告诉它无权使用这些命令。

## 步骤

### 1. 询问范围

询问用户：是**仅为当前项目**安装（`.claude/settings.json`），还是为**所有项目**安装（`~/.claude/settings.json`）？

### 2. 复制 hook 脚本

随附的脚本位于：[scripts/block-dangerous-git.sh](scripts/block-dangerous-git.sh)

根据范围把它复制到目标位置：

- **项目**：`.claude/hooks/block-dangerous-git.sh`
- **全局**：`~/.claude/hooks/block-dangerous-git.sh`

用 `chmod +x` 给它加上可执行权限。

### 3. 把 hook 加入设置

添加到对应的设置文件中：

**项目**（`.claude/settings.json`）：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

**全局**（`~/.claude/settings.json`）：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

如果设置文件已经存在，把这个 hook 合并到已有的 `hooks.PreToolUse` 数组中。不要覆盖其他设置。

### 4. 询问是否需要自定义

询问用户是否要在拦截列表中添加或删除某些模式。据此编辑复制过去的脚本。

### 5. 验证

跑一个快速测试：

```bash
echo '{"tool_input":{"command":"git push origin main"}}' | <path-to-script>
```

应当以退出码 2 退出，并向 stderr 打印一条 BLOCKED 消息。
