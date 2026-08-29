#!/usr/bin/env bash
# Collect incremental knowledge evidence with gh.
# Usage:
#   collect-delta.sh [--checkpoint FILE] [--head SHA] [checkpoint_sha] [issue_updated_since] [pr_merged_since]
# First run: omit checkpoint. Never use gh issue list --search.
set -euo pipefail

ROOT="$("$(dirname "$0")/../../../scripts/plugin-root.sh")"
IDENTITY="${ROOT}/skills/gh-knowledge-maintain/scripts/repo-identity.sh"
PARSE_YAML="${ROOT}/skills/gh-wiki-validate/scripts/parse-yaml.mjs"
PREFLIGHT="${ROOT}/skills/gh-wiki-management/scripts/preflight.sh"

CHECKPOINT_FILE=""
HEAD_OVERRIDE=""
POSITIONAL=()
while [[ $# -gt 0 ]]; do
	case "${1}" in
	--checkpoint)
		CHECKPOINT_FILE="${2:?--checkpoint requires a file}"
		shift 2
		;;
	--head)
		HEAD_OVERRIDE="${2:?--head requires a SHA}"
		shift 2
		;;
	-*)
		echo "ERROR: unknown option ${1}" >&2
		exit 1
		;;
	*)
		POSITIONAL+=("${1}")
		shift
		;;
	esac
done

CHECKPOINT_SHA=""
ISSUE_SINCE=""
PR_SINCE=""
if [[ ${#POSITIONAL[@]} -gt 0 ]]; then
	CHECKPOINT_SHA="${POSITIONAL[0]}"
fi
if [[ ${#POSITIONAL[@]} -gt 1 ]]; then
	ISSUE_SINCE="${POSITIONAL[1]}"
fi
if [[ ${#POSITIONAL[@]} -gt 2 ]]; then
	PR_SINCE="${POSITIONAL[2]}"
fi

if [[ -n "${CHECKPOINT_FILE}" ]]; then
	[[ -f "${CHECKPOINT_FILE}" ]] || {
		echo "ERROR: checkpoint file not found: ${CHECKPOINT_FILE}" >&2
		exit 1
	}
	checkpoint_json="$(node "${PARSE_YAML}" "${CHECKPOINT_FILE}")"
	if [[ -z "${CHECKPOINT_SHA}" ]]; then
		CHECKPOINT_SHA="$(printf '%s' "${checkpoint_json}" | jq -r '.last_successful_run.repository_sha // empty')"
	fi
	if [[ -z "${ISSUE_SINCE}" ]]; then
		ISSUE_SINCE="$(printf '%s' "${checkpoint_json}" | jq -r '.evidence_watermarks.issue_updated_at // empty')"
	fi
	if [[ -z "${PR_SINCE}" ]]; then
		PR_SINCE="$(printf '%s' "${checkpoint_json}" | jq -r '.evidence_watermarks.pull_request_updated_at // empty')"
	fi
fi

identity="$(bash "${IDENTITY}")"
owner="$(printf '%s' "${identity}" | jq -r .owner)"
repo="$(printf '%s' "${identity}" | jq -r .repo)"
branch="$(printf '%s' "${identity}" | jq -r .default_branch)"

if [[ -n "${HEAD_OVERRIDE}" ]]; then
	head="${HEAD_OVERRIDE}"
else
	head="$(gh api "repos/${owner}/${repo}/commits/${branch}" --jq .sha)"
fi

wiki_json="$(bash "${PREFLIGHT}")"
has_wiki="$(printf '%s' "${wiki_json}" | jq -c .has_wiki)"
wiki_remote="$(printf '%s' "${wiki_json}" | jq -r .wiki_remote)"

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

if [[ -n "${CHECKPOINT_SHA}" && "${CHECKPOINT_SHA}" == "${head}" ]]; then
	delta='{"files":[],"commits":[],"skipped":"checkpoint-equals-head"}'
elif [[ -n "${CHECKPOINT_SHA}" ]]; then
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
	--arg checkpoint_sha "${CHECKPOINT_SHA}" \
	--arg issue_updated_since "${ISSUE_SINCE}" \
	--arg pr_merged_since "${PR_SINCE}" \
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
    checkpoint_sha: $checkpoint_sha,
    issue_updated_since: $issue_updated_since,
    pr_merged_since: $pr_merged_since,
    has_wiki: $has_wiki,
    wiki_remote: $wiki_remote,
    issues: $issues,
    merged_pull_requests: $prs,
    compare: $delta
  }'
