# GitHub Project Management Agent Skills

## Overview

This repository is a collection of specialized **Agent Skills** and **Subagents** designed to automate and streamline GitHub workflows by leveraging the **GitHub CLI (`gh`)**. These skills empower AI agents (like Cursor, Claude Code, or Gemini CLI) to interact deeply with GitHub issues, milestones, labels, and project boards, enabling autonomous project management and triage.

<video src="docs/assets/test-skills.mp4" controls="controls" style="max-width: 100%;">
  Your browser does not support the video tag.
</video>

## Key Features

- **Zero-Config Authentication**: Leverages the GitHub CLI (`gh` command) for authentication, eliminating the need to manage Personal Access Tokens (PATs).
- **Triage Automation**: Automatically categorize, label, and assign incoming issues based on content analysis.
- **Project Synchronization**: Keep GitHub Project boards (v2) in sync with repository state, moving items through statuses and updating custom fields.
- **Issue Lifecycle Management**: Automate common tasks such as creating, closing, locking, and transferring issues across repositories.
- **Advanced Discovery**: Perform complex searches for issues and pull requests to identify duplicates or related work.

## Standards

All skills in this repository comply with the [Agent Skills Specification](https://agentskills.io/specification), ensuring consistent naming, metadata extraction, and progressive disclosure patterns.

## Agents

This repository includes the following Agents:

<!-- START-AGENTS -->

- **[github-project-manager](agents/github-project-manager.md)**: Technical project manager agent. Use proactively to synchronize repository work with GitHub Project boards.
- **[github-triage-agent](agents/github-triage-agent.md)**: Expert triage agent. Use proactively to categorize, label, and assign new issues.
<!-- END-AGENTS -->

## Agent Skills

This repository includes the following Agent Skills:

<!-- START-SKILLS -->

- **[gh-adding-items-to-projects](skills/gh-adding-items-to-projects/)**: Adds an issue or PR to a GitHub Project. Use to link repository work to a project board.
- **[gh-assigning-issues](skills/gh-assigning-issues/)**: Manages assignees on a GitHub issue. Use to indicate ownership or request review.
- **[gh-closing-issues](skills/gh-closing-issues/)**: Closes a GitHub issue. Use when a task is completed or an issue is resolved.
- **[gh-commenting-on-issues](skills/gh-commenting-on-issues/)**: Adds a comment to a GitHub issue. Use to provide updates, ask questions, or link related work.
- **[gh-creating-issues](skills/gh-creating-issues/)**: Creates a new GitHub issue. Use when a new task, bug, or feature request needs to be tracked.
- **[gh-creating-project-drafts](skills/gh-creating-project-drafts/)**: Creates a draft issue item in a GitHub Project. Use for items that don't yet have a corresponding repository issue.
- **[gh-labeling-issues](skills/gh-labeling-issues/)**: Manages labels on a GitHub issue. Use for triage and categorization.
- **[gh-linking-branches-to-issues](skills/gh-linking-branches-to-issues/)**: Creates and links a development branch to an issue. Use to start implementation work.
- **[gh-listing-issues](skills/gh-listing-issues/)**: Lists GitHub issues with optional filtering. Use when you need to browse open, closed, or specifically labeled issues in a repository.
- **[gh-listing-labels](skills/gh-listing-labels/)**: Lists available labels in a repository. Use to discover valid labels for triage.
- **[gh-listing-milestones](skills/gh-listing-milestones/)**: Lists milestones in a repository. Use to track progress against release goals.
- **[gh-listing-project-fields](skills/gh-listing-project-fields/)**: Lists custom fields in a GitHub Project. Use to discover field IDs like "Status" or "Priority".
- **[gh-listing-projects](skills/gh-listing-projects/)**: Lists GitHub Projects (v2). Use when you need to find project IDs or view available boards.
- **[gh-locking-conversations](skills/gh-locking-conversations/)**: Locks or unlocks an issue conversation. Use to manage noise or conclude discussions.
- **[gh-searching-issues](skills/gh-searching-issues/)**: Performs advanced searches for issues. Use when looking for duplicates or specific keywords across repositories.
- **[gh-setting-milestones](skills/gh-setting-milestones/)**: Associates an issue with a milestone. Use for release planning.
- **[gh-transferring-issues](skills/gh-transferring-issues/)**: Transfers an issue to another repository. Use for cross-project reorganization.
- **[gh-updating-issues](skills/gh-updating-issues/)**: Updates existing GitHub issues (title, body, labels, assignees, milestones, and projects). Use to refine issue details or synchronize with project boards.
- **[gh-updating-project-fields](skills/gh-updating-project-fields/)**: Updates a field value for an item in a GitHub Project. Use to move items between statuses or set custom field data.
- **[gh-viewing-issue-details](skills/gh-viewing-issue-details/)**: Retrieves detailed information about a specific GitHub issue. Use when you need to read the body, comments, or labels of an issue.
- **[gh-viewing-project-items](skills/gh-viewing-project-items/)**: Lists items within a GitHub Project. Use when you need to see which issues or PRs are on a board.
<!-- END-SKILLS -->

## Development

This project uses [uv](https://github.com/astral-sh/uv) for Python dependency management.

### Useful Commands

- `make format`: Format the codebase using `trunk fmt`.
- `make lint`: Check for linting issues using `trunk check`.
- `make validate`: Validate all agent skills under the `skills/` directory.
