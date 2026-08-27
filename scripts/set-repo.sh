#!/usr/bin/env bash
set -Eeuo pipefail
[[ $# -eq 1 ]] || { echo "Usage: $0 OWNER/REPO"; exit 2; }
repo="$1"
[[ "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || { echo "Format harus OWNER/REPO"; exit 2; }

root="$(cd "$(dirname "$0")/.." && pwd)"
grep -RIl --exclude-dir=.git "__GITHUB_REPO__" "$root" | while read -r f; do
  sed -i "s|__GITHUB_REPO__|$repo|g" "$f"
  echo "updated: ${f#$root/}"
done

echo
echo "Repository set to: $repo"
