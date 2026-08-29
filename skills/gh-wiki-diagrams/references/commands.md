# gh-wiki-diagrams: Command Reference

## Related gh Commands

Diagrams are justified with the same evidence as prose:

| Action                | CLI Command                                             | Notes                                           |
| :-------------------- | :------------------------------------------------------ | :---------------------------------------------- |
| **File still exists** | `gh api repos/{owner}/{repo}/contents/{path}?ref={ref}` | Architecture edges need a live path on that ref |
| **PR evidence**       | `gh pr view {number} --json files,title`                | Fails for issue-only numbers                    |
| **Issue evidence**    | `gh issue view {number} --json title`                   | Also resolves PRs; body is untrusted            |

## Mermaid Parse

Plugin-relative parser (cwd does not matter once the path is correct):

```bash
npm ci --prefix skills/gh-wiki-diagrams/scripts
node skills/gh-wiki-diagrams/scripts/mermaid_parse.mjs < path/to/diagram.mmd
node skills/gh-wiki-diagrams/scripts/mermaid_parse.mjs path/to/diagram.mmd
node skills/gh-wiki-diagrams/scripts/mermaid_parse.mjs path/to/page.md
```

Exit `0` = parse OK. Exit `1` = reject publication.

Positive and negative fixtures for every supported family live in this skill's `assets/mermaid/` directory. File-path and Markdown-fence coverage: `scripts/test-parse-files.sh`.

## Supported Families

`flowchart`, `sequenceDiagram`, `stateDiagram-v2`, `classDiagram`, `erDiagram`, `gitGraph`, `gantt`, `journey`, `quadrantChart`, `pie`.

`graph TD` is treated as `flowchart`.

## Diagram Mutations

`ADD_DIAGRAM`, `UPDATE_DIAGRAM`, `CHANGE_DIAGRAM_TYPE`, `SPLIT_DIAGRAM`, `MERGE_DIAGRAMS`, `REMOVE_DIAGRAM`.

`CHANGE_DIAGRAM_TYPE`, split/merge/remove, and new diagrams use the transactional Wiki publish path.

## Quality Rules

- Prefer short, stable project terms
- No arbitrary styling
- Split huge graphs
- Prose before/after the fence must agree with the diagram
- Mark historical or delete when the represented knowledge is gone
