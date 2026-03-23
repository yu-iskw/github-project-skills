---
name: gh-project-management
description: Comprehensive management of GitHub Projects (v2). Use to list projects, view items, add items, update fields, and manage project structure in a single skill.
metadata:
  pattern: tool-wrapper
---

# GitHub Project Management

## Purpose

Consolidates all GitHub Project (v2) operations into a single, token-efficient skill. This reduces context overhead and simplifies workflows for synchronizing issues with project boards.

## 1. Safety & Verification

- **Mandatory Context**: Ensure `gh-verifying-context` has been run and confirmed by the user.
- **Human-in-the-Loop**: You MUST present all state-changing commands (add item, edit field, archive, delete) and their parameters to the user before execution.
- **Verification**: Always verify Project IDs and Item IDs before editing. Use listing workflows if these are unknown.
- **Owner Flag**: Ensure the correct `--owner` (user or organization) is specified.

## 2. Common Workflows

### Workflow: Identify Project and Items

Finds the target project and lists its current contents.

**Command**:

```bash
# List projects for an owner
gh project list --owner "my-org" --json number,title,id

# List items in a project
gh project item-list <project-number> --owner "my-org" --json id,title,content
```

### Workflow: Add and Categorize Items

Adds an issue to a project and moves it to a specific status.

**Command**:

```bash
# Add issue to project
gh project item-add <project-number> --owner <owner> --url <issue-url>

# Update a field (e.g., Status)
gh project item-edit --id <item-id> --project-id <project-id> --field-id <field-id> --single-select-option-id <option-id>
```

### Workflow: Manage Project Structure

Discovers fields and creates draft items.

**Command**:

```bash
# List fields in a project
gh project field-list <project-number> --owner <owner> --json id,name,options

# Create a draft issue
gh project item-create <project-number> --owner <owner> --title "Draft Title" --body "Draft Body"
```

## 3. Reference Table of Actions

See [references/commands.md](references/commands.md) for the full action reference table, ID type guide, and list of state-changing commands that require approval.

## 4. Output Handling

Always prefer `--json` for structured data. The internal **Item ID** (e.g., `PVTI_...`) is critical for `item-edit` and `item-archive` operations, while the **Project Number** is used for `item-list` and `item-add`.
