#!/bin/zsh

set -u

WD_HOME="${WHISPERDROP_HOME:-$HOME/.local/share/whisperdrop}"
WD_CONFIG_DIR="${WHISPERDROP_CONFIG_DIR:-$HOME/.config/whisperdrop}"
WD_CONFIG="$WD_CONFIG_DIR/config"
WD_LOG_DIR="${WHISPERDROP_LOG_DIR:-$HOME/Library/Logs/WhisperDrop}"
WD_STATE_DIR="$WD_HOME/state"

mkdir -p "$WD_LOG_DIR" "$WD_STATE_DIR"

log() {
  local level="$1"; shift
  printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*" >> "$WD_LOG_DIR/whisperdrop.log"
}

notify() {
  local title="$1"
  local message="$2"
  if [[ "${NOTIFICATIONS:-true}" == "true" ]]; then
    /usr/bin/osascript -e "display notification \"${message//\"/\\\"}\" with title \"${title//\"/\\\"}\"" >/dev/null 2>&1 || true
  fi
}

load_config() {
  if [[ ! -f "$WD_CONFIG" ]]; then
    print -u2 "WhisperDrop config missing: $WD_CONFIG"
    return 1
  fi
  source "$WD_CONFIG"
}

command_path() {
  local name="$1"
  local found=""

  found="$(command -v "$name" 2>/dev/null || true)"
  if [[ -n "$found" ]]; then
    print -r -- "$found"
    return 0
  fi

  if [[ -x "/opt/homebrew/bin/$name" ]]; then
    print -r -- "/opt/homebrew/bin/$name"
    return 0
  fi

  if [[ -x "/usr/local/bin/$name" ]]; then
    print -r -- "/usr/local/bin/$name"
    return 0
  fi

  return 1
}

is_supported_extension() {
  local ext="${1:l}"
  local item
  for item in ${(z)SUPPORTED_EXTENSIONS}; do
    [[ "$ext" == "$item" ]] && return 0
  done
  return 1
}

safe_stem() {
  local filename="$1"
  print -r -- "${filename:r}"
}
