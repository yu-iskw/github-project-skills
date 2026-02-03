---
name: test-skills
description: Comprehensive testing suite for GitHub agent skills and subagents. Executes 15 workflows and generates a detailed report.
---

# GitHub Agent Testing Skill

## Purpose

Automates the verification of GitHub management skills and subagents through 17 practical project management workflows. It ensures that the system can handle a full issue lifecycle from creation to closure, including project board integration and content updates.

## 1. Prerequisites

- **Target Project**: You MUST identify the GitHub project to use for testing.
- **Resources**: Familiarize yourself with the [17 scenarios](references/scenarios.md) and the [report template](assets/report-template.md).

## 2. Initialization

Before starting the tests, you must ask the user which GitHub Project should be the target of the test.

**Action**: Use the `AskQuestion` tool to prompt for the Project URL or Number.

## 3. Test Orchestration Workflow

Follow this checklist to execute the comprehensive test suite:

- [ ] **Step 0**: Identify Target Project (Ask user).
- [ ] **Step 1**: List Open Issues (Baseline).
- [ ] **Step 2**: Create Project-linked Test Bug.
- [ ] **Step 3**: Add Triage Comment.
- [ ] **Step 4**: Apply Categorization Labels.
- [ ] **Step 5**: Remove Temporary Labels.
- [ ] **Step 6**: Assign Lead Maintainer.
- [ ] **Step 7**: Set Release Milestone.
- [ ] **Step 8**: Create Linked Branch.
- [ ] **Step 9**: List Global Projects.
- [ ] **Step 10**: Verify Project Linkage.
- [ ] **Step 11**: Retrieve Project Items.
- [ ] **Step 12**: Move Item to 'In Progress'.
- [ ] **Step 13**: Search for Duplicate Issues.
- [ ] **Step 14**: Refine Issue Content (Title/Body).
- [ ] **Step 15**: Multi-Attribute Update (Labels/Milestone).
- [ ] **Step 16**: Move Item to 'Done'.
- [ ] **Step 17**: Close the Verified Issue.
- [ ] **Finalize**: Generate Test Report.

## 4. Instructions

1.  **Capture Timestamps**: For every operation, record the ISO timestamp to populate the "Timeline of Operations" in the final report.
2.  **Verify Outcomes**: After each atomic skill call, verify that the state in GitHub has changed as expected (e.g., check that a label was actually added).
3.  **Handle Errors**: If a step fails, document the error in the "Observations" section of the report but attempt to continue subsequent steps if they are not dependent on the failure.
4.  **Reporting**: Use the [assets/report-template.md](assets/report-template.md) to write a detailed Markdown file summarizing the results.

## 5. Examples

### Scenario Execution

**Input**: "Run the test suite on Project #2."
**Behavior**: The agent lists projects, confirms #2, executes the 17 steps while logging timestamps, and finally outputs the report.
