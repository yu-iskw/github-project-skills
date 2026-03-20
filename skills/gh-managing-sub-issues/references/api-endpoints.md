# gh-managing-sub-issues: API Endpoint Reference

## Sub-Issues REST API

All sub-issue operations use the GitHub REST API via `gh api`. This is because sub-issues are not yet first-class flags in the `gh issue` commands.

## Endpoint Reference Table

| Operation        | Method   | Endpoint                                                              | Body Fields                                      |
| :--------------- | :------- | :-------------------------------------------------------------------- | :----------------------------------------------- |
| **List**         | `GET`    | `/repos/{owner}/{repo}/issues/{issue_number}/sub_issues`              | None                                             |
| **Add**          | `POST`   | `/repos/{owner}/{repo}/issues/{parent_number}/sub_issues`             | `sub_issue_id` (integer database ID)             |
| **Remove**       | `DELETE` | `/repos/{owner}/{repo}/issues/{parent_number}/sub_issue`              | `sub_issue_id` (integer database ID)             |
| **Reprioritize** | `PATCH`  | `/repos/{owner}/{repo}/issues/{parent_number}/sub_issues/priority`    | `sub_issue_id` + `after_id` or `before_id`       |

## Important: Issue Number vs. Database ID

- **Issue Number**: The human-readable integer shown in the GitHub UI (e.g., `#42`). Used in endpoint paths.
- **Database ID**: An internal integer (e.g., `1234567`). Required in the request body for `sub_issue_id`, `after_id`, `before_id`.

Retrieve the database ID with:

```bash
gh issue view <issue-number> --json id --jq '.id'
```

## Limits

- Maximum sub-issues per parent: **100**
- Maximum nesting depth: **8 levels**

## Error Reference

| HTTP Status | Meaning | Action |
| :--- | :--- | :--- |
| `404` | Issue not found or wrong ID type used | Verify you are using `id` (database), not `number` |
| `422` | Validation error | Check field names and value types |
| `403` | Insufficient permissions | Ensure token has `write` access to the repository |
