#!/usr/bin/env bash
# Wiki publish preflight. Prints JSON with has_wiki, wiki_remote, clone_url.
# Exit 0 when gh succeeds (audit may continue even if wiki_remote is not ready).
# --require-ready: exit 2 when publish must STOP (disabled or uninitialized).
set -euo pipefail

ROOT="$("$(dirname "$0")/../../../scripts/plugin-root.sh")"
IDENTITY="${ROOT}/skills/gh-knowledge-maintain/scripts/repo-identity.sh"

require_ready=0
if [[ "${1:-}" == "--require-ready" ]]; then
	require_ready=1
fi

identity="$(bash "${IDENTITY}")"
owner="$(printf '%s' "${identity}" | jq -r .owner)"
repo="$(printf '%s' "${identity}" | jq -r .repo)"
clone_url="https://github.com/${owner}/${repo}.wiki.git"

has_wiki="$(gh api "repos/${owner}/${repo}" --jq .has_wiki)"
wiki_remote="unavailable"
if [[ "${has_wiki}" == "true" ]] && git ls-remote "${clone_url}" HEAD >/dev/null 2>&1; then
	wiki_remote="ready"
elif [[ "${has_wiki}" == "true" ]]; then
	wiki_remote="uninitialized"
fi

jq -n \
	--arg owner "${owner}" \
	--arg repo "${repo}" \
	--argjson has_wiki "${has_wiki}" \
	--arg wiki_remote "${wiki_remote}" \
	--arg clone_url "${clone_url}" \
	'{
    owner: $owner,
    repo: $repo,
    has_wiki: $has_wiki,
    wiki_remote: $wiki_remote,
    clone_url: $clone_url
  }'

if [[ "${require_ready}" -eq 1 && "${wiki_remote}" != "ready" ]]; then
	exit 2
fi
exit 0
