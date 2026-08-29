#!/usr/bin/env bash
# Resolve {owner}/{repo}/default_branch from gh repo view, never the auth username.
# If .github/project-config.json exists, compare owner/repo and exit 1 on mismatch.
# Missing project config does not stop knowledge work.
set -euo pipefail

ROOT="$("$(dirname "$0")/../../../scripts/plugin-root.sh")"

identity="$(
	gh repo view --json owner,name,defaultBranchRef \
		--jq '{owner: .owner.login, repo: .name, default_branch: .defaultBranchRef.name}'
)"

owner="$(printf '%s' "${identity}" | jq -r .owner)"
repo="$(printf '%s' "${identity}" | jq -r .repo)"
if [[ -z "${owner}" || -z "${repo}" || "${owner}" == "null" ]]; then
	echo "ERROR: gh repo view did not return owner/repo" >&2
	exit 1
fi

config="${ROOT}/.github/project-config.json"
if [[ -f "${config}" ]]; then
	cfg_owner="$(jq -r .owner "${config}")"
	cfg_repo="$(jq -r .repo "${config}")"
	if [[ "${cfg_owner}" != "${owner}" || "${cfg_repo}" != "${repo}" ]]; then
		echo "ERROR: .github/project-config.json (${cfg_owner}/${cfg_repo}) does not match gh repo view (${owner}/${repo})" >&2
		exit 1
	fi
fi

printf '%s\n' "${identity}"
