#!/usr/bin/env bash
# Set up the workspace around this rules repo:
#   1. clone every service in repos.txt that is not present yet, next to this repo
#   2. install the workspace pointer files (AGENTS.md, CLAUDE.md) if missing
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
workspace="$(cd "${root}/.." && pwd)"

if [[ "$(basename "${root}")" != "sdd-standard" ]]; then
  echo "warn  rules repo directory is '$(basename "${root}")'; skills expect 'sdd-standard'"
fi

while read -r name url || [[ -n "${name:-}" ]]; do
  [[ -z "${name:-}" || "${name}" == \#* ]] && continue
  if [[ -d "${workspace}/${name}" ]]; then
    echo "skip  ${name} (already exists)"
  else
    echo "clone ${name}"
    # stdin redirected so git does not consume the rest of repos.txt
    git clone "${url}" "${workspace}/${name}" < /dev/null
  fi
done < "${root}/repos.txt"

for file in AGENTS.md CLAUDE.md; do
  target="${workspace}/${file}"
  if [[ ! -e "${target}" ]]; then
    cp "${root}/templates/workspace/${file}" "${target}"
    echo "add   ${target}"
  elif ! grep -q 'sdd-standard' "${target}"; then
    echo "note  ${target} already exists; add this pointer manually:"
    sed 's/^/        /' "${root}/templates/workspace/${file}"
  fi
done
