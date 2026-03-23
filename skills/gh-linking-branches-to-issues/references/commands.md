# gh-linking-branches-to-issues: Command Reference

## Core Command

```bash
gh issue develop <issue-number> --name "branch-name"
```

## Flag Reference

| Flag | Description | Example |
| :--- | :--- | :--- |
| `<issue-number>` | The issue to link the branch to | `42` |
| `--name` | The branch name to create | `"feature/add-login"` |
| `--base` | Base branch to branch from (default: repo default branch) | `--base main` |
| `--checkout` | Checkout the newly created branch immediately | `--checkout` |
| `--repo` | Target repository if not the current directory | `--repo owner/repo` |

## Naming Conventions

Use descriptive, lowercase branch names following the pattern `<type>/<brief-description>`:

- `feature/` — new functionality
- `fix/` — bug fix
- `chore/` — maintenance or tooling
- `docs/` — documentation only

Example: `gh issue develop 42 --name "feature/add-login-flow"`

## Verification

After creation, confirm the branch is linked by visiting the issue on GitHub or running:

```bash
gh issue view <issue-number> --json developmentBranches
```
