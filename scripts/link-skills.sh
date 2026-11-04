#!/usr/bin/env bash
# Symlink every skills/sdd-* skill into the personal skill directories, so a
# `git pull` in this repo keeps everyone's installed skills up to date.
#   ~/.claude/skills  Claude Code
#   ~/.agents/skills  Codex and other Agent Skills-compatible tools
# An existing non-symlink entry with the same name is left untouched.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
dests=("${HOME}/.claude/skills" "${HOME}/.agents/skills")

for dest in "${dests[@]}"; do
  mkdir -p "${dest}"
  for src in "${root}"/skills/sdd-*/; do
    src="${src%/}"
    name="$(basename "${src}")"
    target="${dest}/${name}"
    if [[ -e "${target}" && ! -L "${target}" ]]; then
      echo "skip  ${target} (exists and is not a symlink; remove it manually to link)"
      continue
    fi
    ln -sfn "${src}" "${target}"
    echo "link  ${target} -> ${src}"
  done
done
