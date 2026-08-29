# Full Wiki reconciliation (deferred)

Phase 1 of the knowledge maintainer implements incremental `/knowledge-maintain` only. This note specifies `/knowledge-maintain --full` so later work can implement it without inventing product behavior.

## Command

```text
/knowledge-maintain --full
```

This is an adversarial audit, not a blind rewrite of the Wiki. It always uses the **transactional** Wiki git path (local branch, validate the complete candidate tree, merge into the default branch, push default only).

## What it must detect

- completeness gaps against the Architecture (and later) taxonomy
- stale claims versus current `gh` evidence (`gh api compare`, `gh pr view`, `gh issue view`, `gh api .../contents/{path}`)
- contradictions between Wiki pages
- duplicated pages or diagrams
- orphan pages (no inbound Wiki links and no evidence)
- broken internal Wiki links
- architecture drift (flowchart vs live module/skill layout)
- procedure drift (sequence/journey vs current operator flow)
- stale or contradictory Mermaid diagrams
- missing diagrams where a visual model would materially help
- accidental loss of historical context

## Diagram-drift checks

For every maintained fence:

1. Parse with `gh-wiki-diagrams` (`node scripts/mermaid_parse.mjs`).
2. Confirm the family still matches the semantics (do not leave a flowchart that should be a sequence or state diagram).
3. Confirm every edge, participant, state, class, or entity still has `gh` evidence.
4. Confirm the diagram agrees with surrounding prose.
5. Split or remove "everything diagrams".

## Publication

- Never use direct push for a full run.
- Never advance `.knowledge/checkpoint.yml` unless the default-branch push succeeded.
- If the audit exceeds budget, stop as incomplete. Do not pretend success.

## Non-goals (still)

No vector database, MCP server, or automatic skill evolution. Those remain later phases after the Wiki layer is trustworthy.
