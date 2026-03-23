# Best Practices for Implementation

When creating a new Agent Skill, adhere to the following standards from the official [Agent Skills specification](https://agentskills.io/specification):

## Directory & Naming

- **Structure**: Each skill must be in its own directory: `skills/<skill-name>/`.
- **File**: The main file must be named `SKILL.md`.
- **Naming Convention**:
  - Use **unicode lowercase alphanumeric characters and hyphens** (`a-z`, `0-9`, and `-`).
  - Must match the parent directory name exactly.
  - Length: 1-64 characters.
  - Must not start or end with a hyphen.
  - Must not contain consecutive hyphens (`--`).
  - **Gerund form** (verb + -ing) is recommended: e.g. `processing-pdfs`, `analyzing-spreadsheets`, `implementing-agent-skills`. Noun phrases like `pdf-processing` are also acceptable. Avoid vague names (`helper`, `utils`, `tools`) and reserved words (`anthropic`, `claude`).
  - Example: `processing-pdfs` (Good), `PDF_Helper` (Bad), `pdf--processing` (Bad).

## Frontmatter & Metadata

Every `SKILL.md` must start with YAML frontmatter containing required and optional fields.

```yaml
---
name: skill-name
description: Brief summary of what this skill does and when to use it.
license: Apache-2.0 (Optional)
compatibility: Requires git, docker, jq (Optional, max 500 chars)
metadata: (Optional)
  author: example-org
  version: "1.0"
allowed-tools: Bash(git:*) Read (Optional, space-delimited list)
---
```

### Required Fields

- **name**: Must match the directory name and follow naming conventions.
- **description**: 1-1024 characters. **Always write in third person** (e.g. "Processes Excel files and generates reports"). Avoid "I can help..." or "You can use...". Describe both **what** the skill does and **when** to use it; include specific keywords for agent discovery.

### Optional Fields

- **license**: License name or reference to a bundled license file.
- **compatibility**: Environment requirements (e.g., specific OS, tools, or internet access).
- **metadata**: Arbitrary key-value mapping for custom properties.
- **allowed-tools**: Space-delimited list of pre-approved tools.

## Standard Directory Structure

Organize additional resources into these optional subdirectories:

- `scripts/`: Contains executable code (Python, Bash, JS). Scripts should be self-contained and handle errors gracefully.
- `references/`: Detailed technical documentation, templates, or domain-specific data.
- `assets/`: Static resources like configuration templates, images, or lookup tables.

## Progressive Disclosure

Structure the skill for efficient context usage:

1.  **Metadata** (~100 tokens): `name` and `description` (loaded at startup).
2.  **Instructions** (< 5000 tokens recommended): The full `SKILL.md` body (loaded when activated).
3.  **Resources** (as needed): External files in `scripts/`, `references/`, or `assets/` (loaded only when required).

## File References

- **Paths**: Use relative paths from the skill root (e.g., `[details](references/DETAIL.md)`). Use forward slashes only, even on Windows.
- **Depth**: Keep file references one level deep from `SKILL.md`. Avoid deeply nested chains.

## MCP Tool References

When the skill uses MCP (Model Context Protocol) tools, use **fully qualified tool names** to avoid "tool not found" errors:

- **Format**: `ServerName:tool_name`
- **Example**: "Use the BigQuery:bigquery_schema tool to retrieve table schemas. Use the GitHub:create_issue tool to create issues."
- Without the server prefix, the agent may fail to locate the tool when multiple MCP servers are available.

## Workflows and Checklists

For complex, multi-step tasks:

- **Checklist pattern**: Provide a copyable checklist in SKILL.md that the agent can tick off as it progresses (e.g. "Implementation Progress: - [ ] Step 1 ... - [ ] Step 2 ...").
- **Feedback loops**: Include validation steps (run validator → fix errors → repeat) so the agent can verify outputs before proceeding.

## Degrees of Freedom

Match the level of specificity to the task:

- **High freedom**: Multiple approaches are valid; use text-based instructions (e.g. code review guidelines).
- **Medium freedom**: A preferred pattern exists; use pseudocode or parameterized scripts.
- **Low freedom**: Operations are fragile; use exact commands and scripts with few or no parameters (e.g. database migrations).

## Evaluation-Driven Development

- **Build evaluations first** before writing extensive documentation: identify gaps without the skill, create scenarios that test those gaps, establish a baseline, then write minimal instructions to pass.
- Iterate using real usage: test the skill on similar tasks and refine based on where the agent struggles or succeeds.

## Validation

Before finalizing a skill, validate it using the `skills-ref` CLI:

```bash
skills-ref validate ./my-skill
```

This ensures the frontmatter and naming conventions strictly follow the specification.

## Design Patterns

When creating a new skill, choose the pattern that best matches the skill's interaction model and declare it in the frontmatter under `metadata: pattern:`.

### Pattern Decision Guide

| Ask yourself | If YES | Pattern |
| :--- | :--- | :--- |
| Does this skill wrap a CLI tool or external API with a reference table of commands? | Yes | `tool-wrapper` |
| Does this skill fill in a template or generate output from a fixed structure? | Yes | `generator` |
| Does this skill evaluate, score, or audit something against a checklist? | Yes | `reviewer` |
| Does this skill need to ask the user multiple questions before acting? | Yes | `inversion` |
| Does this skill run a fixed sequence of steps where each step must complete before the next? | Yes | `pipeline` |

When multiple patterns apply, use the **most specific** one. For example, a skill that wraps a CLI tool AND asks the user questions before each command is `inversion`. A skill that wraps a CLI tool and runs steps in sequence is `pipeline`.

### Pattern Descriptions

#### `tool-wrapper`

- **When to use**: The skill's primary job is exposing a CLI tool or API to the agent. It contains a reference table of commands, flags, or endpoints.
- **Key structural elements**: `references/commands.md` (or `references/api-endpoints.md`) extracted from SKILL.md; `Safety & Verification` section with human-in-the-loop requirement.
- **Examples in this repo**: `gh-issue-management`, `gh-project-management`, `gh-verifying-context`

#### `generator`

- **When to use**: The skill produces output by filling in templates or assembling content from structured sources. Steps are: load template → collect variables → fill → output.
- **Key structural elements**: `assets/` directory containing output templates; `references/` containing the style guide or schema the output must conform to.
- **Examples in this repo**: `readme-sync`

#### `reviewer`

- **When to use**: The skill evaluates something (code, configuration, test results) against an external checklist. It produces a scored or categorized report.
- **Key structural elements**: `references/review-checklist.md` loaded at review time; severity levels (error / warning / info) in the output format.
- **Examples in this repo**: `test-github-project-skills`

#### `inversion`

- **When to use**: The task is irreversible or requires accurate upfront specification to avoid rework. The agent must interview the user through multiple phases before acting.
- **Key structural elements**: Numbered interview phases; explicit `GATE:` markers after each phase; Phase 3 is always a confirmation summary; `interaction: multi-turn` in frontmatter metadata.
- **Template**: [../assets/templates/inversion.md](../assets/templates/inversion.md)

#### `pipeline`

- **When to use**: The task is a strict sequential workflow. Each step depends on the previous. Gate conditions prevent proceeding until user confirms or a condition is met.
- **Key structural elements**: Numbered steps with `> GATE:` markers; explicit conditions ("DO NOT proceed until..."); copyable `[ ]` checklist for agent progress tracking.
- **Examples in this repo**: `github-triage-agent`, `github-project-manager`, `implementing-agent-skills`
