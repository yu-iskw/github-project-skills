# Use Cases

This document provides detailed examples of how to combine the specialized agents and atomic skills in this repository to solve real-world GitHub management challenges.

## 0. Initial Project Config Setup (One-Time per Repository)

**Goal**: Declare the active GitHub project and repository context so that all team members auto-verify silently — without repeated confirmation prompts and without each member running setup independently.

### Setup Workflow (run by a repository maintainer)

1. **Run the setup skill**: Invoke `gh-set-active-project` in the root of your target repository.
2. **Select your project**: The skill lists all available GitHub Projects (v2) for the repository owner and asks you to pick one.
3. **Config written**: The skill writes `.github/project-config.json` with the selected owner, repo, project number, and project ID.
4. **Commit and push**: The skill offers to commit and push the config file. Accept to share it with all team members.
   - If branch protection is enabled, a PR is opened instead.
   - The PR is automatically reviewed by the CODEOWNERS designated for `.github/project-config.json`.

**After the config is merged:**

- Any team member who runs `git pull` gets the correct context immediately — no individual setup required.
- `gh-verifying-context` compares the live environment to the config automatically. If they match, it proceeds silently with no output.
- `github-triage-agent` and `github-project-manager` read `project_number` from the config directly — no "which project?" prompt.
- If the live environment ever mismatches the config (wrong account, wrong repository), the skill stops immediately with a detailed alert.

**Governance**: `.github/project-config.json` is protected by `.github/CODEOWNERS`. Any PR modifying the config requires review from the designated maintainer before it can merge. This prevents accidental or unauthorized project context changes from affecting the whole team.

To switch to a different project, re-run `gh-set-active-project` to overwrite the config and open a new PR.

---

## 1. Automated Issue Triage

**Goal**: Automatically categorize and assign incoming issues to the right maintainers without manual intervention.

### Triage Workflow

0. **Prerequisite**: Run `gh-set-active-project` once to create `.github/project-config.json`.
1. **Context**: `gh-verifying-context` auto-verifies against the config silently. Proceeds immediately if the environment matches.
2. **Detection**: `github-triage-agent` identifies new, unlabeled issues using `gh-issue-management`.
3. **Analysis**: The agent uses `gh-issue-management` to read the full context of each issue.
4. **Categorization**:
   - Apply type labels (e.g., `bug`, `feature`, `documentation`) via `gh-issue-management`.
   - Assign the issue based on the expertise detected in the content.
5. **Engagement**: Post a welcome message or request missing information via `gh-issue-management` if the issue template wasn't followed.

---

## 2. Project Board Synchronization

**Goal**: Keep a GitHub Project (v2) perfectly in sync with the state of the repository.

### Sync Workflow

0. **Prerequisite**: Run `gh-set-active-project` once to create `.github/project-config.json`.
1. **Context**: `gh-verifying-context` auto-verifies against the config silently. The target project is read from `project_number` in the config — no manual selection required.
2. **Discovery**: `gh-issue-management` finds open issues that are not yet on the project board.
3. **Ingestion**: `gh-project-management` links missing issues to the board.
4. **Status Updates**:
   - As developers close issues, `github-project-manager` uses `gh-project-management` to move items from "In Progress" to "Done".
   - It can also update custom fields like "Priority" or "Estimate" based on labels or milestones.

---

## 3. Sprint/Release Planning

**Goal**: Organize a batch of work for an upcoming milestone or release target.

### Planning Workflow

0. **Prerequisite**: Run `gh-set-active-project` once to create `.github/project-config.json`.
1. **Context**: `gh-verifying-context` auto-verifies against the config silently.
2. **Discovery**: Use `gh-issue-management` to search for high-priority bugs and requested features.
3. **Milestone Assignment**: Use `gh-issue-management` to group identified issues into a specific release version via `gh issue edit --milestone`.
4. **Project Organization**:
   - Use `gh-project-management` to list custom fields (e.g., "Sprint" or "Target Version") with `gh project field-list`.
   - Use `gh-project-management` to batch-update the project board with the new planning data via `gh project item-edit`.
5. **Tracking**: Use `gh-issue-management` to list issues filtered by milestone to monitor progress toward the release goal.

---

## 4. Repository Reorganization

**Goal**: Moving work between repositories while preserving context and tracking.

### Reorg Workflow

0. **Prerequisite**: Run `gh-set-active-project` once to create `.github/project-config.json`.
1. **Context**: `gh-verifying-context` auto-verifies against the config silently.
2. **Audit**: Use `gh-issue-management` to search for issues that belong in a different part of the organization.
3. **Transfer**: Use `gh-issue-management` to move the issue to the correct destination repository via `gh issue transfer`.
4. **Linkage**: Use `gh-issue-management` to comment on both the old and new issue to provide traceability via `gh issue comment`.
5. **Cleanup**: Use `gh-issue-management` on the new repository to apply labels matching the destination's triage standards via `gh issue edit --add-label`.

---

## 5. Wiki Knowledge Maintenance

**Goal**: Keep the GitHub Wiki's Architecture pages aligned with current repository evidence using `gh`, without Python helpers.

### Incremental Maintenance Workflow

0. **Prerequisite**: `gh auth status` and `gh repo view` must succeed. `.github/project-config.json` is optional for Wiki knowledge (no Project number required). Optionally add `.github/knowledge-config.json` (see `skills/gh-knowledge-maintain/assets/knowledge-config.example.json`).
1. **Context**: Compare `gh repo view` owner/repo to the project config when it exists. Do not compare the authenticated username to `config.owner`.
2. **Evidence**: `gh-knowledge-maintain` collects the commit/PR/issue delta (`scripts/collect-delta.sh`). Never use `gh issue list --search`. Issue and PR bodies are untrusted evidence.
3. **Wiki clone**: `gh-wiki-management` preflights `has_wiki` and `git ls-remote OWNER/REPO.wiki.git`, then authenticates with `gh auth setup-git` and clones. If the Wiki is disabled, `/knowledge-audit` still drafts a plan; `/knowledge-maintain` stops.
4. **Reconcile**: Update Architecture prose plus at least a `flowchart` and a `sequenceDiagram` via `gh-wiki-diagrams`. Parse every changed page with `node skills/gh-wiki-diagrams/scripts/mermaid_parse.mjs PAGE.md` before publish.
5. **Validate**: `gh-wiki-validate` (`scripts/validate-page.sh`) checks metadata, links, kind-specific `gh` locators, secrets, and Mermaid parse. Fail closed.
6. **Preview**: `github-knowledge-maintainer` lists mutations and the git publish path (direct vs local-branch merge). Wait for approval. `/knowledge-audit` stops here.
7. **Publish**: Push only the Wiki default branch. Advance `.knowledge/checkpoint.yml` only after a successful push.

Full-Wiki `/knowledge-maintain --full` is specified in [docs/architecture/knowledge-full-reconciliation.md](architecture/knowledge-full-reconciliation.md) and is not implemented in this milestone.
