---
name: gh-wiki-management
description: Clones, reads, and publishes GitHub Wiki pages using gh for auth and repo metadata plus git for the Wiki repository. Use to fetch the Wiki, detect the default branch, commit low-risk changes directly, or merge a local transaction branch, never force-pushing.
compatibility: Requires gh (GitHub CLI) and git.
metadata:
  pattern: tool-wrapper
---

# GitHub Wiki Management

## Purpose

GitHub has no Wiki write REST API. Authenticate with `gh`, then clone and push `OWNER/REPO.wiki.git`. Non-default Wiki branches are not rendered and have no pull requests — transactional publishes stay local, then merge into the default branch and push that branch only.

## 1. Safety & Verification

- **Repository identity**: `{owner}` / `{repo}` from `gh repo view` (`.owner.login`), not the authenticated username.
- **Human-in-the-Loop**: Present the exact `git commit` / `git push` commands before execution.
- **Never force-push** the Wiki default branch.
- **Empty / disabled Wiki**: Preflight `has_wiki` and `git ls-remote`. If either fails, stop publish. Do not force-push to bootstrap. Create the first page in the GitHub Wiki UI, then retry.
- **Concurrency**: Fetch and compare remote HEAD to the SHA captured at clone time. If it moved, abort and revalidate. Do not force.

## 2. Common Workflows

### Workflow: Confirm Wiki and Clone

```bash
owner="$(gh repo view --json owner --jq .owner.login)"
repo="$(gh repo view --json name --jq .name)"
has_wiki="$(gh api "repos/${owner}/${repo}" --jq .has_wiki)"
test "${has_wiki}" = "true"
git ls-remote "https://github.com/${owner}/${repo}.wiki.git" HEAD >/dev/null
gh auth setup-git
git clone "https://github.com/${owner}/${repo}.wiki.git" wiki-work
```

If `has_wiki` is `false` or `ls-remote`/`clone` returns repository-not-found (exit 128), stop with bootstrap instructions. Local verification without a live Wiki uses [scripts/test-wiki-local.sh](scripts/test-wiki-local.sh).

### Workflow: Detect Default Branch

Do not assume `main`. Wikis often use `master`.

```bash
git -C wiki-work remote show origin | sed -n '/HEAD branch/s/.*: //p'
# fallback
git -C wiki-work rev-parse --abbrev-ref HEAD
```

Capture `EXPECTED_SHA="$(git -C wiki-work rev-parse HEAD)"` before edits.

### Workflow: Direct Validated Publish

For low-risk mutations only (see `gh-knowledge-maintain` publication policy):

```bash
git -C wiki-work fetch origin
remote_sha="$(git -C wiki-work rev-parse "origin/${DEFAULT_BRANCH}")"
test "${remote_sha}" = "${EXPECTED_SHA}"
git -C wiki-work add -A
git -C wiki-work diff --cached --quiet && echo "no-op" && exit 0
git -C wiki-work commit -m "docs(wiki): knowledge maintenance"
git -C wiki-work push origin "${DEFAULT_BRANCH}"
```

Never `git push --force`.

### Workflow: Transactional Local Branch

For complex/high-impact mutations:

```bash
git -C wiki-work fetch origin
remote_sha="$(git -C wiki-work rev-parse "origin/${DEFAULT_BRANCH}")"
test "${remote_sha}" = "${EXPECTED_SHA}"
git -C wiki-work checkout -b knowledge-maintenance
git -C wiki-work add -A
git -C wiki-work commit -m "docs(wiki): candidate knowledge mutation"
git -C wiki-work checkout "${DEFAULT_BRANCH}"
git -C wiki-work merge --no-ff knowledge-maintenance -m "docs(wiki): validated wiki update"
git -C wiki-work push origin "${DEFAULT_BRANCH}"
git -C wiki-work branch -D knowledge-maintenance
```

Push **only** the default branch. Do not open a GitHub PR against the Wiki remote.

## 3. Page Naming

GitHub Wiki URLs are a flat namespace. Use unique prefixed files such as `Architecture-Overview.md`, plus links from `Home.md`. Put the checkpoint under `.knowledge/`, not in a page.

## 4. Reference

See [references/commands.md](references/commands.md) for clone URLs, race handling, and commands that require approval.
