#!/usr/bin/env bash
# PreToolUse guardrail for Bash calls. Blocks dangerous, hard-to-reverse commands
# with exit 2 + a BLOCKED: stderr message (which Claude Code surfaces to the model).
# Degrades gracefully to exit 0 if jq is missing — never blocks work over tooling.

command -v jq >/dev/null 2>&1 || exit 0

cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# Each pattern is an extended-regex matched against the raw command string.
# Keep these conservative: block the clearly-destructive, let everything else through.
patterns=(
  'git[[:space:]]+push[[:space:]].*(--force|-f([[:space:]]|$)|\+)'  # force push
  'git[[:space:]]+push[[:space:]].*--force-with-lease'              # still destructive to shared history
  'git[[:space:]]+reset[[:space:]]+--hard'                          # discards working tree
  'git[[:space:]]+clean[[:space:]]+.*-[a-zA-Z]*f'                   # deletes untracked files
  'git[[:space:]]+branch[[:space:]]+.*-D'                           # force-delete branch
  'git[[:space:]]+checkout[[:space:]]+\.'                           # discards unstaged changes
  'git[[:space:]]+restore[[:space:]]+\.'                            # discards unstaged changes
  'rm[[:space:]]+-rf[[:space:]]+/'                                  # rm -rf on an absolute path (outside repo)
  'rm[[:space:]]+-rf[[:space:]]+~'                                  # rm -rf on home
  'DROP[[:space:]]+TABLE'                                           # destructive SQL
  'DROP[[:space:]]+DATABASE'
  'TRUNCATE[[:space:]]+TABLE'
)

for p in "${patterns[@]}"; do
  if echo "$cmd" | grep -iqE "$p"; then
    echo "BLOCKED: guardrail matched a dangerous pattern (/$p/) in: $cmd" >&2
    echo "BLOCKED: if this is genuinely intended, run it yourself outside the agent, or narrow the command." >&2
    exit 2
  fi
done

exit 0
