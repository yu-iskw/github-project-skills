---
name: gh-set-active-project
description: Sets the active GitHub project and repository context by writing a repo-level config file at .github/project-config.json. Run once per repository to eliminate repeated context verification prompts. All subsequent agent sessions will auto-verify silently against this config.
metadata:
  pattern: tool-wrapper
---

# Setting the Active GitHub Project

## Purpose

This skill performs a **one-time interactive setup** that writes `.github/project-config.json`
to the current repository. Once the config exists, `gh-verifying-context` switches from a
mandatory human-confirmation gate to a **silent auto-verify** mode: it checks the live
environment against the config and only alerts the user when a mismatch is detected.

## 1. When to Use

- **First time** setting up a repository for use with these GitHub agent skills.
- When **switching** to a different GitHub Project (re-run to overwrite the config).
- After changing the repository's GitHub organization or ownership.

## 2. Workflow

### Step 1 – Verify Authentication

Run the following to confirm the authenticated account and repository:

```bash
gh auth status && git remote -v
```

Parse and report:
- `Logged in as`: GitHub username
- `Active Repository`: `<owner>/<repo>` from git remote
- `Remote URL`: origin URL

> Present these values to the user before proceeding. This is the **only** manual
> confirmation step required — it happens once during setup.

### Step 2 – Identify the Repository Owner and Name

```bash
gh repo view --json owner,name --jq '{"owner": .owner.login, "repo": .name}'
```

### Step 3 – List Available GitHub Projects

```bash
gh project list --owner <owner> --json number,title,id,url
```

Present the project list as a numbered table so the user can select the target project.

> GATE: Ask the user: "Which project should be set as active for this repository?"
> DO NOT proceed until a project is selected.

### Step 4 – Write the Config File

Create or overwrite `.github/project-config.json` with the confirmed values:

```json
{
  "owner": "<owner>",
  "repo": "<repo>",
  "project_number": <number>,
  "project_id": "<PVT_...>",
  "set_at": "<ISO-8601 timestamp>"
}
```

Ensure `.github/` directory exists before writing:

```bash
mkdir -p .github
```

### Step 5 – Confirm Success

Report the written config to the user:

```
Active project set successfully:
- Owner:          <owner>
- Repository:     <repo>
- Project:        <title> (#<number>)
- Config written: .github/project-config.json

Future sessions will auto-verify silently. No confirmation prompts unless a mismatch is detected.
```

## 3. Reference

See [references/commands.md](references/commands.md) for the full command reference and config schema.
