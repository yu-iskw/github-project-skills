#!/usr/bin/env bash
# Collect incremental knowledge evidence with gh.
# Usage: collect-delta.sh [checkpoint_sha] [issue_updated_since] [pr_merged_since]
# First run: omit checkpoint_sha (do not call compare). Never use gh issue list --search.
set -euo pipefail

CHECKPOINT_SHA="${1:-}"
ISSUE_SINCE="${2:-}"
PR_SINCE="${3:-}"

owner="$(gh repo view --json owner --jq .owner.login)"
repo="$(gh repo view --json name --jq .name)"
branch="$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)"
head="$(gh api "repos/${owner}/${repo}/commits/${branch}" --jq .sha)"
has_wiki="$(gh api "repos/${owner}/${repo}" --jq .has_wiki)"

wiki_remote="unavailable"
if [[ "${has_wiki}" == "true" ]] && git ls-remote "https://github.com/${owner}/${repo}.wiki.git" HEAD >/dev/null 2>&1; then
	wiki_remote="ready"
elif [[ "${has_wiki}" == "true" ]]; then
	wiki_remote="uninitialized"
fi

issues_json="$(
	gh issue list --repo "${owner}/${repo}" --state all --limit 100 \
		--json number,title,body,updatedAt,url
)"
if [[ -n "${ISSUE_SINCE}" ]]; then
	issues_json="$(
		printf '%s' "${issues_json}" | jq --arg since "${ISSUE_SINCE}" \
			'[.[] | select(.number > 0 and .updatedAt >= $since)]'
	)"
else
	issues_json="$(printf '%s' "${issues_json}" | jq '[.[] | select(.number > 0)]')"
fi

if [[ -n "${PR_SINCE}" ]]; then
	prs_json="$(
		gh pr list --repo "${owner}/${repo}" --state merged --limit 100 \
			--search "merged:>=${PR_SINCE}" \
			--json number,title,body,mergedAt,updatedAt,url,files
	)"
else
	prs_json="$(
		gh pr list --repo "${owner}/${repo}" --state merged --limit 20 \
			--json number,title,body,mergedAt,updatedAt,url,files
	)"
fi

if [[ -n "${CHECKPOINT_SHA}" ]]; then
	delta="$(
		gh api "repos/${owner}/${repo}/compare/${CHECKPOINT_SHA}...${head}" \
			--jq '{files: [.files[]? | {filename, status, sha}], commits: [.commits[]? | {sha, message: .commit.message}]}'
	)"
else
	delta='{"files":[],"commits":[],"skipped":"first-run-no-compare"}'
fi

jq -n \
	--arg owner "${owner}" \
	--arg repo "${repo}" \
	--arg branch "${branch}" \
	--arg head "${head}" \
	--argjson has_wiki "${has_wiki}" \
	--arg wiki_remote "${wiki_remote}" \
	--argjson issues "${issues_json}" \
	--argjson prs "${prs_json}" \
	--argjson delta "${delta}" \
	'{
    owner: $owner,
    repo: $repo,
    default_branch: $branch,
    head_sha: $head,
    has_wiki: $has_wiki,
    wiki_remote: $wiki_remote,
    issues: $issues,
    merged_pull_requests: $prs,
    compare: $delta
  }'
