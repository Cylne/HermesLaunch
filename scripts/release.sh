#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(cat "$ROOT/VERSION")"
NAME="HermesLaunch-v$VERSION"
DIST="$ROOT/dist"

rm -rf "$DIST"
mkdir -p "$DIST"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/$NAME"
rsync -a \
  --exclude '.git' \
  --exclude 'dist' \
  --exclude '.env' \
  --exclude '*.log' \
  "$ROOT/" "$tmp/$NAME/"

(
  cd "$tmp"
  zip -qr "$DIST/$NAME.zip" "$NAME"
  tar -czf "$DIST/$NAME.tar.gz" "$NAME"
)

(
  cd "$DIST"
  sha256sum "$NAME.zip" "$NAME.tar.gz" > CHECKSUMS.sha256
)

echo "Release built:"
ls -lh "$DIST"
echo
cat "$DIST/CHECKSUMS.sha256"
