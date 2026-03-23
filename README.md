# GitHub Project Management Agent Skills

## Overview

This repository is a collection of specialized **Agent Skills** and **Subagents** designed to automate and streamline GitHub workflows by leveraging the **GitHub CLI (`gh`)**. These skills empower AI agents (like Cursor, Claude Code, or Gemini CLI) to interact deeply with GitHub issues, milestones, labels, and project boards, enabling autonomous project management and triage.

<video src="docs/assets/test-skills.mp4" controls="controls" style="max-width: 100%;">
  Your browser does not support the video tag.
</video>

## Key Features

- **Zero-Config Authentication**: Leverages the GitHub CLI (`gh` command) for authentication, eliminating the need to manage Personal Access Tokens (PATs).
- **Repo-Level Project Config**: A single `.github/project-config.json` file declares the active GitHub project and repository context. After one-time setup, all agent sessions auto-verify silently — no repeated confirmation prompts.
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

- **[gh-set-active-project](skills/gh-set-active-project/)**: One-time interactive setup that writes `.github/project-config.json` to declare the active GitHub project and repository. Run once per repository to enable silent auto-verification for all subsequent sessions.
- **[gh-issue-management](skills/gh-issue-management/)**: Comprehensive management of GitHub issues, including sub-issue hierarchies. Use to create, update, close, list, search, view, comment on, and manage parent-child relationships between issues in a single skill.
- **[gh-project-management](skills/gh-project-management/)**: Comprehensive management of GitHub Projects (v2). Use to list projects, view items, add items, update fields, and manage project structure in a single skill.
- **[gh-verifying-context](skills/gh-verifying-context/)**: Verifies the current GitHub authentication status and repository against `.github/project-config.json`. Proceeds silently when the environment matches the config; alerts only on mismatch or missing config.
- **[gh-linking-branches-to-issues](skills/gh-linking-branches-to-issues/)**: Creates and links a development branch to an issue. Use to start implementation work.
<!-- END-SKILLS -->

## Installation

### Claude Code Plugin (Recommended)

This repository is available as a **Claude Code plugin**. Install it directly from the built-in custom marketplace:

```shell
# 1. Add this repository as a custom marketplace
/plugin marketplace add yu-iskw/github-project-skills

# 2. Install the plugin
/plugin install github-project-skills@github-project-skills

# 3. Activate (reload plugins)
/reload-plugins
```

This installs all 5 agent skills and 2 subagents into Claude Code automatically.

### Project Config Setup (One-Time per Repository)

After installing the plugin, run the following once in each repository you want to manage:

```
gh-set-active-project
```

This interactive skill queries your available GitHub Projects, lets you select the target, and
writes `.github/project-config.json`. After setup:

- `gh-verifying-context` auto-verifies silently on every session — no confirmation prompts.
- All agents (`github-triage-agent`, `github-project-manager`) read the project number directly
  from the config, eliminating repeated "which project?" questions.

To switch to a different project, simply re-run `gh-set-active-project`.

### Local Development Install

To load the plugin from a local clone during development:

```shell
claude --plugin-dir /path/to/github-project-skills
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
