#!/usr/bin/env bash
# Validate all agent skills under skills/ and .cursor/skills/ (including nested dirs).
# Repo root is derived from script location; may be run from any directory. Exits 1 if no skills found or any validation fails.

set -Eeuo pipefail

SCRIPT_DIR="$(dirname "$0")"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"
SKILLS_DIRS=("${ROOT_DIR}/skills" "${ROOT_DIR}/.cursor/skills")

found=0
failed=0
for SKILLS_DIR in "${SKILLS_DIRS[@]}"; do
	[[ -d ${SKILLS_DIR} ]] || continue
	SKILL_PATHS_FILE=$(mktemp)
	find "${SKILLS_DIR}" -type f -name 'SKILL.md' 2>/dev/null >"${SKILL_PATHS_FILE}"
	while IFS= read -r path; do
		[[ -z ${path} ]] && continue
		found=1
		dir="$(dirname "${path}")"
		if ! uv run --directory "${ROOT_DIR}" skills-ref validate "${dir}"; then
			failed=1
		fi
	done <"${SKILL_PATHS_FILE}"
	rm -f "${SKILL_PATHS_FILE}"
done

if [[ ${found} -eq 0 ]]; then
	echo "No agent skills found under skills/ or .cursor/skills/"
	exit 1
fi
exit "${failed}"
