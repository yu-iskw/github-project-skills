---
name: knowledge-audit
description: Analyze Architecture Wiki drift from gh evidence without cloning-to-publish, pushing, or advancing the checkpoint. Use for /knowledge-audit.
---

Run the `github-knowledge-maintainer` agent in audit mode.

1. Resolve `{owner}/{repo}` with `gh repo view`.
2. Collect evidence with `gh-knowledge-maintain` (`scripts/collect-delta.sh`). First run omits compare.
3. Draft the Architecture mutation plan (shape: `skills/gh-knowledge-maintain/assets/Architecture-Overview.example.md`).
4. Parse Mermaid with `node skills/gh-wiki-diagrams/scripts/mermaid_parse.mjs PAGE.md`.
5. Validate locators with `gh-wiki-validate` when pages exist.

Do not clone-write the live Wiki, do not `git push`, and do not write `.knowledge/checkpoint.yml`. If the Wiki remote is uninitialized, still complete the evidence plan.
