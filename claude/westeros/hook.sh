#!/bin/bash
# Westeros battlefield hook: appends the hook payload to an event log. Never blocks.
LOG="$HOME/.claude/westeros/events.jsonl"
payload=$(cat)
ts=$(date +%s000)
printf '{"ts":%s,"payload":%s}\n' "$ts" "$payload" >> "$LOG" 2>/dev/null
exit 0
