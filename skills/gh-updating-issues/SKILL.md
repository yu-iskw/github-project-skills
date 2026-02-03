---
name: gh-updating-issues
description: Updates existing GitHub issues (title, body, labels, assignees, milestones, and projects). Use to refine issue details or synchronize with project boards.
---

# Updating GitHub Issues

## Purpose

Enables the modification of existing issues using the `gh issue edit` command. This skill is critical for keeping issues accurate and properly tracked within GitHub Projects.

## 1. Safety & Verification

Before updating an issue:

1.  **Verify Issue Exists**: Use `gh-viewing-issue-details` to confirm the issue number/URL and its current state.
2.  **Project Authorization**: Editing project associations requires the `project` scope. If you encounter authorization errors, the user may need to run `gh auth refresh -s project`.

## 2. Common Workflows

### Workflow: Update Title and Body

Refines the core description of the issue.

**Command**:

```bash
gh issue edit <issue-number> --title "Updated Title" --body "Updated Body"
```

### Workflow: Update Project Associations

Adds or removes issues from GitHub Project boards.

**Command**:

```bash
# Add to a project
gh issue edit <issue-number> --add-project "Project Title"

# Remove from a project
gh issue edit <issue-number> --remove-project "Project Title"
```

### Workflow: Manage Metadata (Labels, Assignees, Milestones)

Efficiently updates multiple fields in a single call.

**Command**:

```bash
# Add labels and assign yourself
gh issue edit <issue-number> --add-label "bug,high-priority" --add-assignee "@me"

# Set a milestone
gh issue edit <issue-number> --milestone "v1.0-release"
```

## 3. Combined Updates

You can perform multiple updates simultaneously for efficiency.

**Command**:

```bash
gh issue edit <issue-number> \
  --title "Refined Bug Report" \
  --add-label "bug" \
  --add-project "Maintenance" \
  --add-assignee "@me"
```

## 4. Error Handling

- **Invalid Flag**: If a flag is rejected, run `gh issue edit --help` to check for syntax changes in the CLI version.
- **Resource Not Found**: If the issue or project title doesn't exist, verify the names using listing skills.
