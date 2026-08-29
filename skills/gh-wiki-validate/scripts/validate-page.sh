#!/usr/bin/env bash
# Fail-closed checks for one Wiki knowledge page.
# Usage: validate-page.sh PAGE.md [git-ref-for-file-evidence]
set -euo pipefail

PAGE="${1:?page markdown required}"
ROOT="$("$(dirname "$0")/../../../scripts/plugin-root.sh")"
PARSER="${ROOT}/skills/gh-wiki-diagrams/scripts/mermaid_parse.mjs"
FRONTMATTER="${ROOT}/skills/gh-wiki-validate/scripts/frontmatter.mjs"
IDENTITY="${ROOT}/skills/gh-knowledge-maintain/scripts/repo-identity.sh"

if [[ -n "${2:-}" ]]; then
	REF="${2}"
elif [[ -n "${KNOWLEDGE_REF:-}" ]]; then
	REF="${KNOWLEDGE_REF}"
elif git -C "${PWD}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	REF="$(git -C "${PWD}" rev-parse HEAD)"
else
	REF="$(git -C "${ROOT}" rev-parse HEAD)"
fi

errors=0
error() {
	echo "ERROR: $*" >&2
	errors=$((errors + 1))
}

if [[ ! -f "${PAGE}" ]]; then
	echo "ERROR: missing page ${PAGE}" >&2
	exit 1
fi

if ! parsed="$(node "${FRONTMATTER}" "${PAGE}")"; then
	echo "ERROR: YAML frontmatter parse failed" >&2
	exit 1
fi

for key in knowledge_schema knowledge_id knowledge_class status confidence evidence; do
	if ! printf '%s' "${parsed}" | jq -e --arg k "${key}" '.frontmatter | has($k)' >/dev/null; then
		error "missing YAML key ${key}"
	fi
done

page_id="$(printf '%s' "${parsed}" | jq -r '.frontmatter.knowledge_id // empty')"
page_class="$(printf '%s' "${parsed}" | jq -r '.frontmatter.knowledge_class // empty')"

if grep -E -q 'AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|gho_[A-Za-z0-9]{36}|ghu_[A-Za-z0-9]{36}|ghs_[A-Za-z0-9]{36}|ghr_[A-Za-z0-9]{36}|github_pat_|-----BEGIN |xox[baprs]-|xoxe-' "${PAGE}"; then
	error "secret-like pattern in page"
fi

families="$(printf '%s' "${parsed}" | jq -r '.mermaid_families[]?')"
if [[ -n "${families}" ]]; then
	if ! node "${PARSER}" "${PAGE}" >/dev/null; then
		error "mermaid parse failed"
	fi
fi

if [[ "${page_class}" == "architecture" ]]; then
	has_flow=0
	has_seq=0
	while IFS= read -r family; do
		[[ -z "${family}" ]] && continue
		case "${family}" in
		flowchart | graph)
			has_flow=1
			;;
		sequenceDiagram)
			has_seq=1
			;;
		esac
	done <<<"${families}"
	if [[ "${has_flow}" -ne 1 || "${has_seq}" -ne 1 ]]; then
		error "Architecture page must include flowchart and sequenceDiagram"
	fi
	evidence_len="$(printf '%s' "${parsed}" | jq '.frontmatter.evidence | length')"
	if [[ "${evidence_len}" -lt 1 ]]; then
		error "Architecture page must include at least one evidence locator"
	fi
fi

page_dir="$(cd "$(dirname "${PAGE}")" && pwd)"
page_abs="$(cd "$(dirname "${PAGE}")" && pwd)/$(basename "${PAGE}")"
if [[ -n "${page_id}" ]]; then
	shopt -s nullglob
	for sibling in "${page_dir}"/*.md; do
		sibling_abs="$(cd "$(dirname "${sibling}")" && pwd)/$(basename "${sibling}")"
		[[ "${sibling_abs}" == "${page_abs}" ]] && continue
		sib_json="$(node "${FRONTMATTER}" "${sibling}" 2>/dev/null || true)"
		[[ -z "${sib_json}" ]] && continue
		sib_id="$(printf '%s' "${sib_json}" | jq -r '.frontmatter.knowledge_id // empty')"
		if [[ -n "${sib_id}" && "${sib_id}" == "${page_id}" ]]; then
			error "duplicate knowledge_id ${page_id} also on $(basename "${sibling}")"
		fi
	done
	shopt -u nullglob
fi

while IFS= read -r target; do
	[[ -z "${target}" ]] && continue
	if [[ ! -f "${page_dir}/${target}.md" ]]; then
		error "Wiki link [[${target}]] does not resolve to ${target}.md"
	fi
done < <(printf '%s' "${parsed}" | jq -r '.wiki_links[]?')

identity="$(bash "${IDENTITY}")"
owner="$(printf '%s' "${identity}" | jq -r .owner)"
repo="$(printf '%s' "${identity}" | jq -r .repo)"

while IFS= read -r item; do
	[[ -z "${item}" ]] && continue
	kind="$(printf '%s' "${item}" | jq -r '.kind // empty')"
	case "${kind}" in
	issue)
		value="$(printf '%s' "${item}" | jq -r '.ref // empty')"
		if [[ -z "${value}" ]] || ! gh issue view "${value}" --repo "${owner}/${repo}" --json number >/dev/null 2>&1; then
			error "issue ${value} does not resolve"
		fi
		;;
	pull_request | pr)
		value="$(printf '%s' "${item}" | jq -r '.ref // empty')"
		if [[ -z "${value}" ]] || ! gh pr view "${value}" --repo "${owner}/${repo}" --json number >/dev/null 2>&1; then
			error "pull_request ${value} does not resolve via gh pr view"
		fi
		;;
	file)
		value="$(printf '%s' "${item}" | jq -r '.path // empty')"
		if [[ -z "${value}" ]]; then
			error "file evidence missing path"
			continue
		fi
		if gh api "repos/${owner}/${repo}/commits/${REF}" --jq .sha >/dev/null 2>&1; then
			if ! gh api "repos/${owner}/${repo}/contents/${value}?ref=${REF}" --jq .path >/dev/null 2>&1; then
				error "file ${value} missing at ref ${REF}"
			fi
		elif [[ -f "${PWD}/${value}" || -f "${ROOT}/${value}" ]]; then
			:
		else
			error "file ${value} missing locally and commit ${REF} is not on GitHub"
		fi
		;;
	esac
done < <(printf '%s' "${parsed}" | jq -c '.frontmatter.evidence[]? // empty')

if [[ "${errors}" -ne 0 ]]; then
	echo "Wiki validation: FAIL"
	exit 1
fi
echo "Wiki validation: PASS"
exit 0
