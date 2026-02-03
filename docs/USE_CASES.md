# Use Cases

This document provides detailed examples of how to combine the specialized agents and atomic skills in this repository to solve real-world GitHub management challenges.

## 1. Automated Issue Triage

**Goal**: Automatically categorize and assign incoming issues to the right maintainers without manual intervention.

### Triage Workflow

1. **Detection**: `github-triage-agent` identifies new, unlabeled issues using `gh-listing-issues`.
2. **Analysis**: The agent uses `gh-viewing-issue-details` to read the full context.
3. **Categorization**:
   - `gh-labeling-issues` is used to apply type labels (e.g., `bug`, `feature`, `documentation`).
   - `gh-assigning-issues` is used to assign the issue based on the expertise detected in the content.
4. **Engagement**: `gh-commenting-on-issues` is used to post a welcome message or request missing information if the issue template wasn't followed.

---

## 2. Project Board Synchronization

**Goal**: Keep a GitHub Project (v2) perfectly in sync with the state of the repository.

### Sync Workflow

1. **Verification**: `github-project-manager` verifies the target project using `gh-listing-projects`.
2. **Discovery**: `gh-searching-issues` finds open issues that are not yet on the project board.
3. **Ingestion**: `gh-adding-items-to-projects` links missing issues to the board.
4. **Status Updates**:
   - As developers close issues, `github-project-manager` uses `gh-updating-project-fields` to move items from "In Progress" to "Done".
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
