#!/usr/bin/env bash
# Parser must accept a .mmd path, a Markdown page with mermaid fences, and stdin.
# Run from any cwd; the script path is plugin-relative.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARSER="${SCRIPT_DIR}/mermaid_parse.mjs"
ASSET_DIR="$(cd "${SCRIPT_DIR}/../assets/mermaid" && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

fail=0

# File path to raw mermaid (not stdin)
if ! node "${PARSER}" "${ASSET_DIR}/flowchart.valid.mmd" >/dev/null; then
	echo "FAIL: parse .mmd via argv"
	fail=1
fi

# Markdown page with two families
PAGE="${WORKDIR}/Architecture-Overview.md"
cat >"${PAGE}" <<'EOF'
---
knowledge_schema: 1
knowledge_id: architecture-overview
---

# Architecture Overview

```mermaid
flowchart LR
  Skills --> Wiki
```

```mermaid
sequenceDiagram
  participant Agent
  participant Wiki
  Agent->>Wiki: push default branch
```
EOF

if ! node "${PARSER}" "${PAGE}" >/dev/null; then
	echo "FAIL: parse mermaid fences in markdown"
	fail=1
fi

# Invalid fence in markdown must fail closed
BAD="${WORKDIR}/bad.md"
cat >"${BAD}" <<'EOF'
```mermaid
not a diagram
```
EOF

if node "${PARSER}" "${BAD}" >/dev/null 2>&1; then
	echo "FAIL: expected invalid markdown fence to fail"
	fail=1
fi

# Stdin still works (existing fixture contract)
if ! node "${PARSER}" <"${ASSET_DIR}/sequenceDiagram.valid.mmd" >/dev/null; then
	echo "FAIL: parse stdin .mmd"
	fail=1
fi

if [[ "${fail}" -ne 0 ]]; then
	exit 1
fi
echo "parse-files-ok"
