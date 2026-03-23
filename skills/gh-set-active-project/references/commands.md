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
