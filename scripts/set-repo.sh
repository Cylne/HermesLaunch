#!/usr/bin/env bash
set -Eeuo pipefail
[[ $# -eq 1 ]] || { echo "Usage: $0 OWNER/REPO"; exit 2; }
NEW="$1"
[[ "$NEW" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || { echo "Invalid OWNER/REPO"; exit 2; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OLD="Cylne/HermesLaunch"

grep -RIl --exclude-dir=.git --exclude-dir=dist "$OLD" "$ROOT" | while read -r f; do
  sed -i "s|$OLD|$NEW|g" "$f"
  echo "updated: ${f#"$ROOT"/}"
done
