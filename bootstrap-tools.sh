#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${HERMESLAUNCH_REPO:-Cylne/HermesLaunch}"
REF="${HERMESLAUNCH_REF:-main}"
BASE="https://raw.githubusercontent.com/${REPO}/${REF}"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

curl -fsSL "$BASE/toolbox/install-ai-stack.sh" -o "$TMP"
chmod 700 "$TMP"
HERMESLAUNCH_REPO="$REPO" HERMESLAUNCH_REF="$REF" bash "$TMP"
