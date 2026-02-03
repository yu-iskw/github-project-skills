# 17 Practical GitHub Management Scenarios

These scenarios test the atomic skills and composite subagents in a realistic project lifecycle.

## Group A: Core Agent Scenarios

These scenarios verify the primary workflows used by the `github-project-manager` and `github-triage-agent`.

### Scenario 1: Listing Open Issues

- **Goal**: Verify visibility of existing work.
- **Skill**: `gh-listing-issues`
- **Verification**: Ensure output is valid JSON and contains current issues.

### Scenario 2: Creating a Bug Report within a Project

- **Goal**: Test issue initialization with project linkage.
- **Skill**: `gh-creating-issues`
- **Input**: Title: "TEST: Workflow Malfunction", Body: "Reproduction steps: 1. Launch...", Project: "Target Project Title"
- **Verification**: Capture the URL of the created issue and confirm it appears in the target project.

### Scenario 3: Adding a Triage Comment

- **Goal**: Test communication capability.
- **Skill**: `gh-commenting-on-issues`
- **Input**: Body: "Triage Agent starting analysis..."
- **Verification**: Confirm comment exists on the issue.

### Scenario 4: Applying Categorization Labels

- **Goal**: Test metadata management.
- **Skill**: `gh-labeling-issues`
- **Input**: Add label "bug".
- **Verification**: Check issue details for the label.

### Scenario 5: Removing Temporary Labels

- **Goal**: Test update flexibility.
- **Skill**: `gh-labeling-issues`
- **Input**: Remove any "triage-needed" label if present.
- **Verification**: Label is no longer present.

### Scenario 6: Assigning a Lead Maintainer

- **Goal**: Test ownership assignment.
- **Skill**: `gh-assigning-issues`
- **Input**: Add `@me` as assignee.
- **Verification**: Check issue details for assignee.

### Scenario 7: Setting a Release Milestone

- **Goal**: Test planning integration.
- **Skill**: `gh-setting-milestones`
- **Input**: Associate with an existing or new milestone.
- **Verification**: Milestone is visible in issue JSON.

### Scenario 9: Listing Global Projects

- **Goal**: Verify project discovery.
- **Skill**: `gh-listing-projects`
- **Verification**: Project #2 (or specified) is in the list.

### Scenario 10: Verifying Project Linkage

- **Goal**: Confirm the issue was correctly linked at creation.
- **Skill**: `gh-viewing-project-items` or `gh-viewing-issue-details`
- **Input**: Verify the issue from Scenario 2 is linked to the target project.
- **Verification**: Item ID is returned/discovered.

### Scenario 11: Retrieving Project Items

- **Goal**: Verify board state.
- **Skill**: `gh-viewing-project-items`
- **Verification**: The issue from Scenario 2 is listed in the project items.

### Scenario 12: Moving Item to 'In Progress'

- **Goal**: Test status automation.
- **Skill**: `gh-updating-project-fields`
- **Input**: Set "Status" to "In progress".
- **Verification**: Field value reflects the update.

### Scenario 13: Searching for Duplicate Issues

- **Goal**: Test search qualifiers.
- **Skill**: `gh-searching-issues`
- **Input**: Search for "Workflow Malfunction".
- **Verification**: At least the test issue is found.

### Scenario 14: Moving Item to 'Done'

- **Goal**: Test final state transition.
- **Skill**: `gh-updating-project-fields`
- **Input**: Set "Status" to "Done".
- **Verification**: Field value reflects "Done".

### Scenario 15: Closing the Verified Issue

- **Goal**: Complete the lifecycle.
- **Skill**: `gh-closing-issues`
- **Input**: Reason "completed".
- **Verification**: Issue state is "closed".

### Scenario 16: Refining Issue Content

- **Goal**: Test updating core issue data.
- **Skill**: `gh-updating-issues`
- **Input**: Update Title: "TEST: Refined Workflow Malfunction", Body: "Updated repro steps..."
- **Verification**: Check issue details for new title and body.

### Scenario 17: Multi-Attribute Metadata Update

- **Goal**: Test batch updates for efficiency.
- **Skill**: `gh-updating-issues`
- **Input**: Add label "documentation", set milestone, and add to project (if not already added).
- **Verification**: All attributes reflect changes in a single verification check.

## Group B: Atomic Skill Scenarios (Extension/Experimental)

These scenarios test standalone skills that are not yet integrated into core subagents or require specific environment configurations.

### Scenario 8: Creating a Linked Branch

- **Goal**: Test development workflow bridge.
- **Skill**: `gh-linking-branches-to-issues`
- **Input**: Create branch "test/fix-malfunction".
- **Verification**: Branch is linked to the issue.
