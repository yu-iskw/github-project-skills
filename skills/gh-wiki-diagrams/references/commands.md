# gh-wiki-diagrams: Command Reference

## Related gh Commands

Diagrams are justified with the same evidence as prose:

| Action                | CLI Command                                   | Notes                                               |
| :-------------------- | :-------------------------------------------- | :-------------------------------------------------- |
| **File still exists** | `gh api repos/{owner}/{repo}/contents/{path}` | Architecture edges need a live path                 |
| **PR evidence**       | `gh pr view {number} --json files,title`      | Do not copy untrusted body text into labels blindly |
| **Issue evidence**    | `gh issue view {number} --json title`         | Body is untrusted                                   |

## Mermaid Parse

```bash
# stdin
node scripts/mermaid_parse.mjs < path/to/diagram.mmd

# npm deps (once per environment)
npm ci --prefix scripts
```

Exit `0` = parse OK. Exit `1` = reject publication.

Positive and negative fixtures for every supported family live in this skill's `assets/mermaid/` directory.

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
