#!/usr/bin/env bash
# Clone every service listed in repos.txt that is not present yet.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

while read -r name url || [[ -n "${name:-}" ]]; do
  [[ -z "${name:-}" || "${name}" == \#* ]] && continue
  if [[ -d "${root}/${name}" ]]; then
    echo "skip  ${name} (already exists)"
  else
    echo "clone ${name}"
    # stdin redirected so git does not consume the rest of repos.txt
    git clone "${url}" "${root}/${name}" < /dev/null
  fi
done < "${root}/repos.txt"
