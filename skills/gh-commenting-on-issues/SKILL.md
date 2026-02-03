---
name: gh-commenting-on-issues
description: Adds a comment to a GitHub issue. Use to provide updates, ask questions, or link related work.
---

# Commenting on Issues

## Purpose

Posts updates to an existing issue using the `gh issue comment` command.

## 1. Safety & Verification

- **Target**: Must provide a valid issue number or URL.

## 2. Common Workflows

### Workflow: Post Update

Adds a simple text comment.

**Command**:

```bash
gh issue comment <issue-number> --body "Updated the implementation."
```

### Workflow: Multi-line Comment

Use quotes for the body string.

**Command**:

```bash
gh issue comment <issue-number> --body "Line 1
Line 2"
```

## 3. Best Practices

Be concise and clear in your updates.
