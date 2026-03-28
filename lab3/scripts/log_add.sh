_LOG_VARS=(LOG_DEST LOG_LEVEL)
_LOG_TO_NUM=([ERROR]=0 [WARN]=1 [INFO]=2 [DEBUG]=3)

for var in "${_LOG_VARS[@]}"; do
  if [[ -z "${!var}" ]]; then
    echo "$0: Missing variable: $var." >&2
    exit 1
  fi
done

case "$LOG_LEVEL" in
  ERROR|WARN|INFO|DEBUG)
    _LOG_LEVEL_NUM=${_LOG_TO_NUM[INFO]}
    ;;

  *)
    echo "Unknown LOG_LEVEL value: $LOG_LEVEL." >&2
    exit 1
    ;;
esac


log_add() {
  local log_level="$1"
  local log_level_num=${_LOG_TO_NUM["$1"]:-${_LOG_TO_NUM[INFO]}}
  shift

  if [[ $log_level_num -le $_LOG_LEVEL_NUM ]]; then
    echo "[$$] [$(date --utc --iso-8601=s)] [$log_level]: $@" >> "$LOG_DEST"
  fi
}
