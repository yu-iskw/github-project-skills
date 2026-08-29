#!/usr/bin/env bash
# Classify Wiki publication strategy from mutation classes (stdin) and diff size.
# Usage: publication-strategy.sh [files_changed] [lines_changed]
# Prints: direct | transactional
set -euo pipefail

files="${1:-0}"
lines="${2:-0}"
max_files="${DIRECT_PUBLISH_MAX_FILES:-3}"
max_lines="${DIRECT_PUBLISH_MAX_LINES:-50}"

transactional_class() {
	case "${1}" in
	REMOVE_PAGE | SPLIT_PAGE | MOVE_SECTION | MERGE_DUPLICATES | ADD_PAGE | \
		CHANGE_DIAGRAM_TYPE | SPLIT_DIAGRAM | MERGE_DIAGRAMS | REMOVE_DIAGRAM | ADD_DIAGRAM)
		return 0
		;;
	*)
		return 1
		;;
	esac
}

strategy="direct"
while IFS= read -r class || [[ -n "${class}" ]]; do
	[[ -z "${class}" ]] && continue
	if transactional_class "${class}"; then
		strategy="transactional"
	fi
done

if [[ "${files}" -gt "${max_files}" || "${lines}" -gt "${max_lines}" ]]; then
	strategy="transactional"
fi

printf '%s\n' "${strategy}"
