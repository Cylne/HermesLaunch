#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '\r\n' < "$ROOT/VERSION")"
NAME="HermesLaunch-v$VERSION"
DIST="$ROOT/dist"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

rm -rf "$DIST"
mkdir -p "$DIST" "$TMP/$NAME"

cp -a "$ROOT/." "$TMP/$NAME/"
rm -rf "$TMP/$NAME/.git" "$TMP/$NAME/dist"
find "$TMP/$NAME" \( -name '.env' -o -name '.env.*' \) -type f -delete

(
  cd "$TMP"
  zip -qr "$DIST/$NAME.zip" "$NAME"
  tar -czf "$DIST/$NAME.tar.gz" "$NAME"
)

(
  cd "$DIST"
  sha256sum "$NAME.zip" "$NAME.tar.gz" > CHECKSUMS.sha256
)

echo "Release built:"
ls -lh "$DIST"
cat "$DIST/CHECKSUMS.sha256"
