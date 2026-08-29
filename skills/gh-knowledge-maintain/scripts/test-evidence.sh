#!/usr/bin/env bash
# Live gh evidence recipes against the current repository.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
COLLECT="${ROOT}/skills/gh-knowledge-maintain/scripts/collect-delta.sh"
PARSER="${ROOT}/skills/gh-wiki-diagrams/scripts/mermaid_parse.mjs"
EXAMPLE="${ROOT}/skills/gh-knowledge-maintain/assets/Architecture-Overview.example.md"

command -v gh >/dev/null
command -v jq >/dev/null
gh auth status >/dev/null

owner="$(gh repo view --json owner --jq .owner.login)"
auth_user="$(gh auth status 2>&1 | sed -n 's/.*Logged in to github.com account \([^ ]*\).*/\1/p' | head -n1)"
if [[ -z "${owner}" ]]; then
	echo "FAIL: owner.login empty" >&2
	exit 1
fi
# Authenticated user is not a substitute for repo owner (cursor vs yu-iskw).
if [[ -n "${auth_user}" && "${auth_user}" == "${owner}" ]]; then
	echo "note: auth user equals repo owner (${owner})"
fi

payload="$(bash "${COLLECT}")"
echo "${payload}" | jq -e '.owner != "" and .repo != "" and .head_sha != ""' >/dev/null
echo "${payload}" | jq -e '[.issues[].number] | all(. > 0)' >/dev/null
echo "${payload}" | jq -e '.compare.skipped == "first-run-no-compare"' >/dev/null

# Kind-specific view: RFC #27 is an issue, not a PR.
if gh pr view 27 --repo "${owner}/$(gh repo view --json name --jq .name)" >/dev/null 2>&1; then
	echo "FAIL: gh pr view 27 should not resolve an issue" >&2
	exit 1
fi
gh issue view 27 --json number,title,state >/dev/null

# Contents must use ?ref= for files that exist only on this commit.
ref="$(git -C "${ROOT}" rev-parse HEAD)"
if gh api "repos/${owner}/$(gh repo view --json name --jq .name)/commits/${ref}" --jq .sha >/dev/null 2>&1; then
	gh api "repos/${owner}/$(gh repo view --json name --jq .name)/contents/skills/gh-knowledge-maintain/SKILL.md?ref=${ref}" \
		--jq .path >/dev/null
else
	test -f "${ROOT}/skills/gh-knowledge-maintain/SKILL.md"
	echo "note: commit ${ref} not on GitHub yet; asserted local path"
fi

echo "${payload}" | jq -e '.wiki_remote | IN("ready", "uninitialized", "unavailable")' >/dev/null

node "${PARSER}" "${EXAMPLE}" >/dev/null

echo "evidence-ok owner=${owner} auth=${auth_user:-unknown}"
