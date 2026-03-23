---
name: doing-something-descriptive
description: [Third person: what it does and when to use it.] Use when [trigger conditions/keywords].
license: (Optional: e.g., Apache-2.0)
compatibility: (Optional: Environment requirements)
metadata:
  pattern: (any)
  author: (Optional)
  version: (Optional)
allowed-tools: (Optional: space-delimited list of tools)
---

# [Skill Title]

## Purpose

A brief explanation of what this skill helps the agent achieve.

## Instructions

1.  **Step 1**: Describe the first step.
2.  **Step 2**: Describe the second step.

## Safety & Verification (Mandatory for State Changes)

If this skill modifies files, repositories, or external systems:

- **Context Awareness**: Ensure the agent has verified the current operating environment (e.g., `gh-verifying-context`).
- **Human-in-the-Loop**: Present the proposed changes (diffs, commands, content) to the user before execution.
- **Data Leakage Check**: Verify that sensitive information (credentials, internal data) is not being exposed.

## Workflow (optional)

For multi-step tasks, add a copyable checklist:

- [ ] Step 1: [Description]
- [ ] Step 2: [Description]
- [ ] Step 3: [Description]

## Examples

### Example 1: [Scenario]

**Input**: [Description of input]
**Output**:

```[language]
[Example output]
```

## Additional Resources

- For detailed standards, see [references/best-practices.md](../../references/best-practices.md)
