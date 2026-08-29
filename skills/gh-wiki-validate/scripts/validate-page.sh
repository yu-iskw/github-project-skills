#!/usr/bin/env bash
# Fail-closed checks for one Wiki knowledge page.
# Usage: validate-page.sh PAGE.md [git-ref-for-file-evidence]
set -euo pipefail

PAGE="${1:?page markdown required}"
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
REF="${2:-${KNOWLEDGE_REF:-$(git -C "${ROOT}" rev-parse HEAD)}}"
PARSER="${ROOT}/skills/gh-wiki-diagrams/scripts/mermaid_parse.mjs"

errors=0
error() {
	echo "ERROR: $*" >&2
	errors=$((errors + 1))
}

if [[ ! -f "${PAGE}" ]]; then
	echo "ERROR: missing page ${PAGE}" >&2
	exit 1
fi

for key in knowledge_schema knowledge_id knowledge_class status confidence; do
	if ! grep -E -q "^${key}:" "${PAGE}"; then
		error "missing YAML key ${key}"
	fi
done

if grep -E -q 'AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_|-----BEGIN |xox[baprs]-' "${PAGE}"; then
	error "secret-like pattern in page"
fi

if ! node "${PARSER}" "${PAGE}" >/dev/null; then
	error "mermaid parse failed"
fi

if ! grep -q 'flowchart' "${PAGE}" || ! grep -q 'sequenceDiagram' "${PAGE}"; then
	error "Architecture page must include flowchart and sequenceDiagram"
fi

owner="$(gh repo view --json owner --jq .owner.login)"
repo="$(gh repo view --json name --jq .name)"

while IFS= read -r line; do
	kind="$(printf '%s' "${line}" | awk '{print $1}')"
	value="$(printf '%s' "${line}" | awk '{print $2}')"
	case "${kind}" in
	issue)
		if ! gh issue view "${value}" --repo "${owner}/${repo}" --json number >/dev/null 2>&1; then
			error "issue ${value} does not resolve"
		fi
		;;
	pull_request | pr)
		if ! gh pr view "${value}" --repo "${owner}/${repo}" --json number >/dev/null 2>&1; then
			error "pull_request ${value} does not resolve via gh pr view"
		fi
		;;
	file)
		if gh api "repos/${owner}/${repo}/commits/${REF}" --jq .sha >/dev/null 2>&1; then
			if ! gh api "repos/${owner}/${repo}/contents/${value}?ref=${REF}" --jq .path >/dev/null 2>&1; then
				error "file ${value} missing at ref ${REF}"
			fi
		elif [[ ! -f "${ROOT}/${value}" ]]; then
			error "file ${value} missing locally and commit ${REF} is not on GitHub"
		fi
		;;
	esac
done < <(
	awk '
    $1 == "-" && $2 == "kind:" { kind=$3; next }
    $1 == "kind:" { kind=$2; next }
    $1 == "ref:" {
      gsub(/"/, "", $2)
      print kind, $2
      next
    }
    $1 == "path:" { print "file", $2 }
  ' "${PAGE}"
)

if [[ "${errors}" -ne 0 ]]; then
	echo "Wiki validation: FAIL"
	exit 1
fi
echo "Wiki validation: PASS"
exit 0
