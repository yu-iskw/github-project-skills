---
name: gh-adding-items-to-projects
description: Adds an issue or PR to a GitHub Project. Use to link repository work to a project board.
---

# Adding Items to Projects

## Purpose

Links a resource to a project using the `gh project item-add` command.

## 1. Safety & Verification

- **Resource URL**: Requires the full URL of the issue or PR to add.

## 2. Common Workflows

### Workflow: Add Issue

Links an issue to a project.

**Command**:

```bash
gh project item-add <project-number> --owner <owner> --url <issue-url>
```
