---
name: gh-closing-issues
description: Closes a GitHub issue. Use when a task is completed or an issue is resolved.
---

# Closing GitHub Issues

## Purpose

Resolves an issue using the `gh issue close` command.

## 1. Safety & Verification

- **Reason**: You can specify a reason (completed, not planned).

## 2. Common Workflows

### Workflow: Close as Completed

Default closing behavior.

**Command**:

```bash
gh issue close <issue-number> --reason completed
```

### Workflow: Close with Comment

It's often good practice to add a comment explaining why the issue is being closed.

**Command**:

```bash
gh issue comment <issue-number> --body "Closing as this is resolved." && gh issue close <issue-number>
```
