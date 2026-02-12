#!/bin/bash
input=$(cat)

# Get path and branch from the current working directory
DISPLAY_PATH="${PWD##*/}"
GIT_BRANCH=$(git --no-optional-locks branch --show-current 2>/dev/null)

# Extract context window data
USED_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
CURRENT_USAGE=$(echo "$input" | jq -r '.context_window.current_usage')

# Calculate used tokens from current_usage
if [ "$CURRENT_USAGE" != "null" ]; then
    USED_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens + .context_window.current_usage.cache_creation_input_tokens + .context_window.current_usage.cache_read_input_tokens')
else
    USED_TOKENS=0
fi

# Extract lines added/removed
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Format token counts (e.g., 20k/200k)
format_tokens() {
    local num=$1
    if [ "$num" -ge 1000 ]; then
        echo "$((num / 1000))k"
    else
        echo "$num"
    fi
}

USED_FMT=$(format_tokens $USED_TOKENS)
TOTAL_FMT=$(format_tokens $CONTEXT_SIZE)

# ANSI colors
RED='\033[31m'
GREEN='\033[32m'
ORANGE='\033[38;5;208m'
BLUE='\033[34m'
CYAN='\033[36m'
RESET='\033[0m'

# Build output - path (branch) then metrics
OUTPUT="${BLUE}${DISPLAY_PATH}${RESET}"

if [ -n "$GIT_BRANCH" ]; then
    OUTPUT="${OUTPUT} (${CYAN}${GIT_BRANCH}${RESET})"
fi

OUTPUT="${OUTPUT} [${RED}${USED_PCT}%${RESET}] [${ORANGE}${USED_FMT}${RESET}/${BLUE}${TOTAL_FMT}${RESET}] [${GREEN}+${LINES_ADDED}${RESET}/${RED}-${LINES_REMOVED}${RESET}]"

echo -e "$OUTPUT"
