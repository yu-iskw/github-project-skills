#!/usr/bin/env bash
set -euo pipefail

ROOT="$("$(dirname "$0")/../../../scripts/plugin-root.sh")"
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
evidence: []
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

DUP_DIR="${WORKDIR}/dup"
mkdir -p "${DUP_DIR}"
cat >"${DUP_DIR}/a.md" <<'EOF'
---
knowledge_schema: 1
knowledge_id: same-id
knowledge_class: procedure
status: active
confidence: high
evidence: []
---

# A

```mermaid
flowchart LR
  A --> B
```
EOF
cp "${DUP_DIR}/a.md" "${DUP_DIR}/b.md"
if bash "${VALIDATE}" "${DUP_DIR}/a.md" >/dev/null 2>&1; then
	echo "FAIL: duplicate knowledge_id across sibling pages must fail" >&2
	exit 1
fi

LINK_DIR="${WORKDIR}/links"
mkdir -p "${LINK_DIR}"
cat >"${LINK_DIR}/Has-Link.md" <<'EOF'
---
knowledge_schema: 1
knowledge_id: has-link
knowledge_class: procedure
status: active
confidence: high
evidence: []
---

See [[Missing-Page]].

```mermaid
flowchart LR
  A --> B
```
EOF
if bash "${VALIDATE}" "${LINK_DIR}/Has-Link.md" >/dev/null 2>&1; then
	echo "FAIL: broken Wiki link must fail closed" >&2
	exit 1
fi

cat >"${LINK_DIR}/Target.md" <<'EOF'
---
knowledge_schema: 1
knowledge_id: link-target
knowledge_class: procedure
status: active
confidence: high
evidence: []
---

# Target

```mermaid
flowchart LR
  A --> B
```
EOF
cat >"${LINK_DIR}/Good-Link.md" <<'EOF'
---
knowledge_schema: 1
knowledge_id: good-link
knowledge_class: procedure
status: active
confidence: high
evidence: []
---

See [[Target]].

```mermaid
flowchart LR
  A --> B
```
EOF
if ! bash "${VALIDATE}" "${LINK_DIR}/Good-Link.md" >/dev/null; then
	echo "FAIL: Wiki link to an existing sibling page should pass" >&2
	exit 1
fi

NO_DIAGRAM="${WORKDIR}/no-diagram.md"
cat >"${NO_DIAGRAM}" <<'EOF'
---
knowledge_schema: 1
knowledge_id: no-diagram
knowledge_class: procedure
status: active
confidence: high
evidence: []
---

# Notes without a diagram
EOF
if ! bash "${VALIDATE}" "${NO_DIAGRAM}" >/dev/null; then
	echo "FAIL: non-Architecture page without Mermaid fences should pass" >&2
	exit 1
fi

SECRET="${WORKDIR}/secret.md"
cat >"${SECRET}" <<'EOF'
---
knowledge_schema: 1
knowledge_id: secret-page
knowledge_class: procedure
status: active
confidence: high
evidence: []
---

token ghs_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
EOF
if bash "${VALIDATE}" "${SECRET}" >/dev/null 2>&1; then
	echo "FAIL: GitHub App token prefix ghs_ must fail closed" >&2
	exit 1
fi

GRAPH="${WORKDIR}/graph-td.md"
cat >"${GRAPH}" <<'EOF'
---
knowledge_schema: 1
knowledge_id: graph-td-architecture
knowledge_class: architecture
status: active
confidence: high
evidence:
  - kind: file
    path: skills/gh-wiki-validate/SKILL.md
---

# Graph alias

```mermaid
graph TD
  A --> B
```

```mermaid
sequenceDiagram
  participant A
  participant B
  A->>B: ok
```
EOF
if ! bash "${VALIDATE}" "${GRAPH}" >/dev/null; then
	echo "FAIL: Architecture graph TD must count as flowchart" >&2
	exit 1
fi

echo "validate-page-ok"
