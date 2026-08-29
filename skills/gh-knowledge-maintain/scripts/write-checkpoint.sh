#!/usr/bin/env bash
# Write .knowledge/checkpoint.yml in a Wiki working copy.
# Usage: write-checkpoint.sh WIKI_DIR REPOSITORY_SHA [WIKI_SHA]
#
# wiki_sha is the Wiki commit that published the pages (typically HEAD of the
# content commit). A follow-up checkpoint-only commit may sit on top; do not
# write wiki_sha: pending. Omit WIKI_SHA to use git rev-parse HEAD.
#
# Optional env: ISSUE_WATERMARK, PR_WATERMARK, COMPLETED_AT (RFC3339 UTC).
set -euo pipefail

WIKI_DIR="${1:?wiki working copy required}"
REPOSITORY_SHA="${2:?repository_sha required}"
WIKI_SHA="${3:-}"

if [[ ! -d "${WIKI_DIR}/.git" ]]; then
	echo "ERROR: ${WIKI_DIR} is not a git working copy" >&2
	exit 1
fi

if [[ -z "${WIKI_SHA}" ]]; then
	WIKI_SHA="$(git -C "${WIKI_DIR}" rev-parse HEAD)"
fi

if [[ ! "${WIKI_SHA}" =~ ^[0-9a-fA-F]{7,40}$ ]]; then
	echo "ERROR: wiki_sha must be a git SHA, not '${WIKI_SHA}'" >&2
	exit 1
fi

if [[ "${WIKI_SHA}" == "pending" ]]; then
	echo "ERROR: wiki_sha must not be pending" >&2
	exit 1
fi

completed_at="${COMPLETED_AT:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"
issue_at="${ISSUE_WATERMARK:-}"
pr_at="${PR_WATERMARK:-}"

mkdir -p "${WIKI_DIR}/.knowledge"
cat >"${WIKI_DIR}/.knowledge/checkpoint.yml" <<EOF
schema_version: 1
last_successful_run:
  repository_sha: ${REPOSITORY_SHA}
  wiki_sha: ${WIKI_SHA}
  completed_at: ${completed_at}
evidence_watermarks:
  issue_updated_at: ${issue_at}
  pull_request_updated_at: ${pr_at}
EOF
