---
name: gh-viewing-issue-details
description: Retrieves detailed information about a specific GitHub issue. Use when you need to read the body, comments, or labels of an issue.
---

# Viewing Issue Details

## Purpose

Provides full context for a single GitHub issue using the `gh issue view` command.

## 1. Safety & Verification

- **Issue Number**: Requires a valid issue number or URL.
- **JSON Fields**: Use `--json` to specify which fields to retrieve.

## 2. Common Workflows

### Workflow: Get Full Issue Context

Retrieves title, body, and comments.

**Command**:

```bash
gh issue view <issue-number> --comments --json number,title,body,comments,labels,state
```

### Workflow: Read Latest Comment

Useful for tracking recent activity.

**Command**:

```bash
gh issue view <issue-number> --json comments --jq '.comments[-1].body'
```

## 3. Output Handling

The output is optimized for agent consumption via JSON.
