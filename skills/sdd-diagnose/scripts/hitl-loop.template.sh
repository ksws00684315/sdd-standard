#!/usr/bin/env bash
# Human-in-the-loop reproduction loop.
# Copy this file, edit the steps below, and run it.
# The agent runs the script; the user follows the prompts in the terminal.
#
# Two helpers:
#   step "<instruction>"          show an instruction, wait for Enter
#   capture VAR "<question>"      show a question, read the answer into VAR
#
# Captured values are printed as KEY=VALUE at the end for the agent to parse.
# Capture observations only; leave signing in to the user as a `step`.

set -euo pipefail

step() {
  printf '\n>>> %s\n' "$1"
  read -r -p "    [完成后按回车] " _
}

capture() {
  local var="$1" question="$2" answer
  printf '\n>>> %s\n' "$question"
  read -r -p "    > " answer
  printf -v "$var" '%s' "$answer"
}

# --- edit below ---------------------------------------------------------

step "在浏览器打开 http://localhost:8080 并登录测试账号。"

capture ERRORED "点击'导出'按钮。是否报错？(y/n)"

capture ERROR_MSG "粘贴报错信息（没有就填 none）："

# --- edit above ---------------------------------------------------------

printf '\n--- Captured ---\n'
printf 'ERRORED=%s\n' "$ERRORED"
printf 'ERROR_MSG=%s\n' "$ERROR_MSG"
