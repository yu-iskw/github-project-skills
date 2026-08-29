#!/usr/bin/env bash
# Live gh evidence recipes against the current repository.
set -euo pipefail

ROOT="$("$(dirname "$0")/../../../scripts/plugin-root.sh")"
COLLECT="${ROOT}/skills/gh-knowledge-maintain/scripts/collect-delta.sh"
IDENTITY="${ROOT}/skills/gh-knowledge-maintain/scripts/repo-identity.sh"

command -v gh >/dev/null
command -v jq >/dev/null
gh auth status >/dev/null

identity="$(bash "${IDENTITY}")"
owner="$(printf '%s' "${identity}" | jq -r .owner)"
repo="$(printf '%s' "${identity}" | jq -r .repo)"
auth_user="$(gh auth status 2>&1 | sed -n 's/.*Logged in to github.com account \([^ ]*\).*/\1/p' | head -n1)"
if [[ -z "${owner}" ]]; then
	echo "FAIL: owner.login empty" >&2
	exit 1
fi
if [[ -n "${auth_user}" && "${auth_user}" == "${owner}" ]]; then
	echo "note: auth user equals repo owner (${owner})"
fi

payload="$(bash "${COLLECT}")"
echo "${payload}" | jq -e '.owner != "" and .repo != "" and .head_sha != ""' >/dev/null
echo "${payload}" | jq -e '[.issues[].number] | all(. > 0)' >/dev/null
echo "${payload}" | jq -e '.compare.skipped == "first-run-no-compare"' >/dev/null

# Kind-specific view: an issue-only number must not resolve with gh pr view.
issue_num=""
while IFS= read -r n; do
	[[ -z "${n}" ]] && continue
	if ! gh pr view "${n}" --repo "${owner}/${repo}" >/dev/null 2>&1; then
		issue_num="${n}"
		break
	fi
done < <(gh issue list --repo "${owner}/${repo}" --state all --limit 30 --json number --jq '.[].number')
if [[ -z "${issue_num}" ]]; then
	echo "FAIL: need at least one issue that is not a pull request" >&2
	exit 1
fi
gh issue view "${issue_num}" --repo "${owner}/${repo}" --json number,title,state >/dev/null

# Contents must use ?ref= for files that exist only on this commit.
ref="$(git -C "${ROOT}" rev-parse HEAD)"
if gh api "repos/${owner}/${repo}/commits/${ref}" --jq .sha >/dev/null 2>&1; then
	gh api "repos/${owner}/${repo}/contents/skills/gh-knowledge-maintain/SKILL.md?ref=${ref}" \
		--jq .path >/dev/null
else
	test -f "${ROOT}/skills/gh-knowledge-maintain/SKILL.md"
	echo "note: commit ${ref} not on GitHub yet; asserted local path"
fi

echo "${payload}" | jq -e '.wiki_remote | IN("ready", "uninitialized", "unavailable")' >/dev/null

echo "evidence-ok owner=${owner} auth=${auth_user:-unknown} issue=${issue_num}"
