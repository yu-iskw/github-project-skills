---
name: gh-labeling-issues
description: Manages labels on a GitHub issue. Use for triage and categorization.
---

# Labeling Issues

## Purpose

Updates labels using the `gh issue edit` command.

## 1. Safety & Verification

- **Existing Labels**: Verify the label exists in the repo first.

## 2. Common Workflows

### Workflow: Add Labels

Attaches new categories to an issue.

**Command**:

```bash
gh issue edit <issue-number> --add-label "bug,triage"
```

### Workflow: Remove Labels

Detaches labels from an issue.

**Command**:

```bash
gh issue edit <issue-number> --remove-label "needs-investigation"
```
