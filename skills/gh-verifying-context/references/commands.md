# gh-verifying-context: Command Reference

## Verification Commands

### Step 1 – Read Repo Config

```bash
cat .github/project-config.json
```

**Expected output** (parsed as JSON):
```json
{
  "owner": "yu-iskw",
  "repo": "my-repo",
  "project_number": 2,
  "project_id": "PVT_kgDO...",
  "set_at": "2026-03-23T10:00:00Z"
}
```

If the file does not exist, prompt the user to run `gh-set-active-project`.

### Step 2 – Check Live Environment

```bash
gh auth status && gh repo view --json owner,name
```

| Command | Key Output |
| :--- | :--- |
| `gh auth status` | `Logged in to github.com as <username>` |
| `gh repo view --json owner,name` | `{"owner": {"login": "<owner>"}, "name": "<repo>"}` |

### Step 3 – Compare Config vs Live

| Config Field | Live Source | Match Check |
| :--- | :--- | :--- |
| `owner` | `gh repo view` → `owner.login` | Must be equal |
| `repo` | `gh repo view` → `name` | Must be equal |

If all fields match → proceed silently.
If any field mismatches → STOP and report.

## Config File Schema

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `owner` | string | Yes | GitHub org or user owning the repository |
| `repo` | string | Yes | Repository name |
| `project_number` | integer | Yes | Project number used in `gh project` commands |
| `project_id` | string | No | Project node ID for GraphQL operations |
| `set_at` | string | No | ISO-8601 timestamp of last config write |

## Stop Conditions

| Condition | Action |
| :--- | :--- |
| `owner` in config ≠ `owner.login` from `gh repo view` | STOP — wrong repository owner |
| `repo` in config ≠ `name` from `gh repo view` | STOP — wrong repository |
| `.github/project-config.json` not found | Prompt to run `gh-set-active-project` |
| `gh auth status` fails | STOP — not authenticated; run `gh auth login` |

## Fallback (No Config — Legacy Behavior)

If no config file exists and the user cannot run `gh-set-active-project`, fall back to the
manual verification flow and report the result in this format:

```
- Logged in as: <username>
- Active Repository: <owner>/<repo>
- Remote URL: <origin-url>
```

Request explicit user confirmation before proceeding with any GitHub operations.
