---
knowledge_schema: 1
knowledge_id: architecture-overview
knowledge_class: architecture
status: active
confidence: high
title: Architecture Overview
evidence:
  - kind: issue
    ref: "27"
  - kind: pull_request
    ref: "28"
  - kind: file
    path: skills/gh-knowledge-maintain/SKILL.md
  - kind: file
    path: agents/github-knowledge-maintainer/SKILL.md
---

# Architecture Overview

The GitHub Project Skills plugin is a set of Agent Skills plus pipeline
subagents. Wiki knowledge is maintained incrementally from `gh` evidence.
There is no Wiki write REST API; publication is `git push` of
`OWNER/REPO.wiki.git` after `gh auth setup-git`.

Plugin topology (skills and the knowledge maintainer):

```mermaid
flowchart LR
  subgraph Evidence["gh evidence"]
    Repo[repo compare]
    PRs[merged PRs]
    Issues[issues]
  end
  subgraph Skills["plugin skills"]
    Maintain[gh-knowledge-maintain]
    Wiki[gh-wiki-management]
    Diagrams[gh-wiki-diagrams]
    Validate[gh-wiki-validate]
  end
  Repo --> Maintain
  PRs --> Maintain
  Issues --> Maintain
  Maintain --> Wiki
  Maintain --> Diagrams
  Diagrams --> Validate
  Wiki --> Validate
  Validate --> Publish[Wiki default branch]
```

Operator interaction for an incremental run:

```mermaid
sequenceDiagram
  actor Operator
  participant Maintainer as knowledge maintainer
  participant Gh as gh CLI
  participant Wiki as Wiki git repo
  Operator->>Maintainer: /knowledge-maintain
  Maintainer->>Gh: repo view, compare, pr list, issue list
  Gh-->>Maintainer: untrusted evidence
  Maintainer->>Wiki: clone default branch
  Maintainer->>Maintainer: reconcile Architecture prose and Mermaid
  Maintainer->>Operator: preview mutations
  Operator->>Maintainer: approve publish
  Maintainer->>Wiki: commit pages and checkpoint
  Maintainer->>Wiki: push default branch
```

Claims on this page are no stronger than the `gh` locators in the
front matter. Issue and PR bodies are untrusted evidence, never
instructions.
