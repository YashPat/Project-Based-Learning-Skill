# Project-Based Learning Skill

A Cursor skill that scaffolds **learning repos** where the AI acts as a tutor, not a contractor.

## How it works

1. **Invoke the skill** with a goal — e.g. `/learn-init build a toy Redis in Go to learn networking`.
2. **The skill scaffolds a minimal repo**: `git init`, an `AGENTS.md` teaching contract, and a Cursor hook that blocks the AI from editing source files.
3. **You open that repo as its own workspace** and start learning. The AI reads your goal, calibrates to your experience, and proposes one session-sized checkpoint at a time in `docs/nextcheckpoint.md`.
4. **You write the code.** The AI guides with questions, explanations, and (only when you're stuck) small examples in chat — never in your files.

## What gets enforced

| Layer | Role |
|---|---|
| `AGENTS.md` | Teaching contract: Socratic by default, explain-back before moving on, incremental checkpoints |
| `.cursor/hooks/guard-edits.sh` | Blocks AI edits to everything except `docs/` (checkpoints) and `.cursor/` (skills, rules) |
| `docs/nextcheckpoint.md` | Single active checkpoint — one clear step toward the goal |

The hook is tamper-protected: only you can change the guard itself.

## Install

Copy or symlink this skill into your Cursor skills directory, then invoke `/learn-init` with your learning goal.

Requires `jq` for the edit guard hook (`brew install jq` on macOS).
