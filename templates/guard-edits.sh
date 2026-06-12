#!/bin/bash
# Learning-repo guard: blocks AI edits to everything except .cursor/**
# (and even there, .cursor/hooks/** and .cursor/hooks.json are tamper-protected).
# The AI guides, the user types.

# Without jq the script would silently allow everything, so hard-block instead
# (exit 2). The matcher in hooks.json scopes this hook to edit tools, so this
# cannot lock out reads or shell commands.
command -v jq >/dev/null 2>&1 || exit 2

input=$(cat)

# Belt-and-suspenders: the hooks.json matcher should already scope us to edit
# tools, but re-check here in case it over-matches.
tool=$(echo "$input" | jq -r '.tool_name // .tool // .toolName // empty')

case "$tool" in
  Write|StrReplace|Edit|MultiEdit|EditNotebook|Delete|write|edit|delete) ;;
  *)
    echo '{ "permission": "allow" }'
    exit 0
    ;;
esac

path=$(echo "$input" | jq -r '
  .tool_input.path // .tool_input.file_path // .tool_input.target_file //
  .tool_input.target_notebook // .input.path // .input.file_path // empty')

deny() {
  jq -n --arg um "$1" '{
    permission: "deny",
    user_message: $um,
    agent_message: "Blocked by the learning-repo guard hook: this is a learning project and the AI edits no files here. Per the teaching contract in AGENTS.md, guide the user to write this change themselves (Socratic by default; a minimal example in chat at most). If a file genuinely needs new content, propose it in chat for the user to type in."
  }'
  exit 0
}

if [ -z "$path" ]; then
  deny "Edit blocked: could not determine the target file in this learning repo."
fi

# Tamper protection: the enforcement mechanism itself is off-limits to the AI.
# This must run before any allow rules.
case "$path" in
  .cursor/hooks/*|*/.cursor/hooks/*|.cursor/hooks.json|*/.cursor/hooks.json)
    deny "Edit blocked: the learning-repo guard hook is tamper-protected. Edit it yourself if you want to change the rules."
    ;;
esac

case "$path" in
  .cursor/*|*/.cursor/*)
    echo '{ "permission": "allow" }'
    exit 0
    ;;
esac

deny "Edit to $(basename "$path") blocked: this is a learning repo — the AI guides, you write the code."
