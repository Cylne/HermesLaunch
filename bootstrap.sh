#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${HERMESLAUNCH_REPO:-Cylne/HermesLaunch}"
REF="${HERMESLAUNCH_REF:-main}"
BASE="https://raw.githubusercontent.com/${REPO}/${REF}"

is_termux() {
  [[ -n "${TERMUX_VERSION:-}" ]] || [[ "${PREFIX:-}" == *"com.termux"* ]] || [[ "$(uname -o 2>/dev/null || true)" == "Android" ]]
}

TMPDIR_HL="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_HL"' EXIT

if is_termux; then
  TARGET="install-termux.sh"
  echo "HermesLaunch: Android / Termux Mobile Mode"
else
  TARGET="install-vps.sh"
  echo "HermesLaunch: Linux VPS Mode"
fi

echo "Repository: https://github.com/${REPO}.git"
curl -fsSL "${BASE}/${TARGET}" -o "${TMPDIR_HL}/${TARGET}"
chmod 700 "${TMPDIR_HL}/${TARGET}"
bash "${TMPDIR_HL}/${TARGET}"
