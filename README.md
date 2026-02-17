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
- **Balanced Granularity**: Skills are consolidated into high-level "Managers" (Issues, Projects) to reduce token consumption and latency while maintaining modularity.

## Use Cases

Learn how to leverage this repository for common GitHub workflows:

- **[Automated Issue Triage](docs/USE_CASES.md#1-automated-issue-triage)**: Categorize and assign incoming issues automatically.
- **[Project Board Sync](docs/USE_CASES.md#2-project-board-synchronization)**: Keep your Project v2 boards in sync with repository state.
- **[Sprint Planning](docs/USE_CASES.md#3-sprintrelease-planning)**: Organize work into milestones and target versions.
- **[Repo Reorganization](docs/USE_CASES.md#4-repository-reorganization)**: Smoothly transfer issues between repositories.

## Standards

All skills in this repository comply with the [Agent Skills Specification](https://agentskills.io/specification), ensuring consistent naming, metadata extraction, and progressive disclosure patterns.

## Agents

<!-- START-AGENTS -->

- **[github-project-manager](agents/github-project-manager/SKILL.md)**: Technical project manager agent. Use proactively to synchronize repository work with GitHub Project boards.
- **[github-triage-agent](agents/github-triage-agent/SKILL.md)**: Expert triage agent. Use proactively to categorize, label, and assign new issues.
<!-- END-AGENTS -->

## Agent Skills

<!-- START-SKILLS -->

- **[gh-issue-management](skills/gh-issue-management/)**: Comprehensive management of GitHub issues. Use to create, update, close, list, search, view, and comment on issues in a single skill.
- **[gh-project-management](skills/gh-project-management/)**: Comprehensive management of GitHub Projects (v2). Use to list projects, view items, add items, update fields, and manage project structure in a single skill.
- **[gh-managing-sub-issues](skills/gh-managing-sub-issues/)**: Manages GitHub sub-issues (parent-child relationships) using the GitHub REST API. Use when you need to list, add, remove, or reprioritize sub-issues for a parent issue.
- **[gh-verifying-context](skills/gh-verifying-context/)**: Verifies the current GitHub authentication status and git remote to ensure the agent is operating in the correct account and repository.
- **[gh-linking-branches-to-issues](skills/gh-linking-branches-to-issues/)**: Creates and links a development branch to an issue. Use to start implementation work.
<!-- END-SKILLS -->

## Synchronization

You can synchronize the skills and agents in this repository with your local AI agents (like Cursor, Claude Code, or Gemini CLI) using the provided synchronization tool. This tool wraps the `[skills](https://npmjs.org/package/skills)` npm package.

### Quick Start

To install all skills and agents from this repository to your local agents:

```bash
make sync
```

To install them globally (available across all projects):

```bash
make sync-global
```

### Advanced Usage

You can use the `scripts/sync.sh` script directly for more control:

```bash
# Install to specific agents
./scripts/sync.sh install --agent cursor --agent claude-code

# Reinstall (remove and then install)
./scripts/sync.sh reinstall --agent cursor

# Install skills from an external GitHub repository
./scripts/sync.sh install vercel-labs/agent-skills
```

## Development

This project uses [uv](https://github.com/astral-sh/uv) for Python dependency management.

### Useful Commands

- `make format`: Format the codebase using `trunk fmt`.
- `make lint`: Check for linting issues using `trunk check`.
- `make validate`: Validate all agent skills under the `skills/` and `agents/` directories.
- `make sync`: Synchronize local skills with target agents.
- `make sync-global`: Synchronize local skills globally.
- `make update-skills`: Update all installed skills.
- `make uninstall-skills`: Remove installed skills.
