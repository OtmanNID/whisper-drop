#!/bin/zsh

set -u
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/../lib/common.sh"

print "WhisperDrop doctor"
print "==================="

if load_config; then
  print "✓ Config: $WD_CONFIG"
else
  print "✗ Config missing"
  exit 1
fi

for CMD in ffmpeg whisper-cli; do
  P="$(command -v "$CMD" 2>/dev/null || true)"
  if [[ -n "$P" ]]; then
    print "✓ $CMD: $P"
  else
    print "✗ $CMD not found"
  fi
done

if [[ -f "$MODEL_PATH" ]]; then
  print "✓ Model: $MODEL_PATH"
else
  print "✗ Model missing: $MODEL_PATH"
fi

if [[ -d "$WATCH_DIR" ]]; then
  print "✓ Watch folder: $WATCH_DIR"
else
  print "✗ Watch folder missing: $WATCH_DIR"
fi

if launchctl print "gui/$(id -u)/com.whisperdrop.watcher" >/dev/null 2>&1; then
  print "✓ launchd watcher: running"
else
  print "✗ launchd watcher: not running"
fi

if [[ "${SUMMARY_PROVIDER:-none}" == "shortcuts" ]]; then
  if /usr/bin/shortcuts list 2>/dev/null | grep -Fxq "$SHORTCUT_NAME"; then
    print "✓ Shortcut: $SHORTCUT_NAME"
  else
    print "✗ Shortcut not found: $SHORTCUT_NAME"
  fi
fi
