#!/bin/zsh

set -u
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/../lib/common.sh"
load_config || exit 1

FFMPEG="$(command_path ffmpeg)"
WHISPER="$(command_path whisper-cli)"
SHORTCUTS_BIN="/usr/bin/shortcuts"

[[ -x "$FFMPEG" ]] || { log ERROR "ffmpeg not found"; notify "WhisperDrop" "FFmpeg introuvable"; exit 1; }
[[ -x "$WHISPER" ]] || { log ERROR "whisper-cli not found"; notify "WhisperDrop" "whisper-cli introuvable"; exit 1; }
[[ -f "$MODEL_PATH" ]] || { log ERROR "Model missing: $MODEL_PATH"; notify "WhisperDrop" "Modèle Whisper introuvable"; exit 1; }

if [[ $# -lt 1 ]]; then
  print -u2 "Usage: $0 <audio-file> [...]"
  exit 2
fi

if [[ "$THREADS" == "auto" ]]; then
  CPU_COUNT="$(sysctl -n hw.logicalcpu 2>/dev/null || print 4)"
  THREADS_CALC=$(( CPU_COUNT / 2 ))
  (( THREADS_CALC < 2 )) && THREADS_CALC=2
else
  THREADS_CALC="$THREADS"
fi

for INPUT in "$@"; do
  [[ -f "$INPUT" ]] || continue

  FILENAME="${INPUT:t}"
  EXT="${FILENAME:e:l}"
  STEM="$(safe_stem "$FILENAME")"
  DIR="${INPUT:h}"
  TXT="$DIR/$STEM.txt"
  SUMMARY="$DIR/$STEM - résumé.txt"

  is_supported_extension "$EXT" || { log INFO "Ignoring unsupported file: $INPUT"; continue; }
  [[ "$STEM" == *_whisper* ]] && continue
  [[ "$STEM" == *" - résumé" ]] && continue

  if [[ -f "$TXT" ]]; then
    log INFO "Transcript already exists, skipping: $TXT"
    continue
  fi

  sleep "${SETTLE_SECONDS:-2}"

  TMP_DIR="$(mktemp -d -t whisperdrop)"
  TMP_WAV="$TMP_DIR/audio.wav"
  trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

  log INFO "Converting: $INPUT"
  "$FFMPEG" -hide_banner -loglevel error -y -i "$INPUT" -ar 16000 -ac 1 "$TMP_WAV"
  if [[ $? -ne 0 ]]; then
    log ERROR "ffmpeg conversion failed: $INPUT"
    notify "WhisperDrop" "Échec de conversion : $FILENAME"
    rm -rf "$TMP_DIR"
    trap - EXIT INT TERM
    continue
  fi

  LANG_ARGS=()
  if [[ "${LANGUAGE:-auto}" != "auto" ]]; then
    LANG_ARGS=(-l "$LANGUAGE")
  fi

  log INFO "Transcribing: $INPUT"
  "$WHISPER" \
    -m "$MODEL_PATH" \
    -f "$TMP_WAV" \
    -t "$THREADS_CALC" \
    "${LANG_ARGS[@]}" \
    -otxt \
    -of "$DIR/$STEM" > /dev/null 2>> "$WD_LOG_DIR/whisperdrop.log"

  STATUS=$?
  rm -rf "$TMP_DIR"
  trap - EXIT INT TERM

  if [[ $STATUS -ne 0 || ! -f "$TXT" ]]; then
    log ERROR "Whisper failed: $INPUT"
    notify "WhisperDrop" "Échec de transcription : $FILENAME"
    continue
  fi

  log INFO "Transcript created: $TXT"

  if [[ "${SUMMARY_PROVIDER:-none}" == "shortcuts" ]]; then
    if [[ -x "$SHORTCUTS_BIN" ]] && "$SHORTCUTS_BIN" list 2>/dev/null | grep -Fxq "$SHORTCUT_NAME"; then
      log INFO "Running shortcut: $SHORTCUT_NAME"
      "$SHORTCUTS_BIN" run "$SHORTCUT_NAME" -i "$TXT" >> "$WD_LOG_DIR/whisperdrop.log" 2>&1 || log ERROR "Shortcut failed for: $TXT"
    else
      log ERROR "Shortcut not found: $SHORTCUT_NAME"
    fi
  fi

  if [[ "${ARCHIVE_AUDIO:-false}" == "true" ]]; then
    mkdir -p "$ARCHIVE_DIR"
    mv -n "$INPUT" "$ARCHIVE_DIR/" && log INFO "Archived audio: $INPUT"
  fi

  if [[ -f "$SUMMARY" ]]; then
    notify "WhisperDrop" "Transcription + résumé terminés : $FILENAME"
  else
    notify "WhisperDrop" "Transcription terminée : $FILENAME"
  fi

done
