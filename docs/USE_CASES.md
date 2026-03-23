# Use Cases

This document provides detailed examples of how to combine the specialized agents and atomic skills in this repository to solve real-world GitHub management challenges.

## 0. Initial Project Config Setup (One-Time per Repository)

**Goal**: Declare the active GitHub project and repository context so that all subsequent agent sessions auto-verify silently — without repeated confirmation prompts.

### Setup Workflow

1. **Run the setup skill**: Invoke `gh-set-active-project` in the root of your target repository.
2. **Select your project**: The skill lists all available GitHub Projects (v2) for the repository owner and asks you to pick one.
3. **Config written**: The skill writes `.github/project-config.json` with the selected owner, repo, project number, and project ID.

After this one-time setup:
- `gh-verifying-context` compares the live environment to the config automatically. If they match, it proceeds silently with no output.
- `github-triage-agent` and `github-project-manager` read `project_number` from the config directly — no "which project?" prompt.
- If the live environment ever mismatches the config (wrong account, wrong repository), the skill stops immediately with a detailed alert.

To switch to a different project, re-run `gh-set-active-project` to overwrite the config.

---

## 1. Automated Issue Triage

**Goal**: Automatically categorize and assign incoming issues to the right maintainers without manual intervention.

### Triage Workflow

0. **Prerequisite**: Run `gh-set-active-project` once to create `.github/project-config.json`.
1. **Context**: `gh-verifying-context` auto-verifies against the config silently. Proceeds immediately if the environment matches.
2. **Detection**: `github-triage-agent` identifies new, unlabeled issues using `gh-issue-management`.
3. **Analysis**: The agent uses `gh-issue-management` to read the full context of each issue.
4. **Categorization**:
   - Apply type labels (e.g., `bug`, `feature`, `documentation`) via `gh-issue-management`.
   - Assign the issue based on the expertise detected in the content.
5. **Engagement**: Post a welcome message or request missing information via `gh-issue-management` if the issue template wasn't followed.

---

## 2. Project Board Synchronization

**Goal**: Keep a GitHub Project (v2) perfectly in sync with the state of the repository.

### Sync Workflow

0. **Prerequisite**: Run `gh-set-active-project` once to create `.github/project-config.json`.
1. **Context**: `gh-verifying-context` auto-verifies against the config silently. The target project is read from `project_number` in the config — no manual selection required.
2. **Discovery**: `gh-issue-management` finds open issues that are not yet on the project board.
3. **Ingestion**: `gh-project-management` links missing issues to the board.
4. **Status Updates**:
   - As developers close issues, `github-project-manager` uses `gh-project-management` to move items from "In Progress" to "Done".
   - It can also update custom fields like "Priority" or "Estimate" based on labels or milestones.

---

## 3. Sprint/Release Planning

**Goal**: Organize a batch of work for an upcoming milestone or release target.

### Planning Workflow

1. **Discovery**: Use `gh-searching-issues` to find high-priority bugs and requested features.
2. **Milestone Assignment**: Use `gh-setting-milestones` to group identified issues into a specific release version.
3. **Project Organization**:
   - Use `gh-listing-project-fields` to find custom fields like "Sprint" or "Target Version".
   - Use `gh-updating-project-fields` to batch-update the project board with the new planning data.
4. **Tracking**: Use `gh-listing-milestones` to monitor progress toward the release goal.

---

## 4. Repository Reorganization

**Goal**: Moving work between repositories while preserving context and tracking.

### Reorg Workflow

1. **Audit**: Use `gh-searching-issues` to find issues in a repository that actually belong in a different part of the organization.
2. **Transfer**: Use `gh-transferring-issues` to move the issue to the correct destination repository.
3. **Linkage**: Use `gh-commenting-on-issues` on both the old and new issue to provide traceability.
4. **Cleanup**: Use `gh-labeling-issues` on the new repository to ensure the transferred work matches the destination's triage standards.
