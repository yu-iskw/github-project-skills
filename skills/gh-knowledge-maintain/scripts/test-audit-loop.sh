#!/usr/bin/env bash
# Audit-mode knowledge loop against the current repository (no Wiki push).
set -euo pipefail

ROOT="$("$(dirname "$0")/../../../scripts/plugin-root.sh")"
cd "${ROOT}"

echo "== 1. identity (owner from repo view, not auth user) =="
gh auth status >/dev/null
identity="$(bash skills/gh-knowledge-maintain/scripts/repo-identity.sh)"
echo "${identity}" | jq -e '.owner != "" and .repo != ""' >/dev/null
if [[ -f .github/project-config.json ]]; then
	cfg_owner="$(jq -r .owner .github/project-config.json)"
	live_owner="$(echo "${identity}" | jq -r .owner)"
	test "${cfg_owner}" = "${live_owner}"
else
	echo "no project-config.json; knowledge audit continues"
fi

echo "== 2. collect evidence (first-run, no compare, no issue --search) =="
payload="$(bash skills/gh-knowledge-maintain/scripts/collect-delta.sh)"
echo "${payload}" | jq '{owner, repo, head_sha, has_wiki, wiki_remote, issue_count: (.issues|length), pr_count: (.merged_pull_requests|length), compare}'
echo "${payload}" | jq -e '.compare.skipped == "first-run-no-compare"' >/dev/null
echo "${payload}" | jq -e '[.issues[].number] | all(. > 0)' >/dev/null

echo "== 3. wiki preflight =="
preflight="$(bash skills/gh-wiki-management/scripts/preflight.sh)"
has_wiki="$(echo "${preflight}" | jq -r .has_wiki)"
wiki_remote="$(echo "${preflight}" | jq -r .wiki_remote)"
if [[ "${has_wiki}" == "true" && "${wiki_remote}" == "ready" ]]; then
	echo "Wiki remote ready (publish mode would clone)"
else
	echo "Wiki unavailable (has_wiki=${has_wiki} wiki_remote=${wiki_remote}); audit continues, publish would STOP"
fi

echo "== 4. validate Architecture candidate (includes Mermaid parse) =="
bash skills/gh-wiki-validate/scripts/validate-page.sh \
	skills/gh-knowledge-maintain/assets/Architecture-Overview.example.md

echo "== 5. local wiki git loop (no live Wiki required) =="
bash skills/gh-wiki-management/scripts/test-wiki-local.sh

echo "audit-loop-ok"
