#!/usr/bin/env bash
# Claude Code loads skills from directories that contain SKILL.md, not from SKILL.md paths.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="${ROOT}/.claude-plugin/plugin.json"

command -v jq >/dev/null
fail=0

while IFS= read -r entry; do
	path="${ROOT}/${entry#./}"
	if [[ "${entry}" == *SKILL.md ]]; then
		echo "FAIL: skills entry is a file path: ${entry}"
		fail=1
		continue
	fi
	if [[ ! -d "${path}" ]]; then
		echo "FAIL: skills entry is not a directory: ${entry}"
		fail=1
		continue
	fi
	if [[ ! -f "${path}/SKILL.md" ]]; then
		echo "FAIL: missing SKILL.md in ${entry}"
		fail=1
	fi
done < <(jq -r '.skills[]' "${MANIFEST}")

for cmd in knowledge-maintain knowledge-audit; do
	if [[ ! -f "${ROOT}/commands/${cmd}.md" ]]; then
		echo "FAIL: missing slash command commands/${cmd}.md"
		fail=1
	fi
done

if [[ "${fail}" -ne 0 ]]; then
	exit 1
fi
echo "plugin-manifest-ok"
