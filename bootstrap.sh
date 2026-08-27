#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${HERMESLAUNCH_REPO:-__GITHUB_REPO__}"
REF="${HERMESLAUNCH_REF:-main}"

if [[ "$REPO" == "__GITHUB_REPO__" ]]; then
  cat >&2 <<'EOF'
HermesLaunch belum dikonfigurasi dengan alamat repository GitHub.

Pemilik repo:
  jalankan scripts/set-repo.sh USERNAME/HermesLaunch sebelum publish.

User:
  gunakan:
  HERMESLAUNCH_REPO=OWNER/REPO bash bootstrap.sh
EOF
  exit 2
fi

URL="https://raw.githubusercontent.com/${REPO}/${REF}/install.sh"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

echo "HermesLaunch bootstrap"
echo "Source: $URL"
curl -fsSL "$URL" -o "$TMP"
chmod 700 "$TMP"
bash "$TMP"
