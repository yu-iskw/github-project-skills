---
name: gh-verifying-context
description: Verifies the current GitHub authentication status and git remote to ensure the agent is operating in the correct account and repository. Use at the start of every session.
metadata:
  pattern: tool-wrapper
---

# Verifying GitHub Context

## Purpose

This skill ensures that the agent is aware of its identity (GitHub user) and location (repository and organization) before performing any actions. This prevents accidental data leakage between personal and work accounts.

## 1. Safety & Verification

- **Mandatory First Step**: This skill MUST be executed at the beginning of every interaction involving GitHub.
- **Human Confirmation**: The agent MUST report the results (User, Organization, Repository) to the user and wait for explicit confirmation that the context is correct.

## 2. Common Workflows

### Workflow: Check Authentication and Remote

Retrieves current login and remote URLs.

**Command**:

```bash
gh auth status && git remote -v
```

## 3. Reference

See [references/commands.md](references/commands.md) for the full command reference, output parsing format, and stop conditions table.
