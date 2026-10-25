# Agent instructions

**github-project-skills** is a collection of Agent Skills and subagents for GitHub issue and Project (v2) workflows using the GitHub CLI (`gh`). Overview and installation: `README.md`. Plugin manifest: `.claude-plugin/plugin.json`.

## Layout

- `skills/` — agent skills (each directory has `SKILL.md`).
- `agents/` — subagent definitions (`SKILL.md`).
- `docs/` — `TEST_REPORT.md`, `USE_CASES.md`, and assets.

## Prerequisites

- GitHub CLI (`gh`) with authentication (`README.md`).
- [uv](https://github.com/astral-sh/uv) for the `skills-ref` validator (`pyproject.toml`, `README.md`).

## Build, lint, and validate

Run from the repository root:

- `make format` — `trunk fmt -a` (`Makefile`).
- `make lint` — `trunk check -a -y` (`Makefile`).
- `make validate` — `bash ./scripts/validate_agent_skills.sh` (`Makefile`), which runs `uv run skills-ref validate` on each `skills/**/SKILL.md` (`scripts/validate_agent_skills.sh`).

Pull requests also run Trunk Check (`.github/workflows/trunk_check.yml`) and skill validation on `main`/PRs (`.github/workflows/validate_skills.yml`: `uv python install`, then `uv run bash ./scripts/validate_agent_skills.sh`).

## When documentation and code disagree

When a repository's documentation and its existing code disagree, follow the conventions used in the existing code, and in your final reply point out each inconsistency you found between the documentation and the code.

"Documentation" includes this file, `CLAUDE.md`, editor rules, READMEs, `docs/`, ADRs, RFCs, and code comments. Treat what they say about the code as claims to check against the code, not as facts.

- **Documented target state wins only when it is explicit.** Follow the documentation instead of the code only when the documentation says the code is legacy or a migration is in progress. For example: a "migration in progress", "legacy", or "deprecated" marker, `@deprecated` on the code you would copy, or an ADR/RFC with status _Accepted_ that is not superseded and is newer than the code it replaces. Ignore ADRs/RFCs that are _Proposed_, _Rejected_, _Deprecated_, or _Superseded_. Follow the superseding one.
- **When you can't tell which is current,** compare recency (`git log -1 --format=%cs -- <doc>` vs the code paths). Prefer the newer source, and say that you did. If the choice changes behavior and is still unclear, ask before proceeding.
- **Scope.** Apply the convention you choose to the code you are writing or changing. Don't rewrite working code, and don't edit documentation just to make the two agree, unless the task asks for it.
- **Process and safety rules still apply.** Commands to run, quality gates, review/merge rules, and security constraints in this file are not descriptions of the code. Follow them.
- **Report.** In your final reply (and in the PR description, if you open one), list each inconsistency: the document and section, what the code actually does, which one you followed, and why.
