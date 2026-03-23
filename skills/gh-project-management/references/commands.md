# gh-project-management: Command Reference

## Action Reference Table

| Action             | CLI Command                      | Key Flags / Notes                                                         |
| :----------------- | :------------------------------- | :------------------------------------------------------------------------ |
| **List Projects**  | `gh project list`                | `--owner` (required), `--json`                                            |
| **List Items**     | `gh project item-list`           | `<number>`, `--owner`, `--json`                                           |
| **Add Item**       | `gh project item-add`            | `<number>`, `--owner`, `--url` (issue/PR)                                 |
| **Edit Item**      | `gh project item-edit`           | `--id` (item), `--field-id`, `--text/number/date/single-select-option-id` |
| **List Fields**    | `gh project field-list`          | `<number>`, `--owner`, `--json`                                           |
| **Create Draft**   | `gh project item-create`         | `<number>`, `--owner`, `--title`, `--body`                                |
| **Archive/Delete** | `gh project item-archive/delete` | `--id` (item), `--project-id`                                             |

## ID Types

Two distinct ID types are used and must not be confused:

| ID Type | Format | Used In |
| :--- | :--- | :--- |
| **Project Number** | Integer (e.g., `2`) | `item-list`, `item-add`, `field-list`, `item-create` |
| **Item ID** | `PVTI_...` (string) | `item-edit`, `item-archive`, `item-delete` |
| **Project ID** | `PVT_...` (string) | `item-edit` `--project-id` flag |
| **Field ID** | `PVTF_...` (string) | `item-edit` `--field-id` flag |

Always use `gh project item-list` and `gh project field-list` with `--json` to capture the correct IDs before running edit operations.

## State-Changing Commands (Require User Approval)

| Command | Effect |
| :--- | :--- |
| `gh project item-add` | Adds issue or PR to project board |
| `gh project item-edit` | Updates a field value on a project item |
| `gh project item-create` | Creates a draft item in the project |
| `gh project item-archive` | Removes item from active view |
| `gh project item-delete` | Permanently deletes a project item |
