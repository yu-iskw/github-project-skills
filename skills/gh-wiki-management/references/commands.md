# gh-wiki-management: Command Reference

## gh Commands

| Action         | CLI Command                                  | Key Flags / Notes                         |
| :------------- | :------------------------------------------- | :---------------------------------------- |
| **Owner/repo** | `gh repo view --json owner,name`             | `--jq` for `.owner.login` and `.name`     |
| **Wiki flag**  | `gh api repos/{owner}/{repo} --jq .has_wiki` | `false` means stop                        |
| **Git auth**   | `gh auth setup-git`                          | HTTPS git uses the `gh` credential helper |
| **Auth check** | `gh auth status`                             | Must succeed before clone/push            |

## Wiki Git Commands

| Action                | CLI Command                                            | Notes                                                     |
| :-------------------- | :----------------------------------------------------- | :-------------------------------------------------------- |
| **Clone**             | `git clone https://github.com/{owner}/{repo}.wiki.git` | Separate repo from the code remote                        |
| **Default branch**    | `git remote show origin`                               | Often `master`, not `main`                                |
| **Fetch**             | `git fetch origin`                                     | Before every publish                                      |
| **Compare HEAD**      | `git rev-parse HEAD` vs `origin/{default}`             | Abort on mismatch                                         |
| **Commit**            | `git add -A && git commit`                             | Skip commit when `git diff --cached --quiet` (idempotent) |
| **Push default**      | `git push origin {default}`                            | Never `--force`                                           |
| **Local transaction** | `checkout -b` then `merge --no-ff`                     | Wiki PRs are not supported                                |

## Clone URLs

- HTTPS: `https://github.com/{owner}/{repo}.wiki.git`
- SSH: `git@github.com:{owner}/{repo}.wiki.git`

## State-Changing Commands (Require User Approval)

| Command                                  | Effect                                |
| :--------------------------------------- | :------------------------------------ |
| `git commit` in the Wiki clone           | Records a candidate Wiki state        |
| `git merge` into the Wiki default branch | Makes the candidate canonical locally |
| `git push origin {default}`              | Publishes the live Wiki               |

## Failure Behavior

| Failure                      | Required behavior                        |
| :--------------------------- | :--------------------------------------- |
| `gh` / clone / fetch failure | Abort; checkpoint unchanged              |
| Remote HEAD != expected SHA  | Abort; do not force-push                 |
| Validation failure           | Do not commit or push the default branch |
| No file changes              | No commit (idempotent)                   |
