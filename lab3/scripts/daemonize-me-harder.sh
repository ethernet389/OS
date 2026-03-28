#!/usr/bin/env bash

is_running() {
  if [[ ! -e /var/run/process-watcher.pid ]]; then
    return 1
  fi

  kill -0 $(cat /var/run/process-watcher.pid) 2>/dev/null
  return $?
}

make_report() {
  local current_day=$(date +"%Y%m%d")

  local report_file=/var/log/process-watcher.$current_day.report

  local start_time=$(date -d "24 hours ago" +"%Y-%m-%dT%H:%M:%S" 2>/dev/null)
  local events=$(awk -v start="$start_time" '$2 >= start && /New file detected/ {count++} END {print count+0}' /var/log/process-watcher.log)
  local total_events=$(grep -c "New file detected" /var/log/process-watcher.log || echo 0)

cat > "$report_file" <<EOF
Process Watcher Report - $(date)

Time period: last 24 hours (since $start_time)
Events in last 24h: $events
Total events since service start: $total_events
Service runnning: $(is_running && echo YES || echo NO)
EOF

}

case "$1" in
  start)
    if is_running; then
      echo "Man, is running. Don't do this." >&2
      exit 1
    fi

    ( setsid /opt/process-watcher-service.sh </dev/null >/dev/null 2>&1 & ) \
       && echo "Daemonization is done."
    ;;

  status)
    if is_running; then
      pid=$(cat /var/run/process-watcher.pid)
      kill -USR1 "$pid"
      echo "Status request done. Check /var/log/process-watcher.log"
    else
      echo "Damn. It's not running, man." >&2
      exit 1
    fi
    ;;

  stop)
    if ! is_running; then
      echo "Damn. It's not running, man." >&2
      exit 1
    fi
    
    pid=$(cat /var/run/process-watcher.pid)

    kill -TERM "$pid"
    echo "Send stop request."
    ;;

  report)
    make_report && echo "Make report."
    ;;

  rotate)
    if ! is_running; then
      echo "Damn. It's not running, man." >&2
      exit 1
    fi
    
    pid=$(cat /var/run/process-watcher.pid)

    kill -USR2 "$pid"
    echo "Send rotate request."
esac
