# gh-set-active-project: Command Reference

## Setup Commands

### 1. Authenticate and Get Remote

```bash
gh auth status && git remote -v
```

| Output Field | Purpose |
| :--- | :--- |
| `Logged in to github.com as <username>` | Confirms authenticated account |
| `origin <url>` | Derives `<owner>/<repo>` |

### 2. Get Repository Owner and Name

```bash
gh repo view --json owner,name --jq '{"owner": .owner.login, "repo": .name}'
```

**Output:**
```json
{"owner": "yu-iskw", "repo": "my-repo"}
```

### 3. List Available Projects

```bash
gh project list --owner <owner> --json number,title,id,url
```

**Output (example):**
```json
[
  {"number": 2, "title": "My Board", "id": "PVT_kgDO...", "url": "https://github.com/..."}
]
```

### 4. Write Config File

After the user selects a project, write `.github/project-config.json`:

```bash
mkdir -p .github
cat > .github/project-config.json << 'EOF'
{
  "owner": "<owner>",
  "repo": "<repo>",
  "project_number": <number>,
  "project_id": "<PVT_...>",
  "set_at": "<ISO-8601 timestamp>"
}
EOF
```

## Config File Schema

| Field | Type | Description |
| :--- | :--- | :--- |
| `owner` | string | GitHub organization or user owning the repository |
| `repo` | string | Repository name (without owner prefix) |
| `project_number` | integer | GitHub Project (v2) number used in `gh project` commands |
| `project_id` | string | Project node ID (e.g., `PVT_kgDO...`) used in GraphQL/item-edit |
| `set_at` | string | ISO-8601 timestamp of when the config was last written |

## Example Config

```json
{
  "owner": "yu-iskw",
  "repo": "github-project-skills",
  "project_number": 2,
  "project_id": "PVT_kgDOABCDEF",
  "set_at": "2026-03-23T10:00:00Z"
}
```

## Team Sharing Commands

After writing the config, commit and push to share with all team members.

### Simple push (no branch protection):

```bash
git add .github/project-config.json
git commit -m "chore: set active GitHub project to <title> (#<number>)"
git push
```

### Via Pull Request (branch protection enabled):

```bash
git checkout -b chore/set-active-project
git add .github/project-config.json
git commit -m "chore: set active GitHub project to <title> (#<number>)"
git push -u origin chore/set-active-project
gh pr create \
  --title "chore: set active GitHub project" \
  --body "Sets .github/project-config.json so all team members auto-verify silently against the correct project context."
```

## CODEOWNERS Governance

To require maintainer approval on all config changes, add this line to `.github/CODEOWNERS`:

```
# Requires designated maintainer review for any project config changes
.github/project-config.json  @<owner-or-team>
```

This ensures:
- Any PR modifying `.github/project-config.json` automatically requests review from the listed owner/team
- The config cannot be merged without explicit approval
- GitHub enforces this rule when branch protection is set to "Require review from Code Owners"
