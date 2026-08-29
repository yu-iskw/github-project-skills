#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
VALIDATE="${ROOT}/skills/gh-wiki-validate/scripts/validate-page.sh"
EXAMPLE="${ROOT}/skills/gh-knowledge-maintain/assets/Architecture-Overview.example.md"

bash "${VALIDATE}" "${EXAMPLE}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT
BAD="${WORKDIR}/bad.md"
cat >"${BAD}" <<'EOF'
---
title: missing schema
---

# Bad

```mermaid
not a diagram
```
EOF

if bash "${VALIDATE}" "${BAD}" >/dev/null 2>&1; then
	echo "FAIL: expected invalid page to fail closed" >&2
	exit 1
fi

OTHER="${WORKDIR}/other.md"
cat >"${OTHER}" <<'EOF'
---
knowledge_schema: 1
knowledge_id: other-page
knowledge_class: procedure
status: active
confidence: high
---

# Other

```mermaid
flowchart LR
  A --> B
```
EOF

if ! bash "${VALIDATE}" "${OTHER}" >/dev/null; then
	echo "FAIL: non-Architecture page should not require sequenceDiagram" >&2
	exit 1
fi

echo "validate-page-ok"
