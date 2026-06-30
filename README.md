# Project-Based Learning Skill

A Cursor skill that turns a repo into a **learning project** where the AI acts as a tutor, not a contractor. It works two ways: scaffold a brand-new learning repo, or add learning mode to an existing codebase.

## How it works

### New repo

1. **Invoke the skill** with a goal — e.g. `/learn-init build a toy Redis in Go to learn networking`.
2. **The skill scaffolds a minimal repo**: `git init`, an `AGENTS.md` teaching contract, and a Cursor hook that blocks the AI from editing source files.
3. **You open that repo as its own workspace** and start learning. The AI reads your goal, calibrates to your experience, and proposes one session-sized checkpoint at a time in `docs/nextcheckpoint.md`.
4. **You write the code.** The AI guides with questions, explanations, and (only when you're stuck) small examples in chat — never in your files.

### Existing repo

1. **Invoke the skill in your repo** — e.g. `/learn-init use this project to learn`.
2. **The skill asks about your experience** so the AI can calibrate, then adds a "Learning mode" section to your `AGENTS.md` and installs the same edit-guard hook. The goal is usually inferred from the repo; the skill only asks for one when it isn't already clear (no `AGENTS.md`, or one without a clear goal), recording it as a `## Goal` section.
3. **You reload the workspace** and start learning in your existing codebase, with the AI guiding instead of writing the code.

## What gets enforced

| Layer | Role |
|---|---|
| `AGENTS.md` | Teaching contract: Socratic by default, explain-back before moving on, incremental checkpoints (full file for a new repo, an appended "Learning mode" section for an existing one) |
| `.cursor/hooks/guard-edits.sh` | Blocks AI edits to everything except `docs/` (checkpoints) and `.cursor/` (skills, rules) |
| `docs/nextcheckpoint.md` | Single active checkpoint — one clear step toward the goal |

The hook is tamper-protected: only you can change the guard itself.

## Install

Copy or symlink this skill into your Cursor skills directory, then invoke `/learn-init` with your learning goal.

Requires `jq` for the edit guard hook (`brew install jq` on macOS).
