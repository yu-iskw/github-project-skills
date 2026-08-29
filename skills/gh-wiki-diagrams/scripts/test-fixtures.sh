#!/usr/bin/env bash
# Classify and parse Mermaid fixtures. Requires Node deps in this directory (npm ci).
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ASSET_DIR="$(cd "${SCRIPT_DIR}/../assets/mermaid" && pwd)"
PARSER="${SCRIPT_DIR}/mermaid_parse.mjs"

FAMILIES=(
	flowchart
	sequenceDiagram
	stateDiagram-v2
	classDiagram
	erDiagram
	gitGraph
	gantt
	journey
	quadrantChart
	pie
)

first_keyword() {
	awk 'NF && $1 !~ /^%%/ { print $1; exit }' "$1"
}

failed=0
classified=0

for family in "${FAMILIES[@]}"; do
	valid="${ASSET_DIR}/${family}.valid.mmd"
	invalid="${ASSET_DIR}/${family}.invalid.mmd"
	if [[ ! -f "${valid}" || ! -f "${invalid}" ]]; then
		echo "FAIL missing fixtures for ${family}"
		failed=1
		continue
	fi
	keyword="$(first_keyword "${valid}")"
	if [[ "${keyword}" != "${family}" ]]; then
		echo "FAIL classify ${valid}: got ${keyword} want ${family}"
		failed=1
	else
		classified=$((classified + 1))
	fi
	if ! node "${PARSER}" <"${valid}" >/dev/null; then
		echo "FAIL parse valid ${valid}"
		failed=1
	fi
	if node "${PARSER}" <"${invalid}" >/dev/null 2>&1; then
		echo "FAIL expected invalid parse: ${invalid}"
		failed=1
	fi
done

if [[ ${classified} -lt 2 ]]; then
	echo "FAIL diagram policy appears hard-coded to a single family"
	failed=1
fi

if [[ ${classified} -eq ${#FAMILIES[@]} ]]; then
	echo "classified ${classified} families (not flowchart-only)"
fi

exit "${failed}"
