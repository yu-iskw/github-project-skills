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
