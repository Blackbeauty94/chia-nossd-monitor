#!/bin/bash

################################
# CONFIG
################################

DIR="$(cd "$(dirname "$0")" && pwd)"

BOT_TOKEN="BotToken"
CHAT_HOURLY="chat id"
CHAT_ALERTS="chat id"

################################
# FIND LATEST LOG FILE
################################

LOG_FILE="$(ls -t "$DIR"/*.log 2>/dev/null | head -n1)"

if [ ! -f "$LOG_FILE" ]; then
  echo "No log file found"
  exit 1
fi

################################
# SEND MESSAGE
################################

send_msg() {
  chat="$1"
  text="$2"

  curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$chat" \
    --data-urlencode text="$text" >/dev/null
}

################################
# COUNT SHARES BETWEEN TIMESTAMPS
################################

count_shares_between() {
  start_ts="$1"
  end_ts="$2"
  now_hour=$(date +%H)

  awk -v s="$start_ts" -v e="$end_ts" -v nowh="$now_hour" '
    /Share generated/ {

      # full date + time
      if ($1 ~ /^[0-9]{4}-/ && $2 ~ /^[0-9]{2}:/) {
        cmd="date -d \""$1" "$2"\" +%s"
      }

      # time only → detect yesterday
      else if ($1 ~ /^[0-9]{2}:/) {
        split($1,t,":")
        logh=t[1]

        if (logh > nowh)
          cmd="date -d \"yesterday "$1"\" +%s"
        else
          cmd="date -d \"today "$1"\" +%s"
      }

      else next

      cmd | getline ts
      close(cmd)

      if (ts >= s && ts < e) c++
    }
    END { print c+0 }
  ' "$LOG_FILE"
}

################################
# WAIT UNTIL NEXT :30
################################

wait_until_half_hour() {
  m=$(date +%M)
  s=$(date +%S)

  if [ "$m" -lt 30 ]; then
    sleep $(( (30 - m) * 60 - s ))
  else
    sleep $(( (90 - m) * 60 - s ))
  fi
}

################################
# HOURLY REPORT LOOP
################################

hourly_loop() {
  wait_until_half_hour

  while true; do
    end_ts=$(date +%s)
    start_ts=$((end_ts - 3600))

    FROM_TIME=$(date -d "@$start_ts" +"%H:%M")
    TO_TIME=$(date -d "@$end_ts" +"%H:%M")

    COUNT=$(count_shares_between "$start_ts" "$end_ts")

    MSG="📊 Hourly Share Report
From: $FROM_TIME
To: $TO_TIME
Share generated: $COUNT"

    send_msg "$CHAT_HOURLY" "$MSG"

    sleep 3600
  done
}

################################
# DAILY + ERROR MONITOR
################################

daily_and_alert_loop() {
  start_day=$(date +%s)
  daily_shares=0
  alert_count=0

  tail -F "$LOG_FILE" | while read -r line; do

    case "$line" in
      *"Share generated"*)
        daily_shares=$((daily_shares + 1))
        ;;
      *"Too slow read"*|*"Failed to read quality string"*|*"WARNING: Missed"*)
        send_msg "$CHAT_ALERTS" "⚠️ Alert detected
$line"
        alert_count=$((alert_count + 1))
        ;;
    esac

    now=$(date +%s)
    if [ $((now - start_day)) -ge 86400 ]; then
      send_msg "$CHAT_ALERTS" "📅 Daily Summary (24h)

Share generated: $daily_shares
Alerts: $alert_count"

      start_day="$now"
      daily_shares=0
      alert_count=0
    fi
  done
}

################################
# START
################################

hourly_loop &
daily_and_alert_loop &
wait
