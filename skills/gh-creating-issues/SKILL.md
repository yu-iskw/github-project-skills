---
name: gh-creating-issues
description: Creates a new GitHub issue. Use when a new task, bug, or feature request needs to be tracked.
---

# Creating GitHub Issues

## Purpose

Enables the creation of new issues using the `gh issue create` command.

## 1. Safety & Verification

- **Required Fields**: At least a title is required.
- **Templates**: If the repo has templates, they will be used by default unless specified otherwise.

## 2. Common Workflows

### Workflow: Create Basic Issue

Creates an issue with a title and body.

**Command**:

```bash
gh issue create --title "My Title" --body "My Description"
```

### Workflow: Create with Labels and Assignees

Sets metadata at creation time.

**Command**:

```bash
gh issue create --title "Bug Report" --body "Steps to repro..." --label "bug" --assignee "@me"
```

## 3. Output Handling

Returns the URL of the created issue.
