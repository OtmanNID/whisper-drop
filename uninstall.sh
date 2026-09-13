#!/bin/zsh

set -e

INSTALL_DIR="$HOME/.local/share/whisperdrop/app"
DATA_DIR="$HOME/.local/share/whisperdrop"
CONFIG_DIR="$HOME/.config/whisperdrop"
BIN_LINK="$HOME/.local/bin/whisperdrop"
PLIST="$HOME/Library/LaunchAgents/com.whisperdrop.watcher.plist"

print "WhisperDrop uninstaller"
print ""

launchctl bootout "gui/$(id -u)/com.whisperdrop.watcher" >/dev/null 2>&1 || true
rm -f "$PLIST" "$BIN_LINK"
rm -rf "$INSTALL_DIR"

print "Application files removed."
print ""
read "DELETE_DATA?Also delete models, config and state? (y/N): "
if [[ "${DELETE_DATA:l}" == "y" || "${DELETE_DATA:l}" == "yes" ]]; then
  rm -rf "$DATA_DIR" "$CONFIG_DIR"
  print "Models and config removed."
else
  print "Kept: $DATA_DIR and $CONFIG_DIR"
fi

print "Your watched audio folder was not deleted."
