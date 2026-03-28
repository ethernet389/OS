#!/usr/bin/env bash


# Default config
LOOK_PATH="/tmp"
ITER_DELAY=1
LOG_LEVEL="INFO"
PID_FILE="${PID_FILE:-/var/run/process-watcher.pid}"
LOG_DEST="${LOG_DEST:-/var/log/process-watcher.log}"
REPORT_FILE="${REPORT_FILE:-/var/log/process-watcher.report}"
CONFIG_FILE="${CONFIG_FILE:-/etc/process-watcher.config}"
CMD_FIFO="${CMD_FIFO:-/var/run/process-watcher.fifo}"

# Only one instance allowed
exec 200<> "$PID_FILE"
flock -n 200 || exit 1
echo $$ >&200


# Enable logger
if [[ ! -f /opt/log_add.sh ]]; then
  echo "ERROR: log_add.sh not found at /opt/log_add.sh" >&2
  exit 1
fi

source /opt/log_add.sh


# Statistics
SIGHUP_COUNT=0
SIGUSR1_COUNT=0
SIGUSR2_COUNT=0
SIGTERM_COUNT=0
SIGINT_COUNT=0
declare -A PROCESSED_FILES


# Signal flags
sighup_flag=0
sigusr1_flag=0
sigusr2_flag=0
sigterm_flag=0
sigint_flag=0


# Functions
cleanup() {
  rm -f "$PID_FILE"
  flock -u 200
  exec 100>&-
}

rotate_log() {
  [[ ! -f "$LOG_DEST" ]] && exit

  local timestamp=$(date --utc --iso-8601=s)

  mv "$LOG_DEST" "${LOG_DEST}.${timestamp}"
  log_add INFO "Log rotated: ${LOG_DEST}.${timestamp}"
}

scan_directory() {
  if [[ ! -d "$LOOK_PATH" ]]; then
    log_add ERROR "Directory doesn't exist: $LOOK_PATH"
    return
  fi

  while read fname; do
    [[ -n "${PROCESSED_FILES[$fname]:-}" ]] && continue

    PROCESSED_FILES[$fname]=1
    log_add INFO "New file detected: $fname"
  done < <(find "$LOOK_PATH" -maxdepth 1 -type f -printf "%f\n" 2>/dev/null)
}

make_report() {
cat > "$REPORT_FILE" << EOF
PID: $$
Processed files: ${#PROCESSED_FILES[@]}
Signals handled: $(( SIGHUP_COUNT + SIGUSR1_COUNT + SIGUSR2_COUNT + SIGTERM_COUNT + SIGINT_COUNT ))
  SIGHUP: $SIGHUP_COUNT
  SIGUSR1: $SIGUSR1_COUNT
  SIGUSR2: $SIGUSR2_COUNT
  SIGTERM: $SIGTERM_COUNT
  SIGINT: $SIGINT_COUNT
Current LOG_LEVEL: $LOG_LEVEL
Watching: $LOOK_PATH
FIFO: $CMD_FIFO
EOF
}

make_status_snapshot() {
  log_add INFO "(PID: $$, Watching: $LOOK_PATH, FIFO: $CMD_FIFO)"
}


# Setup config and validate it
init_config_if_needed() {
  [[ -f "$CONFIG_FILE" ]] && return

cat > "$CONFIG_FILE" << EOF
LOOK_PATH=/tmp
ITER_DELAY=2
LOG_LEVEL=INFO
LOG_DEST=/var/log/process-watcher.log
CMD_FIFO=/var/run/process-watcher.fifo
EOF

  log_add INFO "Created default config file: $CONFIG_FILE"
}

validate_look_path() {
  if [[ -z "$LOOK_PATH" ]]; then
    log_add ERROR "LOOK_PATH is not set in config"
    return 1
  fi

  if [[ ! -d "$LOOK_PATH" ]]; then
    log_add ERROR "LOOK_PATH does not exist or is not a directory: $LOOK_PATH"
    return 1
  fi
}

validate_iter_delay() {
  if [[ "$ITER_DELAY" -le 0 ]]; then
    log_add ERROR "ITER_DELAY must be a positive integer, got: $ITER_DELAY"
    return 1
  fi

  return 0
}

validate_log_level() {
  case "$LOG_LEVEL" in
    ERROR|WARN|INFO|DEBUG) ;;

    *)
      log_add ERROR "Invalid LOG_LEVEL: $LOG_LEVEL (must be ERROR, WARN, INFO, or DEBUG)"
      return 1
      ;;
  esac
}

load_config() {
  init_config_if_needed

  if ! source "$CONFIG_FILE"; then
    log_add ERROR "Failed to source config file: $CONFIG_FILE"
    exit 1
  fi

  validate_look_path  || exit 1
  validate_iter_delay || exit 1
  validate_log_level  || exit 1

  PROCESSED_FILES=()
}



# Handle FIFO
close_fifo() {
  rm -f "$CMD_FIFO"
  exec 100>&-
}

create_fifo() {
  close_fifo >/dev/null 2>&1

  if ! mkfifo -m 0666 "$CMD_FIFO"; then
    log_add ERROR "Cannot create FIFO: $CMD_FIFO"
    return 1
  fi

  log_add INFO "Created FIFO: $CMD_FIFO"

  exec 100<> "$CMD_FIFO"
}


read_fifo() {
    if ! read -t 0 -u 100 2>/dev/null; then
      return
    fi

    if IFS= read -r -u 100 msg; then
      log_add INFO "FIFO message: $msg"

      case "$msg" in
	STATUS)
	  make_status_snapshot
	  ;;

	STOP)
	  log_add INFO "Read STOP command from FIFO. I should die gracefully"
	  sigterm_flag=1
	  ;;

	ROTATE)
	  rotate_log
	  ;;

	MODE_CHANGE)
	  if [[ "$LOG_LEVEL" == "INFO" ]]; then
	    LOG_LEVEL="DEBUG"
	    log_add INFO "Switched to DEBUG mode (via FIFO)"
	  else
	    LOG_LEVEL="INFO"
	    log_add INFO "Switched to INFO mode (via FIFO)"
	  fi
	  ;;
      esac
    fi
}


# Signal handlers
handle_sighup() {
  sighup_flag=1
  ((++SIGHUP_COUNT))
}

handle_sigusr1() {
  sigusr1_flag=1
  ((++SIGUSR1_COUNT))
}

handle_sigusr2() {
  sigusr2_flag=1
  ((++SIGUSR2_COUNT))
}

handle_sigterm() {
  sigterm_flag=1
  ((++SIGTERM_COUNT))
}

handle_sigint() {
  sigint_flag=1
  ((++SIGINT_COUNT))
}


# Main programm
make_one_step() {
  if (( sighup_flag )); then
    log_add INFO "SIGHUP received, reloading configuration"
    sighup_flag=0

    local old_look_path="$LOOK_PATH"
    load_config

    [[ "$LOOK_PATH" != "$old_look_path" ]] && PROCESSED_FILES=()

    log_add INFO "Configuration reloaded"
  fi

  if (( sigusr1_flag )); then
    sigusr1_flag=0
    make_report
  fi

  if (( sigusr2_flag )); then
    sigusr2_flag=0
    rotate_log
  fi

  if (( sigterm_flag || sigint_flag )); then
    log_add INFO "Shutdown signal received, exiting gracefully"
    exit 0
  fi

  scan_directory
  read_fifo
}

# Setup traps
trap cleanup EXIT
trap handle_sighup SIGHUP
trap handle_sigusr1 SIGUSR1
trap handle_sigusr2 SIGUSR2
trap handle_sigterm SIGTERM
trap handle_sigint SIGINT

load_config
log_add INFO "Process watcher started (PID: $$)"

create_fifo
log_add INFO "FIFO opened: $CMD_FIFO"

while true; do
  make_one_step
  sleep "$ITER_DELAY"
done

