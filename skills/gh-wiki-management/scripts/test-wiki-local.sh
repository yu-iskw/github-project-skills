#!/usr/bin/env bash
# Local Wiki git loop: clone, publish, checkpoint, idempotent no-op, race abort.
# Does not require GitHub Wiki to be enabled.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
PARSE="${ROOT}/skills/gh-wiki-diagrams/scripts/mermaid_parse.mjs"
EXAMPLE="${ROOT}/skills/gh-knowledge-maintain/assets/Architecture-Overview.example.md"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

BARE="${WORKDIR}/wiki.git"
git init --bare "${BARE}" >/dev/null
git -C "${BARE}" symbolic-ref HEAD refs/heads/master

clone_wiki() {
	local dest="$1"
	git clone "${BARE}" "${dest}" >/dev/null 2>&1
	git -C "${dest}" config user.email "test@example.com"
	git -C "${dest}" config user.name "Wiki Test"
}

W1="${WORKDIR}/w1"
clone_wiki "${W1}"

mkdir -p "${W1}/.knowledge"
printf '%s\n' "# Seed" >"${W1}/Home.md"
git -C "${W1}" add Home.md
git -C "${W1}" commit -m "seed" >/dev/null
git -C "${W1}" push origin HEAD >/dev/null

cp "${EXAMPLE}" "${W1}/Architecture-Overview.md"
node "${PARSE}" "${W1}/Architecture-Overview.md" >/dev/null

printf '%s\n' "schema_version: 1
last_successful_run:
  repository_sha: testha
  wiki_sha: pending
  completed_at: 2026-08-29T00:00:00Z
evidence_watermarks:
  issue_updated_at: 2026-08-01T00:00:00Z
  pull_request_updated_at: 2026-08-01T00:00:00Z
" >"${W1}/.knowledge/checkpoint.yml"

git -C "${W1}" add Architecture-Overview.md .knowledge/checkpoint.yml
git -C "${W1}" commit -m "docs(wiki): architecture overview" >/dev/null
BEFORE_PUSH="$(git -C "${W1}" rev-parse origin/master)"
git -C "${W1}" fetch origin >/dev/null
test "$(git -C "${W1}" rev-parse origin/master)" = "${BEFORE_PUSH}"
git -C "${W1}" push origin HEAD >/dev/null
test "$(git -C "${W1}" rev-parse HEAD)" = "$(git -C "${W1}" rev-parse origin/master)"

# Idempotent no-op: identical page does not stage
W2="${WORKDIR}/w2"
clone_wiki "${W2}"
git -C "${W2}" add Architecture-Overview.md
if ! git -C "${W2}" diff --cached --quiet; then
	echo "FAIL: identical wiki page should not stage a change" >&2
	exit 1
fi

# Transactional: local branch, merge default, push default
git -C "${W2}" checkout -b knowledge/tx >/dev/null 2>&1
printf '\n<!-- extra -->\n' >>"${W2}/Architecture-Overview.md"
git -C "${W2}" add Architecture-Overview.md
git -C "${W2}" commit -m "docs(wiki): extra" >/dev/null
git -C "${W2}" checkout master >/dev/null 2>&1
git -C "${W2}" merge --ff-only knowledge/tx >/dev/null
git -C "${W2}" push origin HEAD >/dev/null

# Race abort: stale clone behind after another push
W3="${WORKDIR}/w3"
clone_wiki "${W3}"
printf '\n<!-- race winner -->\n' >>"${W2}/Architecture-Overview.md"
git -C "${W2}" add Architecture-Overview.md
git -C "${W2}" commit -m "docs(wiki): race winner" >/dev/null
git -C "${W2}" push origin HEAD >/dev/null
git -C "${W3}" fetch origin >/dev/null
STALE_HEAD="$(git -C "${W3}" rev-parse HEAD)"
REMOTE_HEAD="$(git -C "${W3}" rev-parse origin/master)"
if [[ "${STALE_HEAD}" == "${REMOTE_HEAD}" ]]; then
	echo "FAIL: expected origin to be ahead of stale clone" >&2
	exit 1
fi

# First-run checkpoint: missing file is empty, not a git compare
rm -f "${W3}/.knowledge/checkpoint.yml"
test ! -f "${W3}/.knowledge/checkpoint.yml"

echo "wiki-local-ok"
