# gh-issue-management: Command Reference

## Action Reference Table

| Action           | CLI Command             | Key Flags / Notes                                                                 |
| :--------------- | :---------------------- | :-------------------------------------------------------------------------------- |
| **Create**       | `gh issue create`       | `--title`, `--body`, `--label`, `--assignee`, `--project`                         |
| **Update**       | `gh issue edit`         | `--add-label`, `--remove-label`, `--add-assignee`, `--milestone`, `--add-project` |
| **List**         | `gh issue list`         | `--state`, `--label`, `--assignee`, `--limit`, `--json`                           |
| **Search**       | `gh search issues`      | `QUERY`, `--state`, `--label`, `--no-project`, `--json`                           |
| **View**         | `gh issue view`         | `<number>`, `--json`, `--web`                                                     |
| **Comment**      | `gh issue comment`      | `--body`, `--edit-last`                                                           |
| **Close/Reopen** | `gh issue close/reopen` | `--reason` (completed, not planned)                                               |
| **Labels**       | `gh label list`         | Discover valid labels: `--json name,description`                                  |
| **Milestones**   | `gh api .../milestones` | Discover milestones: `--jq '.[] \| {number, title, state}'`                       |
| **Transfer**     | `gh issue transfer`     | `<destination-repo>`                                                              |
| **Lock/Unlock**  | `gh issue lock/unlock`  | `--reason` (off-topic, too heated, resolved, spam)                                |

## State-Changing Commands (Require User Approval)

The following commands modify GitHub state and MUST be presented to the user before execution:

| Command | Effect |
| :--- | :--- |
| `gh issue create` | Creates a new issue |
| `gh issue edit` | Modifies issue metadata |
| `gh issue comment` | Posts a public comment |
| `gh issue close` | Changes issue lifecycle state |
| `gh issue transfer` | Moves issue to another repository |
| `gh issue lock` | Restricts commenting on an issue |
| `gh api POST .../sub_issues` | Links an issue as a sub-issue |
| `gh api DELETE .../sub_issue` | Removes a sub-issue link |
| `gh api PATCH .../sub_issues/priority` | Reorders a sub-issue |

## Sub-issues API Reference

Sub-issue operations use `gh api` (GitHub REST API) because sub-issues are not yet first-class flags in `gh issue` commands.

### Endpoint Reference Table

| Operation        | Method   | Endpoint                                                           | Body Fields                                |
| :--------------- | :------- | :----------------------------------------------------------------- | :----------------------------------------- |
| **List**         | `GET`    | `/repos/{owner}/{repo}/issues/{issue_number}/sub_issues`           | None                                       |
| **Add**          | `POST`   | `/repos/{owner}/{repo}/issues/{parent_number}/sub_issues`          | `sub_issue_id` (integer database ID)       |
| **Remove**       | `DELETE` | `/repos/{owner}/{repo}/issues/{parent_number}/sub_issue`           | `sub_issue_id` (integer database ID)       |
| **Reprioritize** | `PATCH`  | `/repos/{owner}/{repo}/issues/{parent_number}/sub_issues/priority` | `sub_issue_id` + `after_id` or `before_id` |

### Important: Issue Number vs. Database ID

- **Issue Number**: The human-readable integer shown in the GitHub UI (e.g., `#42`). Used in endpoint paths.
- **Database ID**: An internal integer (e.g., `1234567`). Required in the request body for `sub_issue_id`, `after_id`, `before_id`.

Retrieve the database ID with:

```bash
gh issue view <issue-number> --json id --jq '.id'
```

### Limits

- Maximum sub-issues per parent: **100**
- Maximum nesting depth: **8 levels**

### Error Reference

| HTTP Status | Meaning | Action |
| :--- | :--- | :--- |
| `404` | Issue not found or wrong ID type used | Verify you are using `id` (database), not `number` |
| `422` | Validation error | Check field names and value types |
| `403` | Insufficient permissions | Ensure token has `write` access to the repository |
