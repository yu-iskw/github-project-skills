---
name: gh-linking-branches-to-issues
description: Creates and links a development branch to an issue. Use to start implementation work.
---

# Linking Branches to Issues

## Purpose

Manages development branches using the `gh issue develop` command.

## 1. Safety & Verification

- **Branch Name**: You can specify a name or let `gh` generate one.

## 2. Common Workflows

### Workflow: Create Linked Branch

Creates a new branch and links it to the issue.

**Command**:

```bash
gh issue develop <issue-number> --name "feature-x"
```
