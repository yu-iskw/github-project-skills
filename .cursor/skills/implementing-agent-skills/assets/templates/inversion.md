---
name: interviewing-for-task-name
description: Interviews the user to gather all required context before performing [Task Name]. Use when the task requires upfront specification to avoid rework or irreversible actions.
metadata:
  pattern: inversion
  interaction: multi-turn
---

# Interview: [Task Name]

## Purpose

Gathers all required information from the user through a structured interview before performing [Task Name]. No action is taken until all phases are complete.

## Interview Phases

### Phase 1: Scope

Ask the user the following questions one at a time. DO NOT proceed to Phase 2 until ALL answers are collected.

- [ ] **[Question 1]**: [e.g., "Which repository should I operate on?"]
- [ ] **[Question 2]**: [e.g., "What is the target branch?"]
- [ ] **[Question 3]**: [e.g., "Are there any exclusions or constraints?"]

> GATE: DO NOT proceed to Phase 2 until the user has answered every question in Phase 1.

### Phase 2: Preferences

Ask the user about preferences and constraints. DO NOT proceed to Phase 3 until ALL answers are collected.

- [ ] **[Question 4]**: [e.g., "Should I create a PR or commit directly?"]
- [ ] **[Question 5]**: [e.g., "What is the urgency or priority level?"]

> GATE: DO NOT proceed to Phase 3 until the user has answered every question in Phase 2.

### Phase 3: Confirmation

Summarize the collected information and ask the user to confirm before proceeding.

Present a summary in this format:

```
Scope:
  - [Answer to Q1]
  - [Answer to Q2]
  - [Answer to Q3]

Preferences:
  - [Answer to Q4]
  - [Answer to Q5]
```

Ask: "Does this summary accurately capture your requirements? Confirm to proceed, or let me know what to change."

> GATE: DO NOT begin execution until the user explicitly confirms the summary is correct. If the user requests changes, return to the relevant phase and re-collect answers.

## Execution

Only after all gates have been passed, proceed with the task using the confirmed parameters.

1. **Step 1**: [First execution step using confirmed parameters]
2. **Step 2**: [Second execution step]
3. **Step 3**: [Validation step — verify the output matches requirements]

## Notes

- If the user asks to skip the interview, explain that the questions are required to avoid irreversible actions and ask the questions again.
- If the user provides partial answers in one message, acknowledge what was received and ask only for the missing items.
- Always present the Phase 3 summary even if the user provided all answers upfront.
