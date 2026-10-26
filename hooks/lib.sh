#!/bin/bash
# Shared helpers for the guard hooks. Sourced, not executed.
#
# Every guard reads the PreToolUse payload on stdin, decides only on `git commit`,
# and stays silent (exit 0, no output) unless the repo opted in with `.claude/guards`.

GUARD_MARKER=".claude/guards"

read_payload() {
  HOOK_INPUT=$(cat)
  if command -v jq >/dev/null 2>&1; then
    HOOK_COMMAND=$(printf '%s' "$HOOK_INPUT" | jq -r '.tool_input.command // empty')
    HOOK_CWD=$(printf '%s' "$HOOK_INPUT" | jq -r '.cwd // empty')
  elif command -v python3 >/dev/null 2>&1; then
    HOOK_COMMAND=$(printf '%s' "$HOOK_INPUT" | python3 -Ic 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("command",""))')
    HOOK_CWD=$(printf '%s' "$HOOK_INPUT" | python3 -Ic 'import json,sys; print(json.load(sys.stdin).get("cwd",""))')
  else
    HOOK_COMMAND=""
    HOOK_CWD=""
  fi
  [ -n "$HOOK_CWD" ] || HOOK_CWD="${CLAUDE_PROJECT_DIR:-$PWD}"
}

# True when the command would create a commit. Chained commands (`a && git commit`) count.
is_git_commit() {
  printf '%s' "$HOOK_COMMAND" | grep -Eq '(^|[;&|[:space:]])git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?commit([[:space:]]|$)'
}

# Enter the repo and check for the marker. Returns 1 when the guard should stay out of the way.
guard_enabled() {
  cd "$HOOK_CWD" 2>/dev/null || return 1
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  cd "$root" || return 1
  [ -e "$GUARD_MARKER" ]
}

# Emit a deny decision with a reason the model can relay, then exit 0.
deny() {
  local reason=$1
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg reason "$reason" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
  else
    local escaped
    escaped=$(printf '%s' "$reason" | python3 -Ic 'import json,sys; print(json.dumps(sys.stdin.read()))')
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s}}\n' "$escaped"
  fi
  exit 0
}
