---
name: gh-verifying-context
description: Verifies the current GitHub authentication status and git remote against the repo-level config at .github/project-config.json. Proceeds silently when the environment matches the config. Alerts only when a mismatch is detected or no config exists. Use at the start of every session.
metadata:
  pattern: tool-wrapper
---

# Verifying GitHub Context

## Purpose

This skill ensures the agent is operating in the correct GitHub account and repository before
performing any actions. It uses a **repo-level config file** (`.github/project-config.json`)
as the baseline — if the live environment matches the config, the skill proceeds silently
without requiring human confirmation. Only mismatches or missing configs surface to the user.

## Behavior by State

| State | Behavior |
| :--- | :--- |
| Config exists + live env matches | **Proceed silently** — no output, no gate |
| Config exists + mismatch detected | **STOP** — alert user with details of the mismatch |
| No config found | **Prompt once** — ask user to run `gh-set-active-project` to create the config |

## 1. Common Workflows

### Workflow A: Auto-Verify (Config Exists)

**Step 1 – Read the config:**

```bash
cat .github/project-config.json
```

Parse `owner`, `repo`, and `project_number` from the file.

**Step 2 – Check live environment:**

```bash
gh auth status && gh repo view --json owner,name
```

**Step 3 – Compare:**

- If `authenticated_user.org` matches `config.owner` AND `repo.name` matches `config.repo` →
  **proceed silently** with the config values available for downstream skills.
- If any field mismatches → **STOP** and execute the Mismatch Alert workflow below.

### Workflow B: Mismatch Alert

When the live environment does not match the config:

1. Report the mismatch in detail:
   ```
   ⚠️  Context mismatch detected — stopping.

   Expected (from .github/project-config.json):
   - Owner:      <config.owner>
   - Repository: <config.repo>

   Actual (live environment):
   - Logged in as: <current_username>
   - Repository:   <current_owner>/<current_repo>

   Resolution options:
   1. Run `gh-set-active-project` to update the config for this repository.
   2. Switch to the correct GitHub account: gh auth switch
   3. Navigate to the correct repository directory.
   ```
2. **Do not proceed** with any GitHub operations.

### Workflow C: No Config Found

When `.github/project-config.json` does not exist:

```
ℹ️  No project config found at .github/project-config.json.

To set up context verification for this repository, run:
  gh-set-active-project

This is a one-time setup. After setup, all sessions auto-verify silently.
```

Do not proceed with GitHub operations until the config is created.

## 2. Output on Silent Pass

When auto-verify succeeds, the skill produces **no output** — downstream skills simply receive
the config values and proceed. This is by design: the absence of a prompt means all is correct.

## 3. Available Config Values for Downstream Skills

After a successful silent pass, the following values are available for use in other skills:

| Field | Source | Used By |
| :--- | :--- | :--- |
| `owner` | config | `gh-issue-management`, `gh-project-management` |
| `repo` | config | `gh-issue-management`, `gh-project-management` |
| `project_number` | config | `gh-project-management` |
| `project_id` | config | `gh-project-management` (item-edit) |

## 4. Reference

See [references/commands.md](references/commands.md) for the full command reference, output
parsing format, and config schema.
