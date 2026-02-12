#!/bin/bash
WEBHOOK_URL="<Slack Webhook url here>"
INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"')

if [ "$EVENT" = "Stop" ]; then
  HEADER="✅ *Claude Code task completed*"
elif [ "$EVENT" = "Notification" ]; then
  HEADER="🔔 *Claude Code needs your attention*"
else
  exit 0
fi

MSG="${HEADER}
📁 ${CWD}"

curl -s -X POST -H 'Content-type: application/json' \
  --data "$(jq -n --arg text "$MSG" '{text: $text}')" \
  "$WEBHOOK_URL" > /dev/null 2>&1

exit 0
