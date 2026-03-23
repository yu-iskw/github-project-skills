---
name: gh-issue-management
description: Comprehensive management of GitHub issues. Use to create, update, close, list, search, view, and comment on issues in a single skill.
metadata:
  pattern: tool-wrapper
---

# GitHub Issue Management

## Purpose

Consolidates all issue-related operations into a single, token-efficient skill. This reduces context overhead and enables multi-action workflows in fewer turns.

## 1. Safety & Verification

- **Mandatory Context**: Ensure `gh-verifying-context` has been run and confirmed by the user.
- **Human-in-the-Loop**: You MUST present all state-changing commands (create, edit, close, comment, transfer, lock) and their parameters to the user before execution.
- **Sensitivity Check**: Do not include internal credentials, server IPs, or proprietary data in issue titles, bodies, or comments.
- **Repository Check**: Confirm the target repository name and owner with the user.

## 2. Common Workflows

### Workflow: Create and Configure Issue

Creates an issue and sets labels, assignees, and projects in one step.

**Command**:

```bash
gh issue create --title "Title" --body "Description" --label "bug,triage" --assignee "@me" --project "Roadmap"
```

### Workflow: Update Multiple Metadata Fields

Refines an existing issue's title, body, and associations.

**Command**:

```bash
gh issue edit <issue-number> --title "New Title" --body "New Body" --add-label "bug" --remove-label "needs-investigation" --add-assignee "@me" --milestone "v1.0"
```

### Workflow: List and Search

Retrieves issues based on state, labels, or keywords.

**Command**:

```bash
# List open bugs
gh issue list --state open --label "bug" --json number,title,updatedAt

# Search across repositories for unprojected issues
gh search issues --no-project --state open --json number,title,repository
```

### Workflow: Engagement and Lifecycle

Comments on, closes, or transfers issues.

**Command**:

```bash
# Post a comment
gh issue comment <issue-number> --body "Implementation finished."

# Close with reason
gh issue close <issue-number> --reason "completed"
```

## 3. Reference Table of Actions

See [references/commands.md](references/commands.md) for the full action reference table and list of state-changing commands that require approval.

## 4. Output Handling

Always prefer `--json` for structured data when listing or viewing. Use `jq` for extraction if needed.
