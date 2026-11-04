#!/usr/bin/env bash
# Pre-MR check for SDD specs. Run from inside a service repository:
#   ../sdd-standard/scripts/check-spec.sh [--base <ref>]
# Exit code 1 when any ERROR is reported; WARN lines need a human decision.
set -uo pipefail

# 需求单号：需求系统里的纯数字（commit 里写作 %<单号>，% 和项目前缀如 %CloudCamera-18544
# 都不属于单号本身），因此需求目录名形如 18544-add-icon。规则仓库的示例沿用 REQ-0000 这种
# 带前缀的写法，两种都接受。
REQ_ID_PATTERN='([0-9]+|REQ-[0-9]+)'
VALID_STATUSES='草稿 评审中 已确认 已上线 已中止'

errors=0
warns=0
err()  { echo "ERROR $*"; errors=$((errors + 1)); }
warn() { echo "WARN  $*"; warns=$((warns + 1)); }
ok()   { echo "OK    $*"; }

base_override=""
if [[ "${1:-}" == "--base" ]]; then
  base_override="${2:-}"
fi

repo="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "ERROR not inside a git repository"; exit 1; }
cd "${repo}"
service="$(basename "${repo}")"
branch="$(git rev-parse --abbrev-ref HEAD)"

if [[ -d openspec ]]; then
  layout="openspec"; changes_dir="openspec/changes"; specs_dir="openspec/specs"; spec_file="proposal.md"
else
  layout="docs"; changes_dir="docs/changes"; specs_dir="docs/specs"; spec_file="spec.md"
fi
echo "      service=${service} branch=${branch} layout=${layout}"

# Read "- <field>：<value>" from a spec header, given the file content on stdin.
field() { sed -n "s/^- $1：[[:space:]]*//p" | head -1 | sed 's/[[:space:]]*$//'; }

# ---- 1. change spec of the current requirement --------------------------------
req_dir=""; status=""; version=""
case "${branch}" in
  feature/*) req_dir="${branch#feature/}" ;;
esac

if [[ -z "${req_dir}" ]]; then
  case "${branch}" in
    fix/*|develop*|dev*|release*|master|main)
      ok "${branch} is not a feature branch; change-spec checks skipped" ;;
    *)
      # 分支名不符合任何约定时不能当作 L0 放过，否则改代码前写 spec 这条门禁会被静默跳过
      warn "branch '${branch}' matches no convention; expected feature/<需求单号>-<描述>" ;;
  esac
else
  dir="${changes_dir}/${req_dir}"
  if [[ ! -d "${dir}" ]]; then
    err "${dir}/ not found for branch ${branch}"
  else
    ok "${dir}/ exists"
    main_ref=""; have_status=0
    if [[ -f "${dir}/tasks.md" ]]; then
      main_ref="$(sed -n 's/^- 主 spec：[[:space:]]*`\{0,1\}\([A-Za-z0-9._-]*:[A-Za-z0-9._-]*\).*/\1/p' "${dir}/tasks.md" | head -1)"
    fi
    if [[ -z "${main_ref}" && -f "${dir}/${spec_file}" ]]; then
      main_ref="$(sed -n 's/^主 spec：[[:space:]]*`\{0,1\}\([A-Za-z0-9._-]*:[A-Za-z0-9._-]*\).*/\1/p' "${dir}/${spec_file}" | head -1)"
    fi

    if [[ -n "${main_ref}" ]]; then
      # participant service: status and version live in the main service's spec
      main_svc="${main_ref%%:*}"; main_dir="${main_ref#*:}"
      main_repo="${repo}/../${main_svc}"
      if [[ -d "${main_repo}/openspec" ]]; then
        main_path="openspec/changes/${main_dir}/proposal.md"
      else
        main_path="docs/changes/${main_dir}/spec.md"
      fi
      main_content="$(git -C "${main_repo}" show "feature/${main_dir}:${main_path}" 2>/dev/null || cat "${main_repo}/${main_path}" 2>/dev/null || true)"
      if [[ -z "${main_content}" ]]; then
        warn "participant of ${main_ref}, but its spec could not be read from ${main_repo}; status check skipped"
      else
        status="$(printf '%s\n' "${main_content}" | field '状态')"
        version="$(printf '%s\n' "${main_content}" | field '目标版本')"
        have_status=1
        ok "participant of ${main_ref}"
      fi
    elif [[ -f "${dir}/${spec_file}" ]]; then
      status="$(field '状态' < "${dir}/${spec_file}")"
      version="$(field '目标版本' < "${dir}/${spec_file}")"
      have_status=1
    else
      err "${dir}/ has neither ${spec_file} nor a 主 spec reference in tasks.md"
    fi

    if [[ "${have_status}" -eq 1 ]]; then
      if [[ -n "${status}" && " ${VALID_STATUSES} " == *" ${status} "* ]]; then
        ok "status=${status}"
      else
        err "status '${status}' is not one of: ${VALID_STATUSES}"
      fi
    fi
  fi
fi

# ---- 2. diff against the target branch ----------------------------------------
version="$(printf '%s' "${version}" | grep -oE '[0-9]+(\.[0-9]+)+' | head -1 || true)"
base_ref=""
if [[ -n "${base_override}" ]]; then
  base_ref="${base_override}"
elif [[ -n "${version}" ]]; then
  for candidate in "origin/develop-v${version}" "develop-v${version}"; do
    if git rev-parse --verify -q "${candidate}" >/dev/null; then base_ref="${candidate}"; break; fi
  done
fi

if [[ -z "${base_ref}" ]]; then
  warn "base branch unknown (target version '${version:-none}'); pass --base <ref> to enable diff checks"
else
  merge_base="$(git merge-base "${base_ref}" HEAD 2>/dev/null || true)"
  if [[ -z "${merge_base}" ]]; then
    warn "no merge-base with ${base_ref}; diff checks skipped"
  else
    changed="$( { git diff --name-only "${merge_base}" HEAD; git diff --name-only HEAD; git ls-files --others --exclude-standard; } | sort -u )"
    code_changed="$(printf '%s\n' "${changed}" | grep -E '(^|/)src/main/' || true)"
    specs_changed="$(printf '%s\n' "${changed}" | grep -E "^${specs_dir}/" || true)"
    ok "base=${base_ref}"

    if [[ -n "${code_changed}" && ( "${status}" == "草稿" || "${status}" == "评审中" ) ]]; then
      err "code under src/main changed while spec status is '${status}'; spec must be 已确认 first"
    fi
    if [[ -n "${code_changed}" && -z "${specs_changed}" ]]; then
      warn "src/main changed but ${specs_dir}/ did not; confirm whether business behaviour changed"
    fi
  fi
fi

# ---- 3. current-state spec index and naming -----------------------------------
if [[ "${layout}" == "docs" && -d "${specs_dir}" ]]; then
  if [[ ! -f "${specs_dir}/README.md" ]]; then
    err "${specs_dir}/README.md (index) is missing"
  else
    for f in "${specs_dir}"/*.md; do
      [[ -e "${f}" ]] || continue
      name="$(basename "${f}")"
      [[ "${name}" == "README.md" ]] && continue
      if ! grep -qF "${name}" "${specs_dir}/README.md"; then
        err "${f} is not listed in ${specs_dir}/README.md"
      fi
      if ! [[ "${name}" =~ ^[a-z0-9]+(-[a-z0-9]+)*\.md$ ]]; then
        err "${f}: file name must be lowercase-hyphenated English"
      fi
    done
  fi
fi

# 命名规则只约束本次新增的需求目录。存量目录按"不迁移"原则跳过：已经使用 OpenSpec 的服务
# 里有归档前没有需求单号的目录，接入时不应被判为 ERROR。
added_dirs="$(
  {
    [[ -n "${merge_base:-}" ]] && git diff --diff-filter=AR --name-only "${merge_base}" HEAD -- "${changes_dir}" 2>/dev/null
    git diff --diff-filter=AR --name-only -- "${changes_dir}" 2>/dev/null
    git ls-files --others --exclude-standard -- "${changes_dir}" 2>/dev/null
  } | sed -n "s|^${changes_dir}/\([^/]*\)/.*|\1|p" | sort -u
)"

if [[ -n "${added_dirs}" ]]; then
  while read -r name; do
    [[ -z "${name}" || "${name}" == "archive" ]] && continue
    if ! [[ "${name}" =~ ^${REQ_ID_PATTERN}-[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
      err "${changes_dir}/${name}/: directory name must be <需求单号>-<lowercase-hyphenated-description>"
    fi
  done <<< "${added_dirs}"
fi

echo "      ${errors} error(s), ${warns} warning(s)"
[[ "${errors}" -eq 0 ]]
