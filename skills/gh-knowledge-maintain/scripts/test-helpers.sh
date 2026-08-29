#!/usr/bin/env bash
# Unit tests for knowledge-loop helpers (plugin root, identity, checkpoint, strategy).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
PLUGIN_ROOT_SH="${ROOT}/scripts/plugin-root.sh"
IDENTITY_SH="${ROOT}/skills/gh-knowledge-maintain/scripts/repo-identity.sh"
STRATEGY_SH="${ROOT}/skills/gh-knowledge-maintain/scripts/publication-strategy.sh"
CHECKPOINT_SH="${ROOT}/skills/gh-knowledge-maintain/scripts/write-checkpoint.sh"
PARSE_YAML="${ROOT}/skills/gh-wiki-validate/scripts/parse-yaml.mjs"
COLLECT="${ROOT}/skills/gh-knowledge-maintain/scripts/collect-delta.sh"
PREFLIGHT="${ROOT}/skills/gh-wiki-management/scripts/preflight.sh"

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

command -v gh >/dev/null
command -v jq >/dev/null
gh auth status >/dev/null

echo "== plugin-root =="
[[ -x "${PLUGIN_ROOT_SH}" ]] || fail "missing executable ${PLUGIN_ROOT_SH}"
resolved="$("${PLUGIN_ROOT_SH}")"
[[ "${resolved}" == "${ROOT}" ]] || fail "plugin-root ${resolved} != ${ROOT}"
[[ -f "${resolved}/.claude-plugin/plugin.json" ]] || fail "plugin-root missing plugin.json"

echo "== repo-identity =="
[[ -x "${IDENTITY_SH}" ]] || fail "missing executable ${IDENTITY_SH}"
identity="$(bash "${IDENTITY_SH}")"
echo "${identity}" | jq -e '.owner != "" and .repo != "" and .default_branch != ""' >/dev/null
owner="$(echo "${identity}" | jq -r .owner)"
[[ "${owner}" != "cursor" ]] || fail "owner must come from gh repo view, not the cursor integration login"

echo "== publication-strategy =="
[[ -x "${STRATEGY_SH}" ]] || fail "missing executable ${STRATEGY_SH}"
printf '%s\n' ADD_PAGE | bash "${STRATEGY_SH}" 1 1 | grep -qx transactional || fail "ADD_PAGE must be transactional"
printf '%s\n' UPDATE_CLAIM | bash "${STRATEGY_SH}" 1 10 | grep -qx direct || fail "small UPDATE_CLAIM must be direct"
printf '%s\n' UPDATE_CLAIM | bash "${STRATEGY_SH}" 9 10 | grep -qx transactional || fail "oversize file count must be transactional"
printf '%s\n' ADD_DIAGRAM | bash "${STRATEGY_SH}" 1 1 | grep -qx transactional || fail "ADD_DIAGRAM must be transactional"

echo "== write-checkpoint =="
[[ -x "${CHECKPOINT_SH}" ]] || fail "missing executable ${CHECKPOINT_SH}"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT
git init "${WORKDIR}/wiki" >/dev/null
git -C "${WORKDIR}/wiki" config user.email "test@example.com"
git -C "${WORKDIR}/wiki" config user.name "Wiki Test"
printf '%s\n' "# Home" >"${WORKDIR}/wiki/Home.md"
git -C "${WORKDIR}/wiki" add Home.md
git -C "${WORKDIR}/wiki" commit -m "seed" >/dev/null
pages_sha="$(git -C "${WORKDIR}/wiki" rev-parse HEAD)"
ISSUE_WATERMARK="2026-08-29T11:23:01Z" \
	PR_WATERMARK="2026-08-29T12:10:48Z" \
	bash "${CHECKPOINT_SH}" "${WORKDIR}/wiki" "abc123def456" "${pages_sha}"
[[ -f "${WORKDIR}/wiki/.knowledge/checkpoint.yml" ]] || fail "checkpoint not written"
grep -qv 'wiki_sha: pending' "${WORKDIR}/wiki/.knowledge/checkpoint.yml" || fail "wiki_sha must not be pending"
node "${PARSE_YAML}" "${WORKDIR}/wiki/.knowledge/checkpoint.yml" |
	jq -e --arg sha "${pages_sha}" \
		'.schema_version == 1
     and .last_successful_run.repository_sha == "abc123def456"
     and .last_successful_run.wiki_sha == $sha
     and .evidence_watermarks.issue_updated_at != ""
     and .evidence_watermarks.pull_request_updated_at != ""' >/dev/null \
	|| fail "checkpoint yaml schema"

echo "== collect-delta --checkpoint =="
live_head="$(echo "${identity}" | jq -r .default_branch)"
live_sha="$(gh api "repos/$(echo "${identity}" | jq -r .owner)/$(echo "${identity}" | jq -r .repo)/commits/${live_head}" --jq .sha)"
ISSUE_WATERMARK="2026-08-29T11:23:01Z" \
	PR_WATERMARK="2026-08-29T12:10:48Z" \
	bash "${CHECKPOINT_SH}" "${WORKDIR}/wiki" "${live_sha}" "${pages_sha}"
payload="$(bash "${COLLECT}" --checkpoint "${WORKDIR}/wiki/.knowledge/checkpoint.yml")"
echo "${payload}" | jq -e --arg sha "${live_sha}" '.checkpoint_sha == $sha' >/dev/null || fail "checkpoint_sha missing from payload"
echo "${payload}" | jq -e '.issue_updated_since == "2026-08-29T11:23:01Z"' >/dev/null || fail "issue watermark not applied"
echo "${payload}" | jq -e '.compare.skipped != "first-run-no-compare"' >/dev/null || fail "checkpointed run must not skip compare as first-run"

echo "== wiki preflight =="
[[ -x "${PREFLIGHT}" ]] || fail "missing executable ${PREFLIGHT}"
preflight="$(bash "${PREFLIGHT}")"
echo "${preflight}" | jq -e '.wiki_remote | IN("ready", "uninitialized", "unavailable")' >/dev/null
echo "${preflight}" | jq -e '.clone_url | test("\\.wiki\\.git$")' >/dev/null

echo "helpers-ok"
