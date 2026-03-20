#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
CONTEXT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
FIVE_HR=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
SEVEN_DAY=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)

# Format duration as minutes
DURATION_MIN=$((DURATION_MS / 60000))

# Build output
LINE="${MODEL} | ctx ${CONTEXT}% | \$${COST} | ${DURATION_MIN}m"

# Append rate limits if available
if [ -n "$FIVE_HR" ] && [ "$FIVE_HR" != "null" ]; then
    LINE="${LINE} | 5h ${FIVE_HR}%"
fi
if [ -n "$SEVEN_DAY" ] && [ "$SEVEN_DAY" != "null" ]; then
    LINE="${LINE} 7d ${SEVEN_DAY}%"
fi

echo "$LINE"
