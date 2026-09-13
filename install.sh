#!/bin/zsh

set -e

ROOT_DIR="${0:A:h}"
INSTALL_DIR="$HOME/.local/share/whisperdrop/app"
CONFIG_DIR="$HOME/.config/whisperdrop"
DATA_DIR="$HOME/.local/share/whisperdrop"
MODEL_DIR="$DATA_DIR/models"
LOG_DIR="$HOME/Library/Logs/WhisperDrop"
BIN_DIR="$HOME/.local/bin"
PLIST="$HOME/Library/LaunchAgents/com.whisperdrop.watcher.plist"
DEFAULT_WATCH="$HOME/Documents/WhatsApp Audios"
MODEL_NAME="ggml-large-v3-turbo.bin"
MODEL_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main/$MODEL_NAME"

print ""
print "🎙️  WhisperDrop installer"
print "========================"
print ""

if [[ "$(uname -s)" != "Darwin" ]]; then
  print -u2 "WhisperDrop currently supports macOS only."
  exit 1
fi

setup_brew_path() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

setup_brew_path

if ! command -v brew >/dev/null 2>&1; then
  print "Homebrew is not installed on this Mac."
  print ""
  print "WhisperDrop uses Homebrew to install:"
  print "  • FFmpeg"
  print "  • whisper.cpp"
  print ""
  read "INSTALL_BREW?Install Homebrew now? (Y/n): "
  INSTALL_BREW="${INSTALL_BREW:-Y}"

  case "${INSTALL_BREW:l}" in
    y|yes|o|oui)
      print ""
      print "→ Installing Homebrew using the official installer..."
      print "  macOS may ask for your administrator password."
      print ""
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

      setup_brew_path

      if ! command -v brew >/dev/null 2>&1; then
        print -u2 ""
        print -u2 "Homebrew appears to be installed, but WhisperDrop could not find it in PATH."
        print -u2 "Close and reopen Terminal, then rerun ./install.sh."
        exit 1
      fi

      print ""
      print "✓ Homebrew installed"
      ;;
    *)
      print ""
      print "Installation cancelled. Homebrew is required to continue."
      print "You can install it later from https://brew.sh and rerun ./install.sh."
      exit 1
      ;;
  esac
else
  print "✓ Homebrew detected: $(brew --prefix)"
fi

print "→ Installing dependencies (ffmpeg, whisper-cpp)..."
brew list ffmpeg >/dev/null 2>&1 || brew install ffmpeg
brew list whisper-cpp >/dev/null 2>&1 || brew install whisper-cpp
print "✓ Dependencies ready"

print ""
read "WATCH_DIR?Folder to watch [$DEFAULT_WATCH]: "
WATCH_DIR="${WATCH_DIR:-$DEFAULT_WATCH}"
WATCH_DIR="${WATCH_DIR/#\~/$HOME}"
mkdir -p "$WATCH_DIR" "$INSTALL_DIR" "$CONFIG_DIR" "$MODEL_DIR" "$LOG_DIR" "$BIN_DIR"

print ""
read "LANGUAGE?Main language (fr/en/ar/auto) [fr]: "
LANGUAGE="${LANGUAGE:-fr}"

print ""
print "AI summary mode:"
print "  1) none (local transcription only)"
print "  2) macOS Shortcut / ChatGPT"
read "SUMMARY_CHOICE?Choice [1]: "
SUMMARY_CHOICE="${SUMMARY_CHOICE:-1}"
SUMMARY_PROVIDER="none"
SHORTCUT_NAME="Résumer vocal avec ChatGPT"
if [[ "$SUMMARY_CHOICE" == "2" ]]; then
  SUMMARY_PROVIDER="shortcuts"
  read "CUSTOM_SHORTCUT?Shortcut name [$SHORTCUT_NAME]: "
  SHORTCUT_NAME="${CUSTOM_SHORTCUT:-$SHORTCUT_NAME}"
fi

print ""
read "ARCHIVE_CHOICE?Move processed audio files to a Traités folder? (y/N): "
ARCHIVE_AUDIO="false"
[[ "${ARCHIVE_CHOICE:l}" == "y" || "${ARCHIVE_CHOICE:l}" == "yes" || "${ARCHIVE_CHOICE:l}" == "o" || "${ARCHIVE_CHOICE:l}" == "oui" ]] && ARCHIVE_AUDIO="true"

print "→ Installing WhisperDrop files..."
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cp -R "$ROOT_DIR/bin" "$ROOT_DIR/lib" "$ROOT_DIR/scripts" "$ROOT_DIR/launchd" "$INSTALL_DIR/"

cat > "$CONFIG_DIR/config" <<CFG
WATCH_DIR="$WATCH_DIR"
MODEL_NAME="$MODEL_NAME"
MODEL_PATH="$MODEL_DIR/$MODEL_NAME"
LANGUAGE="$LANGUAGE"
CREATE_TRANSCRIPT="true"
SUMMARY_PROVIDER="$SUMMARY_PROVIDER"
SHORTCUT_NAME="$SHORTCUT_NAME"
ARCHIVE_AUDIO="$ARCHIVE_AUDIO"
ARCHIVE_DIR="$WATCH_DIR/Traités"
NOTIFICATIONS="true"
SUPPORTED_EXTENSIONS="opus mp3 m4a wav mp4 mov aac ogg flac webm"
SETTLE_SECONDS="2"
THREADS="auto"
CFG

if [[ ! -f "$MODEL_DIR/$MODEL_NAME" ]]; then
  print "→ Downloading Whisper model (~1.6 GB)..."
  curl -L --fail --progress-bar -o "$MODEL_DIR/$MODEL_NAME.part" "$MODEL_URL"
  mv "$MODEL_DIR/$MODEL_NAME.part" "$MODEL_DIR/$MODEL_NAME"
else
  print "✓ Whisper model already present"
fi

ln -sf "$INSTALL_DIR/bin/whisperdrop" "$BIN_DIR/whisperdrop"

PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
if [[ -f "$HOME/.zshrc" ]]; then
  grep -Fq "$PATH_LINE" "$HOME/.zshrc" || print "\n# WhisperDrop\n$PATH_LINE" >> "$HOME/.zshrc"
else
  print "# WhisperDrop\n$PATH_LINE" > "$HOME/.zshrc"
fi

TEMPLATE="$INSTALL_DIR/launchd/com.whisperdrop.watcher.plist.template"
ESC_INSTALL="${INSTALL_DIR//&/&amp;}"
ESC_WATCH="${WATCH_DIR//&/&amp;}"
ESC_LOG="${LOG_DIR//&/&amp;}"
sed -e "s|__INSTALL_DIR__|$ESC_INSTALL|g" -e "s|__WATCH_DIR__|$ESC_WATCH|g" -e "s|__LOG_DIR__|$ESC_LOG|g" "$TEMPLATE" > "$PLIST"

launchctl bootout "gui/$(id -u)/com.whisperdrop.watcher" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl enable "gui/$(id -u)/com.whisperdrop.watcher" >/dev/null 2>&1 || true
launchctl kickstart -k "gui/$(id -u)/com.whisperdrop.watcher" >/dev/null 2>&1 || true

print ""
print "✅ WhisperDrop installed"
print ""
print "Watched folder: $WATCH_DIR"
print "Config:         $CONFIG_DIR/config"
print "Logs:           $LOG_DIR/whisperdrop.log"
print ""
print "Open a new Terminal, then try:"
print "  whisperdrop status"
print "  whisperdrop doctor"
print ""
if [[ "$SUMMARY_PROVIDER" == "shortcuts" ]]; then
  print "⚠️  ChatGPT summary is enabled. Make sure the macOS Shortcut exists:"
  print "   $SHORTCUT_NAME"
  print "   See docs/CHATGPT.md"
fi
