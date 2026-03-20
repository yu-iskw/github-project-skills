# gh-verifying-context: Command Reference

## Verification Commands

### Primary Verification (Run Together)

```bash
gh auth status && git remote -v
```

### Individual Commands

| Command | Purpose | Key Output |
| :--- | :--- | :--- |
| `gh auth status` | Reports currently authenticated GitHub account | `Logged in to github.com as <username>` |
| `git remote -v` | Lists configured git remotes and their URLs | `origin <url>` (fetch/push) |
| `gh repo view --json owner,name` | Confirms repository owner and name in JSON form | `{"owner": ..., "name": ...}` |

## Parsing the Output

After running verification, report to the user in this format:

```
- Logged in as: <username>
- Active Repository: <owner>/<repo>
- Remote URL: <origin-url>
```

## Stop Conditions

Immediately STOP and alert the user if ANY of the following are true:

| Condition | Risk |
| :--- | :--- |
| Username belongs to work account but task is personal | Data leakage risk |
| Username belongs to personal account but task is work-related | Wrong identity |
| Repository owner does not match expected organization | Wrong repository |
| No remotes configured | Cannot push; may be wrong directory |
