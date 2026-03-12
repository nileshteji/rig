#!/bin/zsh

input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
output_tokens=$(echo "$input" | jq -r '.context_window.current_usage.output_tokens // empty')

# Git branch (skip lock to avoid contention)
branch=""
if [ -d "$dir" ]; then
  branch=$(cd "$dir" 2>/dev/null && git -c core.fileMode=false -c gc.auto=0 branch --show-current 2>/dev/null)
fi

# Build git info segment
git_info=""
[ -n "$branch" ] && git_info=" ($branch)"

# Build token segment
token_info=""
if [ -n "$input_tokens" ] && [ -n "$output_tokens" ]; then
  total=$(( input_tokens + output_tokens ))
  token_info=" | Tokens: ${total}"
fi

# Build context remaining segment
context_info=""
[ -n "$remaining" ] && context_info=" | Context: ${remaining}%"

echo "${dir}${git_info} | ${model}${token_info}${context_info}"
