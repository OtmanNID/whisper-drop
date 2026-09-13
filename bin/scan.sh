#!/bin/zsh

set -u
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/../lib/common.sh"
load_config || exit 1

[[ -d "$WATCH_DIR" ]] || mkdir -p "$WATCH_DIR"

LOCK_DIR="$WD_STATE_DIR/scan.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  log INFO "Scan already running; exiting"
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT INT TERM

log INFO "Scanning: $WATCH_DIR"

for FILE in "$WATCH_DIR"/*(.N); do
  FILENAME="${FILE:t}"
  EXT="${FILENAME:e:l}"
  STEM="${FILENAME:r}"
  [[ "$EXT" == "txt" ]] && continue
  [[ "$STEM" == *_whisper* ]] && continue
  is_supported_extension "$EXT" || continue
  "$SCRIPT_DIR/transcribe.sh" "$FILE"
done
