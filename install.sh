#!/bin/bash
# Installs Cortive, the private knowledge base for your Mac.
#
#   curl -fsSL https://raw.githubusercontent.com/KadenDevAi/cortive-releases/main/install.sh | bash
#
# What it does, so you can check before running it:
#   1. Downloads Cortive-<version>.zip from this repository's GitHub release.
#   2. Checks the download against the SHA-256 checksum written below; stops if it differs.
#   3. Puts Cortive.app in /Applications (or ~/Applications if /Applications isn't writable),
#      replacing an older Cortive.app there, and opens it.
# It needs no password and changes nothing else on your Mac.
set -euo pipefail

VERSION="0.2.0"
SHA256="84cf1c9a323c19751410a4443cc4d6783cd9a87d6735468eb17ac9cb427cdac4"
URL="https://github.com/KadenDevAi/cortive-releases/releases/download/v${VERSION}/Cortive-${VERSION}.zip"

say() { printf '\033[1m%s\033[0m\n' "$*"; }
fail() { printf '\033[31m%s\033[0m\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || fail "Cortive is for macOS."
[ "$(uname -m)" = "arm64" ] || fail "Cortive needs an Apple silicon Mac (M1 or later)."
MAJOR="$(sw_vers -productVersion | cut -d. -f1)"
[ "$MAJOR" -ge 14 ] || fail "Cortive needs macOS 14 Sonoma or later (this Mac has $(sw_vers -productVersion))."

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

say "Downloading Cortive $VERSION…"
curl -fL --progress-bar -o "$TMP/Cortive.zip" "$URL" || fail "Download failed. Check your connection and try again."

say "Checking the download…"
echo "$SHA256  $TMP/Cortive.zip" | shasum -a 256 -c --status || fail "The download doesn't match its checksum, so it wasn't installed. Try again; if it keeps happening, report it at https://github.com/KadenDevAi/cortive-releases/issues"

ditto -x -k "$TMP/Cortive.zip" "$TMP/unzipped"
[ -d "$TMP/unzipped/Cortive.app" ] || fail "The download didn't contain Cortive.app."

DEST="${CORTIVE_INSTALL_DIR:-/Applications}"
[ -w "$DEST" ] || { DEST="$HOME/Applications"; mkdir -p "$DEST"; }

if pgrep -f "Cortive.app/Contents/MacOS/" >/dev/null 2>&1; then
  say "Quitting the running Cortive…"
  osascript -e 'tell application "Cortive" to quit' >/dev/null 2>&1 || true
  sleep 2
fi

say "Installing to $DEST…"
rm -rf "$DEST/Cortive.app"
ditto "$TMP/unzipped/Cortive.app" "$DEST/Cortive.app"

say "Done. Opening Cortive."
[ -n "${CORTIVE_NO_OPEN:-}" ] || open "$DEST/Cortive.app"
cat <<'EOF'

First run: Cortive downloads its on-device search files (about 865 MB) and asks for
Screen Recording, which it needs for screenshot captures. Your library stays on this Mac.

Using Hermes Agent? Give it Cortive as its memory:
  hermes plugins install KadenDevAi/hermes-cortive
  hermes config set memory.provider cortive
EOF
