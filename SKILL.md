---
name: learn-init
description: >-
  Scaffold a new repository for a project-based learning project: git init plus
  an AGENTS.md teaching contract and a hook that blocks the agent from editing
  source files. Use when the user invokes /learn-init or asks to set up a
  learning project, study project, or tutorial repo from a high-level goal.
---

# learn-init: Scaffold a Learning Project Repo

Turn a high-level goal ("build a toy redis in Go to learn networking") into a
minimal repo where the AI is configured to act as a tutor, not a contractor.

The scaffold is deliberately minimal: `git init` + `AGENTS.md` + an edit-guard
hook. No README, no package files, no starter code — the agent derives the
first checkpoint from the goal and repo state.

## Workflow

### Step 1: Get the goal

The project goal usually comes with the invocation (e.g. `/learn-init build a
toy redis in Go`). If no goal was given, ask for it. Do not ask anything else
unless the goal is too vague to infer a stack from (then ask one clarifying
question).

### Step 2: Scaffold the repo

Determine the target directory: if the current workspace is empty or the user
named one, use it; otherwise create a new directory named after the project
(kebab-case) and report its location in the hand-off — don't stop to ask.

Then:

1. Verify `jq` is installed (`command -v jq`); the hook needs it. If missing,
   tell the user how to install it (`brew install jq`) and continue — without
   jq the hook fails closed and blocks ALL AI edits, including the `.cursor/`
   carve-out for skills and rules, until jq is installed.
2. `git init` in the target directory. If the directory is already inside an
   existing git repo, stop and ask before creating a nested repo.
3. Write `AGENTS.md` from [templates/AGENTS.template.md](templates/AGENTS.template.md),
   filling every `{{PLACEHOLDER}}`. Keep all other text verbatim — especially
   the Teaching contract and Checkpoint protocol sections.
4. Create `docs/nextcheckpoint.md` as an empty file (no active checkpoint yet).
5. Copy [templates/hooks.json](templates/hooks.json) to `.cursor/hooks.json`
   and [templates/guard-edits.sh](templates/guard-edits.sh) to
   `.cursor/hooks/guard-edits.sh` in the new repo. Copy verbatim; do not edit.
6. `chmod +x .cursor/hooks/guard-edits.sh`
7. Initial commit: `git add -A && git commit -m "Scaffold learning project"`

### Step 3: Hand off

Tell the user:

- Where the repo was created, and to open it as its own Cursor workspace
  (hooks load from the project root, so they do not work from a parent
  folder).
- To start working — the agent reads the goal and repo, then sets the first
  incremental checkpoint in `docs/nextcheckpoint.md`.
- That the hook blocks AI edits to everything except `.cursor/` (skills,
  rules) and `docs/` — the AI guides, the user types. The hook itself
  (`.cursor/hooks/` and `.cursor/hooks.json`) is tamper-protected: only the
  user can edit it.

## Template placeholders

| Placeholder | Content |
|---|---|
| `{{GOAL}}` | The user's goal, verbatim |
| `{{TITLE}}` | Short project title derived from the goal |
