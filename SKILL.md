---
name: learn-init
description: >-
  Set up a project-based learning workflow where the AI acts as a tutor instead
  of writing the code. Either scaffold a new learning repo (git init plus an
  AGENTS.md teaching contract and a hook that blocks the agent from editing
  source) or add the learning setup to an existing repo (gauge the learner's
  level, add a mentor contract to AGENTS.md, install the edit guard). Use when
  the user invokes /learn-init or asks to set up, or turn a repo into, a
  learning, study, or tutorial project.
---

# learn-init: Set Up a Project-Based Learning Workflow

Configure a repo so the AI acts as a tutor, not a contractor: it guides, the
user writes the code.

Two modes:

- **New repo** — scaffold a minimal repo from a high-level goal ("build a toy
  redis in Go to learn networking"). `git init` + `AGENTS.md` + an edit-guard
  hook, and nothing else. The agent derives the first checkpoint from the goal
  and repo state.
- **Existing repo** — the user already has a codebase and wants to learn by
  working in it. The project goal is derivable from the repo itself, so
  `AGENTS.md` does **not** need a goal. Instead, gauge the learner's level, add
  a mentor/teaching contract to `AGENTS.md`, and install the edit guard.

## Step 1: Pick the mode

- Use **Existing repo** mode if the user is pointing at an existing, non-empty
  repo — the current workspace is a git repo with real source in it, or they say
  things like "add this to my repo" / "use this project to learn".
- Use **New repo** mode if they give a high-level goal with no repo, or the
  workspace is empty.
- If it is ambiguous, ask one question: scaffold a new project, or add learning
  mode to the current repo?

## Step 2: Gather context

Both modes need **learner context**. New repo also needs the **goal**.

- **Goal (new repo only):** usually comes with the invocation (e.g. `/learn-init
  build a toy redis in Go`). If it is missing, or too vague to infer a stack
  from, ask one clarifying question.
- **Learner context (both modes):** ask one experience question, with the topic
  derived from the goal (new repo) or from the repo's stack and domain (existing
  repo). Example: "What's your background with Go and networking? (e.g.
  'comfortable in Go, never done TCP' or 'new to programming')". Use the answer
  verbatim for `{{LEARNER_CONTEXT}}`. If the user already stated their experience
  in the goal or a follow-up, do not ask again — extract it instead.

## Step 3a: New repo — scaffold

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

## Step 3b: Existing repo — augment

Do not scaffold new project files and do not add a goal — the repo already
defines what to build. Work from the repo root.

1. Verify `jq` is installed (`command -v jq`); the hook needs it. If missing,
   tell the user how to install it (`brew install jq`) and continue — without
   jq the hook fails closed and blocks ALL AI edits until jq is installed.
2. Confirm the repo root with `git rev-parse --show-toplevel` and run the
   remaining steps there. If the path is not a git repo, switch to **New repo**
   mode (or ask).
3. Update `AGENTS.md` using
   [templates/AGENTS.learning-section.template.md](templates/AGENTS.learning-section.template.md),
   filling `{{LEARNER_CONTEXT}}`:
   - If `AGENTS.md` does not exist, create it from the learning-section template.
   - If it exists, append the learning section to the end; do not remove or
     rewrite the user's existing content. If a "Learning mode" section is
     already present, update it in place instead of duplicating it.
4. Create `docs/nextcheckpoint.md` as an empty file if it does not already
   exist. Do not touch it if the user already has one.
5. Install the edit guard:
   - Copy [templates/guard-edits.sh](templates/guard-edits.sh) to
     `.cursor/hooks/guard-edits.sh` (verbatim) and `chmod +x` it.
   - If `.cursor/hooks.json` does not exist, copy
     [templates/hooks.json](templates/hooks.json) to it verbatim. If it already
     exists, merge in the `preToolUse` entry from the template instead of
     overwriting the user's other hooks.
6. Commit only the learning setup, not unrelated working changes:
   `git add AGENTS.md docs/nextcheckpoint.md .cursor && git commit -m "Add
   project-based learning setup"`. If there are unrelated staged changes, stage
   just these paths.

## Step 4: Hand off

Tell the user:

- (New repo) where the repo was created, and to open it as its own Cursor
  workspace; (existing repo) to reload/reopen the workspace so the hook loads —
  hooks load from the project root, so they do not work from a parent folder.
- To start working — the agent reads the goal (the user's stated goal for a new
  repo, or the repo itself for an existing one), the learner context,
  `docs/nextcheckpoint.md`, and the repo, proposes the first incremental
  checkpoint in chat, and writes it to `docs/nextcheckpoint.md` once the user
  confirms.
- That the hook blocks AI edits to everything except `.cursor/` (skills, rules)
  and `docs/` (checkpoint pointer; other docs only when you ask) — the AI
  guides, the user types. The hook itself (`.cursor/hooks/` and
  `.cursor/hooks.json`) is tamper-protected: only the user can edit it.

## Template placeholders

| Placeholder | Content | Modes |
|---|---|---|
| `{{GOAL}}` | The user's goal, verbatim | New repo |
| `{{TITLE}}` | Short project title derived from the goal | New repo |
| `{{LEARNER_CONTEXT}}` | The user's experience with the relevant stack and topic, verbatim | Both |
