#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Bash can parse the POSIX-compatible portions of installer scripts.
bash -n "$ROOT/install.sh"
bash -n "$ROOT/uninstall.sh"

# Ensure executable scripts have shebangs and no CRLF line endings.
for f in "$ROOT"/bin/* "$ROOT"/lib/*.sh "$ROOT"/scripts/*.sh; do
  head -n 1 "$f" | grep -q '^#!'
  if grep -q $'\r' "$f"; then
    echo "CRLF detected: $f" >&2
    exit 1
  fi
done

# Validate plist XML with Python stdlib (portable in CI/container environments).
python3 - <<PY
import xml.etree.ElementTree as ET
ET.parse(r"$ROOT/launchd/com.whisperdrop.watcher.plist.template")
PY

echo "Smoke tests passed."
